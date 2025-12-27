// ignore_for_file: depend_on_referenced_packages

import 'package:example/widgets/ui_kit_card.dart';
import 'package:example/widgets/ui_kit_icon.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Brightness _brightness = Brightness.light;

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
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 30.0,
        children: <Widget>[
          Row(
            children: [
              const Spacer(),
              IconButton(
                iconSize: 64,
                onPressed: () => widget.onBrightnessChanged?.call(
                  widget.brightness == Brightness.light ? Brightness.dark : Brightness.light,
                ),
                icon: Tooltip(
                  message: 'Switch theme',
                  child: Builder(
                    builder: (context) => switch (widget.brightness) {
                      Brightness.light => const Icon(Icons.dark_mode, color: Colors.black87),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                // AppText.labelLarge('Label Large'),
                // AppText.labelMedium('Label Medium'),
                // AppText.labelSmall('Label Small'),
              ],
            ),
          ),

          Row(
            children: [
              const Spacer(),
              Expanded(
                child: UiKitCard(
                  title: 'Logo',
                  child: ColoredBox(
                    color: Colors.grey[900]!,
                    child: const Padding(padding: EdgeInsets.all(8.0), child: AppLogo()),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),

          UiKitCard(
            title: 'Shaders',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    size: const Size.square(250),
                    animate: _aiProgress,
                    child: _aiProgress ? Icon(Icons.mic_off, color: Colors.orange[700]) : null,
                  ),
                ),
                const Shimmer(size: Size(250, 50), radius: Radius.circular(5)),
              ],
            ),
          ),

          const UiKitCard(
            title: 'Icons (app)',
            child: Wrap(
              spacing: 20.0,
              runSpacing: 24,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                UiKitIcon('add', Icons.add),
                UiKitIcon('chevron down', Icons.arrow_drop_down),
                UiKitIcon('question', Icons.help_outline),
              ],
            ),
          ),

          const UiKitCard(
            title: 'Icons (drawer)',
            child: Wrap(
              spacing: 20.0,
              runSpacing: 24,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // UiKitIcon('BO outline', DrawerIcons.BoOutline),
              ],
            ),
          ),

          const UiKitCard(
            title: 'Icons (dashboard)',
            child: Wrap(
              spacing: 20.0,
              runSpacing: 24,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // UiKitIcon('high', DashboardIcons.high),
              ],
            ),
          ),

          const SizedBox(height: 50),
        ],
      ),
    ),
  );
}
