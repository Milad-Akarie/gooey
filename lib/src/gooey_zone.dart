import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _kShaderAsset = 'shaders/gooey.frag';

/// A zone that renders gooey blobs behind its registered [GooeyBlob] children.
///
/// [GooeyZone] manages a collection of gooey blobs that automatically register
/// themselves when they attach to the render tree.
///
/// The gooey effect uses a fragment shader to create a viscous liquid-like
/// deformation at the edges. [GooeyBlob] children push against the boundaries,
/// creating the liquid merge and separate effect.
///
/// ```dart
/// GooeyZone(
///   color: Colors.indigo,
///   gooiness: 30,
///   child: Column(
///     children: [
///       GooeyBlob(shape: const BlobShape.circle(), child: Icon(Icons.add)),
///       GooeyBlob(shape: const BlobShape.circle(), child: Icon(Icons.share)),
///       GooeyBlob(shape: const BlobShape.circle(), child: Icon(Icons.edit)),
///     ],
///   ),
/// )
/// ```
class GooeyZone extends SingleChildRenderObjectWidget {
  /// Creates a [GooeyZone] with the given parameters.
  const GooeyZone({
    super.key,

    /// The intensity of the gooey effect. Higher values create more
    /// pronounced liquid-like deformation. Must be non-negative.
    this.gooiness = 30,

    /// The primary color of the gooey zone.
    required this.color,
    required super.child,

    /// The width of the border around the zone. Defaults to 0.0 (no border).
    this.borderWidth = 0.0,

    /// The color of the border. Defaults to transparent.
    this.borderColor = Colors.transparent,
  }) : assert(gooiness >= 0, 'Gooiness must be non-negative'),
       assert(borderWidth >= 0, 'Border width must be non-negative'),
       fillType = FillType.solid,
       secondColor = null,
       thirdColor = null,
       begin = null,
       end = null,
       center = null,
       radius = null;

  /// Creates a [GooeyZone] with a linear gradient fill.
  ///
  /// The gradient transitions from [color] at [begin] to [secondColor] at
  /// [end], and optionally to [thirdColor] for a three-color gradient.
  ///
  /// Example:
  /// ```dart
  /// GooeyZone.linearGradient(
  ///   gooiness: 40,
  ///   color: Colors.blue,
  ///   secondColor: Colors.purple,
  ///   begin: Alignment.topLeft,
  ///   end: Alignment.bottomRight,
  ///   child: Column(
  ///     children: [
  ///       GooeyBlob(shape: const BlobShape.circle(), child: Icon(Icons.add)),
  ///       GooeyBlob(shape: const BlobShape.circle(), child: Icon(Icons.share)),
  ///       GooeyBlob(shape: const BlobShape.circle(), child: Icon(Icons.edit)),
  ///     ],
  ///   ),
  /// )
  /// ```
  const GooeyZone.linearGradient({
    super.key,

    /// The intensity of the gooey effect. Higher values create more
    /// pronounced liquid-like deformation. Must be non-negative.
    required this.gooiness,

    /// The primary (starting) color of the gradient.
    required this.color,

    /// The second color in the gradient.
    required Color this.secondColor,

    /// An optional third color for a three-color gradient.
    this.thirdColor,

    /// The start point of the gradient. Defaults to [Alignment.centerLeft].
    this.begin = Alignment.centerLeft,

    /// The end point of the gradient. Defaults to [Alignment.centerRight].
    this.end = Alignment.centerRight,

    /// The width of the border around the zone. Defaults to 0.0 (no border).
    this.borderWidth = 0.0,

    /// The color of the border. Defaults to transparent.
    this.borderColor = Colors.transparent,
    required super.child,
  }) : assert(gooiness >= 0, 'Gooiness must be non-negative'),
       assert(borderWidth >= 0, 'Border width must be non-negative'),
       fillType = thirdColor != null ? FillType.linear3 : FillType.linear2,
       center = null,
       radius = null;

