// ignore_for_file: cascade_invocations

import 'dart:math' as math;
import 'dart:ui' as ui hide Size;

import 'package:flutter/rendering.dart' show BoxHitTestResult;
import 'package:flutter/widgets.dart';

/// {@template apple_logo}
/// AppLogoMission widget.
/// {@endtemplate}
class AppLogoMission extends LeafRenderObjectWidget implements PreferredSizeWidget {
  /// {@macro apple_logo}

  const AppLogoMission({this.width = 48, super.key});

  static const double _heightScale = 0.13;

  /// The size of the logo.
  final double width;

  @override
  Size get preferredSize => Size(width, width * _heightScale);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _AppLogoMissionRenderObject().._targetSize = Size(width, width * _heightScale);

  @override
  void updateRenderObject(BuildContext context, RenderBox renderObject) {
    if (renderObject is _AppLogoMissionRenderObject) renderObject._targetSize = Size(width, width * _heightScale);
  }
}

class _AppLogoMissionRenderObject extends RenderBox {
  static const Size _baseSize = Size(100.0, AppLogoMission._heightScale * 100.0); //

  static final ui.Picture _$logoPicture = () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = _baseSize;
    final path_0 = Path();

    path_0.moveTo(size.width * 0.6357774, size.height * 0.9070442);
    path_0.lineTo(size.width * 0.6419706, size.height * 0.901105);
    path_0.lineTo(size.width * 0.642508, size.height * 0.901105);
    path_0.cubicTo(
      size.width * 0.6438388,
      size.height * 0.9269337,
      size.width * 0.6563532,
      size.height * 0.9442449,
      size.width * 0.6711196,
      size.height * 0.9442449,
    );
    path_0.cubicTo(
      size.width * 0.6869354,
      size.height * 0.9442449,
      size.width * 0.6969674,
      size.height * 0.9302486,
      size.width * 0.6969674,
      size.height * 0.9096225,
    );
    path_0.cubicTo(
      size.width * 0.6969674,
      size.height * 0.890884,
      size.width * 0.6903903,
      size.height * 0.8804788,
      size.width * 0.6807678,
      size.height * 0.8752302,
    );
    path_0.lineTo(size.width * 0.6608573, size.height * 0.8645488);
    path_0.cubicTo(
      size.width * 0.6493922,
      size.height * 0.8583794,
      size.width * 0.6397697,
      size.height * 0.847698,
      size.width * 0.6397697,
      size.height * 0.8225599,
    );
    path_0.cubicTo(
      size.width * 0.6397697,
      size.height * 0.7974217,
      size.width * 0.6520282,
      size.height * 0.7798803,
      size.width * 0.6707358,
      size.height * 0.7798803,
    );
    path_0.cubicTo(
      size.width * 0.6880102,
      size.height * 0.7798803,
      size.width * 0.6998592,
      size.height * 0.7967311,
      size.width * 0.7021113,
      size.height * 0.8194751,
    );
    path_0.lineTo(size.width * 0.696174, size.height * 0.8251842);
    path_0.lineTo(size.width * 0.6956366, size.height * 0.8251842);
    path_0.cubicTo(
      size.width * 0.6935381,
      size.height * 0.803361,
      size.width * 0.6840435,
      size.height * 0.7912523,
      size.width * 0.6707102,
      size.height * 0.7912523,
    );
    path_0.cubicTo(
      size.width * 0.6556878,
      size.height * 0.7912523,
      size.width * 0.6471145,
      size.height * 0.803361,
      size.width * 0.6471145,
      size.height * 0.8225599,
    );
    path_0.cubicTo(
      size.width * 0.6471145,
      size.height * 0.8394107,
      size.width * 0.6535637,
      size.height * 0.8472376,
      size.width * 0.6628023,
      size.height * 0.8522099,
    );
    path_0.lineTo(size.width * 0.6830966, size.height * 0.8631215);
    path_0.cubicTo(
      size.width * 0.6950992,
      size.height * 0.8695212,
      size.width * 0.7043122,
      size.height * 0.8825506,
      size.width * 0.7043122,
      size.height * 0.9098527,
    );
    path_0.cubicTo(
      size.width * 0.7043122,
      size.height * 0.9371547,
      size.width * 0.6912604,
      size.height * 0.9556169,
      size.width * 0.671094,
      size.height * 0.9556169,
    );
    path_0.cubicTo(
      size.width * 0.6534357,
      size.height * 0.9556169,
      size.width * 0.6378759,
      size.height * 0.9359116,
      size.width * 0.6357518,
      size.height * 0.9069982,
    );
    path_0.moveTo(size.width * 0.7202559, size.height * 0.9229282);
    path_0.lineTo(size.width * 0.7202559, size.height * 0.8406538);
    path_0.lineTo(size.width * 0.7068202, size.height * 0.8406538);
    path_0.lineTo(size.width * 0.7068202, size.height * 0.8302026);
    path_0.quadraticBezierTo(
      size.width * 0.7204095,
      size.height * 0.8302026,
      size.width * 0.7202559,
      size.height * 0.8019797,
    );
    path_0.lineTo(size.width * 0.7265771, size.height * 0.8019797);
    path_0.lineTo(size.width * 0.7265771, size.height * 0.8302026);
    path_0.lineTo(size.width * 0.7467434, size.height * 0.8302026);
    path_0.lineTo(size.width * 0.7467434, size.height * 0.8406538);
    path_0.lineTo(size.width * 0.7265771, size.height * 0.8406538);
    path_0.lineTo(size.width * 0.7265771, size.height * 0.923895);
    path_0.cubicTo(
      size.width * 0.7265771,
      size.height * 0.9383517,
      size.width * 0.7311836,
      size.height * 0.9447514,
      size.width * 0.7364555,
      size.height * 0.9447514,
    );
    path_0.cubicTo(
      size.width * 0.7393474,
      size.height * 0.9447514,
      size.width * 0.7422649,
      size.height * 0.944291,
      size.width * 0.7452847,
      size.height * 0.9404696,
    );
    path_0.lineTo(size.width * 0.7452847, size.height * 0.9516114);
    path_0.cubicTo(
      size.width * 0.7434421,
      size.height * 0.9539595,
      size.width * 0.7400128,
      size.height * 0.955663,
      size.width * 0.7369674,
      size.height * 0.955663,
    );
    path_0.cubicTo(
      size.width * 0.7272169,
      size.height * 0.955663,
      size.width * 0.7202303,
      size.height * 0.9452118,
      size.width * 0.7202303,
      size.height * 0.9229282,
    );
    path_0.moveTo(size.width * 0.7558541, size.height * 0.8302026);
    path_0.lineTo(size.width * 0.7621753, size.height * 0.8302026);
    path_0.lineTo(size.width * 0.7621753, size.height * 0.8532228);
    path_0.cubicTo(
      size.width * 0.7658605,
      size.height * 0.8394567,
      size.width * 0.7724632,
      size.height * 0.8278545,
      size.width * 0.7823417,
      size.height * 0.8278545,
    );
    path_0.cubicTo(
      size.width * 0.7835189,
      size.height * 0.8278545,
      size.width * 0.7848496,
      size.height * 0.8278545,
      size.width * 0.7861548,
      size.height * 0.8283149,
    );
    path_0.lineTo(size.width * 0.7861548, size.height * 0.8396869);
    path_0.cubicTo(
      size.width * 0.7719258,
      size.height * 0.8354052,
      size.width * 0.7641459,
      size.height * 0.8596225,
      size.width * 0.7621753,
      size.height * 0.875046,
    );
    path_0.lineTo(size.width * 0.7621753, size.height * 0.9533149);
    path_0.lineTo(size.width * 0.7558541, size.height * 0.9533149);
    path_0.lineTo(size.width * 0.7558541, size.height * 0.8302486);
    path_0.close();
    path_0.moveTo(size.width * 0.8400768, size.height * 0.8802486);
    path_0.cubicTo(
      size.width * 0.8391555,
      size.height * 0.8548803,
      size.width * 0.8307102,
      size.height * 0.8387661,
      size.width * 0.8172745,
      size.height * 0.8387661,
    );
    path_0.cubicTo(
      size.width * 0.8038388,
      size.height * 0.8387661,
      size.width * 0.7947281,
      size.height * 0.8558471,
      size.width * 0.7926296,
      size.height * 0.8802486,
    );
    path_0.lineTo(size.width * 0.8400768, size.height * 0.8802486);
    path_0.close();
    path_0.moveTo(size.width * 0.817556, size.height * 0.9447514);
    path_0.cubicTo(
      size.width * 0.8298145,
      size.height * 0.9447514,
      size.width * 0.836929,
      size.height * 0.9354972,
      size.width * 0.8401024,
      size.height * 0.9148711,
    );
    path_0.lineTo(size.width * 0.846833, size.height * 0.9196133);
    path_0.cubicTo(
      size.width * 0.8428663,
      size.height * 0.9418969,
      size.width * 0.8324504,
      size.height * 0.955663,
      size.width * 0.817556,
      size.height * 0.955663,
    );
    path_0.cubicTo(
      size.width * 0.7986948,
      size.height * 0.955663,
      size.width * 0.7853871,
      size.height * 0.9293278,
      size.width * 0.7853871,
      size.height * 0.8916206,
    );
    path_0.cubicTo(
      size.width * 0.7853871,
      size.height * 0.8539134,
      size.width * 0.7984389,
      size.height * 0.8278085,
      size.width * 0.8172745,
      size.height * 0.8278085,
    );
    path_0.cubicTo(
      size.width * 0.8427127,
      size.height * 0.8278085,
      size.width * 0.8481126,
      size.height * 0.869291,
      size.width * 0.8465515,
      size.height * 0.8906538,
    );
    path_0.lineTo(size.width * 0.7922457, size.height * 0.8906538);
    path_0.lineTo(size.width * 0.7922457, size.height * 0.8913444);
    path_0.cubicTo(
      size.width * 0.7922457,
      size.height * 0.9243094,
      size.width * 0.8025336,
      size.height * 0.9447053,
      size.width * 0.817556,
      size.height * 0.9447053,
    );
    path_0.moveTo(size.width * 0.8772617, size.height * 0.9447514);
    path_0.cubicTo(
      size.width * 0.8914907,
      size.height * 0.9447514,
      size.width * 0.8996801,
      size.height * 0.9260129,
      size.width * 0.9020345,
      size.height * 0.908011,
    );
    path_0.lineTo(size.width * 0.9020345, size.height * 0.8876151);
    path_0.lineTo(size.width * 0.8773896, size.height * 0.8947053);
    path_0.cubicTo(
      size.width * 0.8673832,
      size.height * 0.8975599,
      size.width * 0.8611644,
      size.height * 0.9053867,
      size.width * 0.8611644,
      size.height * 0.9208103,
    );
    path_0.cubicTo(
      size.width * 0.8611644,
      size.height * 0.9362339,
      size.width * 0.868023,
      size.height * 0.9447514,
      size.width * 0.8772361,
      size.height * 0.9447514,
    );
    path_0.moveTo(size.width * 0.8543314, size.height * 0.9208103);
    path_0.cubicTo(
      size.width * 0.8543314,
      size.height * 0.9001842,
      size.width * 0.8629047,
      size.height * 0.8878453,
      size.width * 0.8767498,
      size.height * 0.8837937,
    );
    path_0.lineTo(size.width * 0.9021881, size.height * 0.8764273);
    path_0.lineTo(size.width * 0.9021881, size.height * 0.8721455);
    path_0.cubicTo(
      size.width * 0.9021881,
      size.height * 0.848895,
      size.width * 0.8940243,
      size.height * 0.8387201,
      size.width * 0.8834805,
      size.height * 0.8387201,
    );
    path_0.cubicTo(
      size.width * 0.871222,
      size.height * 0.8387201,
      size.width * 0.8649008,
      size.height * 0.8500921,
      size.width * 0.8626488,
      size.height * 0.8669429,
    );
    path_0.lineTo(size.width * 0.8559181, size.height * 0.8622007);
    path_0.cubicTo(
      size.width * 0.8589379,
      size.height * 0.8436924,
      size.width * 0.8677927,
      size.height * 0.8278085,
      size.width * 0.8834549,
      size.height * 0.8278085,
    );
    path_0.cubicTo(
      size.width * 0.897556,
      size.height * 0.8278085,
      size.width * 0.9083813,
      size.height * 0.842035,
      size.width * 0.9083813,
      size.height * 0.8697974,
    );
    path_0.lineTo(size.width * 0.9083813, size.height * 0.9532689);
    path_0.lineTo(size.width * 0.9020601, size.height * 0.9532689);
    path_0.lineTo(size.width * 0.9020601, size.height * 0.9279006);
    path_0.arcToPoint(
      Offset(size.width * 0.8771337, size.height * 0.955663),
      radius: Radius.elliptical(size.width * 0.02789507, size.height * 0.05018416),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.cubicTo(
      size.width * 0.863826,
      size.height * 0.955663,
      size.width * 0.8543314,
      size.height * 0.9424033,
      size.width * 0.8543314,
      size.height * 0.9208103,
    );
    path_0.moveTo(size.width * 0.9239155, size.height * 0.8302026);
    path_0.lineTo(size.width * 0.9302367, size.height * 0.8302026);
    path_0.lineTo(size.width * 0.9302367, size.height * 0.8529466);
    path_0.cubicTo(
      size.width * 0.9345873,
      size.height * 0.8406077,
      size.width * 0.9431606,
      size.height * 0.8278085,
      size.width * 0.9542163,
      size.height * 0.8278085,
    );
    path_0.cubicTo(
      size.width * 0.9664747,
      size.height * 0.8278085,
      size.width * 0.9734613,
      size.height * 0.8387201,
      size.width * 0.9759693,
      size.height * 0.8555709,
    );
    path_0.cubicTo(
      size.width * 0.9814971,
      size.height * 0.8394567,
      size.width * 0.9899424,
      size.height * 0.8278085,
      size.width * 1.000742,
      size.height * 0.8278085,
    );
    path_0.cubicTo(
      size.width * 1.016302,
      size.height * 0.8278085,
      size.width * 1.023544,
      size.height * 0.8453499,
      size.width * 1.023544,
      size.height * 0.8697974,
    );
    path_0.lineTo(size.width * 1.023544, size.height * 0.9532689);
    path_0.lineTo(size.width * 1.017223, size.height * 0.9532689);
    path_0.lineTo(size.width * 1.017223, size.height * 0.8716851);
    path_0.cubicTo(
      size.width * 1.017223,
      size.height * 0.8470074,
      size.width * 1.009699,
      size.height * 0.8387201,
      size.width * 1.000614,
      size.height * 0.8387201,
    );
    path_0.cubicTo(
      size.width * 0.9890211,
      size.height * 0.8387201,
      size.width * 0.9799104,
      size.height * 0.8553407,
      size.width * 0.9768906,
      size.height * 0.875,
    );
    path_0.lineTo(size.width * 0.9768906, size.height * 0.9532689);
    path_0.lineTo(size.width * 0.9705694, size.height * 0.9532689);
    path_0.lineTo(size.width * 0.9705694, size.height * 0.8716851);
    path_0.cubicTo(
      size.width * 0.9705694,
      size.height * 0.8470074,
      size.width * 0.9630454,
      size.height * 0.8387201,
      size.width * 0.9543442,
      size.height * 0.8387201,
    );
    path_0.cubicTo(
      size.width * 0.9424696,
      size.height * 0.8387201,
      size.width * 0.9332566,
      size.height * 0.8553407,
      size.width * 0.9302111,
      size.height * 0.875,
    );
    path_0.lineTo(size.width * 0.9302111, size.height * 0.9532689);
    path_0.lineTo(size.width * 0.92389, size.height * 0.9532689);
    path_0.lineTo(size.width * 0.92389, size.height * 0.8302026);
    path_0.close();
    path_0.moveTo(size.width * 1.055329, size.height * 0.9952578);
    path_0.lineTo(size.width * 1.057428, size.height * 0.9853131);
    path_0.cubicTo(
      size.width * 1.059271,
      size.height * 0.9874309,
      size.width * 1.062444,
      size.height * 0.9888582,
      size.width * 1.065873,
      size.height * 0.9888582,
    );
    path_0.cubicTo(
      size.width * 1.071017,
      size.height * 0.9888582,
      size.width * 1.076417,
      size.height * 0.9826888,
      size.width * 1.079591,
      size.height * 0.9658379,
    );
    path_0.lineTo(size.width * 1.081177, size.height * 0.9573204);
    path_0.lineTo(size.width * 1.05771, size.height * 0.8434622);
    path_0.lineTo(size.width * 1.055202, size.height * 0.8311234);
    path_0.lineTo(size.width * 1.055202, size.height * 0.8301565);
    path_0.lineTo(size.width * 1.061779, size.height * 0.8301565);
    path_0.lineTo(size.width * 1.061907, size.height * 0.8311234);
    path_0.lineTo(size.width * 1.084197, size.height * 0.9406998);
    path_0.lineTo(size.width * 1.103698, size.height * 0.8434622);
    path_0.lineTo(size.width * 1.106078, size.height * 0.8311234);
    path_0.lineTo(size.width * 1.106334, size.height * 0.8301565);
    path_0.lineTo(size.width * 1.113193, size.height * 0.8301565);
    path_0.lineTo(size.width * 1.113193, size.height * 0.8311234);
    path_0.lineTo(size.width * 1.110557, size.height * 0.8434622);
    path_0.lineTo(size.width * 1.085374, size.height * 0.9686924);
    path_0.cubicTo(
      size.width * 1.081152,
      size.height * 0.9893186,
      size.width * 1.074958,
      size.height * 1.0,
      size.width * 1.065336,
      size.height * 1.0,
    );
    path_0.cubicTo(
      size.width * 1.061241,
      size.height * 1.0,
      size.width * 1.057172,
      size.height * 0.9981123,
      size.width * 1.055329,
      size.height * 0.9952578,
    );
    path_0.moveTo(size.width * 1.174101, size.height * 0.8916667);
    path_0.cubicTo(
      size.width * 1.174101,
      size.height * 0.8610958,
      size.width * 1.163148,
      size.height * 0.8387661,
      size.width * 1.148253,
      size.height * 0.8387661,
    );
    path_0.cubicTo(
      size.width * 1.133359,
      size.height * 0.8387661,
      size.width * 1.122559,
      size.height * 0.8610497,
      size.width * 1.122559,
      size.height * 0.8916667,
    );
    path_0.cubicTo(
      size.width * 1.122559,
      size.height * 0.9222836,
      size.width * 1.133359,
      size.height * 0.9447974,
      size.width * 1.148253,
      size.height * 0.9447974,
    );
    path_0.cubicTo(
      size.width * 1.163148,
      size.height * 0.9447974,
      size.width * 1.174101,
      size.height * 0.9222836,
      size.width * 1.174101,
      size.height * 0.8916667,
    );
    path_0.moveTo(size.width * 1.115726, size.height * 0.8916667);
    path_0.cubicTo(
      size.width * 1.115726,
      size.height * 0.8549263,
      size.width * 1.129443,
      size.height * 0.8278545,
      size.width * 1.148279,
      size.height * 0.8278545,
    );
    path_0.cubicTo(
      size.width * 1.167115,
      size.height * 0.8278545,
      size.width * 1.18096,
      size.height * 0.8548803,
      size.width * 1.18096,
      size.height * 0.8916667,
    );
    path_0.cubicTo(
      size.width * 1.18096,
      size.height * 0.928453,
      size.width * 1.167115,
      size.height * 0.955709,
      size.width * 1.148279,
      size.height * 0.955709,
    );
    path_0.cubicTo(
      size.width * 1.129443,
      size.height * 0.955709,
      size.width * 1.115726,
      size.height * 0.9286832,
      size.width * 1.115726,
      size.height * 0.8916667,
    );
    path_0.moveTo(size.width * 1.192297, size.height * 0.9129834);
    path_0.lineTo(size.width * 1.192297, size.height * 0.8302026);
    path_0.lineTo(size.width * 1.198618, size.height * 0.8302026);
    path_0.lineTo(size.width * 1.198618, size.height * 0.9110497);
    path_0.cubicTo(
      size.width * 1.198618,
      size.height * 0.9319061,
      size.width * 1.205988,
      size.height * 0.9447053,
      size.width * 1.217607,
      size.height * 0.9447053,
    );
    path_0.cubicTo(
      size.width * 1.229226,
      size.height * 0.9447053,
      size.width * 1.238439,
      size.height * 0.9280847,
      size.width * 1.241459,
      size.height * 0.9084254,
    );
    path_0.lineTo(size.width * 1.241459, size.height * 0.8301565);
    path_0.lineTo(size.width * 1.24778, size.height * 0.8301565);
    path_0.lineTo(size.width * 1.24778, size.height * 0.9532228);
    path_0.lineTo(size.width * 1.241459, size.height * 0.9532228);
    path_0.lineTo(size.width * 1.241459, size.height * 0.9304788);
    path_0.cubicTo(
      size.width * 1.237108,
      size.height * 0.9428177,
      size.width * 1.228535,
      size.height * 0.9556169,
      size.width * 1.217479,
      size.height * 0.9556169,
    );
    path_0.cubicTo(
      size.width * 1.202047,
      size.height * 0.9556169,
      size.width * 1.192297,
      size.height * 0.9392726,
      size.width * 1.192297,
      size.height * 0.9129374,
    );
    path_0.moveTo(size.width * 1.264005, size.height * 0.8302026);
    path_0.lineTo(size.width * 1.270326, size.height * 0.8302026);
    path_0.lineTo(size.width * 1.270326, size.height * 0.8532228);
    path_0.cubicTo(
      size.width * 1.274012,
      size.height * 0.8394567,
      size.width * 1.280614,
      size.height * 0.8278545,
      size.width * 1.290493,
      size.height * 0.8278545,
    );
    path_0.cubicTo(
      size.width * 1.29167,
      size.height * 0.8278545,
      size.width * 1.293001,
      size.height * 0.8278545,
      size.width * 1.294306,
      size.height * 0.8283149,
    );
    path_0.lineTo(size.width * 1.294306, size.height * 0.8396869);
    path_0.cubicTo(
      size.width * 1.280077,
      size.height * 0.8354052,
      size.width * 1.272297,
      size.height * 0.8596225,
      size.width * 1.270326,
      size.height * 0.875046,
    );
    path_0.lineTo(size.width * 1.270326, size.height * 0.9533149);
    path_0.lineTo(size.width * 1.264005, size.height * 0.9533149);
    path_0.lineTo(size.width * 1.264005, size.height * 0.8302486);
    path_0.close();
    path_0.moveTo(size.width * 1.383826, size.height * 0.9046961);
    path_0.cubicTo(
      size.width * 1.383826,
      size.height * 0.8809853,
      size.width * 1.375253,
      size.height * 0.8676796,
      size.width * 1.359846,
      size.height * 0.8676796,
    );
    path_0.lineTo(size.width * 1.333999, size.height * 0.8676796);
    path_0.lineTo(size.width * 1.333999, size.height * 0.9418969);
    path_0.lineTo(size.width * 1.359846, size.height * 0.9418969);
    path_0.cubicTo(
      size.width * 1.375278,
      size.height * 0.9418969,
      size.width * 1.383826,
      size.height * 0.9285912,
      size.width * 1.383826,
      size.height * 0.9046501,
    );
    path_0.moveTo(size.width * 1.380653, size.height * 0.8252302);
    path_0.cubicTo(
      size.width * 1.380653,
      size.height * 0.8052947,
      size.width * 1.372617,
      size.height * 0.7936924,
      size.width * 1.359821,
      size.height * 0.7936924,
    );
    path_0.lineTo(size.width * 1.333973, size.height * 0.7936924);
    path_0.lineTo(size.width * 1.333973, size.height * 0.8563076);
    path_0.lineTo(size.width * 1.359539, size.height * 0.8563076);
    path_0.cubicTo(
      size.width * 1.372719,
      size.height * 0.8563076,
      size.width * 1.380627,
      size.height * 0.8456262,
      size.width * 1.380627,
      size.height * 0.8252302,
    );
    path_0.moveTo(size.width * 1.326884, size.height * 0.7823204);
    path_0.lineTo(size.width * 1.359053, size.height * 0.7823204);
    path_0.cubicTo(
      size.width * 1.377914,
      size.height * 0.7823204,
      size.width * 1.388049,
      size.height * 0.797744,
      size.width * 1.388049,
      size.height * 0.8252302,
    );
    path_0.cubicTo(
      size.width * 1.388049,
      size.height * 0.8415746,
      size.width * 1.383033,
      size.height * 0.8546501,
      size.width * 1.373948,
      size.height * 0.8610497,
    );
    path_0.cubicTo(
      size.width * 1.385413,
      size.height * 0.8676796,
      size.width * 1.391222,
      size.height * 0.8824125,
      size.width * 1.391222,
      size.height * 0.9041897,
    );
    path_0.cubicTo(
      size.width * 1.391222,
      size.height * 0.9364641,
      size.width * 1.381216,
      size.height * 0.9532689,
      size.width * 1.361689,
      size.height * 0.9532689,
    );
    path_0.lineTo(size.width * 1.326884, size.height * 0.9532689);
    path_0.lineTo(size.width * 1.326884, size.height * 0.7822744);
    path_0.close();
    path_0.moveTo(size.width * 1.403455, size.height * 0.8302026);
    path_0.lineTo(size.width * 1.409776, size.height * 0.8302026);
    path_0.lineTo(size.width * 1.409776, size.height * 0.8532228);
    path_0.cubicTo(
      size.width * 1.413461,
      size.height * 0.8394567,
      size.width * 1.420064,
      size.height * 0.8278545,
      size.width * 1.429942,
      size.height * 0.8278545,
    );
    path_0.cubicTo(
      size.width * 1.43112,
      size.height * 0.8278545,
      size.width * 1.43245,
      size.height * 0.8278545,
      size.width * 1.433756,
      size.height * 0.8283149,
    );
    path_0.lineTo(size.width * 1.433756, size.height * 0.8396869);
    path_0.cubicTo(
      size.width * 1.419527,
      size.height * 0.8354052,
      size.width * 1.411747,
      size.height * 0.8596225,
      size.width * 1.409776,
      size.height * 0.875046,
    );
    path_0.lineTo(size.width * 1.409776, size.height * 0.9533149);
    path_0.lineTo(size.width * 1.403455, size.height * 0.9533149);
    path_0.lineTo(size.width * 1.403455, size.height * 0.8302486);
    path_0.close();
    path_0.moveTo(size.width * 1.457914, size.height * 0.9447514);
    path_0.cubicTo(
      size.width * 1.472143,
      size.height * 0.9447514,
      size.width * 1.480333,
      size.height * 0.9260129,
      size.width * 1.482687,
      size.height * 0.908011,
    );
    path_0.lineTo(size.width * 1.482687, size.height * 0.8876151);
    path_0.lineTo(size.width * 1.458042, size.height * 0.8947053);
    path_0.cubicTo(
      size.width * 1.448036,
      size.height * 0.8975599,
      size.width * 1.441843,
      size.height * 0.9053867,
      size.width * 1.441843,
      size.height * 0.9208103,
    );
    path_0.cubicTo(
      size.width * 1.441843,
      size.height * 0.9362339,
      size.width * 1.448701,
      size.height * 0.9447514,
      size.width * 1.457914,
      size.height * 0.9447514,
    );
    path_0.moveTo(size.width * 1.434958, size.height * 0.9208103);
    path_0.cubicTo(
      size.width * 1.434958,
      size.height * 0.9001842,
      size.width * 1.443532,
      size.height * 0.8878453,
      size.width * 1.457377,
      size.height * 0.8837937,
    );
    path_0.lineTo(size.width * 1.482815, size.height * 0.8764273);
    path_0.lineTo(size.width * 1.482815, size.height * 0.8721455);
    path_0.cubicTo(
      size.width * 1.482815,
      size.height * 0.848895,
      size.width * 1.474651,
      size.height * 0.8387201,
      size.width * 1.464107,
      size.height * 0.8387201,
    );
    path_0.cubicTo(
      size.width * 1.451849,
      size.height * 0.8387201,
      size.width * 1.445528,
      size.height * 0.8500921,
      size.width * 1.443276,
      size.height * 0.8669429,
    );
    path_0.lineTo(size.width * 1.436545, size.height * 0.8622007);
    path_0.cubicTo(
      size.width * 1.439565,
      size.height * 0.8436924,
      size.width * 1.44842,
      size.height * 0.8278085,
      size.width * 1.464082,
      size.height * 0.8278085,
    );
    path_0.cubicTo(
      size.width * 1.478183,
      size.height * 0.8278085,
      size.width * 1.489008,
      size.height * 0.842035,
      size.width * 1.489008,
      size.height * 0.8697974,
    );
    path_0.lineTo(size.width * 1.489008, size.height * 0.9532689);
    path_0.lineTo(size.width * 1.482687, size.height * 0.9532689);
    path_0.lineTo(size.width * 1.482687, size.height * 0.9279006);
    path_0.arcToPoint(
      Offset(size.width * 1.457786, size.height * 0.955663),
      radius: Radius.elliptical(size.width * 0.02789507, size.height * 0.05018416),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    );
    path_0.cubicTo(
      size.width * 1.444479,
      size.height * 0.955663,
      size.width * 1.434984,
      size.height * 0.9424033,
      size.width * 1.434984,
      size.height * 0.9208103,
    );
    path_0.moveTo(size.width * 1.504568, size.height * 0.8302026);
    path_0.lineTo(size.width * 1.510889, size.height * 0.8302026);
    path_0.lineTo(size.width * 1.510889, size.height * 0.8529466);
    path_0.cubicTo(
      size.width * 1.51524,
      size.height * 0.8406077,
      size.width * 1.523813,
      size.height * 0.8278085,
      size.width * 1.534869,
      size.height * 0.8278085,
    );
    path_0.cubicTo(
      size.width * 1.550301,
      size.height * 0.8278085,
      size.width * 1.560051,
      size.height * 0.8441529,
      size.width * 1.560051,
      size.height * 0.870488,
    );
    path_0.lineTo(size.width * 1.560051, size.height * 0.9532689);
    path_0.lineTo(size.width * 1.55373, size.height * 0.9532689);
    path_0.lineTo(size.width * 1.55373, size.height * 0.8724217);
    path_0.cubicTo(
      size.width * 1.55373,
      size.height * 0.8515654,
      size.width * 1.54636,
      size.height * 0.8387661,
      size.width * 1.534741,
      size.height * 0.8387661,
    );
    path_0.cubicTo(
      size.width * 1.523122,
      size.height * 0.8387661,
      size.width * 1.513909,
      size.height * 0.8553867,
      size.width * 1.510889,
      size.height * 0.875046,
    );
    path_0.lineTo(size.width * 1.510889, size.height * 0.9533149);
    path_0.lineTo(size.width * 1.504568, size.height * 0.9533149);
    path_0.lineTo(size.width * 1.504568, size.height * 0.8302486);
    path_0.close();
    path_0.moveTo(size.width * 1.628356, size.height * 0.9004144);
    path_0.lineTo(size.width * 1.628356, size.height * 0.8831031);
    path_0.cubicTo(
      size.width * 1.627434,
      size.height * 0.8572744,
      size.width * 1.617402,
      size.height * 0.8387661,
      size.width * 1.603711,
      size.height * 0.8387661,
    );
    path_0.cubicTo(
      size.width * 1.588816,
      size.height * 0.8387661,
      size.width * 1.578273,
      size.height * 0.8596225,
      size.width * 1.578273,
      size.height * 0.8916667,
    );
    path_0.cubicTo(
      size.width * 1.578273,
      size.height * 0.9237109,
      size.width * 1.588816,
      size.height * 0.9447974,
      size.width * 1.603711,
      size.height * 0.9447974,
    );
    path_0.cubicTo(
      size.width * 1.617428,
      size.height * 0.9447974,
      size.width * 1.627434,
      size.height * 0.9260589,
      size.width * 1.628356,
      size.height * 0.9004604,
    );
    path_0.moveTo(size.width * 1.571388, size.height * 0.8916667);
    path_0.cubicTo(
      size.width * 1.571388,
      size.height * 0.8546501,
      size.width * 1.585234,
      size.height * 0.8278545,
      size.width * 1.603685,
      size.height * 0.8278545,
    );
    path_0.cubicTo(
      size.width * 1.613564,
      size.height * 0.8278545,
      size.width * 1.623852,
      size.height * 0.8375691,
      size.width * 1.62833,
      size.height * 0.8529926,
    );
    path_0.lineTo(size.width * 1.62833, size.height * 0.7799724);
    path_0.lineTo(size.width * 1.634651, size.height * 0.7799724);
    path_0.lineTo(size.width * 1.634651, size.height * 0.9533149);
    path_0.lineTo(size.width * 1.62833, size.height * 0.9533149);
    path_0.lineTo(size.width * 1.62833, size.height * 0.9302947);
    path_0.cubicTo(
      size.width * 1.623852,
      size.height * 0.9457182,
      size.width * 1.613564,
      size.height * 0.955663,
      size.width * 1.603685,
      size.height * 0.955663,
    );
    path_0.cubicTo(
      size.width * 1.585234,
      size.height * 0.955663,
      size.width * 1.571388,
      size.height * 0.9286372,
      size.width * 1.571388,
      size.height * 0.8916206,
    );

    final paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = const Color(0xffffffff);

    canvas.translate(-_baseSize.width * 0.635, -_baseSize.height * 0.77);
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
    } // if (scale < 4.0) {
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
      ..scale(scale, scale * 4.2)
      ..drawPicture(_$logoPicture)
      ..restore();
  }
}
