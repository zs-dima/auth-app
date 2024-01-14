import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FilterUsersWidget extends StatefulWidget {
  const FilterUsersWidget({
    super.key,
    this.onChanged,
  });

  final ValueChanged<String>? onChanged;

  @override
  State createState() => _FilterUsersWidgetState();
}

class _FilterUsersWidgetState extends State<FilterUsersWidget> {
  FocusNode? _searchPartFocus;
  TextEditingController? _searchPartController;

  @override
  void initState() {
    super.initState();

    _searchPartFocus = FocusNode();
    _searchPartController = TextEditingController();
  }

  @override
  void dispose() {
    _searchPartFocus?.dispose();
    _searchPartController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        focusNode: _searchPartFocus,
        controller: _searchPartController,
        decoration: InputDecoration(
          labelText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact().ignore();
              _searchPartFocus!.unfocus();
              _searchPartController!.clear();
              widget.onChanged?.call('');
            },
            icon: const Icon(Icons.close),
          ),
        ),
        onChanged: (v) => widget.onChanged?.call(v),
      );
}
