import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GooeyZoneShader extends SingleChildRenderObjectWidget {
  const GooeyZoneShader({
    super.key,
    required this.gooiness,
    required this.color,
    required super.child,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
  }) : fillType = 0,
       color2 = null,
       color3 = null,
       begin = null,
       end = null,
       center = null,
       radius = null;

  const GooeyZoneShader.linearGradient({
    super.key,
    required this.gooiness,
    required this.color,
    required Color this.color2,
    this.color3,
    this.begin,
    this.end,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    required super.child,
  }) : fillType = 1,
       center = null,
       radius = null;

  const GooeyZoneShader.radialGradient({
    super.key,
    required this.gooiness,
    required this.color,
    required Color this.color2,
    this.color3,
    this.center,
    this.radius,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    required super.child,
  }) : fillType = 2,
       begin = null,
       end = null;

  final double gooiness;
  final Color color;
  final int fillType;
  final Color? color2;
  final Color? color3;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final AlignmentGeometry? center;
  final double? radius;
  final double borderWidth;
  final Color borderColor;

  @override
  RenderGooeyZoneShader createRenderObject(BuildContext context) {
    return RenderGooeyZoneShader(
      gooiness: gooiness,
      color: color,
      fillType: fillType,
      color2: color2,
      color3: color3,
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
    RenderGooeyZoneShader renderObject,
  ) {
    renderObject
      ..gooiness = gooiness
      ..color = color
      ..fillType = fillType
      ..color2 = color2
      ..color3 = color3
      ..gradientStart = begin
      ..gradientEnd = end
      ..gradientFocal = center
      ..gradientRadius = radius
      ..borderWidth = borderWidth
      ..borderColor = borderColor
      ..textDirection = Directionality.maybeOf(context);
  }
}

class GooeyBlobShader extends SingleChildRenderObjectWidget {
  const GooeyBlobShader({
    super.key,
    required super.child,
    this.shape = const BlobShapeShader.circle(),
  });

  final BlobShapeShader shape;

  @override
  RenderGooeyBlobShader createRenderObject(BuildContext context) {
    return RenderGooeyBlobShader(shape: shape);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderGooeyBlobShader renderObject,
  ) {
    renderObject.shape = shape;
  }
}

sealed class BlobShapeShader {
  const BlobShapeShader();

  const factory BlobShapeShader.circle() = _CircleBlobShader;
  const factory BlobShapeShader.rounded(BorderRadius borderRadius) =
      _RoundedRectBlobShader;
}

class _CircleBlobShader extends BlobShapeShader {
  const _CircleBlobShader();
}

class _RoundedRectBlobShader extends BlobShapeShader {
  const _RoundedRectBlobShader(this.borderRadius);
  final BorderRadius borderRadius;
}

class RenderGooeyZoneShader extends RenderProxyBox {
  static const int maxBlobCount = 8;

  RenderGooeyZoneShader({
    required double gooiness,
    required Color color,
    int fillType = 0,
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
       _gradientCenter = gradientFocal,
       _gradientRadius = gradientRadius,
       _borderWidth = borderWidth,
       _borderColor = borderColor {
    _loadProgram();
  }

  ui.FragmentProgram? _program;

  final List<RenderGooeyBlobShader> _blobs = [];
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

  int _fillType;
  set fillType(int value) {
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

  AlignmentGeometry? _gradientCenter;
  set gradientFocal(AlignmentGeometry? value) {
    if (_gradientCenter == value) return;
    _gradientCenter = value;
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
    _program = await ui.FragmentProgram.fromAsset('shaders/gooey.frag');
    markNeedsPaint();
  }

  void _registerBlob(RenderGooeyBlobShader blob) {
    _blobs.add(blob);
    markNeedsPaint();
  }

  void _unregisterBlob(RenderGooeyBlobShader blob) {
    _blobs.remove(blob);
    markNeedsPaint();
  }

  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_program == null) {
      super.paint(context, offset);
      return;
    }

    final w = size.width;
    final h = size.height;

    final blobCount = _blobs.length.clamp(0, maxBlobCount);
    final goo = _gooiness / w;

    final shader = _program!.fragmentShader();
    int i = 0;

    shader.setFloat(i++, offset.dx);
    shader.setFloat(i++, offset.dy);
    shader.setFloat(i++, w);
    shader.setFloat(i++, h);

    shader.setFloat(i++, goo);
    shader.setFloat(i++, blobCount.toDouble());
    shader.setFloat(i++, _borderWidth > 0 ? _borderWidth / w : 0.0);
    shader.setFloat(i++, _fillType.toDouble());

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
   if (_fillType == 1) {
      final start = _gradientStart?.resolve(textDir) ?? Alignment.centerLeft;
      final end = _gradientEnd?.resolve(textDir) ?? Alignment.centerRight;
      shader.setFloat(i++, (start.x + 1.0) * 0.5);
      shader.setFloat(i++, (start.y + 1.0) * 0.5);
      shader.setFloat(i++, (end.x + 1.0) * 0.5);
      shader.setFloat(i++, (end.y + 1.0) * 0.5);
    } else if (_fillType == 2) {
      final center = _gradientCenter?.resolve(textDir) ?? Alignment.center;
      final radius = _gradientRadius ?? 0.5;
      shader.setFloat(i++, (center.x + 1.0) * 0.5);
      shader.setFloat(i++, (center.y + 1.0) * 0.5);
      shader.setFloat(i++, radius);
      shader.setFloat(i++, 0.0);
    } else {
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
    }

    const kBlobOffset = 28;
    final kBlobParamsOffset = 60;

    final blobs = _blobs.where((b) => b.hasSize && b.size != Size.zero);
    for (int b = 0; b < maxBlobCount; b++) {
      final int dataIdx = kBlobOffset + b * 4;
      final int paramsIdx = kBlobParamsOffset + b * 4;

      if (b < blobs.length) {
        final blob = blobs.elementAt(b);
        final blobOffset = blob.getTransformTo(this);
        final blobRect = MatrixUtils.transformRect(
          blobOffset,
          blob.paintBounds,
        );
        final blobSize = blobRect.size;

        final cx = (blobRect.center.dx - offset.dx) / w;
        final cy = (blobRect.center.dy - offset.dy) / w;

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
          borderRadius = shape.borderRadius.topLeft.x / w;
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
        shader.setFloat(paramsIdx + 2, 0.0); // unused
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

    context.canvas.drawRect(
      (offset & size).inflate((_borderWidth * 2) + 4),
      Paint()..shader = shader,
    );
    super.paint(context, offset);
  }
}

class RenderGooeyBlobShader extends RenderProxyBox {
  RenderGooeyBlobShader({required BlobShapeShader shape}) : _shape = shape;

  BlobShapeShader _shape;
  set shape(BlobShapeShader value) {
    if (_shape == value) return;
    _shape = value;
    markNeedsPaint();
  }

  BlobShapeShader get shape => _shape;

  RenderGooeyZoneShader? _zone;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    RenderObject? current = parent;
    while (current != null) {
      if (current is RenderGooeyZoneShader) {
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
