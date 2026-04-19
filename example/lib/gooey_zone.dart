import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum FillType {
  solid(0),
  linear2(1),
  linear3(2),
  radial2(3),
  radial3(4);

  const FillType(this.value);
  final int value;
}

class GooeyZone extends SingleChildRenderObjectWidget {
  const GooeyZone({
    super.key,
     this.gooiness = 30,
    required this.color,
    required super.child,
    this.borderWidth = 0.0,
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

  const GooeyZone.linearGradient({
    super.key,
    required this.gooiness,
    required this.color,
    required Color this.secondColor,
    this.thirdColor,
    AlignmentGeometry this.begin = Alignment.centerLeft,
    AlignmentGeometry this.end = Alignment.centerRight,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    required super.child,
  }) : assert(gooiness >= 0, 'Gooiness must be non-negative'),
       assert(borderWidth >= 0, 'Border width must be non-negative'),
       fillType = thirdColor != null ? FillType.linear3 : FillType.linear2,
       center = null,
       radius = null;

  const GooeyZone.radialGradient({
    super.key,
    required this.gooiness,
    required this.color,
    required Color this.secondColor,
    this.thirdColor,
    AlignmentGeometry this.center = Alignment.center,
    double this.radius = 0.5,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    required super.child,
  }) : assert(gooiness >= 0, 'Gooiness must be non-negative'),
       assert(borderWidth >= 0, 'Border width must be non-negative'),
       fillType = thirdColor != null ? FillType.radial3 : FillType.radial2,
       begin = null,
       end = null;

  final double gooiness;
  final Color color;
  final FillType fillType;
  final Color? secondColor;
  final Color? thirdColor;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final AlignmentGeometry? center;
  final double? radius;
  final double borderWidth;
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
  void updateRenderObject(
    BuildContext context,
    RenderGooeyZone renderObject,
  ) {
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

class GooeyBlob extends SingleChildRenderObjectWidget {
  const GooeyBlob({
    super.key,
    required super.child,
    this.shape = const BlobShape.circle(),
    this.cutout = false,
  });

  final BlobShape shape;
  final bool cutout;

  @override
  RenderGooeyBlob createRenderObject(BuildContext context) {
    return RenderGooeyBlob(shape: shape, cutout: cutout);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderGooeyBlob renderObject,
  ) {
    renderObject.shape = shape;
    renderObject.cutout = cutout;
  }
}

sealed class BlobShape {
  const BlobShape();

  const factory BlobShape.circle() = _CircleBlobShader;

  const factory BlobShape.rounded(double borderRadius) =
      _RoundedRectBlobShader;
}

class _CircleBlobShader extends BlobShape {
  const _CircleBlobShader();
}

class _RoundedRectBlobShader extends BlobShape {
  const _RoundedRectBlobShader(this.borderRadius);
  final double borderRadius;
}

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
      _program = await ui.FragmentProgram.fromAsset('shaders/gooey.frag');
    } catch (e) {
      debugPrint('Error loading shader: $e');
      _program = null;
    }
    markNeedsPaint();
  }

  void _registerBlob(RenderGooeyBlob blob) {
    if (_blobs.contains(blob)) return;
    assert(_blobs.length < maxBlobCount, 'Exceeded maximum blob count of $maxBlobCount');
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
        if (shape is _CircleBlobShader) {
          final radius = blobSize.shortestSide * 0.5;
          hw = radius / w;
          hh = radius / w;
        } else if (shape is _RoundedRectBlobShader) {
          hw = blobSize.width * 0.5 / w;
          hh = blobSize.height * 0.5 / w;
          borderRadius = shape.borderRadius / w;
          type = 1.0;
        } else {
          hw = blobSize.width * 0.5 / w;
          hh = blobSize.height * 0.5 / w;
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

class RenderGooeyBlob extends RenderProxyBox {
  RenderGooeyBlob({required BlobShape shape, bool cutout = false})
    : _shape = shape,
      _cutout = cutout;

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
