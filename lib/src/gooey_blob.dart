part of 'gooey_zone.dart';

/// A per-child configuration widget for [GooeyZone].
///
/// [GooeyBlob] automatically attaches/detaches from the zone on lifecycle events.
/// It only carries blob shape information.
///
/// The blob is rendered as a background layer behind the child widget.
/// The gooey effect applies to the background layer only — the actual child
/// widget is not affected by the blur or thresholding and renders normally.
class GooeyBlob extends SingleChildRenderObjectWidget {
  /// Creates a [GooeyBlob] with the given parameters.
  const GooeyBlob({
    super.key,
    required super.child,
    this.shape = const BlobShape.circle(),
    this.cutout = false,
    this.color,
  });

  /// If true, this blob will punch a hole in the goo instead of adding to it.
  final bool cutout;

  /// Shape of the blob drawn behind this child.
  ///
  /// This defines the background blob shape. The child widget renders on top
  /// of the blob and is not affected by the gooey effect.
  final BlobShape shape;

  /// Optional fill color for this blob.
  /// If null, inherits the [GooeyZone.color] or uses the zone's gradient.
  final Color? color;

  @override
  RenderGooeyBlob createRenderObject(BuildContext context) {
    return RenderGooeyBlob(
      shape: shape,
      cutout: cutout,
      color: color,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderGooeyBlob renderObject) {
    renderObject
      ..shape = shape
      ..cutout = cutout
      ..color = color
      ..textDirection = Directionality.maybeOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BlobShape>('shape', shape));
    properties.add(FlagProperty('cutout', value: cutout, ifTrue: 'cutout'));
    properties.add(ColorProperty('color', color));
  }
}

/// A simple proxy render object that registers itself with the nearest [RenderGooeyZone].
///
/// it also paints the blob shape on the canvas when requested by the zone.
class RenderGooeyBlob extends RenderProxyBox {
  /// Creates a [RenderGooeyBlob] with the given parameters.
  RenderGooeyBlob({
    required BlobShape shape,
    RenderBox? child,
    bool cutout = false,
    Color? color,
    TextDirection? textDirection,
  }) : _shape = shape,
       _cutout = cutout,
       _color = color,
       _textDirection = textDirection,
       super(child);

  BlobShape _shape;
  set shape(BlobShape value) {
    if (_shape == value) return;
    _shape = value;
    _bloobyShape = null;
    markNeedsPaint();
  }

  bool _cutout;

  /// If true, this blob will punch a hole in the goo instead of adding to it.
  bool get cutout => _cutout;

  set cutout(bool value) {
    if (_cutout == value) return;
    _cutout = value;
    markNeedsPaint();
  }

  Color? _color;

  /// Optional fill color for this blob.
  Color? get color => _color;

  set color(Color? value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  TextDirection? _textDirection;

  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _zone?.invalidateSnapshot();
    markNeedsPaint();
  }

  Path? _bloobyShape;

  RenderGooeyZone? _zone;

  Size? _lastSize;
  @override
  void performLayout() {
    super.performLayout();
    if (size == _lastSize) return;
    _lastSize = size;
    _zone?.invalidateSnapshot();
    _bloobyShape = null;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    // Find the nearest RenderGooeyZone ancestor
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
      throw FlutterError('GooeyBlob must be a descendant of a GooeyZone.');
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

  /// Paints this blob on the given canvas with the specified parameters.
  void paintBlob(
    Canvas canvas,
    RenderGooeyZone zone,
    double margin,
    Paint paint,
  ) {
    final childSize = size;
    if (childSize == Size.zero) return;

    // Get the full transformation matrix (includes rotation, scale, translation, etc.)
    final matrix = getTransformTo(zone);
    canvas.save();
    canvas.transform(matrix.storage);
    Paint blobPaint = paint;
    if (_color != null) {
      blobPaint = Paint()
        ..color = _color!
        ..isAntiAlias = false
        ..shader = paint.shader
        ..maskFilter = paint.maskFilter;
    }
    if (_cutout) {
      blobPaint = Paint()
        ..color = paint.color
        ..blendMode = BlendMode.clear
        ..maskFilter = paint.maskFilter
        ..isAntiAlias = false;
    }

    // Draw blob at local coordinates (already transformed by matrix)
    final blobCenter = childSize.center(Offset.zero);
    final shape = _shape;

    final oversize = Size(
      childSize.width + margin,
      childSize.height + margin,
    );
    switch (shape) {
      case _CircleBlob():
        final radius = childSize.shortestSide / 2 + margin;
        canvas.drawCircle(blobCenter, radius, blobPaint);
      case _RoundedRectBlob():
        final borderRadius = shape.borderRadius.resolve(_textDirection);
        final blobRect = Rect.fromCenter(
          center: blobCenter,
          width: oversize.width,
          height: oversize.height,
        );
        canvas.drawRRect(borderRadius.toRRect(blobRect), blobPaint);
      case _SuperEllipseBlob():
        final borderRadius = shape.borderRadius.resolve(_textDirection);
        final blobRect = Rect.fromCenter(
          center: blobCenter,
          width: oversize.width,
          height: oversize.height,
        );
        canvas.drawRSuperellipse(
          borderRadius.toRSuperellipse(blobRect),
          blobPaint,
        );
      case _BlobbyBlob():
        _bloobyShape ??= shape.generateBlobPath(oversize);
        canvas.drawPath(_bloobyShape!, blobPaint);
    }

    canvas.restore();
  }
}

/// Defines the shape of a [GooeyBlob]'s painted background.
///
/// ```dart
/// GooeyBlob(shape: const BlobShape.circle(), child: ...)
/// GooeyBlob(shape: BlobShape.rounded(BorderRadius.circular(12)), child: ...)
/// GooeyBlob(shape: BlobShape.superEllipse(BorderRadius.circular(16)), child: ...)
/// GooeyBlob(shape: BlobShape.blobby(), child: ...) // random irregular blob
/// GooeyBlob(shape: BlobShape.blobby(seed: 42), child: ...) // reproducible
/// ```
sealed class BlobShape {
  const BlobShape();

