// ignore_for_file: cascade_invocations

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class AppLogoIcon extends LeafRenderObjectWidget implements PreferredSizeWidget {
  const AppLogoIcon({super.key, this.size = 48.0});

  /// The target width/height of the square frame.
  final double size;

  @override
  Size get preferredSize => Size.square(size);

  @override
  RenderObject createRenderObject(BuildContext context) => _AppLogoRenderObject()..targetSize = Size.square(size);

  @override
  void updateRenderObject(BuildContext context, covariant RenderBox renderObject) {
    if (renderObject is _AppLogoRenderObject) renderObject.targetSize = Size.square(size);
  }
}

class _AppLogoRenderObject extends RenderBox {
  static const double _baseSize = 100.0;

  static final ui.Picture _$logoPicture = () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    /// Draws the multi-part gradient frame at the given width, height, and corner radius.
    const minSide = _baseSize;
    const borderWidth = minSide * 0.065;
    const boxMinSide = minSide * 0.6;
    const bottomSpace = minSide - borderWidth * 2.3;
    const cornerRadius = borderWidth;

    // Precompute common gradient angle (−30.5° in radians) for parts A and B.
    const angleDeg = -30.5;
    const angleRad = angleDeg * math.pi / 180.0;
    final directionVec = Offset(math.cos(angleRad), math.sin(angleRad));

    // ** Part A **: A vertically oriented rounded rectangle (ring) at the top.
    const sizeA = Size(boxMinSide, bottomSpace);
    final xA = (minSide - sizeA.width) / 2; // center Part A horizontally
    final outerA = RRect.fromLTRBR(
      0,
      0,
      sizeA.width,
      sizeA.height - borderWidth / 3,
      const Radius.circular(cornerRadius),
    );
    final innerA = outerA.deflate(borderWidth);
    final ringPathA = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(outerA)
      ..addRRect(
        RRect.fromLTRBR(innerA.left, innerA.top, innerA.right, innerA.bottom + borderWidth, Radius.zero),
      );
    // Calculate linear gradient start and end points along directionVec for Part A's bounding box.
    final cornersA = <Offset>[
      Offset.zero,
      Offset(sizeA.width, 0),
      Offset(0, sizeA.height),
      Offset(sizeA.width, sizeA.height),
    ];
    var minProj = double.infinity, maxProj = -double.infinity;
    for (final c in cornersA) {
      final projection = c.dx * directionVec.dx + c.dy * directionVec.dy;
      if (projection < minProj) minProj = projection;
      if (projection > maxProj) maxProj = projection;
    }
    final startA = directionVec * minProj;
    final endA = directionVec * maxProj;
    // 7-color gradient (blue → purple → magenta → red → orange) for Part A.
    final paintA = Paint()
      ..shader = ui.Gradient.linear(
        startA,
        endA,
        const [
          Color(0xFF170AE8), // deep blue
          Color(0xFF5E22B9), // purple
          Color(0xFFA2398B), // magenta
          Color(0xFFD44A6A), // red-pink
          Color(0xFFF35556), // orange-red
          Color(0xFFFF594F), // bright red
          Color(0xFFFF594F), // repeated last color for a hard stop
        ],
        const [0.0, 0.17, 0.34, 0.49, 0.6, 0.66, 1.0],
        TileMode.clamp,
      );
    canvas.save();
    canvas.translate(xA, 0);
    canvas.drawPath(ringPathA, paintA);
    canvas.restore();

