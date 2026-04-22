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

/// `sessionStorage` key: breadcrumb set before an `applyUpdate`-triggered
/// reload and consumed on the next page load. Used to detect racing SW
/// installs that finish between the reload starting and the new page's
/// Dart code running, so the racing update is applied silently instead
/// of re-prompting the user who already accepted the first one.
const String _applyChainKey = 'sw-update-apply-chain';

/// Lifetime of the in-memory auto-chain window. The user's click triggers
/// a reload; any racing install that completes within this window after
/// the new page loads is treated as fallout from that click and applied
/// silently. After the window closes, a genuine new update arriving
/// later in the session is prompted through the normal banner path.
///
/// Sized to a few-x the SW registration timeout (`SW_REGISTRATION_TIMEOUT_MS`
/// in sw 0.1.x, 4s) so even a slow install state transition lands in time,
/// while keeping the silent-reload tolerance short enough that users never
/// lose track of why the page refreshed.
const Duration _autoChainWindow = Duration(seconds: 10);

/// JS interop binding for `window.Bootstrap`, installed by sw 0.1.x's
/// `bootstrap.js` (see `packages/sw/src/bootstrap/api.ts → installGlobalAPI`).
///
/// On dev builds that still use Flutter's default `flutter_bootstrap.js`
/// there is no `window.Bootstrap` object; the external getter returns null
/// and [UpdateCheckApiImpl] degrades gracefully.
extension type const _BootstrapApi._(JSObject _) implements JSObject {
  /// Subscribe to the "a newer SW has installed and is waiting" event.
  /// Fires once per SW install; a long-lived tab encountering multiple
  /// deploys will receive multiple events (see sw 0.1.3 CHANGELOG, which
  /// removed the previous `{ once: true }` DOM-bridge constraint).
  /// Returns an unsubscribe function, which we deliberately discard: the
  /// app keeps the subscription for its lifetime and the JS object is
  /// garbage-collected when the page unloads anyway.
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
    if (_consumeApplyChainFlag()) {
      _autoChainNextPending = true;
      // Cap the window of "any racing install is fallout from the user's
      // click" so that a genuine update arriving 15+ minutes later in
      // the same session still surfaces through the normal banner path.
      _autoChainExpiry = Timer(_autoChainWindow, () {
        _autoChainNextPending = false;
        _autoChainExpiry = null;
      });
    }
    _subscribeToBootstrapUpdate();
    _startRegistrationUpdateTimer();
    _startVisibilityListener();
  }

  /// Flipped to `true` by [window.Bootstrap.onUpdateAvailable] (or by the
  /// native-registration probe) once a newer Service Worker is waiting.
  /// Drives [hasPendingUpdate].
  bool _updatePending = false;

  /// True only on the page load that immediately follows a user-approved
  /// [updateApplication]. Consumed on the first pending-update signal
  /// after bootstrap: the user already accepted the reload, so any racing
  /// install that finished during the handoff (common in fast deploy
  /// cycles where `sw.js` bytes change between the reload starting and
  /// the new page registering) is applied transparently instead of
  /// re-prompting with a second banner.
  bool _autoChainNextPending = false;

  /// Expires [_autoChainNextPending] after [_autoChainWindow]. Armed in
  /// the constructor iff the sessionStorage breadcrumb was consumed, and
  /// cancelled either when the flag is consumed early (by a racing
  /// install arriving within the window) or in [dispose].
  Timer? _autoChainExpiry;

  /// Broadcast so the controller can subscribe (and re-subscribe) without
  /// forcing the API to know how many listeners it has.
  final StreamController<void> _updateController = StreamController<void>.broadcast();

  /// 15-min `registration.update()` poll. Started in the constructor on
  /// web only and cancelled in [dispose].
  Timer? _registrationUpdateTimer;

  /// Held reference to the JS-interop'd `visibilitychange` handler so we can
  /// pass the *same* JSFunction back to `removeEventListener` in [dispose].
  JSFunction? _visibilityListener;

  /// Tracks the last `_runRegistrationUpdate` call so the `visibilitychange`
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
    // Breadcrumb for the next page load: if a racing install finishes
    // during the reload, the new constructor will consume this flag and
    // auto-apply the racing update instead of re-prompting the user.
    _writeApplyChainFlag();
    await _doApplyUpdate(clearFlagOnFailure: true);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _autoChainExpiry?.cancel();
    _autoChainExpiry = null;
    _registrationUpdateTimer?.cancel();
    _registrationUpdateTimer = null;
    final listener = _visibilityListener;
    if (listener != null) {
      web.document.removeEventListener('visibilitychange', listener);
      _visibilityListener = null;
    }
    unawaited(_updateController.close());
  }

  /// Shared Service-Worker-activation-and-reload path used by both the
  /// user-initiated [updateApplication] and the silent auto-chain branch
  /// in [_markUpdatePending].
  ///
  /// [clearFlagOnFailure]:
  /// - `true` for user-initiated clicks: if `Bootstrap.applyUpdate` fails
  ///   (hang, exception, timeout), remove the sessionStorage breadcrumb
  ///   so a persistently broken SW cannot loop the app through repeated
  ///   failing reloads.
  /// - `false` for the auto-chain: no breadcrumb was written at this
  ///   layer, so the chain naturally caps at exactly one silent iteration
  ///   per user-initiated click.
  Future<void> _doApplyUpdate({required bool clearFlagOnFailure}) async {
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
      // applyUpdate hung (no `controllerchange`) or threw at the interop
      // boundary — force a reload so the user is never stranded on the
      // update banner.
      if (clearFlagOnFailure) _clearApplyChainFlag();
      web.window.location.reload();
    }
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
    // Race mitigation: sw-registration dispatches `sw-update-available`
    // during stage 2 (SW registration). Dart main runs later in stages
    // 4-5, so any event dispatched before this subscription lands is
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

  /// Persist the auto-chain breadcrumb to [web.Storage] (`sessionStorage`).
  /// Silently no-ops when storage is unavailable (strict privacy modes),
  /// degrading the fix to the pre-existing double-click UX rather than
  /// throwing.
  void _writeApplyChainFlag() {
    try {
      web.window.sessionStorage.setItem(_applyChainKey, '1');
    } on Object {
      // sessionStorage may be blocked; continue — worst case is that the
      // user will see the racing-install banner and click Update Now twice.
    }
  }

  /// Remove the auto-chain breadcrumb. Called when [Bootstrap.applyUpdate]
  /// fails so a broken SW does not retrigger the silent chain on the next
  /// reload (which would loop the app through repeated failing attempts).
  void _clearApplyChainFlag() {
    try {
      web.window.sessionStorage.removeItem(_applyChainKey);
    } on Object {
      // sessionStorage may be blocked; ignore — the failed apply will
      // surface as a banner on the next page load, which is acceptable.
    }
  }

  /// Read and clear the auto-chain breadcrumb in a single call. Returns
  /// `true` iff this page load is the one immediately following a
  /// user-approved [updateApplication].
  bool _consumeApplyChainFlag() {
    try {
      final value = web.window.sessionStorage.getItem(_applyChainKey);
      if (value == null) return false;
      web.window.sessionStorage.removeItem(_applyChainKey);
      return true;
    } on Object {
      return false;
    }
  }

  /// Flip the pending flag (idempotent) and tickle the broadcast stream so
  /// the controller can re-evaluate without waiting for its periodic poll.
  ///
  /// Short-circuits into a silent apply-and-reload when
  /// [_autoChainNextPending] is set — that flag is only true on the page
  /// load immediately following a user-approved update and within the
  /// [_autoChainWindow], where any fresh pending update is racing-install
  /// fallout rather than a new decision point for the user.
  ///
  /// The silent branch calls [_doApplyUpdate] directly without writing a
  /// new sessionStorage breadcrumb, so the chain caps at exactly one
  /// silent iteration per click. If another install races this reload
  /// the user will see the banner normally.
  void _markUpdatePending() {
    if (_disposed) return;
    if (_autoChainNextPending) {
      _autoChainNextPending = false;
      _autoChainExpiry?.cancel();
      _autoChainExpiry = null;
      unawaited(_doApplyUpdate(clearFlagOnFailure: false));
      return;
    }
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
