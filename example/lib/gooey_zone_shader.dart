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
  });

  final double gooiness;
  final Color color;
  final double borderWidth;
  final Color borderColor;

  @override
  RenderGooeyZoneShader createRenderObject(BuildContext context) {
    return RenderGooeyZoneShader(
      gooiness: gooiness,
      color: color,
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
    required double borderWidth,
    required Color borderColor,
  }) : _gooiness = gooiness,
       _color = color,
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

    const kBlobOffset = 6;
    final kCornerRadiusOffset = kBlobOffset + maxBlobCount * 4;
    final kTypeOffset = kCornerRadiusOffset + maxBlobCount * 4;
    final kColorOffset = kTypeOffset + maxBlobCount;
    final kBorderWidthOffset = kColorOffset + 4;
    final kBorderColorOffset = kBorderWidthOffset + 1;

    for (int b = 0; b < maxBlobCount; b++) {
      final int dataIdx = kBlobOffset + b * 4;
      final int cornerIdx = kCornerRadiusOffset + b * 4;
      final int typeIdx = kTypeOffset + b;

      if (b < _blobs.length) {
        final blob = _blobs[b];
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
        BorderRadius br = BorderRadius.zero;
        double type = 0.0;
        if (shape is _CircleBlobShader) {
          final radius = blobSize.shortestSide * 0.5;
          hw = radius / w;
          hh = radius / w;
        } else if (shape is _RoundedRectBlobShader) {
          hw = blobSize.width * 0.5 / w;
          hh = blobSize.height * 0.5 / w;
          br = shape.borderRadius.resolve(_textDirection);
          type = 1.0;
        } else {
          hw = blobSize.width * 0.5 / w;
          hh = blobSize.height * 0.5 / w;
        }
        shader.setFloat(dataIdx + 0, cx);
        shader.setFloat(dataIdx + 1, cy);
        shader.setFloat(dataIdx + 2, hw);
        shader.setFloat(dataIdx + 3, hh);

        shader.setFloat(cornerIdx + 0, br.topLeft.x / w);
        shader.setFloat(cornerIdx + 1, br.topRight.x / w);
        shader.setFloat(cornerIdx + 2, br.bottomRight.x / w);
        shader.setFloat(cornerIdx + 3, br.bottomLeft.x / w);
        shader.setFloat(typeIdx, type);
      } else {
        shader.setFloat(dataIdx + 0, 0.0);
        shader.setFloat(dataIdx + 1, 0.0);
        shader.setFloat(dataIdx + 2, 0.0);
        shader.setFloat(dataIdx + 3, 0.0);
        shader.setFloat(cornerIdx + 0, 0.0);
        shader.setFloat(cornerIdx + 1, 0.0);
        shader.setFloat(cornerIdx + 2, 0.0);
        shader.setFloat(cornerIdx + 3, 0.0);
        shader.setFloat(typeIdx, 0.0);
      }
    }

    shader.setFloat(kColorOffset + 0, _color.r);
    shader.setFloat(kColorOffset + 1, _color.g);
    shader.setFloat(kColorOffset + 2, _color.b);
    shader.setFloat(kColorOffset + 3, _color.a);

    shader.setFloat(
      kBorderWidthOffset,
      _borderWidth > 0 ? _borderWidth / w : 0.0,
    );
    shader.setFloat(kBorderColorOffset + 0, _borderColor.r);
    shader.setFloat(kBorderColorOffset + 1, _borderColor.g);
    shader.setFloat(kBorderColorOffset + 2, _borderColor.b);
    shader.setFloat(kBorderColorOffset + 3, _borderColor.a);

    context.canvas.drawRect((offset & size).inflate(_borderWidth * 2), Paint()..shader = shader);
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