  /// Creates a [GooeyZone] with a radial gradient fill.
  ///
  /// The gradient radiates from [center] with [color] at the center, transitioning
  /// to [secondColor] at the edges defined by [radius], and optionally to [thirdColor] for a three-color gradient.
  ///
  /// Example:
  /// ```dart
  /// GooeyZone.radialGradient(
  ///   gooiness: 40,
  ///   color: Colors.red,
  ///   secondColor: Colors.orange,
  ///   center: Alignment.center,
  ///   radius: 0.5,
  ///   child: Column(
  ///     children: [
  ///       GooeyBlob(shape: const BlobShape.circle(), child: Icon(Icons.add)),
  ///       GooeyBlob(shape: const BlobShape.circle(), child: Icon(Icons.share)),
  ///       GooeyBlob(shape: const BlobShape.circle(), child: Icon(Icons.edit)),
  ///     ],
  ///   ),
  /// )
  /// ```
  const GooeyZone.radialGradient({
    super.key,

    /// The intensity of the gooey effect. Higher values create more
    /// pronounced liquid-like deformation. Must be non-negative.
    required this.gooiness,

    /// The primary (center) color of the gradient.
    required this.color,

    /// The second (outer) color in the gradient.
    required Color this.secondColor,

    /// An optional third color for a three-color gradient.
    this.thirdColor,

    /// The center point of the gradient. Defaults to [Alignment.center].
    AlignmentGeometry this.center = Alignment.center,

    /// The radius of the gradient. Defaults to 0.5.
    double this.radius = 0.5,

    /// The width of the border around the zone. Defaults to 0.0 (no border).
    this.borderWidth = 0.0,

    /// The color of the border. Defaults to transparent.
    this.borderColor = Colors.transparent,
    required super.child,
  }) : assert(gooiness >= 0, 'Gooiness must be non-negative'),
       assert(borderWidth >= 0, 'Border width must be non-negative'),
       fillType = thirdColor != null ? FillType.radial3 : FillType.radial2,
       begin = null,
       end = null;

  /// The intensity of the gooey effect. Higher values create more
  /// pronounced liquid-like deformation at the edges.
  final double gooiness;

  /// The primary color of the gooey zone.
  final Color color;

  /// The fill type used for rendering (solid or gradient).
  final FillType fillType;

  /// The second color in the gradient (used for linear/radial gradients).
  final Color? secondColor;

  /// The third color in a three-color gradient.
  final Color? thirdColor;

  /// The start point for linear gradient. Null for non-linear fills.
  final AlignmentGeometry? begin;

  /// The end point for linear gradient. Null for non-linear fills.
  final AlignmentGeometry? end;

  /// The center point for radial gradient. Null for non-radial fills.
  final AlignmentGeometry? center;

  /// The radius for radial gradient. Null for non-radial fills.
  final double? radius;

  /// The width of the border around the zone.
  final double borderWidth;

  /// The color of the border around the zone.
  final Color borderColor;

  @override
  RenderGooeyZone createRenderObject(BuildContext context) {
    return RenderGooeyZone(
      gooiness: gooiness,
      color: color,
      fillType: fillType,
      color2: secondColor,
      color3: thirdColor,
      gradientStart: begin,
      gradientEnd: end,
      gradientFocal: center,
      gradientRadius: radius,
      borderWidth: borderWidth,
      borderColor: borderColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderGooeyZone renderObject) {
    renderObject
      ..gooiness = gooiness
      ..color = color
      ..fillType = fillType
      ..color2 = secondColor
      ..color3 = thirdColor
      ..gradientStart = begin
      ..gradientEnd = end
      ..gradientFocal = center
      ..gradientRadius = radius
      ..borderWidth = borderWidth
      ..borderColor = borderColor
      ..textDirection = Directionality.maybeOf(context);
  }
}

/// A widget that acts as a gooey blob within a [GooeyZone].
///
/// GooeyBlobs are child widgets that push against the gooey zone boundaries,
/// creating the liquid deformation effect. They must be descendants of a [GooeyZone].
///
/// Example:
/// ```dart
/// GooeyZone(
///   color: Colors.blue,
///   gooiness: 30,
///   child: Row(
///     children: [
///       GooeyBlob(
///         child: Icon(Icons.add),
///         shape: const BlobShape.circle(), // default
///       ),
///       GooeyBlob(
///         child: Icon(Icons.share),
///         shape: BlobShape.rounded(8.0),
///       ),
///     ],
///   ),
/// )
/// ```
class GooeyBlob extends SingleChildRenderObjectWidget {
  /// Creates a [GooeyBlob] with the given parameters.
  const GooeyBlob({
    super.key,
    required super.child,

    /// The shape of the blob. Defaults to a circle.
    this.shape = const BlobShape.circle(),

    /// If true, the blob acts as a cutout (erases the gooey effect in its area).
    this.cutout = false,
  });

