import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gooey/gooey.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GooeyZone', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: const Text('child'),
          ),
        ),
      );

      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('passes color parameter to constructor', (tester) async {
      final widget = GooeyZone(
        color: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.color, equals(Colors.red));
    });

    testWidgets('passes custom blurRadius', (tester) async {
      final widget = GooeyZone(
        color: Colors.indigo,
        blurRadius: 15.0,
        child: const SizedBox(),
      );
      expect(widget.blurRadius, equals(15.0));
    });

    testWidgets('default blurRadius is 12.0', (tester) async {
      final widget = GooeyZone(
        color: Colors.indigo,
        child: const SizedBox(),
      );

      expect(widget.blurRadius, equals(12.0));
    });

    testWidgets('passes custom threshold', (tester) async {
      final widget = GooeyZone(
        color: Colors.indigo,
        threshold: 0.7,
        child: const SizedBox(),
      );

      expect(widget.threshold, equals(0.7));
    });

    testWidgets('default threshold is 0.5', (tester) async {
      final widget = GooeyZone(
        color: Colors.indigo,
        child: const SizedBox(),
      );

      expect(widget.threshold, equals(0.5));
    });

    testWidgets('creates RenderGooeyZone render object', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: const SizedBox(),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderBox>(
        find.byType(GooeyZone),
      );

      expect(renderObject, isNotNull);
    });
  });

  group('GooeyBlob', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: GooeyBlob(
              child: const Text('blob'),
            ),
          ),
        ),
      );

      expect(find.text('blob'), findsOneWidget);
    });

    testWidgets('default shape is BlobShape.circle', (tester) async {
      final blob = GooeyBlob(
        child: const SizedBox(),
      );

      expect(blob.shape, isA<BlobShape>());
    });

    testWidgets('accepts BlobShape.circle', (tester) async {
      final blob = GooeyBlob(
        shape: const BlobShape.circle(),
        child: const SizedBox(),
      );

      expect(blob.shape, equals(const BlobShape.circle()));
    });

    testWidgets('accepts BlobShape.rounded', (tester) async {
      final blob = GooeyBlob(
        shape: BlobShape.rounded(BorderRadius.circular(8)),
        child: const SizedBox(),
      );

      expect(blob.shape, isA<BlobShape>());
    });

    testWidgets('accepts BlobShape.superEllipse', (tester) async {
      final blob = GooeyBlob(
        shape: BlobShape.superEllipse(BorderRadius.circular(16)),
        child: const SizedBox(),
      );

      expect(blob.shape, isA<BlobShape>());
    });

    testWidgets('registers with GooeyZone when rendered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: GooeyBlob(
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      expect(find.byType(GooeyBlob), findsOneWidget);
    });

    testWidgets('renders multiple blobs in zone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: Column(
              children: [
                GooeyBlob(child: const SizedBox(width: 30, height: 30)),
                GooeyBlob(child: const SizedBox(width: 30, height: 30)),
                GooeyBlob(child: const SizedBox(width: 30, height: 30)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GooeyBlob), findsNWidgets(3));
    });

    testWidgets('updates when widget key is same', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: GooeyBlob(
              key: key,
              shape: const BlobShape.circle(),
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      var blob = tester.widget<GooeyBlob>(find.byKey(key));
      expect(blob.shape, equals(const BlobShape.circle()));

      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: GooeyBlob(
              key: key,
              shape: BlobShape.rounded(BorderRadius.circular(8)),
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      blob = tester.widget<GooeyBlob>(find.byKey(key));
      expect(blob.shape, isA<BlobShape>());
    });

    testWidgets('creates RenderGooeyBlob render object', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: GooeyBlob(
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      final renderObject = tester.renderObject<RenderBox>(
        find.byType(GooeyBlob),
      );

      expect(renderObject, isNotNull);
    });
  });

  group('BlobShape', () {
    test('circle creates BlobShape instance', () {
      const shape = BlobShape.circle();
      expect(shape, isA<BlobShape>());
    });

    test('rounded creates BlobShape instance', () {
      final shape = BlobShape.rounded(BorderRadius.circular(12));
      expect(shape, isA<BlobShape>());
    });

    test('superEllipse creates BlobShape instance', () {
      final shape = BlobShape.superEllipse(BorderRadius.circular(16));
      expect(shape, isA<BlobShape>());
    });

    test('circle is sealed class instance', () {
      const shape = BlobShape.circle();
      expect(shape, isA<BlobShape>());
    });

    test('rounded is sealed class instance', () {
      final shape = BlobShape.rounded(BorderRadius.circular(12));
      expect(shape, isA<BlobShape>());
    });

    test('superEllipse is sealed class instance', () {
      final shape = BlobShape.superEllipse(BorderRadius.circular(16));
      expect(shape, isA<BlobShape>());
    });

    test('different borderRadius values are not equal', () {
      final shape1 = BlobShape.rounded(BorderRadius.circular(8));
      final shape2 = BlobShape.rounded(BorderRadius.circular(16));

      expect(shape1, isNot(equals(shape2)));
    });

    test('different superEllipse borderRadius values are not equal', () {
      final shape1 = BlobShape.superEllipse(BorderRadius.circular(8));
      final shape2 = BlobShape.superEllipse(BorderRadius.circular(16));

      expect(shape1, isNot(equals(shape2)));
    });

    test('circle is equal to another circle', () {
      const shape1 = BlobShape.circle();
      const shape2 = BlobShape.circle();

      expect(shape1, equals(shape2));
    });

    test('rounded shapes with same borderRadius are equal', () {
      final shape1 = BlobShape.rounded(BorderRadius.circular(12));
      final shape2 = BlobShape.rounded(BorderRadius.circular(12));

      expect(shape1, equals(shape2));
    });

    test('superEllipse shapes with same borderRadius are equal', () {
      final shape1 = BlobShape.superEllipse(BorderRadius.circular(12));
      final shape2 = BlobShape.superEllipse(BorderRadius.circular(12));

      expect(shape1, equals(shape2));
    });

    test('circle has same hashCode for equal instances', () {
      const shape1 = BlobShape.circle();
      const shape2 = BlobShape.circle();

      expect(shape1.hashCode, equals(shape2.hashCode));
    });

    test('rounded has same hashCode for equal instances', () {
      final shape1 = BlobShape.rounded(BorderRadius.circular(12));
      final shape2 = BlobShape.rounded(BorderRadius.circular(12));

      expect(shape1.hashCode, equals(shape2.hashCode));
    });

    test('superEllipse has same hashCode for equal instances', () {
      final shape1 = BlobShape.superEllipse(BorderRadius.circular(12));
      final shape2 = BlobShape.superEllipse(BorderRadius.circular(12));

      expect(shape1.hashCode, equals(shape2.hashCode));
    });

    test('circle is not equal to rounded', () {
      const circle = BlobShape.circle();
      final rounded = BlobShape.rounded(BorderRadius.circular(12));

      expect(circle, isNot(equals(rounded)));
    });

    test('circle is not equal to superEllipse', () {
      const circle = BlobShape.circle();
      final superEllipse = BlobShape.superEllipse(BorderRadius.circular(12));

      expect(circle, isNot(equals(superEllipse)));
    });

    test('rounded is not equal to superEllipse', () {
      final rounded = BlobShape.rounded(BorderRadius.circular(12));
      final superEllipse = BlobShape.superEllipse(BorderRadius.circular(12));

      expect(rounded, isNot(equals(superEllipse)));
    });
  });

  group('Integration', () {
    testWidgets('blob attaches to zone on mount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: GooeyBlob(
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
      expect(find.byType(GooeyBlob), findsOneWidget);
    });

    testWidgets('zone widget renders without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });

    testWidgets('nested GooeyBlob widgets in zone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: Column(
              children: [
                GooeyBlob(child: const Text('first')),
                GooeyBlob(child: const Text('second')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GooeyBlob), findsNWidgets(2));
    });
  });

  group('Edge Cases', () {
    testWidgets('zone with single child renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: const Text('single'),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
      expect(find.text('single'), findsOneWidget);
    });

    testWidgets('multiple nested blobs in column', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: Column(
              children: [
                GooeyBlob(child: const Text('first')),
                GooeyBlob(child: const Text('second')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GooeyBlob), findsNWidgets(2));
      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('Zone with custom key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            key: const ValueKey('gooey-zone'),
            color: Colors.indigo,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('gooey-zone')), findsOneWidget);
    });

    testWidgets('Blob with custom key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: GooeyBlob(
              key: const ValueKey('gooey-blob'),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('gooey-blob')), findsOneWidget);
    });

    testWidgets('Zone with transparent color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.transparent,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });
  });

  group('GooeyZone.withGradient', () {
    testWidgets('renders with LinearGradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.withGradient(
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.blue],
            ),
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });

    testWidgets('passes gradient to constructor', (tester) async {
      final gradient = const LinearGradient(colors: [Colors.red, Colors.blue]);
      final widget = GooeyZone.withGradient(
        gradient: gradient,
        child: const SizedBox(),
      );

      expect(widget.gradient, equals(gradient));
    });

    testWidgets('passes blobOpacity to constructor', (tester) async {
      final widget = GooeyZone.withGradient(
        gradient: const LinearGradient(colors: [Colors.red]),
        blobOpacity: 0.8,
        child: const SizedBox(),
      );

      expect(widget.blobOpacity, equals(0.8));
    });

    testWidgets('default blobOpacity is null', (tester) async {
      final widget = GooeyZone.withGradient(
        gradient: const LinearGradient(colors: [Colors.red]),
        child: const SizedBox(),
      );

      expect(widget.blobOpacity, isNull);
    });

    testWidgets('renders blob with gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.withGradient(
            gradient: const LinearGradient(colors: [Colors.red, Colors.blue]),
            child: GooeyBlob(
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
      expect(find.byType(GooeyBlob), findsOneWidget);
    });
  });

  group('GooeyBlob cutout', () {
    testWidgets('default cutout is false', (tester) async {
      final blob = GooeyBlob(
        child: const SizedBox(),
      );

      expect(blob.cutout, isFalse);
    });

    testWidgets('passes cutout parameter to constructor', (tester) async {
      final blob = GooeyBlob(
        cutout: true,
        child: const SizedBox(),
      );

      expect(blob.cutout, isTrue);
    });

    testWidgets('renders cutout blob in zone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: GooeyBlob(
              cutout: true,
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      expect(find.byType(GooeyBlob), findsOneWidget);
    });

    testWidgets('renders cutout and non-cutout blobs together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: Column(
              children: [
                GooeyBlob(
                  child: const SizedBox(width: 30, height: 30),
                ),
                GooeyBlob(
                  cutout: true,
                  child: const SizedBox(width: 30, height: 30),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GooeyBlob), findsNWidgets(2));
    });
  });

  group('GooeyBlob color', () {
    testWidgets('default color is null', (tester) async {
      final blob = GooeyBlob(
        child: const SizedBox(),
      );

      expect(blob.color, isNull);
    });

    testWidgets('passes custom color to constructor', (tester) async {
      final blob = GooeyBlob(
        color: Colors.red,
        child: const SizedBox(),
      );

      expect(blob.color, equals(Colors.red));
    });

    testWidgets('renders blob with custom color in zone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            child: GooeyBlob(
              color: Colors.red,
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      expect(find.byType(GooeyBlob), findsOneWidget);
    });
  });

  group('BlobShape.blobby', () {
    test('blobby creates BlobShape instance', () {
      final shape = BlobShape.blobby();
      expect(shape, isA<BlobShape>());
    });

    test('blobby with seed creates reproducible shape', () {
      final shape1 = BlobShape.blobby(seed: 42);
      final shape2 = BlobShape.blobby(seed: 42);

      expect(shape1, equals(shape2));
    });

    test('blobby with different seeds are not equal', () {
      final shape1 = BlobShape.blobby(seed: 1);
      final shape2 = BlobShape.blobby(seed: 2);

      expect(shape1, isNot(equals(shape2)));
    });

    test('blobby with custom irregularity', () {
      final shape = BlobShape.blobby(irregularity: 0.5);
      expect(shape, isA<BlobShape>());
    });

    test('blobby with custom lobes', () {
      final shape = BlobShape.blobby(lobes: 6);
      expect(shape, isA<BlobShape>());
    });

    test('blobby with all parameters', () {
      final shape = BlobShape.blobby(seed: 42, irregularity: 0.3, lobes: 8);
      expect(shape, isA<BlobShape>());
    });

    test('blobby equal shapes have same hashCode', () {
      final shape1 = BlobShape.blobby(seed: 42, irregularity: 0.35, lobes: null);
      final shape2 = BlobShape.blobby(seed: 42, irregularity: 0.35, lobes: null);

      expect(shape1.hashCode, equals(shape2.hashCode));
    });

    test('blobby not equal to circle', () {
      final blobby = BlobShape.blobby();
      const circle = BlobShape.circle();

      expect(blobby, isNot(equals(circle)));
    });

    test('blobby not equal to rounded', () {
      final blobby = BlobShape.blobby();
      final rounded = BlobShape.rounded(BorderRadius.circular(12));

      expect(blobby, isNot(equals(rounded)));
    });
  });

  group('Error handling', () {
    testWidgets('blob throws when not inside GooeyZone', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GooeyBlob(
            child: SizedBox(width: 50, height: 50),
          ),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });
  });

  group('RenderGooeyZone properties', () {
    testWidgets('updates color on rebuild', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.red,
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.blue,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });

    testWidgets('updates blurRadius on rebuild', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            blurRadius: 10.0,
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            blurRadius: 20.0,
            child: const SizedBox(),
          ),
        ),
      );

      final zone = tester.widget<GooeyZone>(find.byType(GooeyZone));
      expect(zone.blurRadius, equals(20.0));
    });

    testWidgets('updates threshold on rebuild', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            threshold: 0.3,
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            threshold: 0.8,
            child: const SizedBox(),
          ),
        ),
      );

      final zone = tester.widget<GooeyZone>(find.byType(GooeyZone));
      expect(zone.threshold, equals(0.8));
    });
  });
}
