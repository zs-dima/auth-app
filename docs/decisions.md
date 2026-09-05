# Decisions log

Append-only, newest first. One entry per consequential decision: date, decision, why, and what
would reverse it. The BreakerSonar repo proved the genre (140+ entries); this file starts it here.

## 2026-09-05 — connectrpc is un-vendored, and the back-pressure patch goes with it

**Decision:** the app takes hosted `connectrpc: ^2.0.0`. `packages/vendor/connectrpc` is deleted,
and the HTTP/2 back-pressure patch it carried is NOT reapplied. This REVERSES the 2026-09-02 entry
below ("re-vendored on 2.0.0, not un-vendored"), which stays where it is: a reversed decision is
part of the record.

**What is actually lost.** Upstream `lib/src/http2/http2.dart` pumps response frames into a
`StreamController` in a `while (await sentinel.race(it.moveNext()))` loop that never consults the
consumer. `package:http2` emits WINDOW_UPDATE as frames are dispatched to its listener, so pausing
that subscription is the only way flow control reaches the server — and nothing pauses it. A slow
consumer of a large server stream therefore buffers without bound. The patch (a demand gate: a
completer driven by `onPause` / `onResume` / `onCancel`, awaited before each `moveNext()`) is
recorded verbatim in `docs/connectrpc-backpressure-issue.md`, ready to file upstream. The diff
between hosted 1.0.0 and 2.0.0 inside `http2/` is formatting only, so upstream has not fixed it.

**Why accept it anyway:** the app has one server-streaming call (`ListUsers`), consumed eagerly
into a list, so there is no slow consumer to starve today. Against that, a vendored copy is a
permanent merge obligation on every connectrpc release, and it was the last thing keeping the
transport out of a normal dependency.

**What `connect_kit` still does:** `ConnectMiddleware` forwards the consumer's pause to the wire
subscription. That is real, and pinned by a test, but it stops at the buffering controller — end
to end, flow control depends on the transport underneath. The package's README, CHANGELOG and
AGENTS file claimed "reaches HTTP/2 flow control"; they now say what is true.

**Reversal condition:** a consumer that streams enough to matter (a real-time feed, a large
export), or upstream merging the gate. The vendored copy is one `git show` away —
`packages/vendor/connectrpc` at the commit before this change.

## 2026-09-05 — corrective pass over the extraction

Eleven fixes, each of them something the extraction or the telemetry rework left half-true.

1. **A cancelled RPC was still shown to the user.** `describeError` silenced the bare
   `ConnectException(canceled)`, but every call leaves through `guardRpcCall` / `guardRpcStream`,
   which map it to `RpcException$Cancelled` (A8) — so the wrapped form fell through to the
   transport arm and produced a `warn` toast reading "…: canceled" after a sign-out, the exact
   sentence refresh_token.md §13 exists to prevent. Unreachable today (no unary call is cancelled
   through a token) and pinned now, for both shapes.
2. **`test/tool/contract_anchors_test.dart` scanned a directory that no longer exists**
   (`packages/model/http_client`) and errored in `setUpAll`. Every INVARIANT tag it used to anchor
   is anchored in the remaining tree.
3. **The A2 "signOut during restore" test could not fail.** Its fake returned `stored` AFTER the
   gate, so the logout's `null` sent `restore()` out through its `credentials == null` early
   return, never reaching the epoch check the test is named for. The fake snapshots before the gate
   now; removing the guard fails the test, which was verified.
4. **The Sentry SDK owned a second, unredacted way out.** `DebugPrintIntegration` replaces
   `debugPrint` in release with a breadcrumb that prints nowhere, so anything any package printed
   shipped verbatim. `enablePrintBreadcrumbs = false` now, and the one `debugPrint` call site in
   the app goes through the pipeline. `enableLogs` is pinned `true` in the same cascade: it is an
   alpha-channel default, and `..sentry()` is a silent no-op without it.
5. **`http.route` was a whitelisted Sentry tag, and the only `ApiClient` talks to S3** — whose
   object keys are `users/<userId>/avatar.webp`, which makes the route a user id. The tag is
   `http.host`; the journal still keeps the route.
6. **The capture test's `setUp` aborted silently.** `options.integrations.clear()` throws on an
   unmodifiable list, and `Sentry.init` swallows a throwing options callback unless
   `automatedTestMode` is set — so the integrations stayed and `beforeSend` was never wired. Ten
   tests were green against a hub configured differently from the one they describe. Only the error
   integrations are removed now: the logger and processor ones have to survive, or `..sentry()` has
   nowhere to go.
7. **`LabelWidget` made `expands` conditional on the screen.** The field always sits in a
   `Flexible` now, and a loose one hands its child unbounded height — under which
   `TextField(expands: true)` resolves an infinite `InputDecorator`. `expands` follows the caller
   again. (Separately, and NOT changed here: `AppTextField.expands` cannot be set at all, because
   the kit's `maxLines` is non-nullable and Flutter asserts `maxLines == null` when a field
   expands. Pre-existing dead parameter.)
8. **The migration ladder was tested from a version that never shipped.** The fixture started at a
   hand-built v2; released builds are at v1, so the rung every device takes first — v2's three
   `DROP TABLE`s — and the composite 1 → 3 path ran in no test at all. The fixture is the real v1
   schema now. `level` changed meaning in v3 (`package:l` 0–6 → OpenTelemetry 1–21) with no data
   migration, and that is deliberate: the row writer was commented out in every commit that ever
   had it, so no released build wrote a row on the old scale.
