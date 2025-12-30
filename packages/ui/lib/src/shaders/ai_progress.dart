import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class AiProgress extends SingleChildRenderObjectWidget {
  /// Creates a shimmering progress placeholder with an optional child.
  const AiProgress({
    super.key,
    this.background,
    this.speed = 15.0,
    this.size = const Size(128, 28),
    this.radius = const Radius.circular(8.0),
    this.initialSeed = 0.0,
    this.animate = true,
    super.child,
  });

  /// The background color of the progress shimmer.
  /// If null, will default to `Theme.of(context).colorScheme.surface` when creating the render object.
  final Color? background;

  /// The radius of the rounded corners of the shimmer box.
  final Radius? radius;

  /// The speed of the shimmering effect (higher means faster).
  final double speed;

  /// The size of the widget. If not null, the shimmer box will be this size.
  final Size? size;

  /// Initial offset (as fraction of width) for the shimmer animation.
  final double initialSeed;

  /// Whether the shimmer animation is active. If false, the shimmer is static.
  final bool animate;

  @override
  RenderObject createRenderObject(BuildContext context) {
    // Determine the actual background color (use theme default if not provided).
    final bg = background ?? Theme.of(context).colorScheme.surface;
    return AiProgressShaderRenderObject(
      background: bg,
      speed: speed,
      size: size,
      radius: radius,
      initialSeed: initialSeed,
      animate: animate,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant AiProgressShaderRenderObject renderObject) {
    final bg = background ?? Theme.of(context).colorScheme.surface;
    renderObject.update(
      background: bg,
      speed: speed,
      size: size,
      radius: radius,
      initialSeed: initialSeed,
      animate: animate,
    );
  }
}

class AiProgressShaderRenderObject extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, WidgetsBindingObserver {
  AiProgressShaderRenderObject({
    required Color background,
    required double speed,
    required Size? size,
    required Radius? radius,
    required double initialSeed,
    required bool animate,
  }) : _backgroundColor = background,
       _speed = speed,
       _sizeParam = size,
       _radius = radius,
       _initialSeed = initialSeed,
       _animate = animate {
    // Initialize paint with background color
    _paint.color = _backgroundColor;
    _paint.style = PaintingStyle.fill;
    _paint.blendMode = BlendMode.srcOver;
    _paint.filterQuality = FilterQuality.low;
    _paint.isAntiAlias = true;
    // Begin loading the shader (if not already loaded)
    _AiProgressShaderManager.setShader(_paint);
    // Create ticker for animation
    _ticker = Ticker(_onTick, debugLabel: 'AiProgressShaderTicker');
    if (_animate) {
      _ticker?.start();
    }
    // Register as an observer to handle app lifecycle (to pause animation when app not active)
    WidgetsBinding.instance.addObserver(this);
  }

  // Properties (with backing fields) for the shimmer parameters:
  Color _backgroundColor;
  double _speed;
  Size? _sizeParam;
  Radius? _radius;
  double _initialSeed;
  bool _animate;

  final Paint _paint = Paint();
  Ticker? _ticker;
  Duration _elapsed = Duration.zero;
  int _activeFlag = 0; // bit flags to track if animation should pause (e.g., app not active or detached)

  @override
  bool get isRepaintBoundary => false;

  @override
  bool get alwaysNeedsCompositing => false;

  void update({
    required Color background,
    required double speed,
    required Size? size,
    required Radius? radius,
    required double initialSeed,
    required bool animate,
  }) {
    var needsLayout = false;
    // If size parameter changes, mark layout needed
    if (size != _sizeParam) {
      _sizeParam = size;
      needsLayout = true;
    }
    // If any painting-related properties change, mark for repaint
    if (background != _backgroundColor) {
      _backgroundColor = background;
      // Update paint color for cases where shader isn't available
      _paint.color = background;
      markNeedsPaint();
    }
    if (speed != _speed) {
      _speed = speed;
      // Changing speed will affect animation timing
      markNeedsPaint();
    }
    if (radius != _radius) {
      _radius = radius;
      markNeedsPaint();
    }
    if (initialSeed != _initialSeed) {
      _initialSeed = initialSeed;
      markNeedsPaint();
    }
    if (animate != _animate) {
      _animate = animate;
      if (_animate) {
        // Resume or start ticker if animation is turned on
        if (_ticker == null) {
          _ticker = Ticker(_onTick, debugLabel: 'AiProgressShaderTicker')..start();
        } else {
          _elapsed = Duration.zero; // reset elapsed time when re-enabling animation, if desired
          _ticker!.start();
        }
      } else {
        // Stop ticker when animation is turned off
        _ticker?.stop();
        // Keep the shimmer at its current appearance (freeze animation)
        markNeedsPaint();
      }
    }
    if (needsLayout) markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    // Reset the "detached" flag bit
    _activeFlag &= ~(1 << 1);
    WidgetsBinding.instance.addObserver(this);
    // Ensure shader is loaded (in case it finished loading while off-tree)
    _AiProgressShaderManager.setShader(_paint);
    // Start or resume ticker if needed
    if (_animate && (_ticker?.isActive != true)) {
      _ticker ??= Ticker(_onTick, debugLabel: 'AiProgressShaderTicker');
      _ticker!.start();
    }
  }

  @override
  void detach() {
    // Set a flag to indicate the RenderObject is detached (so animation stops)
    _activeFlag |= 1 << 1;
    _ticker?.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.detach();
  }

  // Handle app lifecycle changes to pause/resume animation appropriately
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    const lifecycleFlag = 1 << 0;
    state == AppLifecycleState.resumed
        ? // Clear lifecycle pause flag when app is resumed
          _activeFlag &= ~lifecycleFlag
        : // Set flag when app is not active (paused, inactive, detached)
          _activeFlag |= lifecycleFlag;
  }

  // Layout: if a fixed size is provided, use it; otherwise size to child or parent constraints.
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (_sizeParam != null) {
      // If a specific size is set, ensure it fits within constraints
      return constraints.constrain(_sizeParam!);
    }
    if (child != null) {
      // No fixed size: use child's size (constrained by incoming constraints)
      final childSize = child!.getDryLayout(constraints);
      return constraints.constrain(childSize);
    }
    // If no child and no size specified, default to the biggest allowed (or a default minimum)
    final constrained = constraints.biggest;
    return constrained.width == double.infinity || constrained.height == double.infinity
        ? constraints.constrain(const Size(128, 28))
        : constrained;
  }

  @override
  void performLayout() {
    // Determine our own size
    Size desiredSize;
    if (_sizeParam != null) {
      desiredSize = constraints.constrain(_sizeParam!);
    } else if (child != null) {
      // Let child flex within constraints, then adopt child's size
      child!.layout(constraints, parentUsesSize: true);
      desiredSize = constraints.constrain(child!.size);
    } else {
      // No child or size: use constraints (or default if unbounded)
      desiredSize = computeDryLayout(constraints);
    }
    size = desiredSize;
    // If we have a child and a fixed size, layout child to fit within our size
    if (child != null && _sizeParam != null) {
      child!.layout(BoxConstraints.tight(size));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) return; // nothing to paint if zero-sized
    final canvas = context.canvas
      ..save()
      // Translate to the render object's position
      ..translate(offset.dx, offset.dy);
    // Clip to rounded rectangle (or rect) so the shimmer effect and child are confined to the shape
    // if (_radius > 0.0) {
    if (_radius case final Radius radius when radius != Radius.zero) {
      canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, _radius ?? Radius.zero));
    } else {
      canvas.clipRect(Offset.zero & size);
    }
    // Draw the shader effect or a solid background if shader not available
    if (_paint.shader is ui.FragmentShader) {
      // Update shader uniforms: size, time seed, background color, animate flag
      final seedValue = _initialSeed + (_elapsed.inMilliseconds * _speed / 8000.0);
      (_paint.shader! as ui.FragmentShader)
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, seedValue)
        ..setFloat(3, _backgroundColor.r)
        ..setFloat(4, _backgroundColor.g)
        ..setFloat(5, _backgroundColor.b)
        ..setFloat(6, _backgroundColor.a)
        ..setFloat(7, _animate ? 1.0 : 0.0);
      canvas.drawRect(Offset.zero & size, _paint);
    } else {
      // Shader not loaded or supported – fill with background color
      final bgPaint = _paint
        ..shader = null
        ..color = _backgroundColor;
      canvas.drawRect(Offset.zero & size, bgPaint);
    }
    // Paint the child widget on top of the shimmer background (if any)
    if (child != null) {
      context.paintChild(child!, Offset.zero);
    }
    canvas.restore();
  }

  // The ticker callback for animation frames
  void _onTick(Duration elapsed) {
    _elapsed = elapsed;
    // Only mark for paint if we are active and animation is enabled
    if (_activeFlag == 0 && _animate) {
      markNeedsPaint();
    }
  }
}

