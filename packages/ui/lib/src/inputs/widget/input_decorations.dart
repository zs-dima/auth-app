import 'package:flutter/material.dart';

class InputDecorations {
  static const flat = InputDecoration(
    hintStyle: TextStyle(color: Color(0xFFB7C9D9)),
    filled: true,
    fillColor: Color(0xFFE8EDF2),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: .all(.circular(8.0)),
    ),
  );

  static const flatTheme = InputDecorationTheme(
    hintStyle: TextStyle(color: Color(0xFFB7C9D9)),
    filled: true,
    fillColor: Color(0xFFE8EDF2),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: .all(.circular(8.0)),
    ),
  );

  const InputDecorations();
}