  /// The shape of the blob.
  final BlobShape shape;

  /// Whether this blob acts as a cutout.
  final bool cutout;

  @override
  RenderGooeyBlob createRenderObject(BuildContext context) {
    return RenderGooeyBlob(shape: shape, cutout: cutout);
  }

  @override
  void updateRenderObject(BuildContext context, RenderGooeyBlob renderObject) {
    renderObject.shape = shape;
    renderObject.cutout = cutout;
  }
}

/// The render object for [GooeyZone] that handles the shader logic and blob management.
class RenderGooeyZone extends RenderProxyBox {
  static const int maxBlobCount = 10;

  RenderGooeyZone({
    required double gooiness,
    required Color color,
    FillType fillType = FillType.solid,
    Color? color2,
    Color? color3,
    AlignmentGeometry? gradientStart,
    AlignmentGeometry? gradientEnd,
    AlignmentGeometry? gradientFocal,
    double? gradientRadius,
    required double borderWidth,
    required Color borderColor,
  }) : _gooiness = gooiness,
       _color = color,
       _fillType = fillType,
       _color2 = color2,
       _color3 = color3,
       _gradientStart = gradientStart,
       _gradientEnd = gradientEnd,
       _gradientFocal = gradientFocal,
       _gradientRadius = gradientRadius,
       _borderWidth = borderWidth,
       _borderColor = borderColor {
    _loadProgram();
  }

  ui.FragmentProgram? _program;

  final List<RenderGooeyBlob> _blobs = [];
  TextDirection? _textDirection;

  double _gooiness;
  set gooiness(double value) {
    if (_gooiness == value) return;
    _gooiness = value;
    markNeedsPaint();
  }

  Color _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  FillType _fillType;
  set fillType(FillType value) {
    if (_fillType == value) return;
    _fillType = value;
    markNeedsPaint();
  }

  Color? _color2;
  set color2(Color? value) {
    if (_color2 == value) return;
    _color2 = value;
    markNeedsPaint();
  }

  Color? _color3;
  set color3(Color? value) {
    if (_color3 == value) return;
    _color3 = value;
    markNeedsPaint();
  }

  AlignmentGeometry? _gradientStart;
  set gradientStart(AlignmentGeometry? value) {
    if (_gradientStart == value) return;
    _gradientStart = value;
    markNeedsPaint();
  }

  AlignmentGeometry? _gradientEnd;
  set gradientEnd(AlignmentGeometry? value) {
    if (_gradientEnd == value) return;
    _gradientEnd = value;
    markNeedsPaint();
  }

  AlignmentGeometry? _gradientFocal;
  set gradientFocal(AlignmentGeometry? value) {
    if (_gradientFocal == value) return;
    _gradientFocal = value;
    markNeedsPaint();
  }

  double? _gradientRadius;
  set gradientRadius(double? value) {
    if (_gradientRadius == value) return;
    _gradientRadius = value;
    markNeedsPaint();
  }

  double _borderWidth;
  set borderWidth(double value) {
    if (_borderWidth == value) return;
    _borderWidth = value;
    markNeedsPaint();
  }

  Color _borderColor;
  set borderColor(Color value) {
    if (_borderColor == value) return;
    _borderColor = value;
    markNeedsPaint();
  }

  Future<void> _loadProgram() async {
    try {
      _program = await ui.FragmentProgram.fromAsset(_kShaderAsset);
    } catch (e) {
      debugPrint('Error loading shader: $e');
      _program = null;
    }
    markNeedsPaint();
  }

  void _registerBlob(RenderGooeyBlob blob) {
    if (_blobs.contains(blob)) return;
    assert(
      _blobs.length < maxBlobCount,
      'Exceeded maximum blob count of $maxBlobCount',
    );
    _blobs.add(blob);
    markNeedsBlobsUpdate();
    markNeedsPaint();
  }

  void _unregisterBlob(RenderGooeyBlob blob) {
    _blobs.remove(blob);
    markNeedsBlobsUpdate();
    markNeedsPaint();
  }

  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  List<RenderGooeyBlob>? _effectiveBlobs;