// Manager for loading and providing the fragment shader program (similar to Shimmer's manager)
abstract final class _AiProgressShaderManager {
  static final Future<ui.FragmentProgram?> _programFuture = _loadProgram();
  static ui.FragmentProgram? _fragmentProgram;

  /// Assigns the shader to the given Paint if available, or starts loading it.
  static void setShader(Paint paint) {
    if (_fragmentProgram == null) {
      // Trigger the shader load if not started yet, then set it when ready
      _programFuture.then((program) {
        if (program == null) return;
        paint
          ..shader = program.fragmentShader()
          ..blendMode = BlendMode.src
          ..filterQuality = FilterQuality.low
          ..isAntiAlias = false;
      }).ignore();
    } else {
      // If already loaded, attach shader
      paint
        ..shader = _fragmentProgram!.fragmentShader()
        ..blendMode = BlendMode
            .src // use src blend for shader to directly apply its output
        ..filterQuality = FilterQuality.low
        ..isAntiAlias = false;
    }
  }

  static Future<ui.FragmentProgram?> _loadProgram() async {
    const assetPath = 'packages/ui/shaders/ai/progress.frag';
    try {
      return await ui.FragmentProgram.fromAsset(assetPath).timeout(const Duration(seconds: 5));
    } on UnsupportedError {
      // Shader not supported (e.g., Web or older device)
      return null;
    } catch (e, stack) {
      debugPrint('Failed to load progress shader: $e, $stack');
      return null;
    }
  }
}
