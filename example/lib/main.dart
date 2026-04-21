import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gooey/gooey.dart';

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
      home: MyHomePage(title: 'Gooey Blobs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
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
                gooiness: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: .min,
                  spacing: 2,
                  children: [
                    GooeyBlob(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
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
                    ),
                    GooeyBlob(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
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
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
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
      child: GooeyZone.linearGradient(
        color: Colors.blue,
        secondColor: Colors.purple,
        borderWidth: 1,
        borderColor: Colors.deepPurple,
        gooiness: 30,
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
                  child: GooeyBlob(
                    // color: Colors.indigoAccent,
                    child: SizedBox.square(dimension: 70),
                  ),
                ),
                Transform.translate(
                  offset: Offset(sin(t * 2 + 1) * 60, cos(t * 2 + 2) * 25),
                  child: GooeyBlob(
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
                    child: GooeyBlob(
                      // color: Colors.indigoAccent,
                      child: SizedBox.square(dimension: 40),
                    ),
                  ),
                if (widget.counter > 3)
                  Transform.translate(
                    offset: Offset(sin(t * 4 + 3) * 25, cos(t * 4 + 2) * 35),
                    child: GooeyBlob(
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
                    child: GooeyBlob(
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
                    child: GooeyBlob(
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
                    child: GooeyBlob(
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
                    child: GooeyBlob(
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
