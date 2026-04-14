import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

/// Helper class for capturing a layer tree as an image snapshot.
///
/// This utility takes a [ContainerLayer] and renders it to an [ui.Image],
/// which can then be drawn as a texture for performance-optimized rendering.
/// The snapshot caches the blob layer as a texture, avoiding expensive
/// recalculation each frame when blobs haven't changed.
class SnaphshotHelper {
  /// The layer to capture.
  final ContainerLayer layer;

  /// Device pixel ratio for the snapshot resolution.
  ///
  /// Higher values produce sharper images at the cost of memory.
  /// Defaults to 1.0.
  final double pixelRatio;

  /// Creates a new SnapshotHelper for the given [layer].
  ///
  /// The [pixelRatio] controls the output resolution multiplier.
  const SnaphshotHelper(this.layer, {this.pixelRatio = 1.0});

  /// Creates a [ui.Scene] for rendering the layer within the given bounds.
  ui.Scene _createSceneForImage(Rect bounds, Offset offset) {
    final builder = ui.SceneBuilder();
    final transform = Matrix4.diagonal3Values(pixelRatio, pixelRatio, 1);
    transform.translateByDouble(-(bounds.left + offset.dx), -(bounds.top + offset.dy), 0, 1);
    builder.pushTransform(transform.storage);
    return layer.buildScene(builder);
  }

  /// Captures the layer as an image within the specified bounds.
  ///
  /// Returns an [ui.Image] that can be drawn to a canvas.
  /// The caller is responsible for disposing the returned image.
  ui.Image snapshotAsync(Rect bounds, Offset offset) {
    final ui.Scene scene = _createSceneForImage(bounds, offset);
    try {
      return scene.toImageSync(
        (pixelRatio * bounds.width).ceil(),
        (pixelRatio * bounds.height).ceil(),
      );
    } finally {
      scene.dispose();
    }
  }
}
