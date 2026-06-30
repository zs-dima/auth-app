import 'dart:io' show Platform;

import 'package:cronet_http/cronet_http.dart';
import 'package:cupertino_http/cupertino_http.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;

/// Returns the current window origin for the HTTP client.
/// On non-web platforms, this returns an empty string as there is no window origin.
String $getOrigin() => '';

/// Creates an HTTP client backed by the platform's native networking stack where
/// available, falling back to [io_client.IOClient] (dart:io) otherwise.
///
/// - Android: [CronetClient] over a [CronetEngine] with **HTTP/3 (QUIC), HTTP/2 and Brotli
///   enabled** — Cronet's default engine has QUIC and Brotli off, so we build one explicitly.
///   Without a hint QUIC is opportunistic (used only after the server advertises it via Alt-Svc
///   on an earlier response); [quicHints] — `(host, port, alternatePort)` — pre-seeds known
///   HTTP/3 hosts so the **first** request already attempts QUIC. Wrong/stale hints are harmless
///   (Cronet falls back to HTTP/2/1.1). `closeEngine: true` ties the engine's lifetime to the
///   client (closed on `close()`).
/// - iOS/macOS: [CupertinoClient] (NSURLSession) — negotiates HTTP/2, HTTP/3 and compression
///   automatically; [quicHints] does not apply.
/// - Windows/Linux (and any failure, e.g. Android without Play Services Cronet):
///   [io_client.IOClient]; [quicHints] does not apply.
///
/// All of these honor `package:http`'s request abortion (`AbortableRequest`), so
/// cancellation/timeout teardown works consistently across platforms.
///
/// Deliberately not configured: on-disk cache + QUIC 0-RTT (`CacheMode.disk`/`storagePath`) —
/// keeps this factory synchronous and is low-value for a mostly-uncacheable API; `userAgent` —
/// the app already sends `X-App-*` metadata headers; Cronet 1.9 typed exceptions / NetLog —
/// Android-only / debug-only.
///
/// TLS certificate pinning is intentionally **not** wired here: `cronet_http` 1.9.0 exposes
/// no pin config (only `enablePublicKeyPinningBypassForLocalTrustAnchors`) and `cupertino_http`
/// 3.0.2 exposes no auth-challenge/server-trust hook, so pinning is impossible on the primary
/// mobile clients via these adapters. It is only achievable on the `dart:io` [io_client.IOClient]
/// fallback (`SecurityContext`/SPKI) — which on mobile is *not* the active client — so wiring it
/// here would silently leave Cronet/NSURLSession unpinned (false security). If pinning becomes a
/// hard requirement it is a separate decision: force `IOClient` everywhere (losing HTTP/3 when on)
/// or adopt a maintained pinning package.
http.Client $createHttpClient({List<(String, int, int)>? quicHints}) {
  try {
    if (Platform.isAndroid) {
      return CronetClient.fromCronetEngine(
        CronetEngine.build(enableHttp2: true, enableQuic: true, enableBrotli: true, quicHints: quicHints),
        closeEngine: true,
      );
    }
    if (Platform.isIOS || Platform.isMacOS) return CupertinoClient.defaultSessionConfiguration();
  } on Object {
    // Native engine unavailable — fall back to the dart:io client below.
  }
  return io_client.IOClient();
}
