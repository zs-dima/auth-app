import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:ui/src/logo/app_logo_brand.dart';
import 'package:ui/src/logo/app_logo_icon.dart';
import 'package:ui/src/logo/app_logo_mission.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // Define base proportions (based on your current fixed values)
      const double baseWidth = 598; // 200 (icon) + 43 (gap) + 355 (brand/mission)
      const double baseHeight = 200; // Height of the icon

      // Calculate scale factor based on available space
      final availableWidth = constraints.maxWidth;
      final availableHeight = constraints.maxHeight;

      final scale = math.min(availableWidth / baseWidth, availableHeight / baseHeight);

      // Calculate responsive sizes
      final iconSize = scale * 200;
      final gapWidth = scale * 43;
      final textWidth = scale * 355;
      final textGapHeight = scale * 26;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogoIcon(size: iconSize),
          SizedBox(width: gapWidth),
          SizedBox(
            width: textWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppLogoBrand(width: textWidth),
                SizedBox(height: textGapHeight),
                AppLogoMission(width: textWidth),
              ],
            ),
          ),
        ],
      );
    },
  );
}
