// ignore_for_file: cascade_invocations

import 'dart:math' as math;
import 'dart:ui' as ui hide Size;

import 'package:flutter/rendering.dart' show BoxHitTestResult;
import 'package:flutter/widgets.dart';

/// {@template apple_logo}
/// AppleLogo widget.
/// {@endtemplate}
class AppleLogo extends LeafRenderObjectWidget implements PreferredSizeWidget {
  /// {@macro apple_logo}

  const AppleLogo({this.size = 48, super.key});

  /// The size of the logo.
  final double size;

  @override
  Size get preferredSize => Size.square(size);

  @override
  RenderObject createRenderObject(BuildContext context) => _AppleLogoRenderObject().._targetSize = Size.square(size);

  @override
  void updateRenderObject(BuildContext context, RenderBox renderObject) {
    if (renderObject is _AppleLogoRenderObject) renderObject._targetSize = Size.square(size);
  }
}

class _AppleLogoRenderObject extends RenderBox {
  static final ui.Picture _$logoPicture = () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size.square(128);
    final path_0 = Path();
    path_0.moveTo(size.width * 0.5450875, size.height * 0.2307692);
    path_0.cubicTo(
      size.width * 0.590225,
      size.height * 0.2307692,
      size.width * 0.6468042,
      size.height * 0.2002542,
      size.width * 0.6804958,
      size.height * 0.1595675,
    );
    path_0.cubicTo(
      size.width * 0.7110125,
      size.height * 0.1226954,
      size.width * 0.7332625,
      size.height * 0.07120167,
      size.width * 0.7332625,
      size.height * 0.01970758,
    );

    path_0.cubicTo(
      size.width * 0.7332625,
      size.height * 0.01271458,
      size.width * 0.732625,
      size.height * 0.005721542,
      size.width * 0.7313542,
      0,
    );
    path_0.cubicTo(
      size.width * 0.6811333,
      size.height * 0.001907183,
      size.width * 0.6207375,
      size.height * 0.03369358,
      size.width * 0.5845,
      size.height * 0.0762875,
    );
    path_0.cubicTo(
      size.width * 0.5558958,
      size.height * 0.1087096,
      size.width * 0.5298292,
      size.height * 0.1595679,
      size.width * 0.5298292,
      size.height * 0.2116975,
    );
    path_0.cubicTo(
      size.width * 0.5298292,
      size.height * 0.2193262,
      size.width * 0.5311,
      size.height * 0.226955,
      size.width * 0.5317375,
      size.height * 0.2294979,
    );
    path_0.cubicTo(
      size.width * 0.5349167,
      size.height * 0.2301333,
      size.width * 0.54,
      size.height * 0.2307692,
      size.width * 0.5450875,
      size.height * 0.2307692,
    );
    path_0.close();
    path_0.moveTo(size.width * 0.3861546, size.height);

    path_0.cubicTo(
      size.width * 0.4478208,
      size.height,
      size.width * 0.4751583,
      size.height * 0.9586792,
      size.width * 0.5520792,
      size.height * 0.9586792,
    );
    path_0.cubicTo(
      size.width * 0.630275,
      size.height * 0.9586792,
      size.width * 0.6474375,
      size.height * 0.9987292,
      size.width * 0.7160958,
      size.height * 0.9987292,
    );
    path_0.cubicTo(
      size.width * 0.7834833,
      size.height * 0.9987292,
      size.width * 0.8286208,
      size.height * 0.9364292,
      size.width * 0.8712167,
      size.height * 0.8753958,
    );
    path_0.cubicTo(
      size.width * 0.9188958,
      size.height * 0.8054667,
      size.width * 0.9386042,
      size.height * 0.7368083,
      size.width * 0.939875,
      size.height * 0.7336292,
    );
    path_0.cubicTo(
      size.width * 0.935425,
      size.height * 0.7323583,
      size.width * 0.8063708,
      size.height * 0.6795917,
      size.width * 0.8063708,
      size.height * 0.5314667,
    );

    path_0.cubicTo(
      size.width * 0.8063708,
      size.height * 0.4030517,
      size.width * 0.9080875,
      size.height * 0.3452004,
      size.width * 0.9138083,
      size.height * 0.34075,
    );
    path_0.cubicTo(
      size.width * 0.8464208,
      size.height * 0.2441196,
      size.width * 0.7440708,
      size.height * 0.2415767,
      size.width * 0.7160958,
      size.height * 0.2415767,
    );
    path_0.cubicTo(
      size.width * 0.6404458,
      size.height * 0.2415767,
      size.width * 0.5787792,
      size.height * 0.2873492,
      size.width * 0.54,
      size.height * 0.2873492,
    );
    path_0.cubicTo(
      size.width * 0.4980417,
      size.height * 0.2873492,
      size.width * 0.4427333,
      size.height * 0.2441196,
      size.width * 0.3772546,
      size.height * 0.2441196,
    );

    path_0.cubicTo(
      size.width * 0.2526517,
      size.height * 0.2441196,
      size.width * 0.1261417,
      size.height * 0.3471075,
      size.width * 0.1261417,
      size.height * 0.5416417,
    );
    path_0.cubicTo(
      size.width * 0.1261417,
      size.height * 0.6624292,
      size.width * 0.1731858,
      size.height * 0.7902083,
      size.width * 0.2310371,
      size.height * 0.8728542,
    );
    path_0.cubicTo(
      size.width * 0.2806238,
      size.height * 0.9427833,
      size.width * 0.3238533,
      size.height,
      size.width * 0.3861546,
      size.height,
    );
    path_0.close();
    final paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = const Color(0xFF000000);
    canvas.drawPath(path_0, paint0Fill);
    return recorder.endRecording();
  }();

  Size _targetSize = Size.zero;

  double _scale = 0.0;

  @override
  bool get isRepaintBoundary => false;

  @override
  bool get alwaysNeedsCompositing => false;

  @override
  bool get sizedByParent => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(_targetSize);

  @override
  void performLayout() {
    final size = super.size = computeDryLayout(constraints);
    _scale = math.min(size.width / 128, size.height / 128);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    final scale = _scale;
    final canvas = context.canvas..save();
    if (scale < 0.01) {
      // No need to paint if the scale is too small.
      return;
    } else if (scale < 1.0) {
      // Move the logo to the center of the box.
      canvas.translate(offset.dx + (size.width - scale * 128) / 2, offset.dy + (size.height - scale * 128) / 2);
    } else {
      // Move the logo to the top left corner of the box.
      canvas.translate(offset.dx, offset.dy);
    }
    canvas
      // ..clipRect(Offset.zero & size)
      ..scale(scale, scale)
      ..drawPicture(_$logoPicture)
      ..restore();
  }
}