  /// Returns the list of blobs in the order they should be rendered (normal blobs first, then cutouts).
  List<RenderGooeyBlob> get effectiveBlobs {
    if (_effectiveBlobs != null) return _effectiveBlobs!;
    final normal = <RenderGooeyBlob>[];
    final cutouts = <RenderGooeyBlob>[];
    for (final blob in _blobs) {
      if (blob.cutout) {
        cutouts.add(blob);
      } else {
        normal.add(blob);
      }
    }
    return _effectiveBlobs = [...normal, ...cutouts];
  }

  void markNeedsBlobsUpdate() {
    _effectiveBlobs = null;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_program == null) {
      super.paint(context, offset);
      return;
    }

    final w = size.width;
    final h = size.height;

    final goo = _gooiness / w;

    final shader = _program!.fragmentShader();
    int i = 0;

    shader.setFloat(i++, offset.dx);
    shader.setFloat(i++, offset.dy);
    shader.setFloat(i++, w);
    shader.setFloat(i++, h);

    final blobs = effectiveBlobs;

    shader.setFloat(i++, goo);
    shader.setFloat(i++, blobs.length.toDouble());
    shader.setFloat(i++, _borderWidth > 0 ? _borderWidth / w : 0.0);
    shader.setFloat(i++, _fillType.value.toDouble());

    shader.setFloat(i++, _color.r);
    shader.setFloat(i++, _color.g);
    shader.setFloat(i++, _color.b);
    shader.setFloat(i++, _color.a);

    final c2 = _color2 ?? _color;
    shader.setFloat(i++, c2.r);
    shader.setFloat(i++, c2.g);
    shader.setFloat(i++, c2.b);
    shader.setFloat(i++, c2.a);

    final c3 = _color3 ?? _color2 ?? _color;
    shader.setFloat(i++, c3.r);
    shader.setFloat(i++, c3.g);
    shader.setFloat(i++, c3.b);
    shader.setFloat(i++, c3.a);

    shader.setFloat(i++, _borderColor.r);
    shader.setFloat(i++, _borderColor.g);
    shader.setFloat(i++, _borderColor.b);
    shader.setFloat(i++, _borderColor.a);

    // Gradient params
    final textDir = _textDirection ?? TextDirection.ltr;
    if (_fillType == FillType.linear2 || _fillType == FillType.linear3) {
      final start = _gradientStart?.resolve(textDir) ?? Alignment.centerLeft;
      final end = _gradientEnd?.resolve(textDir) ?? Alignment.centerRight;
      shader.setFloat(i++, (start.x + 1.0) * 0.5);
      shader.setFloat(i++, (start.y + 1.0) * 0.5);
      shader.setFloat(i++, (end.x + 1.0) * 0.5);
      shader.setFloat(i++, (end.y + 1.0) * 0.5);
    } else if (_fillType == FillType.radial2 || _fillType == FillType.radial3) {
      final focal = _gradientFocal?.resolve(textDir) ?? Alignment.center;
      final radius = _gradientRadius ?? 0.5;
      shader.setFloat(i++, (focal.x + 1.0) * 0.5);
      shader.setFloat(i++, (focal.y + 1.0) * 0.5);
      shader.setFloat(i++, radius);
      shader.setFloat(i++, 0.0);
    } else {
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
    }

    Rect? blobBounds;
    const kBlobOffset = 28;
    const kBlobParamsOffset = 68;

