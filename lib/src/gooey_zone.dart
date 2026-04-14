import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gooey/src/snapshot_helper.dart';
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
    this.shouldSnapshot = true,
  }) : gradient = null;

  /// Creates a [GooeyZone] with a custom gradient fill for the blobs.
  const GooeyZone.withGradient({
    super.key,
    required Gradient this.gradient,
    this.blobOpacity = 1.0,
    this.blurRadius = 12.0,
    this.threshold = 0.5,
    required super.child,
    this.shouldSnapshot = true,
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

  /// If true, the zone will bake its blobs into a texture and reuse it across frames until any blob reports a change.
  ///
  /// If false, the zone will apply the goo effect live every frame without caching.
  ///
  /// Ideally this should stay true for static blobs, conditionally and temporarily set to false for animated blobs,
  /// and then set back to true when the animation is done to cache the final state.
  ///
  /// ```dart
  ///  GooeyZone(
  ///    shouldSnapshot: !isAnimating, // e.g !animationController.isAnimating
  ///    child: ..
  ///   );
  /// ```
  ///
  /// This parameter is useful when animating blobs. When an animation is running,
  /// set [shouldSnapshot] to false to render the gooey effect live each frame.
  /// Once the animation completes, set it back to true to enable texture
  /// caching and improve performance.
  final bool shouldSnapshot;

  @override
  RenderGooeyZone createRenderObject(BuildContext context) {
    return RenderGooeyZone(
      color: color,
      blurRadius: blurRadius,
      threshold: threshold,
      gradient: gradient,
      blobOpacity: blobOpacity,
      shouldSnapshot: shouldSnapshot,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderGooeyZone renderObject) {
    renderObject
      ..color = color
      ..blurRadius = blurRadius
      ..threshold = threshold
      ..gradient = gradient
      ..shouldSnapshot = shouldSnapshot
      ..blobOpacity = blobOpacity
      ..devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
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
    required bool shouldSnapshot,
    required double devicePixelRatio,
    Gradient? gradient,

    RenderBox? child,
  }) : _color = color,
       _blurRadius = blurRadius,
       _threshold = threshold,
       _blobOpacity = blobOpacity,
       _gradient = gradient,
       _shouldSnapshot = shouldSnapshot,
       _devicePixelRatio = devicePixelRatio,
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
    _invalidateSnapshot();
    markNeedsPaint();
  }

  Color _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    _blobPaint = null; // Invalidate blob paint cache
    _invalidateSnapshot();
    markNeedsPaint();
  }

  double _blurRadius;
  set blurRadius(double value) {
    if (_blurRadius == value) return;
    _blurRadius = value;
    _blobPaint = null; // Invalidate blob paint cache
    _invalidateSnapshot();
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

  double _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (_devicePixelRatio == value) return;
    _devicePixelRatio = value;
    _blobPaint = null;
    _invalidateSnapshot();
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get alwaysNeedsCompositing => true;

  ui.Image? _blobsSnapshot;

  // The flag that toggles between "Texture Mode" and "Live Filter Mode"
  bool _shouldSnapshot = true;
  set shouldSnapshot(bool value) {
    if (_shouldSnapshot == value) return;
    _shouldSnapshot = value;
    // If we stop snapshotting, kill the old image immediately.
    // If we start snapshotting, we'll bake on the next paint.
    _invalidateSnapshot();
    markNeedsPaint();
  }

  /// Public method for blobs to report changes
  void invalidateSnapshot() {
    // We only care about invalidating if we are actually in snapshot mode.
    // If shouldSnapshot is false, we are already painting live every frame.
    if (_shouldSnapshot && _blobsSnapshot != null) {
      _invalidateSnapshot();
      markNeedsPaint();
    }
  }

  Size? _lastSize;
  @override
  void performLayout() {
    super.performLayout();
    if (size == _lastSize) return;
    _lastSize = size;
    _blobPaint = null;
    _invalidateSnapshot();
  }

  void _invalidateSnapshot() {
    _blobsSnapshot?.dispose();
    _blobsSnapshot = null;
  }

  @override
  void dispose() {
    _opacityLayerHandle.layer = null;
    _filterLayerHandler.layer = null;
    _invalidateSnapshot();
    super.dispose();
  }

  @override
  void reassemble() {
    // We kill the snapshot so you can see your code changes immediately.
    _invalidateSnapshot();
    super.reassemble();
  }

  void _paintBlobs(PaintingContext context, Offset offset) {
    final double margin = (_blurRadius * 0.2) * 2;
    final bounds = (Offset.zero & size).inflate(margin);
    if (!_shouldSnapshot || _blobsSnapshot == null) {
      _filterLayerHandler.layer = context.pushColorFilter(offset, colorFilter, (
        ctx,
        offset,
      ) {
        for (final blob in _blobs) {
          blob.paintBlob(ctx.canvas, this, margin, blobPaint);
        }
      }, oldLayer: _filterLayerHandler.layer);

      if (_shouldSnapshot && _blobsSnapshot == null) {
        final snapshotHelper = SnaphshotHelper(
          _filterLayerHandler.layer!,
          pixelRatio: _devicePixelRatio,
        );
        _blobsSnapshot = snapshotHelper.snapshotAsync(bounds, offset);
        // Release the live layer, we'll use the snapshot from now on until invalidated.
        Future.microtask(() {
          _filterLayerHandler.layer = null;
          markNeedsPaint();
        });
      }
    }

    if (_shouldSnapshot && _blobsSnapshot != null) {
      final Rect src = Rect.fromLTWH(0, 0, _blobsSnapshot!.width.toDouble(), _blobsSnapshot!.height.toDouble());
      context.canvas.drawImageRect(_blobsSnapshot!, src, bounds, Paint());
    }
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
