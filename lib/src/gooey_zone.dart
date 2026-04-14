import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
part 'gooey_blob.dart';

/// A zone that renders gooey blobs behind its registered [GooeyBlob] children.
///
/// [GooeyZone] manages a collection of gooey blobs that automatically register
/// themselves when they attach to the render tree.
///
/// ```dart
/// GooeyZone(
///   color: Colors.indigo,
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
    required this.color,
    this.blurRadius = 12.0,
    this.threshold = 0.5,
    required super.child,
    this.blobOpacity = 1.0,
  }) : gradient = null;

  /// Creates a [GooeyZone] with a custom gradient fill for the blobs.
  const GooeyZone.withGradient({
    super.key,
    required Gradient this.gradient,
    this.blobOpacity = 1.0,
    this.blurRadius = 12.0,
    this.threshold = 0.5,
    required super.child,
  }) : color = Colors.white;

  /// Optional gradient to fill the blobs. If null, [color] is used as a solid fill.
  ///
  /// Use a gradient with full opacity (alpha = 1.0) for best results,
  /// as the blur and thresholding will be applied to the alpha channel of the blob layer.
  /// The [blobOpacity] parameter can be used to adjust the final opacity of the blobs without affecting the blur and thresholding.
  final Gradient? gradient;

  /// Fill color of all blobs.
  ///
  /// Provided Color should have full opacity (alpha = 1.0) for best results,
  ///  as the blur and thresholding will be applied to the alpha channel of the blob layer.
  ///  The [blobOpacity] parameter can be used to adjust the final opacity of the blobs without affecting the blur and thresholding.
  final Color color;

  /// Gaussian blur radius applied to the blob layer before thresholding.
  /// Higher values = wider merge distance between blobs.
  /// Defaults to 12.0.
  final double blurRadius;

  /// Alpha threshold for the goo snap effect (0.0–1.0).
  /// Higher values = sharper, more aggressive merge snap.
  /// Defaults to 0.5.
  final double threshold;

  /// Opacity applied to the blob layer only (not the child content).
  /// At 1.0 (default) no extra layer is pushed. At 0.0 blobs are skipped entirely.
  final double blobOpacity;

  @override
  RenderGooeyZone createRenderObject(BuildContext context) {
    return RenderGooeyZone(
      color: color,
      blurRadius: blurRadius,
      threshold: threshold,
      gradient: gradient,
      blobOpacity: blobOpacity,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderGooeyZone renderObject) {
    renderObject
      ..color = color
      ..blurRadius = blurRadius
      ..threshold = threshold
      ..gradient = gradient
      ..blobOpacity = blobOpacity;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('blurRadius', blurRadius));
    properties.add(DoubleProperty('threshold', threshold));
    properties.add(DoubleProperty('blobOpacity', blobOpacity));
  }
}

/// Manages a zone of registered gooey blobs.
class RenderGooeyZone extends RenderProxyBox {
  /// Creates a [RenderGooeyZone] with the given parameters.
  RenderGooeyZone({
    required Color color,
    required double blurRadius,
    required double threshold,
    required double blobOpacity,
    Gradient? gradient,
    RenderBox? child,
  }) : _color = color,
       _blurRadius = blurRadius,
       _threshold = threshold,
       _blobOpacity = blobOpacity,
       _gradient = gradient,
       super(child);

  Paint? _blobPaint;

  /// Lazily creates and caches the paint object used to render blobs
  Paint get blobPaint {
    if (_blobPaint != null) {
      return _blobPaint!;
    }
    final paint = Paint()
      ..color = _color
      ..isAntiAlias = false;
    if (_gradient != null && hasSize) {
      paint.shader = _gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    }
    if (_blurRadius > 0) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, _blurRadius);
    }
    return _blobPaint = paint;
  }

  final _opacityLayerHandle = LayerHandle<OpacityLayer>();
  final _filterLayerHandler = LayerHandle<ColorFilterLayer>();
  final List<RenderGooeyBlob> _blobs = [];
  ColorFilter? _filter;

  void _registerBlob(RenderGooeyBlob blob) {
    if (blob.cutout) {
      _blobs.add(blob);
    } else {
      _blobs.insert(0, blob);
    }
    markNeedsPaint();
  }

  void _unregisterBlob(RenderGooeyBlob blob) {
    _blobs.remove(blob);
    markNeedsPaint();
  }

  Gradient? _gradient;
  set gradient(Gradient? value) {
    if (_gradient == value) return;
    _gradient = value;
    _blobPaint = null; // Invalidate blob paint cache
    markNeedsPaint();
  }

  Color _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    _blobPaint = null; // Invalidate blob paint cache
    markNeedsPaint();
  }

  double _blurRadius;
  set blurRadius(double value) {
    if (_blurRadius == value) return;
    _blurRadius = value;
    _blobPaint = null; // Invalidate blob paint cache
    markNeedsPaint();
  }

  double _threshold;
  set threshold(double value) {
    if (_threshold == value) return;
    _threshold = value;
    _filter = null; // Invalidate cache
    markNeedsPaint();
  }

  double _blobOpacity;
  set blobOpacity(double value) {
    if (_blobOpacity == value) return;
    _blobOpacity = value;
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void dispose() {
    _opacityLayerHandle.layer = null;
    _filterLayerHandler.layer = null;
    super.dispose();
  }

  void _paintBlobs(PaintingContext context, Offset offset) {
    _filterLayerHandler.layer = context.pushColorFilter(offset, colorFilter, (
      ctx,
      offset,
    ) {
      final overdraw = _blurRadius * .2;
      for (final blob in _blobs) {
        blob.paintBlob(ctx.canvas, this, overdraw, blobPaint);
      }
    }, oldLayer: _filterLayerHandler.layer);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_blobs.isNotEmpty && _blobOpacity > 0.0) {
      if (_blobOpacity < 1.0) {
        _opacityLayerHandle.layer = context.pushOpacity(
          offset,
          (_blobOpacity * 255).round(),
          _paintBlobs,
          oldLayer: _opacityLayerHandle.layer,
        );
      } else {
        _opacityLayerHandle.layer = null;
        _paintBlobs(context, offset);
      }
    } else {
      _opacityLayerHandle.layer = null;
    }
    super.paint(context, offset);
  }

  /// Lazily computes and caches the color filter used for thresholding the blurred blobs
  ColorFilter get colorFilter {
    if (_filter != null) {
      return _filter!;
    }
    final contrast = 50.0 + _threshold * 20.0;
    final biasValue = -contrast * 127.5;
    // dart format off
    final filter = ui.ColorFilter.matrix(<double>[
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, contrast, biasValue,
    ]);
    // dart format on
    return _filter = filter;
  }
}
