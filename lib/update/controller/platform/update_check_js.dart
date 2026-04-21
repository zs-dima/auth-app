// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:js_interop';

import 'package:auth_app/update/controller/update_check_api.dart';
import 'package:web/web.dart' as web;

/// Max time we will wait for [window.Bootstrap.applyUpdate] to resolve.
/// `applyUpdate` internally awaits `controllerchange`, which can hang if the
/// new Service Worker fails to activate. A timeout + hard reload guarantees
/// the user never stalls on the update banner.
const Duration _applyUpdateTimeout = Duration(seconds: 10);

/// Cadence for the active `registration.update()` probe. Forces the browser
/// to issue a conditional GET on `sw.js`; if its bytes are unchanged the
/// browser does no further work, otherwise the install/activate state
/// machine fires and `wireUpdateDetection` (in sw 0.1.x) dispatches
/// `sw-update-available`. 15 minutes mirrors Workbox / Vite-PWA defaults
/// and gives idle tabs a guaranteed deploy-detection window.
const Duration _registrationUpdateInterval = Duration(minutes: 15);

/// Minimum spacing between two [_runRegistrationUpdate] calls triggered by
/// `visibilitychange`. Without this, rapid focus toggling (Alt+Tab spam)
/// could spawn dozens of concurrent `update()` calls — they're cheap, but
/// not free, and the SW registration only changes on a deploy boundary.
const Duration _visibilityDebounce = Duration(seconds: 30);

/// JS interop binding for `window.Bootstrap`, installed by sw 0.1.x's
/// `bootstrap.js` (see `packages/sw/src/bootstrap/api.ts → installGlobalAPI`).
///
/// On dev builds that still use Flutter's default `flutter_bootstrap.js`
/// there is no `window.Bootstrap` object; the external getter returns null
/// and [UpdateCheckApiImpl] degrades gracefully.
extension type const _BootstrapApi._(JSObject _) implements JSObject {
  /// Subscribe to the "a newer SW has installed and is waiting" event.
  /// Fires at most once per pipeline (pipeline.ts registers the DOM event
  /// with `{ once: true }`). Returns an unsubscribe function, which we
  /// deliberately discard — the app keeps the subscription for its
  /// lifetime, and the JS object is garbage-collected when the page
  /// unloads anyway.
  external JSFunction onUpdateAvailable(JSFunction handler);

  /// Apply a waiting SW update: posts `skipWaiting` to the waiting worker,
  /// awaits `controllerchange`, then reloads the page when `reload` is
  /// true. Resolves to `false` when no waiting worker exists or Service
  /// Workers are unsupported.
  external JSPromise<JSBoolean> applyUpdate(JSBoolean reload);
}

@JS('Bootstrap')
external _BootstrapApi? get _bootstrap;

final class UpdateCheckApiImpl implements UpdateCheckApi {
  UpdateCheckApiImpl() {
    _subscribeToBootstrapUpdate();
    _startRegistrationUpdateTimer();
    _startVisibilityListener();
  }

  /// Flipped to `true` by [window.Bootstrap.onUpdateAvailable] (or by the
  /// native-registration probe) once a newer Service Worker is waiting.
  /// Drives [hasPendingUpdate].
  bool _updatePending = false;

  /// Broadcast so the controller can subscribe (and re-subscribe) without
  /// forcing the API to know how many listeners it has.
  final StreamController<void> _updateController = StreamController<void>.broadcast();

  /// 15-min `registration.update()` poll. Started in the constructor on
  /// web only and cancelled in [dispose].
  Timer? _registrationUpdateTimer;

  /// Held reference to the JS-interop'd visibilitychange handler so we can
  /// pass the *same* JSFunction back to `removeEventListener` in [dispose].
  JSFunction? _visibilityListener;