    for (int b = 0; b < maxBlobCount; b++) {
      final int dataIdx = (kBlobOffset + b * 4);
      final int paramsIdx = (kBlobParamsOffset + b * 4);

      if (b < blobs.length) {
        final blob = blobs.elementAt(b);
        final blobOffset = blob.getTransformTo(this);
        final blobRect = MatrixUtils.transformRect(
          blobOffset,
          blob.paintBounds,
        );
        final blobSize = blobRect.size;
        final shouldDraw = blobSize != Size.zero;

        final double cx;
        final double cy;
        if (shouldDraw) {
          cx = (blobRect.center.dx - offset.dx) / w;
          cy = (blobRect.center.dy - offset.dy) / w;
          blobBounds = blobBounds?.expandToInclude(blobRect) ?? blobRect;
        } else {
          cx = 0.0;
          cy = 0.0;
        }
        final shape = blob.shape;
        double hw;
        double hh;
        double borderRadius = 0.0;
        double type = 0.0;

        switch (shape) {
          case _CircleBlob():
            final radius = blobSize.shortestSide * 0.5;
            hw = radius / w;
            hh = radius / w;
          case _RoundedRectBlob():
            hw = blobSize.width * 0.5 / w;
            hh = blobSize.height * 0.5 / w;
            borderRadius = shape.borderRadius / w;
            type = 1.0;
        }

        shader.setFloat(dataIdx + 0, cx);
        shader.setFloat(dataIdx + 1, cy);
        shader.setFloat(dataIdx + 2, hw);
        shader.setFloat(dataIdx + 3, hh);

        shader.setFloat(paramsIdx + 0, borderRadius);
        shader.setFloat(paramsIdx + 1, type);
        shader.setFloat(paramsIdx + 2, blob.cutout ? 1.0 : 0.0); // cutout
        shader.setFloat(paramsIdx + 3, 0.0); // unused
      } else {
        shader.setFloat(dataIdx + 0, 0.0);
        shader.setFloat(dataIdx + 1, 0.0);
        shader.setFloat(dataIdx + 2, 0.0);
        shader.setFloat(dataIdx + 3, 0.0);
        shader.setFloat(paramsIdx + 0, 0.0);
        shader.setFloat(paramsIdx + 1, 0.0);
        shader.setFloat(paramsIdx + 2, 0.0);
        shader.setFloat(paramsIdx + 3, 0.0);
      }
    }

    if (blobBounds != null) {
      final inflated = blobBounds.inflate(
        (_gooiness * .5) + (_borderWidth * 2),
      );
      context.canvas.drawRect(inflated, Paint()..shader = shader);
    }
    super.paint(context, offset);
  }
}

/// The render object for [GooeyBlob] that registers itself with the nearest ancestor [RenderGooeyZone].
class RenderGooeyBlob extends RenderProxyBox {
  RenderGooeyBlob({required BlobShape shape, bool cutout = false}) : _shape = shape, _cutout = cutout;

  BlobShape _shape;
  set shape(BlobShape value) {
    if (_shape == value) return;
    _shape = value;
    markNeedsPaint();
  }

  BlobShape get shape => _shape;

  bool get cutout => _cutout;
  bool _cutout;
  set cutout(bool value) {
    if (_cutout == value) return;
    _cutout = value;
    _zone?.markNeedsBlobsUpdate();
    markNeedsPaint();
  }

  RenderGooeyZone? _zone;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    RenderObject? current = parent;
    while (current != null) {
      if (current is RenderGooeyZone) {
        _zone = current;
        _zone!._registerBlob(this);
        break;
      }
      current = current.parent;
    }
    if (_zone == null) {
      throw FlutterError(
        'GooeyBlobShader must be a descendant of a GooeyZoneShader.',
      );
    }
  }

  @override
  void detach() {
    if (_zone != null) {
      _zone!._unregisterBlob(this);
      _zone = null;
    }
    super.detach();
  }
}

/// The shape configuration for a [GooeyBlob].
///
/// Use [BlobShape.circle] for circular blobs or [BlobShape.rounded] for
/// rounded rectangle blobs.
sealed class BlobShape {
  const BlobShape();

  /// Creates a circular blob shape.
  ///
  /// Example:
  /// ```dart
  /// GooeyBlob(
  ///   shape: BlobShape.circle(),
  ///   child: Icon(Icons.add),
  /// )
  /// ```
  const factory BlobShape.circle() = _CircleBlob;

  /// Creates a rounded rectangle blob shape.
  ///
  /// Example:
  /// ```dart
  /// GooeyBlob(
  ///   shape: BlobShape.rounded(12.0),
  ///   child: Icon(Icons.menu),
  /// )
  /// ```
  const factory BlobShape.rounded(double borderRadius) = _RoundedRectBlob;
}

class _CircleBlob extends BlobShape {
  const _CircleBlob();
}

class _RoundedRectBlob extends BlobShape {
  const _RoundedRectBlob(this.borderRadius);
  final double borderRadius;
}

/// The fill type used by [GooeyZone] to determine how to render the background.
enum FillType {
  /// Solid single-color fill.
  solid(0),

  /// Two-color linear gradient fill.
  linear2(1),

  /// Three-color linear gradient fill.
  linear3(2),

  /// Two-color radial gradient fill.
  radial2(3),

  /// Three-color radial gradient fill.
  radial3(4)
  ;

  const FillType(this.value);

  /// The internal value used by the shader.
  final int value;
}
