// ignore_for_file: cascade_invocations

import 'dart:math' as math;
import 'dart:ui' as ui hide Size;

import 'package:flutter/rendering.dart' show BoxHitTestResult;
import 'package:flutter/widgets.dart';

/// {@template apple_logo}
/// AppLogoBrand widget.
/// {@endtemplate}
class AppLogoBrand extends LeafRenderObjectWidget implements PreferredSizeWidget {
  /// {@macro apple_logo}

  const AppLogoBrand({this.width = 48, super.key});

  static const double _heightScale = 0.3531669865642994;

  /// The size of the logo.
  final double width;

  @override
  Size get preferredSize => Size(width, width * _heightScale);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _AppLogoBrandRenderObject().._targetSize = Size(width, width * _heightScale);

  @override
  void updateRenderObject(BuildContext context, RenderBox renderObject) {
    if (renderObject is _AppLogoBrandRenderObject) renderObject._targetSize = Size(width, width * _heightScale);
  }
}

class _AppLogoBrandRenderObject extends RenderBox {
  static const Size _baseSize = Size(100.0, AppLogoBrand._heightScale * 100.0);

  static final ui.Picture _$logoPicture = () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = _baseSize;
    final path_0 = Path();
    path_0.moveTo(size.width * 0.9662188, size.height * 0.9626087);
    path_0.lineTo(size.width * 0.8416891, size.height * 0.02688406);
    path_0.arcToPoint(
      Offset(size.width * 0.8372873, size.height * 0.01826087),
      radius: Radius.elliptical(size.width * 0.004683301, size.height * 0.01326087),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 0.7639667, size.height * 0.01826087);
    path_0.cubicTo(
      size.width * 0.7617402,
      size.height * 0.01826087,
      size.width * 0.7597697,
      size.height * 0.02210145,
      size.width * 0.7590019,
      size.height * 0.02797101,
    );
    path_0.lineTo(size.width * 0.6346257, size.height * 0.9625362);
    path_0.arcToPoint(
      Offset(size.width * 0.6385413, size.height * 0.9786232),
      radius: Radius.elliptical(size.width * 0.004197057, size.height * 0.01188406),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 0.7228407, size.height * 0.9786232);
    path_0.cubicTo(
      size.width * 0.7246321,
      size.height * 0.9786232,
      size.width * 0.7262444,
      size.height * 0.9753623,
      size.width * 0.7268074,
      size.height * 0.9705072,
    );
    path_0.lineTo(size.width * 0.7446449, size.height * 0.8172464);
    path_0.cubicTo(
      size.width * 0.7452079,
      size.height * 0.8123188,
      size.width * 0.7468458,
      size.height * 0.8089855,
      size.width * 0.7486628,
      size.height * 0.8089855,
    );
    path_0.lineTo(size.width * 0.8521305, size.height * 0.8089855);
    path_0.cubicTo(
      size.width * 0.8539475,
      size.height * 0.8089855,
      size.width * 0.8555598,
      size.height * 0.8122464,
      size.width * 0.8561228,
      size.height * 0.8171739,
    );
    path_0.lineTo(size.width * 0.8737556, size.height * 0.9686957);
    path_0.arcToPoint(
      Offset(size.width * 0.878618, size.height * 0.9786232),
      radius: Radius.elliptical(size.width * 0.005118362, size.height * 0.01449275),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 0.9622521, size.height * 0.9786232);
    path_0.arcToPoint(
      Offset(size.width * 0.9661676, size.height * 0.9625362),
      radius: Radius.elliptical(size.width * 0.004197057, size.height * 0.01188406),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.moveTo(size.width * 0.8264875, size.height * 0.612971);
    path_0.lineTo(size.width * 0.7742035, size.height * 0.612971);
    path_0.arcToPoint(
      Offset(size.width * 0.7702623, size.height * 0.5975362),
      radius: Radius.elliptical(size.width * 0.004145873, size.height * 0.01173913),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.lineTo(size.width * 0.7963404, size.height * 0.3735507);
    path_0.arcToPoint(
      Offset(size.width * 0.8045042, size.height * 0.3735507),
      radius: Radius.elliptical(size.width * 0.004299424, size.height * 0.01217391),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.lineTo(size.width * 0.8305566, size.height * 0.5971739);
    path_0.arcToPoint(
      Offset(size.width * 0.8265131, size.height * 0.6130435),
      radius: Radius.elliptical(size.width * 0.004273832, size.height * 0.01210145),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.moveTo(size.width * 1.22009, size.height * 0.02072464);
    path_0.lineTo(size.width * 1.148509, size.height * 0.02072464);
    path_0.cubicTo(
      size.width * 1.146257,
      size.height * 0.02072464,
      size.width * 1.144415,
      size.height * 0.02586957,
      size.width * 1.144415,
      size.height * 0.03231884,
    );
    path_0.lineTo(size.width * 1.144415, size.height * 0.2828986);
    path_0.arcToPoint(
      Offset(size.width * 1.141344, size.height * 0.2878986),
      radius: Radius.elliptical(size.width * 0.002047345, size.height * 0.005797101),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.073858, size.height * 0.2378261),
      radius: Radius.elliptical(size.width * 0.1370186, size.height * 0.387971),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.cubicTo(
      size.width * 0.9988484,
      size.height * 0.2378261,
      size.width * 0.9378375,
      size.height * 0.4081884,
      size.width * 0.9378375,
      size.height * 0.6176087,
    );
    path_0.cubicTo(
      size.width * 0.9378375,
      size.height * 0.827029,
      size.width * 0.9988484,
      size.height * 0.9974638,
      size.width * 1.073858,
      size.height * 0.9974638,
    );
    path_0.cubicTo(
      size.width * 1.097658,
      size.height * 0.9974638,
      size.width * 1.120845,
      size.height * 0.9802174,
      size.width * 1.141344,
      size.height * 0.9473188,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.144415, size.height * 0.9523188),
      radius: Radius.elliptical(size.width * 0.002047345, size.height * 0.005797101),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.lineTo(size.width * 1.144415, size.height * 0.9630435);
    path_0.cubicTo(
      size.width * 1.144415,
      size.height * 0.9694203,
      size.width * 1.146257,
      size.height * 0.9746377,
      size.width * 1.148509,
      size.height * 0.9746377,
    );
    path_0.lineTo(size.width * 1.22009, size.height * 0.9746377);
    path_0.cubicTo(
      size.width * 1.222342,
      size.height * 0.9746377,
      size.width * 1.224184,
      size.height * 0.9694203,
      size.width * 1.224184,
      size.height * 0.9630435,
    );
    path_0.lineTo(size.width * 1.224184, size.height * 0.03224638);
    path_0.cubicTo(
      size.width * 1.224184,
      size.height * 0.02586957,
      size.width * 1.222367,
      size.height * 0.02065217,
      size.width * 1.22009,
      size.height * 0.02065217,
    );
    path_0.moveTo(size.width * 1.086116, size.height * 0.7917391);
    path_0.cubicTo(
      size.width * 1.051721,
      size.height * 0.7917391,
      size.width * 1.023749,
      size.height * 0.7136232,
      size.width * 1.023749,
      size.height * 0.6175362,
    );
    path_0.cubicTo(
      size.width * 1.023749,
      size.height * 0.5214493,
      size.width * 1.051721,
      size.height * 0.4433333,
      size.width * 1.086116,
      size.height * 0.4433333,
    );
    path_0.cubicTo(
      size.width * 1.120512,
      size.height * 0.4433333,
      size.width * 1.144415,
      size.height * 0.5214493,
      size.width * 1.144415,
      size.height * 0.6175362,
    );
    path_0.cubicTo(
      size.width * 1.144415,
      size.height * 0.7136232,
      size.width * 1.120537,
      size.height * 0.7917391,
      size.width * 1.086116,
      size.height * 0.7917391,
    );
    path_0.moveTo(size.width * 1.367166, size.height * 0.7863043);
    path_0.lineTo(size.width * 1.353244, size.height * 0.7863043);
    path_0.cubicTo(
      size.width * 1.345643,
      size.height * 0.7863043,
      size.width * 1.339962,
      size.height * 0.780942,
      size.width * 1.336302,
      size.height * 0.7704348,
    );
    path_0.cubicTo(
      size.width * 1.330058,
      size.height * 0.7523913,
      size.width * 1.33039,
      size.height * 0.7222464,
      size.width * 1.330672,
      size.height * 0.7001449,
    );
    path_0.lineTo(size.width * 1.330723, size.height * 0.6951449);
    path_0.lineTo(size.width * 1.330749, size.height * 0.4551449);
    path_0.cubicTo(
      size.width * 1.330749,
      size.height * 0.4487681,
      size.width * 1.332591,
      size.height * 0.4436232,
      size.width * 1.334843,
      size.height * 0.4436232,
    );
    path_0.lineTo(size.width * 1.361433, size.height * 0.4436232);
    path_0.cubicTo(
      size.width * 1.363685,
      size.height * 0.4436232,
      size.width * 1.365528,
      size.height * 0.4384058,
      size.width * 1.365528,
      size.height * 0.432029,
    );
    path_0.lineTo(size.width * 1.365528, size.height * 0.2604348);
    path_0.cubicTo(
      size.width * 1.365528,
      size.height * 0.254058,
      size.width * 1.363685,
      size.height * 0.2488406,
      size.width * 1.361433,
      size.height * 0.2488406,
    );
    path_0.lineTo(size.width * 1.334843, size.height * 0.2488406);
    path_0.arcToPoint(
      Offset(size.width * 1.330749, size.height * 0.2372464),
      radius: Radius.elliptical(size.width * 0.00409469, size.height * 0.0115942),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.lineTo(size.width * 1.330749, size.height * 0.03826087);
    path_0.cubicTo(
      size.width * 1.330749,
      size.height * 0.03188406,
      size.width * 1.328906,
      size.height * 0.02666667,
      size.width * 1.326654,
      size.height * 0.02666667,
    );
    path_0.lineTo(size.width * 1.255074, size.height * 0.02666667);
    path_0.cubicTo(
      size.width * 1.252821,
      size.height * 0.02666667,
      size.width * 1.250979,
      size.height * 0.03188406,
      size.width * 1.250979,
      size.height * 0.03826087,
    );
    path_0.lineTo(size.width * 1.250979, size.height * 0.2372464);
    path_0.cubicTo(
      size.width * 1.250979,
      size.height * 0.2436232,
      size.width * 1.249136,
      size.height * 0.2488406,
      size.width * 1.246884,
      size.height * 0.2488406,
    );
    path_0.lineTo(size.width * 1.220294, size.height * 0.2488406);
    path_0.cubicTo(
      size.width * 1.218042,
      size.height * 0.2488406,
      size.width * 1.2162,
      size.height * 0.254058,
      size.width * 1.2162,
      size.height * 0.2604348,
    );
    path_0.lineTo(size.width * 1.2162, size.height * 0.432029);
    path_0.cubicTo(
      size.width * 1.2162,
      size.height * 0.4384058,
      size.width * 1.218042,
      size.height * 0.4436232,
      size.width * 1.220294,
      size.height * 0.4436232,
    );
    path_0.lineTo(size.width * 1.246884, size.height * 0.4436232);
    path_0.cubicTo(
      size.width * 1.249136,
      size.height * 0.4436232,
      size.width * 1.250979,
      size.height * 0.4488406,
      size.width * 1.250979,
      size.height * 0.4552174,
    );
    path_0.lineTo(size.width * 1.250979, size.height * 0.8034783);
    path_0.cubicTo(
      size.width * 1.250979,
      size.height * 0.9165942,
      size.width * 1.273986,
      size.height * 0.9797826,
      size.width * 1.317466,
      size.height * 0.9862319,
    );
    path_0.lineTo(size.width * 1.318848, size.height * 0.9863043);
    path_0.cubicTo(
      size.width * 1.325988,
      size.height * 0.9863043,
      size.width * 1.349456,
      size.height * 0.9825362,
      size.width * 1.358234,
      size.height * 0.981087,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.362022, size.height * 0.9712319),
      radius: Radius.elliptical(size.width * 0.00409469, size.height * 0.0115942),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.371184, size.height * 0.7996377);
    path_0.arcToPoint(
      Offset(size.width * 1.36714, size.height * 0.7863043),
      radius: Radius.elliptical(size.width * 0.00409469, size.height * 0.0115942),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.moveTo(size.width * 1.629123, size.height * 0.5105797);
    path_0.arcToPoint(
      Offset(size.width * 1.617172, size.height * 0.4317391),
      radius: Radius.elliptical(size.width * 0.1320537, size.height * 0.373913),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.617223, size.height * 0.4317391);
    path_0.lineTo(size.width * 1.614715, size.height * 0.4199275);
    path_0.arcToPoint(
      Offset(size.width * 1.612821, size.height * 0.4115217),
      radius: Radius.elliptical(size.width * 0.1169546, size.height * 0.3311594),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.611363, size.height * 0.4052174);
    path_0.cubicTo(
      size.width * 1.610621,
      size.height * 0.402029,
      size.width * 1.609827,
      size.height * 0.398913,
      size.width * 1.609008,
      size.height * 0.3958696,
    );
    path_0.lineTo(size.width * 1.608855, size.height * 0.3953623);
    path_0.arcToPoint(
      Offset(size.width * 1.605809, size.height * 0.384058),
      radius: Radius.elliptical(size.width * 0.1635317, size.height * 0.4630435),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.604965, size.height * 0.381087);
    path_0.lineTo(size.width * 1.602252, size.height * 0.3718841);
    path_0.lineTo(size.width * 1.601536, size.height * 0.3695652);
    path_0.lineTo(size.width * 1.6, size.height * 0.3733333);
    path_0.lineTo(size.width * 1.601331, size.height * 0.368913);
    path_0.arcToPoint(
      Offset(size.width * 1.596647, size.height * 0.3546377),
      radius: Radius.elliptical(size.width * 0.154984, size.height * 0.4388406),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.595829, size.height * 0.3522464);
    path_0.cubicTo(
      size.width * 1.594754,
      size.height * 0.3492029,
      size.width * 1.593679,
      size.height * 0.3462319,
      size.width * 1.592578,
      size.height * 0.3433333,
    );
    path_0.lineTo(size.width * 1.59222, size.height * 0.3423913);
    path_0.cubicTo(
      size.width * 1.590864,
      size.height * 0.3386957,
      size.width * 1.589482,
      size.height * 0.3351449,
      size.width * 1.588023,
      size.height * 0.3317391,
    );
    path_0.lineTo(size.width * 1.586948, size.height * 0.3291304);
    path_0.cubicTo(
      size.width * 1.585054,
      size.height * 0.3245652,
      size.width * 1.583237,
      size.height * 0.3204348,
      size.width * 1.581369,
      size.height * 0.3164493,
    );
    path_0.lineTo(size.width * 1.580064, size.height * 0.3136957);
    path_0.lineTo(size.width * 1.579706, size.height * 0.312971);
    path_0.arcToPoint(
      Offset(size.width * 1.572949, size.height * 0.2997826),
      radius: Radius.elliptical(size.width * 0.1417786, size.height * 0.4014493),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.572668, size.height * 0.2992754);
    path_0.arcToPoint(
      Offset(size.width * 1.564402, size.height * 0.2853623),
      radius: Radius.elliptical(size.width * 0.2264363, size.height * 0.6411594),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.562534, size.height * 0.2825362);
    path_0.lineTo(size.width * 1.561459, size.height * 0.2874638);
    path_0.lineTo(size.width * 1.562303, size.height * 0.2822464);
    path_0.lineTo(size.width * 1.561945, size.height * 0.2817391);
    path_0.lineTo(size.width * 1.558695, size.height * 0.277029);
    path_0.lineTo(size.width * 1.558106, size.height * 0.2762319);
    path_0.cubicTo(
      size.width * 1.555752,
      size.height * 0.2730435,
      size.width * 1.553423,
      size.height * 0.2700725,
      size.width * 1.551222,
      size.height * 0.2674638,
    );
    path_0.lineTo(size.width * 1.550557, size.height * 0.2666667);
    path_0.lineTo(size.width * 1.546308, size.height * 0.2619565);
    path_0.lineTo(size.width * 1.544773, size.height * 0.2604348);
    path_0.cubicTo(
      size.width * 1.543109,
      size.height * 0.2587681,
      size.width * 1.541446,
      size.height * 0.2571739,
      size.width * 1.539655,
      size.height * 0.2555797,
    );
    path_0.lineTo(size.width * 1.539347, size.height * 0.2552899);
    path_0.cubicTo(
      size.width * 1.537582,
      size.height * 0.2537681,
      size.width * 1.535688,
      size.height * 0.2522464,
      size.width * 1.533512,
      size.height * 0.2506522,
    );
    path_0.lineTo(size.width * 1.531849, size.height * 0.2494203);
    path_0.arcToPoint(
      Offset(size.width * 1.520256, size.height * 0.2428261),
      radius: Radius.elliptical(size.width * 0.1366347, size.height * 0.3868841),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.518618, size.height * 0.2421014);
    path_0.arcToPoint(
      Offset(size.width * 1.506411, size.height * 0.2386232),
      radius: Radius.elliptical(size.width * 0.1576456, size.height * 0.4463768),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.504901, size.height * 0.2384058);
    path_0.arcToPoint(
      Offset(size.width * 1.492386, size.height * 0.2384058),
      radius: Radius.elliptical(size.width * 0.1413692, size.height * 0.4002899),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.490902, size.height * 0.2386232);
    path_0.lineTo(size.width * 1.490544, size.height * 0.2386232);
    path_0.lineTo(size.width * 1.485937, size.height * 0.2396377);
    path_0.lineTo(size.width * 1.485451, size.height * 0.2397826);
    path_0.lineTo(size.width * 1.484095, size.height * 0.2401449);
    path_0.cubicTo(
      size.width * 1.481868,
      size.height * 0.2407971,
      size.width * 1.479898,
      size.height * 0.2415217,
      size.width * 1.478132,
      size.height * 0.2422464,
    );
    path_0.lineTo(size.width * 1.478004, size.height * 0.2422464);
    path_0.lineTo(size.width * 1.477671, size.height * 0.2423913);
    path_0.cubicTo(
      size.width * 1.47588,
      size.height * 0.2431884,
      size.width * 1.472988,
      size.height * 0.2446377,
      size.width * 1.471222,
      size.height * 0.2457246,
    );
    path_0.lineTo(size.width * 1.470198, size.height * 0.2463043);
    path_0.lineTo(size.width * 1.465797, size.height * 0.2491304);
    path_0.lineTo(size.width * 1.465336, size.height * 0.2494203);
    path_0.arcToPoint(
      Offset(size.width * 1.458221, size.height * 0.2549275),
      radius: Radius.elliptical(size.width * 0.09663468, size.height * 0.2736232),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.cubicTo(
      size.width * 1.456302,
      size.height * 0.2565942,
      size.width * 1.454434,
      size.height * 0.2584058,
      size.width * 1.45254,
      size.height * 0.2602899,
    );
    path_0.lineTo(size.width * 1.45126, size.height * 0.2615942);
    path_0.lineTo(size.width * 1.450877, size.height * 0.262029);
    path_0.lineTo(size.width * 1.446756, size.height * 0.2665217);
    path_0.lineTo(size.width * 1.446372, size.height * 0.2669565);
    path_0.lineTo(size.width * 1.445118, size.height * 0.2684058);
    path_0.arcToPoint(
      Offset(size.width * 1.434447, size.height * 0.2828261),
      radius: Radius.elliptical(size.width * 0.126142, size.height * 0.3571739),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.433218, size.height * 0.2847101);
    path_0.lineTo(size.width * 1.432885, size.height * 0.2852174);
    path_0.cubicTo(
      size.width * 1.431606,
      size.height * 0.2871739,
      size.width * 1.430352,
      size.height * 0.2892029,
      size.width * 1.429098,
      size.height * 0.2913043,
    );
    path_0.lineTo(size.width * 1.427588, size.height * 0.2938406);
    path_0.cubicTo(
      size.width * 1.425925,
      size.height * 0.2967391,
      size.width * 1.424261,
      size.height * 0.2996377,
      size.width * 1.422649,
      size.height * 0.3026812,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.379399, size.height * 0.435),
      radius: Radius.elliptical(size.width * 0.1364555, size.height * 0.3863768),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.378221, size.height * 0.4411594);
    path_0.lineTo(size.width * 1.37753, size.height * 0.4447101);
    path_0.lineTo(size.width * 1.376916, size.height * 0.4481884);
    path_0.lineTo(size.width * 1.376404, size.height * 0.451087);
    path_0.lineTo(size.width * 1.37579, size.height * 0.4546377);
    path_0.arcToPoint(
      Offset(size.width * 1.369469, size.height * 0.4986957),
      radius: Radius.elliptical(size.width * 0.1372489, size.height * 0.3886232),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.3654, size.height * 0.6942029),
      radius: Radius.elliptical(size.width * 0.1320537, size.height * 0.373913),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.369469, size.height * 0.7365217),
      radius: Radius.elliptical(size.width * 0.121382, size.height * 0.3436957),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.376251, size.height * 0.7834058),
      radius: Radius.elliptical(size.width * 0.1303647, size.height * 0.3691304),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.376891, size.height * 0.7869565);
    path_0.lineTo(size.width * 1.377274, size.height * 0.7891304);
    path_0.cubicTo(
      size.width * 1.377991,
      size.height * 0.7930435,
      size.width * 1.378708,
      size.height * 0.797029,
      size.width * 1.379475,
      size.height * 0.8008696,
    );
    path_0.lineTo(size.width * 1.379834, size.height * 0.8027536);
    path_0.arcToPoint(
      Offset(size.width * 1.427562, size.height * 0.9414493),
      radius: Radius.elliptical(size.width * 0.1361484, size.height * 0.3855072),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.429072, size.height * 0.9439855);
    path_0.cubicTo(
      size.width * 1.430326,
      size.height * 0.946087,
      size.width * 1.43158,
      size.height * 0.9481159,
      size.width * 1.43286,
      size.height * 0.9500725,
    );
    path_0.lineTo(size.width * 1.433193, size.height * 0.9505797);
    path_0.lineTo(size.width * 1.434421, size.height * 0.9524638);
    path_0.cubicTo(
      size.width * 1.436161,
      size.height * 0.9550725,
      size.width * 1.437901,
      size.height * 0.9576087,
      size.width * 1.439514,
      size.height * 0.9597826,
    );
    path_0.lineTo(size.width * 1.439718, size.height * 0.9600725);
    path_0.arcToPoint(
      Offset(size.width * 1.446372, size.height * 0.9683333),
      radius: Radius.elliptical(size.width * 0.1446449, size.height * 0.4095652),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.446756, size.height * 0.9687681);
    path_0.cubicTo(
      size.width * 1.448113,
      size.height * 0.9703623,
      size.width * 1.449495,
      size.height * 0.9718116,
      size.width * 1.450877,
      size.height * 0.9732609,
    );
    path_0.lineTo(size.width * 1.451209, size.height * 0.9736232);
    path_0.lineTo(size.width * 1.45254, size.height * 0.975);
    path_0.arcToPoint(
      Offset(size.width * 1.46531, size.height * 0.9858696),
      radius: Radius.elliptical(size.width * 0.1241971, size.height * 0.3516667),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.465771, size.height * 0.9862319);
    path_0.cubicTo(
      size.width * 1.46723,
      size.height * 0.9872464,
      size.width * 1.468688,
      size.height * 0.9881884,
      size.width * 1.470173,
      size.height * 0.989058,
    );
    path_0.lineTo(size.width * 1.471939, size.height * 0.9900725);
    path_0.cubicTo(
      size.width * 1.473576,
      size.height * 0.9910145,
      size.width * 1.475214,
      size.height * 0.9918841,
      size.width * 1.476878,
      size.height * 0.9926087,
    );
    path_0.lineTo(size.width * 1.477953, size.height * 0.9931159);
    path_0.lineTo(size.width * 1.478106, size.height * 0.9931159);
    path_0.cubicTo(
      size.width * 1.479898,
      size.height * 0.9938406,
      size.width * 1.481868,
      size.height * 0.9945652,
      size.width * 1.484069,
      size.height * 0.9952174,
    );
    path_0.lineTo(size.width * 1.485425, size.height * 0.9955797);
    path_0.lineTo(size.width * 1.485912, size.height * 0.9957246);
    path_0.cubicTo(
      size.width * 1.487447,
      size.height * 0.9961594,
      size.width * 1.488983,
      size.height * 0.9964493,
      size.width * 1.490518,
      size.height * 0.9966667,
    );
    path_0.lineTo(size.width * 1.490979, size.height * 0.9966667);
    path_0.cubicTo(
      size.width * 1.49144,
      size.height * 0.9968841,
      size.width * 1.4919,
      size.height * 0.9968841,
      size.width * 1.492386,
      size.height * 0.9969565,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.504978, size.height * 0.9969565),
      radius: Radius.elliptical(size.width * 0.1446705, size.height * 0.4096377),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.506488, size.height * 0.9967391);
    path_0.cubicTo(
      size.width * 1.510531,
      size.height * 0.996087,
      size.width * 1.514626,
      size.height * 0.9949275,
      size.width * 1.518772,
      size.height * 0.9932609,
    );
    path_0.lineTo(size.width * 1.520256, size.height * 0.9926087);
    path_0.cubicTo(
      size.width * 1.524146,
      size.height * 0.9908696,
      size.width * 1.528061,
      size.height * 0.9886232,
      size.width * 1.531951,
      size.height * 0.985942,
    );
    path_0.lineTo(size.width * 1.533512, size.height * 0.9848551);
    path_0.cubicTo(
      size.width * 1.535713,
      size.height * 0.9832609,
      size.width * 1.537633,
      size.height * 0.9817391,
      size.width * 1.53945,
      size.height * 0.9801449,
    );
    path_0.lineTo(size.width * 1.539757, size.height * 0.9798551);
    path_0.arcToPoint(
      Offset(size.width * 1.544824, size.height * 0.9750725),
      radius: Radius.elliptical(size.width * 0.1678823, size.height * 0.4753623),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.546488, size.height * 0.9733333);
    path_0.lineTo(size.width * 1.550761, size.height * 0.9686232);
    path_0.lineTo(size.width * 1.551222, size.height * 0.9681159);
    path_0.cubicTo(
      size.width * 1.5535,
      size.height * 0.9654348,
      size.width * 1.555777,
      size.height * 0.9625362,
      size.width * 1.558209,
      size.height * 0.9592754,
    );
    path_0.lineTo(size.width * 1.558848, size.height * 0.9584783);
    path_0.lineTo(size.width * 1.562175, size.height * 0.9537681);
    path_0.lineTo(size.width * 1.56261, size.height * 0.9531159);
    path_0.lineTo(size.width * 1.564479, size.height * 0.9502899);
    path_0.lineTo(size.width * 1.565221, size.height * 0.949058);
    path_0.arcToPoint(
      Offset(size.width * 1.572873, size.height * 0.936087),
      radius: Radius.elliptical(size.width * 0.1373001, size.height * 0.3887681),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.573487, size.height * 0.9349275);
    path_0.cubicTo(
      size.width * 1.575688,
      size.height * 0.9308696,
      size.width * 1.577837,
      size.height * 0.9266667,
      size.width * 1.579962,
      size.height * 0.9222464,
    );
    path_0.lineTo(size.width * 1.581497, size.height * 0.919058);
    path_0.arcToPoint(
      Offset(size.width * 1.587025, size.height * 0.9065217),
      radius: Radius.elliptical(size.width * 0.1230966, size.height * 0.3485507),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.585694, size.height * 0.9021739);
    path_0.lineTo(size.width * 1.587255, size.height * 0.9060145);
    path_0.lineTo(size.width * 1.588612, size.height * 0.9027536);
    path_0.cubicTo(
      size.width * 1.589866,
      size.height * 0.8997101,
      size.width * 1.591094,
      size.height * 0.8965942,
      size.width * 1.592297,
      size.height * 0.8933333,
    );
    path_0.lineTo(size.width * 1.59263, size.height * 0.8924638);
    path_0.lineTo(size.width * 1.595905, size.height * 0.8834058);
    path_0.lineTo(size.width * 1.596827, size.height * 0.8807246);
    path_0.cubicTo(
      size.width * 1.59849,
      size.height * 0.875942,
      size.width * 1.599974,
      size.height * 0.8713043,
      size.width * 1.60151,
      size.height * 0.8664493,
    );
    path_0.lineTo(size.width * 1.602303, size.height * 0.8637681);
    path_0.lineTo(size.width * 1.605118, size.height * 0.8542754);
    path_0.lineTo(size.width * 1.605886, size.height * 0.8515942);
    path_0.lineTo(size.width * 1.607345, size.height * 0.8462319);
    path_0.lineTo(size.width * 1.607422, size.height * 0.8462319);
    path_0.lineTo(size.width * 1.608292, size.height * 0.842971);
    path_0.arcToPoint(
      Offset(size.width * 1.616225, size.height * 0.809058),
      radius: Radius.elliptical(size.width * 0.1373768, size.height * 0.3889855),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.617377, size.height * 0.8037681);
    path_0.lineTo(size.width * 1.617326, size.height * 0.8037681);
    path_0.cubicTo(
      size.width * 1.618477,
      size.height * 0.797971,
      size.width * 1.620397,
      size.height * 0.7866667,
      size.width * 1.621958,
      size.height * 0.7775362,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.618989, size.height * 0.7611594),
      radius: Radius.elliptical(size.width * 0.00409469, size.height * 0.0115942),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.lineTo(size.width * 1.550275, size.height * 0.7261594);
    path_0.cubicTo(
      size.width * 1.548765,
      size.height * 0.7254348,
      size.width * 1.547255,
      size.height * 0.7271739,
      size.width * 1.546308,
      size.height * 0.7305797,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.49817, size.height * 0.7982609),
      radius: Radius.elliptical(size.width * 0.06021753, size.height * 0.1705072),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.445605, size.height * 0.7123913),
      radius: Radius.elliptical(size.width * 0.06095969, size.height * 0.1726087),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.449136, size.height * 0.6947826),
      radius: Radius.elliptical(size.width * 0.00409469, size.height * 0.0115942),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.lineTo(size.width * 1.628535, size.height * 0.6947826);
    path_0.arcToPoint(
      Offset(size.width * 1.632578, size.height * 0.6851449),
      radius: Radius.elliptical(size.width * 0.00409469, size.height * 0.0115942),
      rotation: 0,
      largeArc: false,
      clockwise: false,
    );
    path_0.cubicTo(
      size.width * 1.633909,
      size.height * 0.6632609,
      size.width * 1.634779,
      size.height * 0.6386232,
      size.width * 1.634779,
      size.height * 0.6176812,
    );
    path_0.cubicTo(
      size.width * 1.634779,
      size.height * 0.5814493,
      size.width * 1.632911,
      size.height * 0.5453623,
      size.width * 1.629226,
      size.height * 0.5104348,
    );
    path_0.moveTo(size.width * 1.55048, size.height * 0.5351449);
    path_0.lineTo(size.width * 1.453001, size.height * 0.5351449);
    path_0.cubicTo(
      size.width * 1.450441,
      size.height * 0.5351449,
      size.width * 1.448496,
      size.height * 0.5284783,
      size.width * 1.448957,
      size.height * 0.5213768,
    );
    path_0.cubicTo(
      size.width * 1.452514,
      size.height * 0.4678261,
      size.width * 1.476494,
      size.height * 0.4264493,
      size.width * 1.501727,
      size.height * 0.4264493,
    );
    path_0.cubicTo(
      size.width * 1.529495,
      size.height * 0.4264493,
      size.width * 1.551324,
      size.height * 0.4681159,
      size.width * 1.554523,
      size.height * 0.5215942,
    );
    path_0.arcToPoint(
      Offset(size.width * 1.55048, size.height * 0.5351449),
      radius: Radius.elliptical(size.width * 0.00409469, size.height * 0.0115942),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );

    final paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = const Color(0xffffffff);
    canvas.translate(-_baseSize.width * 0.635, 0);
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
    _scale = math.min(size.width / _baseSize.width, size.height / _baseSize.height);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    final scale = _scale;
    final canvas = context.canvas..save();
    if (scale < 0.1) {
      // No need to paint if the scale is too small.
      return;
    } // if (scale < 1.0) {
    // Move the logo to the center of the box.
    canvas.translate(
      offset.dx + (size.width - _baseSize.width * scale) / 2,
      offset.dy + (size.height - _baseSize.height * scale) / 2,
    );
    // else {
    //   // Move the logo to the top left corner of the box.
    //   canvas.translate(offset.dx, offset.dy);
    // }
    canvas
      // ..clipRect(Offset.zero & size)
      ..scale(scale, scale)
      ..drawPicture(_$logoPicture)
      ..restore();
  }
}
