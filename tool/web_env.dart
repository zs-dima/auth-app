import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) async {
  const webRoot = '/usr/share/nginx/html';
  const envJsonPath = '$webRoot/assets/asset/environment.json';
  final envJson = <String, Object>{};

  // Parse arguments into envJson
  for (final argument in arguments) {
    final split = argument.split('=');

    // Ensure argument is correctly formatted
    if (split.length != 2) {
      throw ArgumentError('Invalid argument format: $argument. Expected format: key=value');
    }

    final arg = split.first.trim().toUpperCase();
    final value = split.last.trim();

    // Ensure argument key and value are not empty
    if (arg.isEmpty || value.isEmpty) {
      throw ArgumentError('Invalid argument: $argument. Key and value should not be empty');
    }

    envJson[arg] = _toJsonValue(value);
  }

  final envFileContent = const JsonEncoder.withIndent('    ').convert(envJson);
  await File(envJsonPath).writeAsString(envFileContent);
}

/// Converts a string to a JSON value
Object _toJsonValue(String value) => switch (value) {
      _ when int.tryParse(value) != null => int.parse(value),
      _ when double.tryParse(value) != null => double.parse(value),
      _ when value.toLowerCase() == 'true' => true,
      _ when value.toLowerCase() == 'false' => false,
      _ => value,
    };
