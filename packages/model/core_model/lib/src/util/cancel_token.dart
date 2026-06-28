import 'dart:async';

import 'package:meta/meta.dart';

/// A token used to cancel one or more in-flight operations.
///
/// Pass the same token to several operations to cancel them together (e.g. when leaving a screen).
/// Backed by a [Completer]: completing it (via [cancel]) signals cancellation to anything awaiting
/// [whenCancel]. Transport-agnostic — e.g. the HTTP client wires [whenCancel] into the request's
/// abort trigger, and the auth session uses it to abort all in-flight work on logout.
class CancelToken {
  final Completer<void> _completer = Completer<void>();

  /// Child tokens that cancel together with this one (e.g. per-request tokens
  /// linked to a session token). Created lazily; only holds *active* children —
  /// each detaches on completion (see [link]) so it never grows with total requests.
  Set<CancelToken>? _children;

  /// Whether [cancel] has already been called.
  bool get isCancelled => _completer.isCompleted;

  /// Future that completes when the token is cancelled.
  Future<void> get whenCancel => _completer.future;

  /// Number of currently-linked child tokens (for tests/diagnostics).
  @visibleForTesting
  int get debugLinkedCount => _children?.length ?? 0;

  Object? _reason;

  /// The reason passed to [cancel], if any.
  Object? get reason => _reason;

  /// Cancels this token (and any linked children, transitively). Idempotent.
  void cancel([Object? reason]) {
    if (_completer.isCompleted) return;
    // Iterative traversal (no recursion) over this token and its linked children.
    final pending = <CancelToken>[this];
    while (pending.isNotEmpty) {
      final token = pending.removeLast();
      if (token._completer.isCompleted) continue;
      token._reason = reason;
      token._completer.complete();
      final children = token._children;
      token._children = null;
      if (children != null) pending.addAll(children);
    }
  }

  /// Links [child] so it cancels together with this token; returns an unlink callback.
  void Function() link(CancelToken child) {
    if (isCancelled) {
      child.cancel(_reason);
      return () {};
    }
    (_children ??= <CancelToken>{}).add(child);
    return () => _children?.remove(child);
  }
}