    // ** Part B **: A horizontally oriented rounded rectangle (ring) near the bottom.
    const sizeB = Size(minSide, boxMinSide);
    final yB = bottomSpace - sizeB.height; // vertical position for Part B
    final outerB = RRect.fromLTRBR(0, 0, sizeB.width, sizeB.height, const Radius.circular(cornerRadius));
    final innerB = outerB.deflate(borderWidth);
    final ringPathB = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(outerB)
      ..addRRect(innerB);
    // Calculate gradient start and end for Part B along the same angle.
    final cornersB = <Offset>[
      Offset.zero,
      Offset(sizeB.width, 0),
      Offset(0, sizeB.height),
      Offset(sizeB.width, sizeB.height),
    ];
    minProj = double.infinity;
    maxProj = -double.infinity;
    for (final c in cornersB) {
      final projection = c.dx * directionVec.dx + c.dy * directionVec.dy;
      if (projection < minProj) minProj = projection;
      if (projection > maxProj) maxProj = projection;
    }
    final startB = directionVec * minProj;
    final endB = directionVec * maxProj;
    // 5-color gradient (blue → teal → green → lime) for Part B.
    final paintB = Paint()
      ..shader = ui.Gradient.linear(
        startB,
        endB,
        const [
          Color(0xFF029FFF), // bright blue
          Color(0xFF029FFF), // same blue (sharp stop)
          Color(0xFF1DA9D5), // teal
          Color(0xFF62C26F), // green
          Color(0xFF8BD233), // lime
        ],
        const [0.0, 0.02, 0.24, 0.73, 1.0],
        TileMode.clamp,
      );
    canvas.save();
    canvas.translate(0, yB);
    canvas.drawPath(ringPathB, paintB);
    canvas.restore();

    // ** Part C **: A connecting line at the very bottom (gradient from blue to pink).
    final xLine = (minSide - sizeA.width) / 2 + borderWidth / 2;
    const yLine = minSide - borderWidth / 2;
    final startLine = Offset(xLine, yLine);
    final endLine = Offset(xLine + boxMinSide - borderWidth, yLine);
    final linePaint = Paint()
      ..shader = ui.Gradient.linear(
        startLine,
        endLine,
        const [
          Color(0xFF33AFFF), // blue
          Color(0xFFFF5E79), // pinkish red
        ],
        const [0.0, 1.0],
      )
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(startLine, endLine, linePaint);

    return recorder.endRecording();
  }();
  double _scale = 1.0;

  // Mark this render object as a repaint boundary to isolate its drawing for performance.
  @override
  bool get isRepaintBoundary => false;
  @override
  bool get alwaysNeedsCompositing => false;

  // This render object has no children.
  @override
  bool get sizedByParent => false;

  // Internal state fields.
  Size _targetSize = Size.zero;

  // The desired square size of the frame (from the widget).
  Size get targetSize => _targetSize;

  set targetSize(Size value) {
    if (_targetSize == value) return;
    _targetSize = value;
    // Size change requires a new layout calculation.
    markNeedsLayout();
  }

  // Determine the size this box would like to be, clamped by the incoming constraints.
  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(_targetSize);

  @override
  void performLayout() {
    // Set the actual size based on constraints and targetSize.
    size = computeDryLayout(constraints);
    // Compute scale factor relative to base design size, so the frame graphics scale with the widget.
    _scale = math.min(size.width / _baseSize, size.height / _baseSize);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    final scale = _scale;
    final canvas = context.canvas..save();

    // If the widget is extremely small, skip painting for efficiency.
    if (_scale < 0.01) {
      canvas.restore();
      return;
    }

    // Center the frame if scaled down; if at least base size or larger, align to top-left (as per original design).
    // if (_scale < 1.0) {
    canvas.translate(
      offset.dx + (size.width - _baseSize * _scale) / 2,
      offset.dy + (size.height - _baseSize * _scale) / 2,
    );
    // } else {
    //   canvas.translate(offset.dx, offset.dy);
    // }
    canvas
      // ..clipRect(Offset.zero & size)
      ..scale(scale, scale)
      ..drawPicture(_$logoPicture)
      ..restore();

    // Draw the gradient frame at the base size.
    // _paintAppLogo(canvas, _baseSize, _baseSize, _radius);

    // canvas.restore();
  }
}
