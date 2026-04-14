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
      title: 'Flutter Demo',
      showPerformanceOverlay: true,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  const _AnimatedBlobs();

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
      child: GooeyZone(
        color: Colors.indigo,
        shouldSnapshot: false,
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
                    color: Colors.indigoAccent,
                    child: SizedBox.square(dimension: 70),
                  ),
                ),
                Transform.translate(
                  offset: Offset(sin(t * 2 + 1) * 60, cos(t * 2 + 2) * 25),
                  child: GooeyBlob(
                    color: Colors.deepPurpleAccent,
                    child: SizedBox.square(dimension: 50),
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    sin(t * 3 + 2) * 35 + sin(t * 3 + 1) * 25,
                    cos(t * 3 + 1) * 20 + cos(t * 3 + 2) * 15,
                  ),
                  child: GooeyBlob(
                    color: Colors.indigoAccent,
                    child: SizedBox.square(dimension: 40),
                  ),
                ),
                Transform.translate(
                  offset: Offset(sin(t * 4 + 3) * 25, cos(t * 4 + 2) * 35),
                  child: GooeyBlob(
                    color: Colors.blue,
                    child: SizedBox.square(dimension: 35),
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
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GooeyZone.withGradient(
              blurRadius: 10,
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.indigo],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              child: Row(
                mainAxisAlignment: .center,
                spacing: 8,
                children: [
                GooeyBlob(
                  child: Padding(
                    padding: const .all(20),
                    child: Text('G', style: textStyle),
                  ),
                ),
                Padding(
                  padding: const .only(top: 12),
                  child: GooeyBlob(
                    child: Padding(
                      padding: const .all(12.0),
                      child: Text('o', style: textStyle),
                    ),
                  ),
                ),
                GooeyBlob(
                  child: Padding( 
                    padding: const .all(16.0),
                    child: Text('O', style: textStyle),
                  ),
                ),
                Padding(
                  padding: const .only(bottom: 12),
                  child: GooeyBlob(
                    child: Padding(
                      padding: const .all(12.0),
                      child: Text('e', style: textStyle),
                    ),
                  ),
                ),
                GooeyBlob(
                  child: Padding(
                    padding: const .all(20.0),
                    child: Text('y', style: textStyle),
                  ),
                ),
            
              ],)),

            const _AnimatedBlobs(),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: GooeyZone(
                color: Colors.indigo,
                blurRadius: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    GooeyBlob(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.star, color: Colors.white),
                      ),
                    ),
                    GooeyBlob(
                      color: Colors.blueAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.star, color: Colors.white),
                      ),
                    ),
                    GooeyBlob(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.star, color: Colors.white),
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