  /// Tracks the last `_runRegistrationUpdate` call so the visibilitychange
  /// debounce can suppress re-entrant focus events.
  DateTime _lastUpdateCallAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Set to true after [dispose] so any in-flight async callbacks
  /// (probe, timer tick, visibility event) become no-ops.
  bool _disposed = false;

  @override
  bool get hasPendingUpdate => _updatePending;

  @override
  Stream<void> get onUpdateAvailable => _updateController.stream;

  @override
  Future<void> updateApplication() async {
    final bootstrap = _bootstrap;
    if (bootstrap == null) {
      // Dev build without sw's bootstrap.js — fall back to a plain reload
      // so the browser re-fetches flutter_bootstrap.js.
      web.window.location.reload();
      return;
    }
    try {
      await bootstrap.applyUpdate(true.toJS).toDart.timeout(_applyUpdateTimeout);
    } on Object {
      // applyUpdate hung (no controllerchange) or threw at the interop
      // boundary — force a reload so the user is never stranded on the
      // update banner.
      web.window.location.reload();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _registrationUpdateTimer?.cancel();
    _registrationUpdateTimer = null;
    final listener = _visibilityListener;
    if (listener != null) {
      web.document.removeEventListener('visibilitychange', listener);
      _visibilityListener = null;
    }
    unawaited(_updateController.close());
  }

  void _subscribeToBootstrapUpdate() {
    final bootstrap = _bootstrap;
    if (bootstrap == null) return;
    try {
      bootstrap.onUpdateAvailable(_markUpdatePending.toJS);
    } on Object {
      // Interop call failed; nothing useful to recover here.
      return;
    }
    // Race mitigation: sw dispatches `sw-update-available` during stage 2
    // (SW registration) with `{ once: true }`. Dart main runs later in
    // stages 4-5, so any event dispatched before this subscription is
    // lost. Ask the native ServiceWorkerRegistration whether a waiting
    // worker already exists and mark _updatePending accordingly.
    unawaited(_probeWaitingRegistration());
  }

  Future<void> _probeWaitingRegistration() async {
    if (_disposed) return;
    final serviceWorker = web.window.navigator.serviceWorker;
    try {
      final registration = await serviceWorker.getRegistration().toDart;
      if (registration != null && registration.waiting != null && serviceWorker.controller != null) {
        _markUpdatePending();
      }
    } on Object {
      // Best-effort probe; ignore failures.
    }
  }

  /// Flip the pending flag (idempotent) and tickle the broadcast stream so
  /// the controller can re-evaluate without waiting for its periodic poll.
  void _markUpdatePending() {
    if (_disposed) return;
    _updatePending = true;
    if (!_updateController.isClosed) _updateController.add(null);
  }

  void _startRegistrationUpdateTimer() {
    _registrationUpdateTimer = Timer.periodic(
      _registrationUpdateInterval,
      (_) => unawaited(_runRegistrationUpdate()),
    );
  }

  void _startVisibilityListener() {
    void onVisibilityChange(web.Event _) {
      if (_disposed) return;
      if (web.document.visibilityState != 'visible') return;
      final now = DateTime.now();
      if (now.difference(_lastUpdateCallAt) < _visibilityDebounce) return;
      unawaited(_runRegistrationUpdate());
    }

    final listener = onVisibilityChange.toJS;
    _visibilityListener = listener;
    web.document.addEventListener('visibilitychange', listener);
  }

  /// Force the browser to refetch `sw.js`. If the bytes match the active
  /// SW the call is a no-op; otherwise the new SW installs and the
  /// existing `sw-update-available` chain takes over.
  Future<void> _runRegistrationUpdate() async {
    if (_disposed) return;
    _lastUpdateCallAt = DateTime.now();
    final serviceWorker = web.window.navigator.serviceWorker;
    try {
      final registration = await serviceWorker.getRegistration().toDart;
      if (registration == null) return;
      await registration.update().toDart;
    } on Object {
      // Offline, transient network failure, or ServiceWorker unsupported.
      // The next tick (or visibility event) will retry naturally.
    }
  }
}
