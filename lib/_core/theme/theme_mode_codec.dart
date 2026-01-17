import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;

/// {@template theme_mode_codec}
/// Codec for [ThemeMode]
/// {@endtemplate}
final class ThemeModeCodec extends Codec<ThemeMode, String> {
  /// {@macro theme_mode_codec}
  const ThemeModeCodec();

  @override
  Converter<String, ThemeMode> get decoder => const _ThemeModeDecoder();

  @override
  Converter<ThemeMode, String> get encoder => const _ThemeModeEncoder();
}

final class _ThemeModeDecoder extends Converter<String, ThemeMode> {
  const _ThemeModeDecoder();

  @override
  ThemeMode convert(String input) => switch (input) {
    'ThemeMode.dark' => .dark,
    'ThemeMode.light' => .light,
    'ThemeMode.system' => .system,
    _ => throw ArgumentError.value(input, 'input', 'Cannot convert $input to $ThemeMode'),
  };
}

final class _ThemeModeEncoder extends Converter<ThemeMode, String> {
  const _ThemeModeEncoder();

  @override
  String convert(ThemeMode input) => switch (input) {
    .dark => 'ThemeMode.dark',
    .light => 'ThemeMode.light',
    .system => 'ThemeMode.system',
  };
}