9. **`DB_DROP` did nothing.** It resolved into `AppEnvironment` and was never passed to
   `Database.lazy`, so the launch configuration whose whole purpose is starting from an empty
   database reused the old one.
10. **An abandoned composition flipped a live global.** `log.buffer.undrain()` ran unconditionally
    in the 'Collect logs' teardown, so a container abandoned by the seven-minute init timeout could
    switch the running app's ring buffer back to keeping `debug` and up — evicting the `trace`
    lines the dev menu is the only home for. Guarded by journal identity, the way the toast sink
    already was.
11. **`AuthLayout` kept its insets outside the scrollable** (`SafeArea > Center >
    SingleChildScrollView`), the shape the 2026-09-04 sweep removed from `AppError`. It is
    `CustomScrollView > SliverSafeArea > SliverPadding > SliverFillRemaining` now, with tests for
    the three behaviours: centred when the form fits, scrolling when it does not, and a viewport
    that spans the window.

**Also:** the layout gate excluded `/tool/`, a SUBSTRING that hid `lib/_core/tool/`,
`packages/tool/**` and nine files in `packages/ui/lib/src/tool/` (removed — the check is still
clean); `web_binaries_pin_test` matched LF only, so a fresh CRLF checkout would have reported
"drift not found in pubspec.lock"; `verify_l10n` had stopped asserting that the migration's own
keys exist, which is what the ICU probe is read from; and `uuid_x.dart` carried a second `isNull`
on `Guid?`, which would have made the first `.isNull` in any file importing it and `connect_kit` an
ambiguous-extension error.

**One thing deliberately NOT changed:** `AuthenticationScope` keys `AuthenticatedScope` by user id,
and that scope sits above the `Router` inside `MaterialApp.builder` — so an identity change
rebuilds the Navigator and every route State, where the previous shape kept the element. That is
the price of keyed per-user disposal, and it is paid at sign-in and sign-out only. If it ever
shows, key the controller-owning layer rather than the whole subtree.

**Corrections to entries below, which describe things that have since moved:** `packages/telemetry`
is not a workspace member — the engine is the external `telemetry` package, consumed by git tag
(the 2026-09-03 entry predates the extraction); the dev journal does NOT show trace lines live, it
reads the ring buffer once in `initState`; the layout check is IMPORTED by
`test/_core/layout_guard_test.dart` rather than spawned as a subprocess; and `journal_sink_test`
holds five promises, not six.

## 2026-09-04 (layout & rebuild sweep, mirrored from the twin)

BreakerSonar's layout pass found rules that hold here too, and the enforcing check found the
instances. What follows is what applied; its content column (`ContentPane`/`SliverContentPane`) did
NOT — `ScaffoldPadding` here is already the right shape, an `EdgeInsets` value handed to a
`SliverPadding` or a `padding:` INSIDE the scrollable, and it was the ancestor that idea came from.

**1. `CaseWrapWidget` is deleted, and `LabelWidget` no longer changes shape.** The kit shipped
"wrap the child only in this case" as a named, reusable widget, and eight input widgets used it the
same way: `largeScreen ? (child) => LabelWidget(...) : null`. `Widget.canUpdate` compares exactly
two things, the runtime type and the key, so a child that changes DEPTH is not updated but rebuilt —
every text field, dropdown and chip field in the app lost its element, its focus, its selection and
the IME's composing region on each crossing of the large-screen breakpoint, which is what dragging a
desktop window edge does continuously. `LabelWidget` had the same bug inside it (`if
(label.isEmpty) return child;`) and now keeps the label as a `Visibility` SLOT, so the field is at
index 1 whatever the label does. `expands` became a parameter (`Flexible(flex: expands ? 1 : 0)`)
instead of `expands ? Expanded(child: child) : child` — swapping `Expanded` in and out around a
text field is the same reshape, on the keystroke that flips the flag. With every call site folded
into `LabelWidget`, `CaseWrapWidget` had no consumers and went (no consumer, no code).
**Reversal:** none wanted — a helper whose whole purpose is a conditional wrap cannot be made safe;
the condition belongs in a parameter.

**2. The whole scope chain rebuilt on every keyboard frame.** `AppWidget.build` read
`MediaQuery.of(context)` — a subscription to EVERY metric — and used it inside `builder:`, so
`WindowSizeScope → WindowScope → OctopusTools → AppMessageScope → AuthenticationScope` was rebuilt
on each frame of the keyboard's inset animation and on every rotation. The `GlobalKey` on that
`MediaQuery` ("disable recreate widget tree") was the workaround, and it is gone with the cause: the
scopes are built once into a local and handed to a new leaf `_TextScale`, whose `child` is that
identical instance and is therefore skipped by `Widget.canUpdate`. This is the framework's own
`withClampedTextScaling` shape.

