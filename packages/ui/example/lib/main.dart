// ignore_for_file: depend_on_referenced_packages

import 'package:example/widgets/ui_kit_card.dart';
import 'package:example/widgets/ui_kit_icon.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

// flutter create --platforms=android,ios,web,windows,macos,linux .

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Brightness _brightness = .light;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'UI Kit',
    theme: ThemeData(
      useMaterial3: true,
      brightness: _brightness,
      colorScheme: ColorScheme.fromSeed(brightness: _brightness, seedColor: Colors.deepPurple),
    ),
    home: MyHomePage(
      title: 'UI Kit',
      brightness: _brightness,
      onBrightnessChanged: (brightness) => setState(() => _brightness = brightness),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.onBrightnessChanged, required this.brightness});

  final String title;
  final ValueChanged<Brightness>? onBrightnessChanged;
  final Brightness brightness;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _aiProgress = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    // appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
    body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: .start,
        mainAxisSize: .min,
        spacing: 30.0,
        children: <Widget>[
          Row(
            children: [
              const Spacer(),
              IconButton(
                iconSize: 64.0,
                onPressed: () => widget.onBrightnessChanged?.call(
                  widget.brightness == .light ? .dark : .light,
                ),
                icon: Tooltip(
                  message: 'Switch theme',
                  child: Builder(
                    builder: (context) => switch (widget.brightness) {
                      .light => const Icon(Icons.dark_mode, color: Colors.black87),
                      _ => const Icon(Icons.light_mode, color: Colors.orange),
                    },
                  ),
                ),
              ),
            ],
          ),
          const UiKitCard(
            title: 'Typography',
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              spacing: 10.0,
              children: [
                AppText.displayLarge('Display Large'),
                AppText.displayMedium('Display Medium'),
                AppText.displaySmall('Display Small'),
                AppText.headlineLarge('Headline Large'),
                AppText.headlineMedium('Headline Medium'),
                AppText.headlineSmall('Headline Small'),
                AppText.titleLarge('Title Large'),
                AppText.titleMedium('Title Medium'),
                AppText.titleSmall('Title Small'),
                AppText.bodyLarge('Body Large'),
                AppText.bodyMedium('Body Medium'),
                AppText.bodySmall('Body Small'),
                AppText.labelLarge('Label Large'),
                AppText.labelMedium('Label Medium'),
                AppText.labelSmall('Label Small'),
              ],
            ),
          ),

          const Row(
            children: [
              Spacer(),
              Expanded(
                child: UiKitCard(
                  title: 'Logo',
                  child: ColoredBox(
                    color: Colors.white,
                    child: Padding(padding: .all(8.0), child: AppleLogo()),
                  ),
                ),
              ),
              Spacer(),
            ],
          ),

          UiKitCard(
            title: 'Shaders',
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              spacing: 10.0,
              children: [
                MouseRegion(
                  onEnter: (_) {
                    if (_aiProgress) return;
                    HapticFeedback.mediumImpact();
                    setState(() => _aiProgress = true);
                  },
                  onExit: (event) {
                    if (!_aiProgress) return;
                    HapticFeedback.mediumImpact();
                    setState(() => _aiProgress = false);
                  },
                  child: AiProgress(
                    background: _aiProgress ? Colors.black : null,
                    size: const Size.square(250.0),
                    animate: _aiProgress,
                    child: _aiProgress ? Icon(Icons.mic_off, color: Colors.orange[700]) : null,
                  ),
                ),
                const Shimmer(size: Size(250.0, 50.0), radius: .circular(5.0)),
              ],
            ),
          ),
          const UiKitCard(
            title: 'Icons (app)',
            child: Wrap(
              spacing: 20.0,
              runSpacing: 24,
              crossAxisAlignment: .center,
              children: [
                UiKitIcon('apple', AppIcons.apple),
                UiKitIcon('windows', AppIcons.windows),
                UiKitIcon('windows outline', AppIcons.windowsOutline),
                UiKitIcon('google', AppIcons.google),
                UiKitIcon('sun', AppIcons.sun),
              ],
            ),
          ),

          const SizedBox(height: 50.0),
        ],
      ),
    ),
  );
}
