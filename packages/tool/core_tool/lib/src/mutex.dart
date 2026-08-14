// Code from the https://gist.github.com/PlugFox/a923f32c9301a653116590da7cc18674

import 'dart:async';
import 'dart:collection';

/// A simple mutex implementation using a queue of completers.
/// This allows for synchronizing access to a critical section of code,
/// ensuring that only one task can execute the critical section at a time.
class Mutex {
  /// Queue of completers representing tasks waiting for the mutex.
  final DoubleLinkedQueue<Completer<void>> _queue = DoubleLinkedQueue<Completer<void>>();

  /// Check if the mutex is currently locked.
  bool get isLocked => _queue.isNotEmpty;

  /// Returns the number of tasks waiting for the mutex.
  int get tasks => _queue.length;

  /// Acquires the lock: returns a future that completes when it's this caller's turn.
  /// Await it, do the work, then call [unlock] exactly once to release.
  Future<void> lock() {
    final previous = _queue.lastOrNull?.future ?? Future<void>.value();
    _queue.add(Completer<void>.sync());
    return previous;
  }

  /// Unlocks the mutex, allowing the next waiting task to proceed.
  ///
  /// Must be balanced with [lock] — [synchronize] guarantees that. A stray unlock trips an
  /// assert in debug and is a no-op in release, so a caller bug never takes production down.
  void unlock() {
    assert(_queue.isNotEmpty, 'Mutex unlock called when no task holds the lock.');
    if (_queue.isEmpty) return;

    final completer = _queue.removeFirst(); // Remove the current lock holder
    // Unreachable by construction: a completer is completed only after it leaves the queue.
    assert(!completer.isCompleted, 'Mutex unlock called when the completer is already completed.');
    if (completer.isCompleted) return;

    completer.complete();
  }

  /// Synchronizes the execution of a function, ensuring that only one
  /// task can execute the function at a time.
  Future<T> synchronize<T>(Future<T> Function() action) async {
    await lock();
    try {
      return await action();
    } finally {
      unlock();
    }
  }
}

// Example usage
// void main() async {
//   final mutex = Mutex();

//   // Simulate a critical section
//   Future<void> criticalSection(int id) async {
//     print('Task $id is in the critical section');
//     await Future<void>.delayed(const Duration(seconds: 1));
//     print('Task $id is leaving the critical section');
//   }

//   // Start multiple tasks
//   for (var i = 0; i < 5; i++) mutex.synchronize(() => criticalSection(i));
// }
