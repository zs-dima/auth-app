import 'dart:async';

import 'package:meta/meta.dart';

enum AuthenticationState {
  authenticating,
  authenticated,
  unauthenticated,
}

abstract interface class IAuthenticationHandler implements Stream<AuthenticationState> {
  void handleAuthenticationError();
  void handleAuthenticated();
}

class AuthenticationHandler extends Stream<AuthenticationState> implements IAuthenticationHandler {
  StreamController<AuthenticationState>? _controller;

  @override
  bool get isBroadcast => true;

  @override
  void handleAuthenticationError() {
    if (_controller?.isClosed == false) _controller?.add(AuthenticationState.unauthenticated);
  }

  @override
  void handleAuthenticated() {
    if (_controller?.isClosed == false) _controller?.add(AuthenticationState.authenticated);
  }

  @override
  StreamSubscription<AuthenticationState> listen(
    void Function(AuthenticationState state)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _controller ??= StreamController<AuthenticationState>.broadcast();

    return _controller!.stream.distinct().listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  @mustCallSuper
  Future<void>? close() => _controller?.close();
}
