# Upstream issue draft — connectrpc/connect-dart

Not filed yet. Written out here so the finding survives the un-vendoring (see
`docs/decisions.md`, 2026-09-05); paste it as-is when someone files it.

---

**Title:** HTTP/2 transport ignores consumer back-pressure on server streams (unbounded buffering)

**Affected:** `connectrpc` 1.0.0 and 2.0.0, `lib/src/http2/http2.dart` (native/VM transport). The
web fetch transport is not affected in the same way — the browser owns that flow.

### What happens

`Stream<http2.StreamMessage>.toBytes` creates a `StreamController` and hands it to `addAll`, which
pumps frames into it as fast as they arrive:

```dart
Stream<Uint8List> toBytes(
  Sentinel sentinel,
  void Function(List<http2.Header>) onHeaders,
  void Function(List<http2.Header>) onTrailers,
) {
  final ctrl = StreamController<Uint8List>();
  addAll(sentinel, onHeaders, onTrailers, ctrl.sink);
  return ctrl.stream;
}

// in addAll:
while (await sentinel.race(it.moveNext())) {
  // …
  sink.add(Uint8List.fromList(frame.bytes));
}
```

The loop never consults the consumer. Pausing the subscription returned to the caller pauses the
`StreamController`'s output, but `moveNext()` keeps pulling from the HTTP/2 stream, so:

- messages accumulate in the controller's internal buffer without bound, and
- `package:http2` keeps dispatching frames to its listener, which is what makes it emit
  `WINDOW_UPDATE` — so the server is never told to slow down.

Pausing the subscription is the only channel through which flow control can reach the server, and
nothing in this path pauses it.

### Why it matters

A consumer slower than the producer (writing each message to disk, rendering it, awaiting anything)
grows the process's memory for the length of the stream. A large server-streaming response can
exhaust it. An interceptor that forwards a pause — which is the natural thing for an interceptor to
do — has no effect, which makes the problem hard to see from above the transport.

### Reproduction

1. A server-streaming method that sends, say, 10 000 messages of ~64 KB as fast as it can.
2. A client that consumes them with a delay:

```dart
await for (final message in client.serverStream(request)) {
  await Future<void>.delayed(const Duration(milliseconds: 50));
}
```

3. Watch RSS. It grows with the number of messages sent rather than staying flat, and the server
   finishes writing long before the client finishes reading.

### Suggested fix

Gate the pump on consumer demand: a completer that `onPause` resets and `onResume` completes,
awaited before every `moveNext()`. `onCancel` must complete it too, or a cancelled call leaves the
pump parked forever. Racing the sentinel keeps abort behaviour unchanged.

```dart
Stream<Uint8List> toBytes(
  Sentinel sentinel,
  void Function(List<http2.Header>) onHeaders,
  void Function(List<http2.Header>) onTrailers,
) {
  final ctrl = StreamController<Uint8List>();
  var resume = Completer<bool>()..complete(true);
  ctrl
    ..onPause = () {
      if (resume.isCompleted) resume = Completer<bool>();
    }
    ..onResume = () {
      if (!resume.isCompleted) resume.complete(true);
    }
    // A cancelled consumer must unblock a parked pump so it can observe the
    // sentinel / stream end and run its cleanup.
    ..onCancel = () {
      if (!resume.isCompleted) resume.complete(true);
    };
  addAll(sentinel, onHeaders, onTrailers, ctrl.sink, () => resume.future);
  return ctrl.stream;
}

// addAll takes `Future<bool> Function() demand` and waits on it per frame:
while (true) {
  // Raced, so an aborted call unparks a paused pump.
  await sentinel.race(demand());
  if (!(await sentinel.race(it.moveNext()))) break;
  // … existing header / trailer / data handling …
}
```

This is the patch we carried as a vendored delta against 1.0.0 and 2.0.0. It is small, local to
`http2.dart`, and changes no public API. Happy to open a PR if the approach looks right.
