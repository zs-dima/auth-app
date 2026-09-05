# Upstream issue draft — `control` (StateController)

Not filed yet. Written out here because the app works around it; see `ControllerObserver.onError`
and `docs/decisions.md`.

---

**Title:** A zone error inside `handle()` skips the handler's own `error:` callback

**Affected:** `control` 1.0.0-dev.1, `lib/src/controller.dart`.

### What happens

`handle()` runs the body inside `runZonedGuarded` and passes two different error paths:

```dart
Future<void> onError(Object e, StackTrace st) async {
  if (isDisposed) return;
  try {
    this.onError(e, st);                       // the observer
    if (isDone || isDisposed || completer.isCompleted) return;
    await error?.call(e, st);                  // the handler's own callback
  } on Object catch (error, stackTrace) {
    this.onError(error, stackTrace);
  }
}

Future<void> handleZoneError(Object error, StackTrace stackTrace) async {
  if (isDisposed) return;
  this.onError(error, stackTrace);             // the observer, and nothing else
  assert(false, 'A zone error occurred during controller event handling. …');
}
```

An error thrown by the body reaches `onError` and therefore `error?.call`. An error from an
unawaited future created inside the body reaches `handleZoneError`, which notifies the observer and
asserts — so in a release build the handler's `error:` callback never runs.

### Why it matters

For a consumer whose reporting policy lives in `error:` (classify the failure, tell the user, decide
whether it becomes a crash-report issue), the second path is invisible: the incident is reported by
nobody. The `assert` makes it loud in debug and silent in release, which is the wrong way round for
a failure whose whole cause is that a future was not awaited.

Concretely, in our app every handler has an `error:` that classifies and reports; a zone error
leaves a single observer breadcrumb and no report at all.

### Suggested fix

Route `handleZoneError` through the same `onError` used by the synchronous path, so the handler's
callback runs in both cases. Keep the `assert` — an unawaited future in a handler is still a bug —
but do not let it be the only consequence:

```dart
Future<void> handleZoneError(Object error, StackTrace stackTrace) async {
  if (isDisposed) return;
  await onError(error, stackTrace);  // observer + the handler's error: callback
  assert(false, 'A zone error occurred during controller event handling. …');
}
```

If calling `error:` after the handler has completed is a contract change you would rather not make,
an alternative is a distinct hook (`onZoneError`) so a consumer can opt in, or a flag on
`StateController`. What does not work today is telling the two apart from outside: the only
signal a consumer has is that `HandlerContext.isDone` is already `true` when the observer fires,
which is what we key on as a workaround.
