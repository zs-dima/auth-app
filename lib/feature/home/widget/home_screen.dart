import 'package:auth_app/_core/widget/common_actions.dart';
import 'package:flutter/material.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatelessWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          title: const Text('Home'),
          leading: const SizedBox.shrink(),
          actions: CommonActions(),
        ),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text('Home'),
          ),
        ),
      ],
    ),
  );
}
