# Gooey

[![Demo](https://raw.githubusercontent.com/Milad-Akarie/gooey/main/demo/Gooey_demo.gif)](#)

A layout-agnostic gooey/metaball effect widget for Flutter.

## What is Gooey?

Gooey creates a metaball-like visual effect by merging multiple widgets together regardless of their layout. Any widget wrapped in `GooeyBlob` and placed as a descendant of `GooeyZone` will visually merge with other blobs to create a cohesive, organic gooey effect.

`GooeyBlob` renders a background blob layer behind its child. The gooey effect (blur + thresholding) applies only to this background layer — the child widget itself renders normally on top and is not affected.

### Layout Agnostic

Gooey works with any Flutter widget arrangement. As long as your blobs are descendants of a `GooeyZone`, they will merge regardless of whether they're in a `Column`, `Row`, `Stack`, `Wrap`, or any other layout widget.

## Important Limitations

While the gooey effect is optimized for maximum performance, this package is **not** designed to create metaball backgrounds or full-surface gooey effects. For such effects (fluid backgrounds, shader-based metaballs, etc.), you should use a solution that works directly with fragment/pixel shaders.

## Features

- **Layout agnostic** — Works with any widget layout
- **Multiple blob shapes** — Circle, rounded rect, super-ellipse, or custom blobby shapes
- **Cutout support** — Create holes in the goo with `cutout: true`
- **Custom colors/gradients** — Per-blob or zone-wide fill coloring
- **Optimized rendering** — Uses Flutter's compositing layers for smooth performance
- **Texture caching** — Snapshot mode for static blobs improves performance

## Usage

> **Note:** The gooey effect relies on alpha channel thresholding. For best results, use colors with full opacity (alpha = 1.0). Use `blobOpacity` to adjust transparency without affecting the blur and thresholding. Note that the gooey effect applies only to the background blob layer — the actual child widget is not affected by the blur or thresholding and renders normally.

Wrap your widgets with `GooeyZone` and use `GooeyBlob` for children that should merge:

```dart
import 'package:gooey/gooey.dart';

GooeyZone(
  color: Colors.indigo,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      GooeyBlob(
        shape: const BlobShape.circle(),
        child: Icon(Icons.add),
      ),
      GooeyBlob(
        shape: const BlobShape.circle(),
        child: Icon(Icons.share),
      ),
      GooeyBlob(
        shape: const BlobShape.circle(),
        child: Icon(Icons.edit),
      ),
    ],
  ),
)
```

### Adjusting the Effect

Control the gooey behavior with these parameters:

- `blurRadius` — How far blobs merge (higher = wider merge distance). Defaults to 12.0.
- `threshold` — Alpha cutoff for the snap effect (0.0–1.0, higher = sharper merge). Defaults to 0.5.
- `sharpness` — Edge sharpness factor (0.0–1.0, maps to 1.0–50.0 internally). Defaults to 1.0.
- `overpaintFactor` — Extra paint margin for blobs as a multiplier of blurRadius. Defaults to 0.2.
- `blobOpacity` — Control blob layer opacity independently (0.0–1.0). Defaults to 1.0.
- `shouldSnapshot` — Enable texture caching for static blobs. Defaults to true.

```dart
GooeyZone(
  color: Colors.indigo,
  blurRadius: 16.0,     // Wider merge
  threshold: 0.6,       // Sharper snap
  sharpness: 0.5,       // Softer edges
  overpaintFactor: 0.3, // More paint margin
  blobOpacity: 0.8,     // Slightly transparent goo
  child: // ...
)
```

### Custom Shapes

Choose from built-in shapes or create custom blobs. The shape defines the background blob layer — the child widget renders on top of it:

```dart
// Circle (default)
GooeyBlob(shape: .circle(), child: ...)

// Rounded rectangle
GooeyBlob(shape: .rounded(BorderRadius.circular(8)), child: ...)

// Super-ellipse (squircle)
GooeyBlob(shape: .superEllipse(BorderRadius.circular(16)), child: ...)

// Random blobby shape
GooeyBlob(shape: .blobby(seed: 42), child: ...)
```

### Gradients

> **Note:** For best results with gradients, ensure gradient colors have full opacity (alpha = 1.0).

Use gradients instead of solid colors:

```dart
GooeyZone.withGradient(
  gradient: LinearGradient(
    colors: [Colors.indigo, Colors.purple],
  ),
  child: // ...
)
```

### Cutouts

Create holes in the gooey background layer:

```dart
GooeyBlob(
  shape: const BlobShape.circle(),
  cutout: true, // This blob punches a hole
  child: Icon(Icons.close),
)
```

### Texture Caching (Snapshot Mode)

By default, GooeyZone caches the blob layer as a texture ([shouldSnapshot]: true). This provides optimal performance for static blobs since the gooey effect is computed once and then rendered as a cached image.

When animating blobs, disable snapshot mode to render the gooey effect live each frame:

```dart
class _ExampleState extends State<Example> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  //...

  @override
  Widget build(BuildContext context) {
    return GooeyZone(
      // Disable snapshot during animation for live rendering
      shouldSnapshot: !_controller.isAnimating,
      color: Colors.indigo,
      child: Column(
        children: [
          GooeyBlob(
            // Animate blob position/size here
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
```

Once the animation completes, set [shouldSnapshot] back to true to re-enable texture caching and restore optimal performance.

## Example

See the `example/` folder for a complete FAB menu demo.

## Additional information

This package is part of the Flutter ecosystem. For issues and contributions, visit the GitHub repository.