  /// Circular blob — radius = shortestSide / 2.
  const factory BlobShape.circle() = _CircleBlob;

  /// Rounded rect blob with the given [borderRadius].
  const factory BlobShape.rounded(BorderRadiusGeometry borderRadius) = _RoundedRectBlob;

  /// Super-ellipse (squircle-like) blob with the given [borderRadius].
  const factory BlobShape.superEllipse(BorderRadiusGeometry borderRadius) = _SuperEllipseBlob;

  /// Random irregular blob with configurable parameters.
  const factory BlobShape.blobby({int? seed, double irregularity, int? lobes}) = _BlobbyBlob;
}

class _CircleBlob extends BlobShape {
  const _CircleBlob();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is _CircleBlob && runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => 0;
}

class _RoundedRectBlob extends BlobShape {
  const _RoundedRectBlob(this.borderRadius);
  final BorderRadiusGeometry borderRadius;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _RoundedRectBlob && runtimeType == other.runtimeType && borderRadius == other.borderRadius;
  }

  @override
  int get hashCode => borderRadius.hashCode;
}

class _SuperEllipseBlob extends BlobShape {
  const _SuperEllipseBlob(this.borderRadius);
  final BorderRadiusGeometry borderRadius;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _SuperEllipseBlob && runtimeType == other.runtimeType && borderRadius == other.borderRadius;
  }

  @override
  int get hashCode => borderRadius.hashCode;
}

class _BlobbyBlob extends BlobShape {
  const _BlobbyBlob({this.seed, this.irregularity = 0.35, this.lobes});

  final int? seed;
  final double irregularity;
  final int? lobes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BlobbyBlob &&
          runtimeType == other.runtimeType &&
          seed == other.seed &&
          irregularity == other.irregularity &&
          lobes == other.lobes;

  @override
  int get hashCode => Object.hash(seed, irregularity, lobes);

  Path generateBlobPath(Size size) {
    final center = size.center(Offset.zero);
    final baseRadius = size.shortestSide / 2;
    final random = math.Random(seed);

    // 8-10 segments is the sweet spot for blurred blobs
    const segmentCount = 10;
    final points = <Offset>[];

    for (int i = 0; i < segmentCount; i++) {
      final angle = (i / segmentCount) * 2 * math.pi;

      // Simpler math: blur will handle the "organic" feel
      final noise = (random.nextDouble() - 0.5) * irregularity * baseRadius * 0.4;
      final r = baseRadius + noise;

      points.add(
        Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        ),
      );
    }

    final path = Path();
    // Start at the first midpoint
    path.moveTo(
      (points[0].dx + points[segmentCount - 1].dx) / 2,
      (points[0].dy + points[segmentCount - 1].dy) / 2,
    );

    for (int i = 0; i < segmentCount; i++) {
      final p0 = points[i];
      final p1 = points[(i + 1) % segmentCount];
      path.quadraticBezierTo(
        p0.dx,
        p0.dy,
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
    }

    return path;
  }
}
