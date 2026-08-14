/// A QUIC hint: pre-seeds a known HTTP/3 host so the **first** request already attempts QUIC
/// (without a hint QUIC is opportunistic — used only after the server advertises it via Alt-Svc
/// on an earlier response).
///
/// The tuple shape `CronetEngine.build(quicHints:)` consumes; a wrong or stale hint is harmless
/// (Cronet falls back to HTTP/2/1.1). Ignored on iOS/macOS/web, where the platform stack picks
/// the protocol itself.
typedef QuicHint = (String host, int port, int alternativePort);
