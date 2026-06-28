import 'dart:async';

import 'package:meta/meta.dart';

enum AuthenticationState {
  authenticating,
  authenticated,
  unauthenticated,
}

typedef AuthenticationCallback = void Function(AuthenticationState state);
typedef VoidCallback = void Function();

/// The single, transport-agnostic auth-state bus. BOTH transports report an auth failure into it
/// (gRPC via `GrpcAuthenticationMiddleware.onAuthError`, and any future authenticated HTTP path),
/// so there is one place that drives logout regardless of transport (A26). The repository is the
/// sole producer of [handleAuthenticated] and the sole consumer that turns an
/// [AuthenticationState.unauthenticated] event into an actual sign-out.
abstract interface class IAuthenticationHandler implements Stream<AuthenticationState> {
  void handleAuthenticationError();
  void handleAuthenticated();
  Future<void> close();
}

class AuthenticationHandler extends Stream<AuthenticationState> implements IAuthenticationHandler {
  // Eagerly created (not lazily on first listen) so an event can never be dropped by a missing
  // controller, and so the contract is simple and testable (A5/A26).
  final StreamController<AuthenticationState> _controller = StreamController<AuthenticationState>.broadcast();

  @override
  bool get isBroadcast => true;

  @override
  void handleAuthenticationError() {
    if (!_controller.isClosed) _controller.add(.unauthenticated);
  }

  @override
  void handleAuthenticated() {
    if (!_controller.isClosed) _controller.add(.authenticated);
  }

  @override
  StreamSubscription<AuthenticationState> listen(
    AuthenticationCallback? onData, {
    Function? onError,
    VoidCallback? onDone,
    bool? cancelOnError,
  }) => _controller.stream.distinct().listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  @mustCallSuper
  Future<void> close() => _controller.close();
}
