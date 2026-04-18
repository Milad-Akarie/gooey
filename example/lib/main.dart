import 'dart:math';
import 'package:example/gooey_zone_shader.dart';
import 'package:flutter/material.dart';
import 'package:gooey/gooey.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gooey',
      showPerformanceOverlay: true,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigoAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        // body: Center(child: _AnimatedBlobs(5)),
        body: Center(
          child: GooeyZoneShader(
            gooiness: 30,
            color: Colors.indigoAccent,
            child: Column(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              spacing: 8,
              children: [
                GooeyBlobShader(
                  shape: .superEllipse(64),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: Colors.red.withValues(alpha: .5),
                        shape: RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ),

                // GooeyBlobShader(
                //   shape: BlobShapeShader.rounded(30),
                //   child: SizedBox(width: 60, height: 60),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _AnimatedBlobs extends StatefulWidget {
  final int counter;
  const _AnimatedBlobs(this.counter);

  @override
  State<_AnimatedBlobs> createState() => _AnimatedBlobsState();
}

class _AnimatedBlobsState extends State<_AnimatedBlobs>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: GooeyZoneShader.radialGradient(
        color: Colors.blue,
        secondColor: Colors.black,
        center: Alignment.center,
        radius: .9,
        borderWidth: 1,
        borderColor: Colors.deepPurple,
        gooiness: 50,
        // threshold: .3,
        // blurRadius: 8,
        // shouldSnapshot: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value * 2 * 3.14159;
            return Stack(
              alignment: .center,
              children: [
                Transform.translate(
                  offset: Offset(
                    sin(t) * 40 + sin(t * 2) * 30,
                    cos(t) * 30 + cos(t * 2) * 20,
                  ),
                  child: GooeyBlobShader(
                    // color: Colors.indigoAccent,
                    child: SizedBox.square(dimension: 70),
                  ),
                ),
                Transform.translate(
                  offset: Offset(sin(t * 2 + 1) * 60, cos(t * 2 + 2) * 25),
                  child: GooeyBlobShader(
                    // color: Colors.deepPurpleAccent,
                    child: SizedBox.square(dimension: 50),
                  ),
                ),
                if (widget.counter > 2)
                  Transform.translate(
                    offset: Offset(
                      sin(t * 3 + 2) * 35 + sin(t * 3 + 1) * 25,
                      cos(t * 3 + 1) * 20 + cos(t * 3 + 2) * 15,
                    ),
                    child: GooeyBlobShader(
                      // color: Colors.indigoAccent,
                      child: SizedBox.square(dimension: 40),
                    ),
                  ),
                if (widget.counter > 3)
                  Transform.translate(
                    offset: Offset(sin(t * 4 + 3) * 25, cos(t * 4 + 2) * 35),
                    child: GooeyBlobShader(
                      // color: Colors.blue,
                      child: SizedBox.square(dimension: 35),
                    ),
                  ),
                if (widget.counter > 4)
                  Transform.translate(
                    offset: Offset(
                      sin(t * 5 + 1) * 20 + sin(t * 5 + 2) * 20,
                      cos(t * 5 + 2) * 25 + cos(t * 5 + 1) * 30,
                    ),
                    child: GooeyBlobShader(
                      // color: Colors.deepPurpleAccent,
                      child: SizedBox.square(dimension: 30),
                    ),
                  ),
                if (widget.counter > 5)
                  Transform.translate(
                    offset: Offset(
                      sin(t * 6 + 1) * 20 + sin(t * 6 + 2) * 50,
                      cos(t * 6 + 2) * 25 + cos(t * 6 + 1) * 60,
                    ),
                    child: GooeyBlobShader(
                      // color: Colors.deepPurpleAccent,
                      child: SizedBox.square(dimension: 30),
                    ),
                  ),

                if (widget.counter > 6)
                  Transform.translate(
                    offset: Offset(
                      sin(t * 7 + 1) * 20 + sin(t * 7 + 2) * 50,
                      cos(t * 7 + 2) * 25 + cos(t * 7 + 1) * 60,
                    ),
                    child: GooeyBlobShader(
                      // color: Colors.deepPurpleAccent,
                      child: SizedBox.square(dimension: 30),
                    ),
                  ),

                if (widget.counter > 7)
                  Transform.translate(
                    offset: Offset(
                      sin(t * 8 + 1) * 20 + sin(t * 8 + 2) * 50,
                      cos(t * 8 + 2) * 25 + cos(t * 8 + 1) * 60,
                    ),
                    child: GooeyBlobShader(
                      // color: Colors.deepPurpleAccent,
                      child: SizedBox.square(dimension: 30),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121416),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AnimatedBlobs(_counter),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: GooeyZone(
                color: Colors.indigo,
                blurRadius: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: .min,
                  spacing: 2,
                  children: [
                    GooeyBlob(
                      child: IconButton(
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.indigoAccent,
                        ),
                        onPressed: _counter <= 2
                            ? null
                            : () {
                                setState(() {
                                  _counter--;
                                });
                              },
                        icon: Icon(Icons.remove, color: Colors.white),
                      ),
                    ),
                    GooeyBlob(
                      color: Colors.indigoAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '$_counter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'RobotoMono',
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    GooeyBlob(
                      child: IconButton(
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.indigoAccent,
                        ),
                        onPressed: _counter >= 5
                            ? null
                            : () {
                                setState(() {
                                  _counter++;
                                });
                              },
                        icon: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class GooeyBackground extends SingleChildRenderObjectWidget {
  const GooeyBackground({
    super.key,
    super.child,
    this.borderRadius = 0.0,
    this.gooiness = 20.0,
  });

  final double borderRadius;
  final double gooiness;

  @override
  RenderGooeyBackground createRenderObject(BuildContext context) {
    return RenderGooeyBackground(
      borderRadius: borderRadius,
      gooiness: gooiness,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderGooeyBackground renderObject,
  ) {
    renderObject
      ..borderRadius = borderRadius
      ..gooiness = gooiness;
  }
}

// ---------------------------------------------------------------------------
// RenderObject
// ---------------------------------------------------------------------------

class RenderGooeyBackground extends RenderProxyBox {
  RenderGooeyBackground({
    required double borderRadius,
    required double gooiness,
  }) : _borderRadius = borderRadius,
       _gooiness = gooiness {
    _loadProgram();
  }

  ui.FragmentProgram? _program;

  double _borderRadius;
  set borderRadius(double v) {
    if (_borderRadius == v) return;
    _borderRadius = v;
    markNeedsPaint();
  }

  double _gooiness;
  set gooiness(double v) {
    if (_gooiness == v) return;
    _gooiness = v;
    markNeedsPaint();
  }

  Future<void> _loadProgram() async {
    _program = await ui.FragmentProgram.fromAsset('shaders/gooey.frag');
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_program == null) {
      if (child != null) context.paintChild(child!, offset);
      return;
    }

    final w = size.width;
    final h = size.height;
    final childSize = child?.size ?? size;

    // Everything normalized by w for isotropic coordinate space.
    final blobCx = childSize.width * 0.5 / w;
    final blobCy = childSize.height * 0.5 / w;
    final blobHw = childSize.width * 0.5 / w;
    final blobHh = childSize.height * 0.5 / w;
    final blobCr = _borderRadius / w;
    final goo = _gooiness / w;

    final shader = _program!.fragmentShader();
    int i = 0;

    shader.setFloat(i++, offset.dx); // uBounds.x
    shader.setFloat(i++, offset.dy); // uBounds.y
    shader.setFloat(i++, w); // uBounds.z
    shader.setFloat(i++, h); // uBounds.w

    shader.setFloat(i++, goo);
    shader.setFloat(i++, 1.0); // uBlobCount

    // blob1 — child bounds (vec4: cx, cy, hw, hh)
    shader.setFloat(i++, blobCx);
    shader.setFloat(i++, blobCy);
    shader.setFloat(i++, blobHw);
    shader.setFloat(i++, blobHh);

    // blob2..6 — inactive
    for (int b = 1; b < 6; b++) {
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
    }

    // blobCornerRadius1 — vec4: (topLeft, topRight, bottomRight, bottomLeft)
    shader.setFloat(i++, blobCr);
    shader.setFloat(i++, blobCr);
    shader.setFloat(i++, blobCr);
    shader.setFloat(i++, blobCr);

    // blobCornerRadius2..6 — inactive (vec4 each)
    for (int b = 1; b < 6; b++) {
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
      shader.setFloat(i++, 0.0);
    }

    // blobType1 — 1.0 = rounded rect
    shader.setFloat(i++, 1.0);
    // blobType2..6 — inactive
    for (int b = 1; b < 6; b++) {
      shader.setFloat(i++, 0.0);
    }

    context.canvas.drawRect(
      (offset & size).inflate(2),
      Paint()..shader = shader,
    );
    super.paint(context, offset);
  }
}