**3. The initialization-failure screen could not scroll on the phones that need it.**
`SafeArea > Center > SingleChildScrollView` — a scroll view inside a `Center` gets a viewport the
height of its own content, so on a short window with a long stack trace there was nothing to scroll
at all, and the scrollbar never reached the edge. Now `CustomScrollView > SliverSafeArea >
SliverPadding > SliverFillRemaining(hasScrollBody: false)`: fill the viewport, then scroll. The
bottom inset goes INSIDE the fill, because an after-padding is not counted in
`precedingScrollExtent` and would make the fill permanently taller than the viewport. Its
`builder:` also stopped hand-building a `MediaQueryData` and uses `MediaQuery.withNoTextScaling`.

**4. Two more of the same kind.** The octopus history overlay wrapped its list in
`Align(topCenter)` with `shrinkWrap: true` to do what a plain list already does — a short list
starts at the top of the space it is given — while measuring every entry on every layout and
shrinking the viewport away from the panel's edge; it already had an `itemExtent`.
`context.mediaQuery` in `packages/ui`'s `BuildContext` extension had no call site and was the worst
accessor to offer: the first person to reach for the short spelling would have subscribed their
widget to every metric. The aspect accessors are already short.

**5. The check that found all of this is now part of the gate.**
`tool/checks/flutter_layout_check.dart` (from `dev-tools`, `my-stack/checks`) plus
`.claude/flutter-layout-check.json` and `test/_core/layout_guard_test.dart`, which runs it as a
subprocess and asserts zero findings — so `dart run tool/test_workspace.dart` and therefore CI
enforce it, with no workflow edit. The three findings left in the dropdown popups are argued in
place with `// layout-check: ignore <rule>`: a popup that must be as wide as its widest suggestion
has no other way to ask, and a popup that sizes to its content IS shrink-wrapping.

**6. A claim the twin recorded, and this repo would have inherited, is false.**
"`StreamController.broadcast().stream` has no `==`, so a `StreamBuilder` resubscribes on every
rebuild of its parent" — the class it returns, `_ControllerStream`, overrides `==` to compare
controllers, so two reads are equal and nothing resubscribes. Ten lines of Dart settle it. The real
case is a TRANSFORMED stream (`.map`, `.expand`, `.asBroadcastStream`), which has no `==` at all;
the check's rule was renamed `stream-getter` → `stream-transform` and narrowed to match, in
`dev-tools` and in both vendored copies. A wrong rule in a shared gate is worse than a missing one:
it teaches the wrong model to every project that adopts it.

**7. The FakeAsync zone trap, which cost an afternoon in the twin.** A future carries the zone it
was CREATED in, and its continuations are scheduled with that zone's `scheduleMicrotask`. Two
consequences, both of which present as a test that hangs at `+0` with no output, and neither of
which `flutter test --timeout` can interrupt (the binding drives the body synchronously, so the
real event loop never runs and the timeout timer never fires — a timeout that fails to fire proves
nothing): (a) awaiting a broadcast subscription's `cancel()` inside `testWidgets` never returns,
because that future is ROOT-zoned; (b) a `close()` on an already-closed controller hands back the
`done` future the first close built, so a teardown awaiting it from another zone waits forever.
`AuthenticationRepository.terminate` now guards its `close()` with `isClosed`, the way it already
guards `add`. Full write-up in the `flutter-layout-perf` skill.

## 2026-09-04 (later) — what a review of the twin found in this code

A pass over BreakerSonar's uncommitted tree turned up defects that are the same code or the same
rule here. Mirrored, with what does not apply left out (its OS notifications, permissions, pairing
and panel are its own).

**1. The SDK's error integrations are removed by TYPE, not by class name.** The previous entry
below says they are removed; it compared `runtimeType.toString()` to `'FlutterErrorIntegration'`,
which an obfuscated build does not have. This app does not pass `--obfuscate` today
(`tool/makefile/deploy.mk`), so the removal worked here and silently did nothing in the twin —
adding the flag would have re-armed it with no signal. `FlutterErrorIntegration` is not exported,
so it is imported through `// ignore: implementation_imports` (precedent: `deep_link_codec.dart`
for octopus) and matched with `is`. The lesson generalises: a check that reads a NAME at runtime is
green in a test and dead in a release build.

**2. `Control | handler | failed` is `debug`, not `warn`.** `control` runs the observer's `onError`
AND the handler's `error:`, and every handler has one (the contract test below). So each failure
produced two `info+` rows carrying the same cause and the same stack — two Sentry breadcrumbs out
of a ring of a hundred. The handler's callback is the incident; the observer's row is the trail
beside it, and it keeps `control.meta.*`, which the report does not carry.

**3. The `handle()` contract test was checking nothing.** Its declaration-vs-call rule put `>` in
the "looks like a declaration" class — and `=>` ends with the same character, while every handler
in this app is arrow-bodied. Twenty-three call sites, all skipped, test green. The arrow is now
checked first, and the test asserts a floor on the number of CALL SITES it judged (a floor on files
could not see this). Proved by deleting one `error:`: it fails.

**4. Two more ratchets were narrower than their own docstrings.** The canonical-body test never
scanned `reportFailure(` or `log.call(` — which is how most bodies are written — and the
release-console floor, cited in this file as a promise, had no test at all.

**5. Four smaller things, each the same shape: a line that says something before it is true.**
`Database | migrate | applied` was logged BEFORE the ladder ran (and before the downgrade throw);
the boot TIMEOUT threw with no line at all, though it is the one boot outcome where no step failed
and so nothing else reports it; `drain()` left the whole boot in a five-second queue, so a crash
right after "Collect logs" took exactly the lines that step exists to keep; and `enableReporting`
flipped `_reporting` only after `await`, so two overlapping calls both started the SDK.

