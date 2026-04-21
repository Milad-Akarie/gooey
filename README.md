# Gooey

[![Demo](https://raw.githubusercontent.com/Milad-Akarie/gooey/main/demo/Gooey_demo.gif)](#)

A layout-agnostic gooey/metaball effect widget for Flutter that uses fragment shaders for smooth, hardware-accelerated rendering.

## What is Gooey?

Gooey creates a metaball-like visual effect by merging multiple widgets together using a fragment shader. Any widget wrapped in `GooeyBlob` and placed as a descendant of `GooeyZone` will visually merge with other blobs to create a cohesive, organic gooey effect.

### Layout Agnostic

Gooey works with any Flutter widget arrangement. As long as your blobs are descendants of a `GooeyZone`, they will merge regardless of whether they're in a `Column`, `Row`, `Stack`, `Wrap`, or any other layout widget.

### Shader-Based

The gooey effect is implemented using a GLSL fragment shader, providing:
- Smooth, hardware-accelerated rendering
- Precise control over the merge effect using signed distance functions
- Support for complex gradient fills

### Limitations

- Each `GooeyZone` supports a maximum of 10 `GooeyBlob` children

## Usage

Import the package and wrap your widgets with `GooeyZone`:

```dart
import 'package:gooey/gooey.dart';

GooeyZone(
  color: Colors.indigo,
  gooiness: 30,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 2,
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

- `gooiness` — The intensity of the liquid-like deformation (higher = more pronounced merge). Defaults to 30.
- `softness` — Controls the anti-aliasing band width of the SDF edges. Defaults to a physically correct 1-pixel AA based on device pixel ratio (recommended). For sharper edges use lower values like `0.001`, for softer/blurry edges use higher values like `0.01`. Values above `0.02` will noticeably blur.
- `borderWidth` — Width of the border around the zone. Defaults to 0.0 (no border).
- `borderColor` — Color of the border. Defaults to transparent.

```dart
GooeyZone(
  color: Colors.indigo,
  gooiness: 40,        // More pronounced merge
  softness: (0.001..0.01) // defaults to 1-pixel AA based on dpr (recommended)
  borderWidth: 2.0,    // Visible border
  borderColor: Colors.white,
  child: // ...
)
```

### Blob Shapes

Choose from built-in shapes:

```dart
// Circle (default)
GooeyBlob(shape: const BlobShape.circle(), child: ...)

// Rounded rectangle
GooeyBlob(shape: const BlobShape.rounded(12.0), child: ...)
```

### Gradients

Use linear or radial gradient fills:

```dart
// Linear gradient
GooeyZone.linearGradient(
  gooiness: 40,
  color: Colors.blue,
  secondColor: Colors.purple,
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  child: // ...
)

// Radial gradient
GooeyZone.radialGradient(
  gooiness: 40,
  color: Colors.red,
  secondColor: Colors.orange,
  center: Alignment.center,
  radius: 0.5,
  child: // ...
)
```

### Cutouts

Create holes in the gooey effect:

```dart
GooeyBlob(
  shape: const BlobShape.circle(),
  cutout: true, // This blob punches a hole
  child: Icon(Icons.close),
)
```

## Example

See the `example/` folder for a complete demo.

## Additional Information

This package is part of the Flutter ecosystem. For issues and contributions, visit the GitHub repository.