**Also:** the release error box's semantics label was hardcoded English on a user-facing surface
(`Localization.currentErrors` now, with `debugSetCurrent` for the tests that have no tree); the tag
whitelist did not carry keys this app writes and may send (`app.settings.key`, `app.environment`,
`db.from`/`db.to`, the boot counters, the verification error code); `..debug = kDebugMode` is
always false, because `enableReporting` refuses in debug; and the route-names rule is a named
function (`routeNamesOf`) rather than an inline `map`, because in the twin a second reporting site
was added later and wrote the LOCATION — which for a route carrying a token in its arguments is
the whole problem.

**Reversal condition for 1:** the SDK exports the type, or grows a documented way to keep its
integrations while delegating the capture decision.

**New tests:** `test/_core/log/journal_sink_test.dart` (six promises of the journal, none held
before), `console_floor_test.dart`, `test/initialization/error_box_test.dart`,
`test/_core/message/ui_messenger_test.dart`, plus the throttle and structured-log cases in
`sentry_capture_test.dart`.

## 2026-09-04 — corrective pass: one reporter, one event, and no value in a body

**Decision:** eight rules, each of which was already written down somewhere and was not true in
the code.

1. **The SDK's own error integrations are removed** in `configureOptions`. `SentryFlutter.init`
   installs `FlutterErrorIntegration` and `OnErrorIntegration` *before* running our options
   callback, both chain the handlers `$initializeApp` already set, and both capture at `fatal`,
   unthrottled and with no tag whitelist. Every framework error was therefore filed twice, with
   two fingerprints and two severities. "One place decides" is a sentence in this file; this is
   what makes it true. Counted by `test/_core/log/sentry_capture_test.dart`, on a real hub over a
   fake transport — the first test in this repo that can tell "captured once" from "captured
   twice".
2. **`app.route` carries route NAMES, never `OctopusState.location`.** `location` encodes each
   node's arguments as query parameters, and `authRecoveryConfirm` reads its password-reset token
   from exactly those — so the row was `app.route=/auth-recovery-confirm?token=…`, kept for 1000
   journal rows, printed to a release device log, and whitelisted as a Sentry tag. Names answer
   "what was on screen"; the values are what must not travel.
3. **A draft's channels resolve once, against one event.** `toast`/`sentry`/`track`/`notify`
   record their request; `_afterActions` fans them out with the single `LogEvent` that was
   logged. Cascade order stops mattering by construction (`..sentry()..error()` used to send a
   structured log *and* capture; `..error()..sentry()` correctly did not), "Details" opens exactly
   the journaled event, and `_snapshot` runs once.
4. **The ring buffer has two lives.** Until `markDrained()` it guarantees `debug` and up — the
   whole boot, before any sink exists. After it, it keeps `trace` only: no sink stores a trace
   line, so the buffer is its one home, and that is what makes the dev menu's `trace` chip work in
   release too.
5. **A captured `print` is `debug`, not `info`.** `info` is the crash reporter's breadcrumb floor
   and `beforeSend` does not touch breadcrumbs, so anything any package printed would have shipped
   verbatim. The journal keeps it either way.
6. **`reportFailure(..., toast: false)`** for a caller that renders the sentence itself. Five auth
   paths (`restore`, `signOut`, `requestVerification`, `recoveryStart`, `recoveryConfirm`) put the
   text under the form and were plain `log.w` — so after the transport middlewares stopped
   capturing, a backend that broke during a password reset filed nothing at all. They classify
   now; only the snack bar is suppressed. `level:` may only *attenuate*, asserted at the call.
7. **A log body is `Area | operation | message` and nothing else** — the crash reporter's
   fingerprint and the breadcrumb category. Fifteen bodies interpolated a value; a body forwarded
   whole (`reportFailure`'s teardown line) is the one exemption. Held by
   `test/_core/log/canonical_body_test.dart`.
8. **`LoggingBridge` forwards a fixed body** (`Logging | forwarded | record`) with the logger name
   and the free text as attributes, and caps the level at `warn` unless the record carries an
   error: a SEVERE record with no error is a third-party package's opinion, not our defect, and it
   was filing one issue per distinct message string.

**Also, in the same pass:** `ProgressOverlay` stopped being an `OverlayEntry` (127 lines → 44) —
it could not be mounted inside `AppMessageScope`, which lives above the Router where there is no
`Overlay`; `UiMessenger.track<T>()` replaced eleven `progressStarted`/`progressDone` pairs with
`try/finally`; `UiMessenger.show` holds a message raised before the first subscriber (cap 8, TTL
10 s), which is why the "your e-mail is verified" toast now actually appears; the dev journal sorts
by `(time, id)` because `time` is seconds and `List.sort` is not stable; `crash_reports_switch`
catches its own write failure instead of letting it become an uncaught zone error; and
`describeError` stops handing the server's `internal` message to the user.

**Reversal condition for 1:** the SDK grows a documented way to keep its integrations while
delegating the capture decision. Then the integrations stay and the pipeline registers as their
sink instead.

## 2026-09-03 (later) — the telemetry facade is `log`, not `tr`; trace tiers are named

**Decision:** the global is `log`. `log('Area | op | msg')…`, `log.d/i/w/e/f(msg, meta: {…})`, and
`log.v1(…)` … `log.v6(…)` for the six `trace` tiers. `TelemetrySink.log` became `handle`,
`LogDraft.log(level)` became `at(level)`, `Telemetry.v(int tier, …)` and `t()` are gone.

**Why:** `tr` is the de-facto *translate* helper in Flutter i18n (easy_localization's `tr()`,
GetX's `.tr`). In an app with four locales, `tr('Auth | signIn | failed')` reads as a translation
call, and "tr" is unsearchable prose — it is also transaction, transport, trace. `log` is the verb
slog, Serilog, Winston and log4j all use, and it reads as English in both call shapes. One
collision existed in this repo (a local named `log` in the maintenance step) and one in
BreakerSonar (`import 'dart:math'` unprefixed); both were renamed.

**Why named tiers:** `tr.v(6, 'Control | dispose | X', {…})` put a magic number in the leading
argument position, and `dart format` pushed it onto a line of its own. `package:l`, whose six tiers
these are, shipped exactly these shortcuts for the same reason. `meta:` is named on every
convenience because Dart forbids optional positional and named parameters on one method — the
original plan's `tr.w('x', {…})` could never have compiled.

**What would reverse it:** a repo-wide i18n convention that claims `log`. Nothing else.

## 2026-09-03 (later) — one place decides what becomes a crash-reporter issue

**Decision:** the Connect and HTTP Sentry middlewares no longer call `Sentry.captureException`.
They own the SPAN, its status and its redacted data; whether a failure is an issue is the telemetry
pipeline's decision, made once from the level `describeError` assigns, and passed through
`ReportThrottle`.

**Why:** they reported independently of the pipeline and of each other. A warn-class outage
(`unavailable`) still filed one issue per call — the exact defect the warn/error split was
introduced to fix — and an error-class failure filed TWO issues with different fingerprints,
because the middleware captures the bare `ConnectException` while the pipeline captures the
`RpcException` chain, and Sentry's `DeduplicationEventProcessor` keys on `throwable.hashCode`.

**Also decided:** `describeError` classifies a server's REFUSAL as `warn`, not `error`
(`invalidArgument`, `alreadyExists`, `notFound`, `permissionDenied`, `failedPrecondition`,
`outOfRange`, `aborted`; HTTP 401 and 403 join the transient statuses). Those are answers, not
faults: the address is already registered, the record is gone, this account may not do that. An
issue per "e-mail already registered" fills the tracker with other people's typing. `unknown`,
`unimplemented`, `internal` and `dataLoss` stay `error`. And the `_ =>` sentence no longer appends
`$e`: the exception's own text is developer English, unlocalized, and on `unknown` it is whatever
the transport put in it.

**What would reverse it:** a failure class the pipeline cannot see at all. There is none today —
both middlewares sit outermost and rethrow.

## 2026-09-03 (later) — what leaves the device is a whitelist, and `run_id` is a tag

**Decision:** attributes reach a captured issue as named TAGS from `SentryTelemetry._taggable`,
never via `setContexts` of `event.attributes`; `exception.stacktrace` is no longer an attribute at
all; exception messages are redacted of anything shaped like an e-mail address on the way out
(`beforeSend`, `beforeSendLog`); `run_id` is set as a scope TAG after `Sentry.init` returns; and
`State #i` on a sampled transaction carries the state's TYPE rather than its rendering.

**Why:** `setContexts` shipped everything an event carried, which in this app includes `app.user.id`,
`auth.reason`, whole `control.from`/`control.to` state renderings, and `exception.message` — a
backend's words about a real person. `exception.stacktrace` as an attribute stored the trace twice
per journal row, rendered it inline in every error tile of the dev menu, and pushed it into Sentry
beside the real one. `Sentry.setAttributes` was called inside the `init` options callback, which
runs BEFORE the hub is built (`sentry.dart:176-178`), so `run_id` reached nothing — and
`setAttributes` scopes structured logs, while the thing that needs joining to the journal is the
issue. A whitelist rather than a blacklist because a blacklist fails silently: every new
`.meta({…})` key would ship until someone noticed.

**What would reverse it:** nothing in this direction. Adding a key to the whitelist is a decision
per key, which is the point.

## 2026-09-03 (later) — the journal covers the whole launch

**Decision:** the pipeline's ring buffer guarantees `debug` and up whether a sink exists yet or not;
`JournalSink.drain` adopts those events when the database opens; `flush()` returns the write and
`dispose()` awaits it; `error` and `fatal` are written through immediately. The boot failure is
logged ONCE, at the step that failed, with the step name as `app.boot.step`. Navigation and app
lifecycle each get a line. Settings writes that fail report and revert.

**Why:** the docstring said "nothing from the earliest boot is lost" and nothing read the buffer.
Ten init steps ran before the journal existed, so a tester's bug report began with the app already
running; the sink's `dispose` did not await its last write and the database closed one step later,
so the tail of every session was dropped; and a native crash took the last five seconds with it.
The boot failure was logged three times — in `composeDependencies`, in `$initializeApp`, and in
`main` with the error object as the BODY — two of them after the sink had been removed, and each
grouping into its own crash-reporter issue.

**Also decided:** the release console floor is `info` (`trace` in debug). A release console is a
device log — `logcat`, Console.app, a tester's screen recording — with no consent, no redaction
and no expiry, and the `debug` lines are state transitions whose attributes carry renderings.

**And the dev menu reads both sources.** The database gives it everything stored; the ring buffer
gives it `trace`, which no sink keeps — so the journal screen shows the current launch's trace
lines live. Level icons are semantic and the six trace tiers are `Icons.looks_one`…`looks_6`:
there the number IS the whole meaning, while for a level a digit says nothing. A `run_id` change
draws a divider, which is how "before the crash" is told from "after it".

**What would reverse it:** nothing. The costs are one drain at boot and one awaited write at
teardown.

## 2026-09-03 — one telemetry pipeline: `packages/telemetry`, `package:l` removed

**Decision:** every log, toast, breadcrumb, crash report and (future) analytics event is one
`LogEvent` — body, OpenTelemetry severity number, attributes, cause/stack, localized description,
launch id — dispatched to sinks (console, drift journal, Sentry, toast bus). The engine is a new
pure-Dart workspace member, `packages/telemetry`; `package:l` is removed.

**Why:** the app had four telemetry mechanisms with no shared model. `d`/`v*` never reached the
stream, so **every controller transition was invisible** to the journal and to Sentry; every
`logger.w` became its own Sentry issue (`_shouldReport => true`), so a ten-minute outage filed one
issue per retry; nothing produced breadcrumbs from logs; `showAppError` dropped the `StackTrace`.
Those are model problems, not missing features — one event with attributes fixes all four.

**Why not a third-party framework** (`talker`, `logger`, `loggy`): each brings its own global, its
own taxonomy and often its own UI, and none offers structured attributes with pluggable sinks. The
industrial pattern — Go `log/slog`, Serilog, the OpenTelemetry logs data model — is a small owned
core plus thin sinks, which is what this is.

**What was taken from `package:l`** (studied in full, 1 756 lines; it is excellent work): the
per-environment console delegates (VM stdout-if-terminal else `Zone.root.print`, JS console per
level, `developer.log` levels, ignore), ANSI colouring, zone-scoped options via `zoneValues`,
print capture that forwards to the parent zone when `handlePrint` is false (its issue #20), release
gating on `dart.vm.product`, `hasListener` stream gating, lazy `Object` messages.
Dropped deliberately: the `<` / `<<` operators (unreadable at review), and `toJson/fromJson` — it
was taken and then removed, because nothing serialises a `LogEvent`: the journal writes columns and
the crash reporter writes tags, each choosing its own subset. Copied delegate code is
credited in place (WTFPL).

**Reversal condition:** the Dart OpenTelemetry SDK implements logs. Then `TelemetrySink` becomes a
bridge to it and the event model stays as it is — that is why the field names are OTel's.

## 2026-09-03 — the call-site shape: a context carrier with independent actions

**Decision:**

```dart
log('Pairing | handshake | refused')
    .meta({'app.pairing.code': code})
    .cause(error)
    .description(copy.pairingRefused)   // the LOCALIZED sentence, for the user
  ..warn()                              // the log is an action, like every other channel
  ..toast(tone: .alert);
```

plus one-call conveniences (`log.w('...', meta: {...})`) for the ~113 plain log sites.
(Written as `tr` when decided; renamed the same day — see the entry above. The shape is unchanged.)

**Why not a terminal-call builder** (`log.warn().meta({...}).emit('msg')`, the zerolog / SLF4J 2
shape): both projects document the same footgun — forget the terminal call and the whole chain is
silently dropped, with no compile-time error. Dart has no lint for it either.

**How this shape closes that hole:** the log is itself an explicit action, so nothing is deferred
to an implicit end of chain; a draft used only for a non-log channel is still logged on the next
microtask, so a user-visible effect is never absent from the journal; and a draft that names no
channel at all trips an `assert` in debug builds.

**The implicit level is `warn`** (added 2026-09-03, second pass). A draft that reaches a channel
without naming a level is logged at `warn` when it carries an error and `info` when it does not —
never at `error`. The reason is the one this whole shape exists for: an implicit emission is the
one the author did not think about, and a level that files a crash-reporter issue is not a
sensible default for something nobody chose.

**Two things `package:l` had that this does not** (same pass): `spanId` on the event — nothing
correlated by it, and the crash reporter's own transaction is what a span means here — and the
`E12`-style numbered helpers, which put a magic number where a level name belongs.

**Why `description` rather than localizing the body:** the journal and the crash reporter need a
stable, language-neutral line (Serilog's message-template principle; Sentry groups issues by
message), while the toast needs the user's language. Two fields, one call — and a `toast()` with
neither `text` nor `description` asserts in debug rather than showing developer English.

## 2026-09-03 — severity decides who hears about a failure

**Decision:** `describeError` classifies a failure into a user sentence AND a level. `warn` is a
condition the user or the network can resolve — wrong password, expired link, backend down, 429,
5xx; it is journaled and breadcrumbed but **never** filed as a crash-report issue. `error` is a
defect and is captured, through a 5-minute dedupe per `body[0..80]#errorType` and a 6/minute cap.
Expected teardown (`RequestSessionEndedException`, a cancelled call, `ApiClientException$Cancelled`)
returns `null`: no toast, no line above trace (refresh_token.md §13).

**Why:** severity used to be a property of the call site's mood. It is really a property of *who
can act on the failure*, and only that reading keeps the issue stream worth reading.

**Reversal condition:** none expected; adding a case is editing `describeError`, which is where a
reviewer will look for it.

## 2026-09-03 — the UI message bus is a stream, not a state

**Decision:** `AppMessageController` (a `StateController` whose state was the last message) is
replaced by `UiMessenger`: `Stream<UiMessage>` for messages, `ValueListenable<int>` for progress.
`AppMessageControllerMixin` is retired; its ~30 call sites now say what happened
(`reportFailure(body, error, caption:)`) instead of pushing a state.

**Why:** a message is an event. As state, a repeat of the same failure could be swallowed as a
no-change, and a widget mounting late re-rendered a toast the user had already dismissed. Progress
as a reference count (rather than two events) means two overlapping operations show one overlay and
the first to finish does not take it from the second. The toast coalescing window also dropped from
**3 s to 300 ms**: three seconds is long enough for the user to have moved on before being told
anything.

## 2026-09-03 — per-user controllers live under `AuthenticatedScope`

**Decision:** `UsersController`, `AuthenticatedUserController`, `AvatarController` and
`ImpersonateController` are created by `AuthenticatedScope`, keyed `ValueKey(userId)`, and disposed
with it (plus `ImpersonateRepository.terminate()`). The composition root keeps only the stateless
`UsersRepository`. The three module-level subscriptions in `initialize_dependencies.dart` are gone:
the scope drives the profile load itself and owns the one subscription that remains.

**Why:** these four outlived the session that created them. `AvatarController._versions` (the
cache-busting map) was never cleared, so a second account could be shown the first one's avatar;
`ImpersonateController.dispose` never terminated its repository; `users_scope.dart` carried a
`// TODO cleanup app data` where the cleanup should have been. A key is a cheaper guarantee than a
cleanup routine: the state cannot outlive the user because the widget cannot.

**Reversal condition:** a controller that must genuinely survive sign-out (an offline outbox, say)
moves back to the root — with an explicit entry here saying why it is safe across identities.

## 2026-09-03 — one CI bootstrap (`.github/actions/setup-flutter`)

**Decision:** a composite action installs Flutter, runs `pub get` and generates code; every
workflow uses it. `code-analysis.yml` runs it with defaults; the deploy gate runs it with
`install: false` (its container ships the SDK). `deploy-firebase.yml`'s build job keeps its own
pipeline — `deploy/build_flutter_web.sh` runs build_runner in parallel across packages, and calling
the composite there would duplicate a multi-minute step for nothing.

**Why:** the copies had already drifted, and not cosmetically — the deploy gate ran `flutter
analyze` with **no codegen at all**, against a tree whose `.g.dart` / `.freezed.dart` are
gitignored.

**Also added:** `ui-kit.yml` publishes `packages/ui/example` to a Firebase preview channel on any
`packages/ui/**` change. A contrast test proves a control still passes; only a rendered gallery
answers whether the kit still looks like the app.

## 2026-09-03 — non-production web builds accept a service-address override

**Decision:** outside production the web build reads `auth_app.api_base_url` /
`auth_app.auth_base_url` from `localStorage` and uses them as the API/auth addresses; an override
logs a warning at startup. Production ignores both keys.

**Why:** addresses are baked in at compile time, so pointing a deployed staging front-end at a
local API meant a rebuild. **Why production is excluded:** the app sends credentials to these
addresses; a value planted through an XSS (web/README.md documents that threat) must not be able to
redirect a real user's sign-in to someone else's server.

## 2026-09-03 — error UX: production text only, details everywhere else

**Decision:** `ErrorWidget.builder` shows the framework's red box in debug and a neutral
placeholder in release (no exception text). A failure toast carries a **Details** action outside
production only, opening the event behind it — attributes, cause, stack, copy button. `AppError`
(the initialization-failure screen) shows the raw error outside release only.

**Why:** the red error box turns one broken list tile into a screen that looks like a crash and
prints internal detail into the user's screenshots — right in debug, wrong in release. The same
line splits the toast: the user reads one localized sentence, and whoever is debugging gets the
rest without leaving the app.

**Also fixed here:** the error toast painted its warning icon in `colorScheme.error` on an `error`
background — an invisible icon on every failure. Tone colours now live in `packages/ui`'s
`AppTone`, the widget-layer twin of the pipeline's `ToastTone`.

## 2026-09-03 — retry middlewares report their attempts

**Decision:** both retry middlewares take an optional `onRetry` (`RetryNotifier`, a plain callback
in `core_model`); the app wires it to a `debug` line carrying `net.attempt` and
`net.retry_delay_ms`. The logger middlewares stay outermost and log one canonical line per CALL —
`Rpc | call | ok`, `Http | call | failed` — with the path, code and duration as attributes.

**Why:** the logger sits outside the retry layer, so it only ever sees the outcome of the last
attempt; retries were completely invisible. A plain callback rather than a logger interface keeps
the transport packages free of any telemetry dependency.

**Why the body carries nothing variable:** it is the crash reporter's grouping key. A path
interpolated into the message groups into one issue per endpoint (Stripe's canonical log line,
OpenTelemetry's attribute naming).

## 2026-09-03 — `SentryNavigatorObserver` without auto transactions

**Decision:** the octopus router mounts `SentryNavigatorObserver(enableAutoTransactions: false)`.

**Why:** navigation breadcrumbs and `contexts.app.view_names` answer "which screen was the user on"
on every report, and they cost nothing. Auto transactions would compete for the scope's span with
`ControllerObserver`, which starts a `bindToScope: true` transaction per handler with the state
timeline attached — this app's tracing is controller-centric, and two owners of one scope span
leaves both half-parented. Screen-load timing is not worth that.

**Reversal condition:** tracing moves to navigation-centric spans; then the controller observer
should attach its work as CHILD spans instead of starting transactions.

## 2026-09-03 — `package:logging` records are forwarded, not dropped

**Decision:** `LoggingBridge` subscribes `Logger.root.onRecord` and forwards each record into the
pipeline with `log.source = logging` and the logger's name as an attribute; levels map by NUMBER,
since both scales are `dart:developer`'s.

**Why:** one package in the tree logs that way — `cupertino_http`, the Darwin URLSession transport —
and nothing in this app ever listened, so its records went nowhere at all. A transport saying "the
session invalidated" and not being heard is exactly what an unexplained failure turns out to have
been. `logging` is now declared in `pubspec.yaml` rather than used transitively.

## 2026-09-03 — dead icon config deleted, source art kept

**Decision:** `icons_launcher.yaml` is deleted; the four PNGs under `assets/icons/app/-/` stay,
with a README explaining what they are.

**Why:** `icons_launcher` was not a dependency and its paths did not resolve (the art sits one
folder deeper). The live generator is `flutter_launcher_icons`, sourcing from `web/*.png` with a
flat adaptive background. The art is the only copy of a higher-fidelity source, and wiring it in
would change the shipped Android icon — a design decision, not a cleanup.

## 2026-09-02 — impersonation stays known-half-built; ui/example stays

**Impersonation:** the feature is wired end-to-end in DI (controller + repository + avatar menu)
but the UI flow is demo-grade and `user_avatar_menu_widget` has no live route reference. Decision:
leave the code as is — it documents the intended multi-account shape for the line — and do NOT
"finish" or delete it without a product decision. (The BreakerMap-line lesson: template code with
no consumer rots; this entry is the consumer-of-record.)

**packages/ui/example:** stays in the repo and OUT of the workspace test runner. The sibling repo
deleted its copy and had to restore it (a Showcase route leaked to release because nothing
exercised the gallery). Keep it as the UI Kit's manual harness; `.vscode/launch.json` carries a
"UI Kit (debug)" config for it.

## 2026-09-02 — Sentry release health (auto session tracking) OFF

**Decision:** `enableAutoSessionTracking = false`, `sendDefaultPii = false`, Session Replay 0.0,
breadcrumb `data` cleared (messages kept — redact-at-source covers them, refresh_token.md §13);
reporting gated on a user-facing "Send crash reports" switch (default ON, opt-out).

**Why:** a release-health session carries a persistent per-install identifier; for an auth demo
the Sentry issues themselves are the signal, and the SDK default flipping under us is exactly the
kind of silent drift the explicit stance prevents. Mirrors the sibling repo's hardening.

**Reversal condition:** a real need for crash-free-session metrics (e.g. staged rollouts) —
flip the flag consciously and document the identifier implication here.

## 2026-09-02 — connectrpc: re-vendored on 2.0.0 (not un-vendored)

**Decision:** rebase the vendored `packages/vendor/connectrpc` onto upstream 2.0.0
(`2.0.0+backpressure`) instead of deleting the vendor and using the hosted package.

**Why:** upstream 2.0.0 (2026-08-31) resolved the original vendoring reason (protobuf ^6), but did
NOT merge the back-pressure patch (HTTP/2 response pump ignores consumer pauses → unbounded
buffering on slow consumers). Un-vendoring would silently regress a real fix. The 1.0.0→2.0.0
upstream delta inside the two patched files was formatting-only, so the patched files carry over
verbatim. Gates green 2026-09-02: protobuf_override_spike_test, connect_model 32/32,
auth_model 72/72, app 99/99.

**Reversal condition:** upstream merges flow control into the HTTP/2 transport — see
`packages/vendor/connectrpc/VENDORED.md` "Updating / exit condition".

## 2026-09-02 — gstatic stays in the prod CSP until `sw` grows a no-CDN toggle

**Decision:** keep `https://www.gstatic.com` in `script-src` of `web/index.prod.html`, even though
the release build self-hosts CanvasKit (`--no-web-resources-cdn`).

**Why:** `sw` 0.1.5's `bootstrap.js` loads CanvasKit CDN-first with no opt-out. Its probe is a
`fetch` (Range GET) — governed by `connect-src`, where `https:` is deliberately broad — so the
probe would still SUCCEED after removing gstatic from `script-src`, and the subsequent script load
would be blocked with no fallback: a broken app. The local-`canvaskit/` fallback only triggers when
the probe itself fails.

**Reversal condition:** `sw` releases a config flag to skip the CDN probe (or the vendored template
is patched). Then: enable the flag, drop gstatic from `script-src` in `index.prod.html`, and update
`web/README.md`'s CSP section.
