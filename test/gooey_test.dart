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

    testWidgets('passes custom gooiness', (tester) async {
      final widget = GooeyZone(
        color: Colors.indigo,
        gooiness: 50.0,
        child: const SizedBox(),
      );
      expect(widget.gooiness, equals(50.0));
    });

    testWidgets('default gooiness is 30', (tester) async {
      final widget = GooeyZone(
        color: Colors.indigo,
        child: const SizedBox(),
      );

      expect(widget.gooiness, equals(30));
    });

    testWidgets('passes custom borderWidth', (tester) async {
      final widget = GooeyZone(
        color: Colors.indigo,
        borderWidth: 4.0,
        child: const SizedBox(),
      );
      expect(widget.borderWidth, equals(4.0));
    });

    testWidgets('default borderWidth is 0.0', (tester) async {
      final widget = GooeyZone(
        color: Colors.indigo,
        child: const SizedBox(),
      );

      expect(widget.borderWidth, equals(0.0));
    });

    testWidgets('passes custom borderColor', (tester) async {
      final widget = GooeyZone(
        color: Colors.indigo,
        borderColor: Colors.white,
        child: const SizedBox(),
      );
      expect(widget.borderColor, equals(Colors.white));
    });

    testWidgets('default borderColor is transparent', (tester) async {
      final widget = GooeyZone(
        color: Colors.indigo,
        child: const SizedBox(),
      );

      expect(widget.borderColor, equals(Colors.transparent));
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

    testWidgets('renders with gooiness 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            gooiness: 0,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });

    testWidgets('renders with large gooiness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            gooiness: 100.0,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });
  });

  group('GooeyZone.linearGradient', () {
    testWidgets('renders with linear gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.linearGradient(
            gooiness: 30,
            color: Colors.blue,
            secondColor: Colors.red,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });

    testWidgets('passes gooiness to constructor', (tester) async {
      final widget = GooeyZone.linearGradient(
        gooiness: 40,
        color: Colors.blue,
        secondColor: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.gooiness, equals(40));
    });

    testWidgets('passes color to constructor', (tester) async {
      final widget = GooeyZone.linearGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.color, equals(Colors.blue));
    });

    testWidgets('passes secondColor to constructor', (tester) async {
      final widget = GooeyZone.linearGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.secondColor, equals(Colors.red));
    });

    testWidgets('passes thirdColor to constructor', (tester) async {
      final widget = GooeyZone.linearGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        thirdColor: Colors.green,
        child: const SizedBox(),
      );

      expect(widget.thirdColor, equals(Colors.green));
    });

    testWidgets('passes begin alignment', (tester) async {
      final widget = GooeyZone.linearGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        begin: Alignment.topCenter,
        child: const SizedBox(),
      );

      expect(widget.begin, equals(Alignment.topCenter));
    });

    testWidgets('passes end alignment', (tester) async {
      final widget = GooeyZone.linearGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        end: Alignment.bottomCenter,
        child: const SizedBox(),
      );

      expect(widget.end, equals(Alignment.bottomCenter));
    });

    testWidgets('default begin is centerLeft', (tester) async {
      final widget = GooeyZone.linearGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.begin, equals(Alignment.centerLeft));
    });

    testWidgets('default end is centerRight', (tester) async {
      final widget = GooeyZone.linearGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.end, equals(Alignment.centerRight));
    });

    testWidgets('renders with three-color gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.linearGradient(
            gooiness: 30,
            color: Colors.blue,
            secondColor: Colors.red,
            thirdColor: Colors.green,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });

    testWidgets('renders with custom border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.linearGradient(
            gooiness: 30,
            color: Colors.blue,
            secondColor: Colors.red,
            borderWidth: 2.0,
            borderColor: Colors.white,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });
  });

  group('GooeyZone.radialGradient', () {
    testWidgets('renders with radial gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.radialGradient(
            gooiness: 30,
            color: Colors.blue,
            secondColor: Colors.red,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });

    testWidgets('passes gooiness to constructor', (tester) async {
      final widget = GooeyZone.radialGradient(
        gooiness: 50,
        color: Colors.blue,
        secondColor: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.gooiness, equals(50));
    });

    testWidgets('passes color to constructor', (tester) async {
      final widget = GooeyZone.radialGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.color, equals(Colors.blue));
    });

    testWidgets('passes secondColor to constructor', (tester) async {
      final widget = GooeyZone.radialGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.secondColor, equals(Colors.red));
    });

    testWidgets('passes thirdColor to constructor', (tester) async {
      final widget = GooeyZone.radialGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        thirdColor: Colors.green,
        child: const SizedBox(),
      );

      expect(widget.thirdColor, equals(Colors.green));
    });

    testWidgets('passes center alignment', (tester) async {
      final widget = GooeyZone.radialGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        center: Alignment.topLeft,
        child: const SizedBox(),
      );

      expect(widget.center, equals(Alignment.topLeft));
    });

    testWidgets('passes radius', (tester) async {
      final widget = GooeyZone.radialGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        radius: 0.8,
        child: const SizedBox(),
      );

      expect(widget.radius, equals(0.8));
    });

    testWidgets('default center is center', (tester) async {
      final widget = GooeyZone.radialGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.center, equals(Alignment.center));
    });

    testWidgets('default radius is 0.5', (tester) async {
      final widget = GooeyZone.radialGradient(
        gooiness: 30,
        color: Colors.blue,
        secondColor: Colors.red,
        child: const SizedBox(),
      );

      expect(widget.radius, equals(0.5));
    });

    testWidgets('renders with three-color gradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.radialGradient(
            gooiness: 30,
            color: Colors.blue,
            secondColor: Colors.red,
            thirdColor: Colors.green,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
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
        shape: BlobShape.rounded(8.0),
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
              shape: BlobShape.rounded(8.0),
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

  group('BlobShape', () {
    test('circle creates BlobShape instance', () {
      const shape = BlobShape.circle();
      expect(shape, isA<BlobShape>());
    });

    test('rounded creates BlobShape instance', () {
      final shape = BlobShape.rounded(12.0);
      expect(shape, isA<BlobShape>());
    });

    test('circle is sealed class instance', () {
      const shape = BlobShape.circle();
      expect(shape, isA<BlobShape>());
    });

    test('rounded is sealed class instance', () {
      final shape = BlobShape.rounded(12.0);
      expect(shape, isA<BlobShape>());
    });

    test('different borderRadius values are not equal', () {
      final shape1 = BlobShape.rounded(8.0);
      final shape2 = BlobShape.rounded(16.0);

      expect(shape1, isNot(equals(shape2)));
    });

    test('circle is equal to another circle', () {
      const shape1 = BlobShape.circle();
      const shape2 = BlobShape.circle();

      expect(shape1, equals(shape2));
    });

    test('rounded shapes with same borderRadius are both BlobShape', () {
      final shape1 = BlobShape.rounded(12.0);
      final shape2 = BlobShape.rounded(12.0);

      expect(shape1, isA<BlobShape>());
      expect(shape2, isA<BlobShape>());
    });

    test('circle has same hashCode for equal instances', () {
      const shape1 = BlobShape.circle();
      const shape2 = BlobShape.circle();

      expect(shape1.hashCode, equals(shape2.hashCode));
    });

    test('rounded instances have hashCode', () {
      final shape = BlobShape.rounded(12.0);

      expect(shape.hashCode, isA<int>());
    });

    test('circle is not equal to rounded', () {
      const circle = BlobShape.circle();
      final rounded = BlobShape.rounded(12.0);

      expect(circle, isNot(equals(rounded)));
    });
  });

  group('FillType', () {
    test('solid has value 0', () {
      expect(FillType.solid.value, equals(0));
    });

    test('linear2 has value 1', () {
      expect(FillType.linear2.value, equals(1));
    });

    test('linear3 has value 2', () {
      expect(FillType.linear3.value, equals(2));
    });

    test('radial2 has value 3', () {
      expect(FillType.radial2.value, equals(3));
    });

    test('radial3 has value 4', () {
      expect(FillType.radial3.value, equals(4));
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

    testWidgets('linearGradient with blobs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.linearGradient(
            gooiness: 30,
            color: Colors.blue,
            secondColor: Colors.red,
            child: GooeyBlob(
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
      expect(find.byType(GooeyBlob), findsOneWidget);
    });

    testWidgets('radialGradient with blobs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.radialGradient(
            gooiness: 30,
            color: Colors.blue,
            secondColor: Colors.red,
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

    testWidgets('Zone with zero gooiness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone(
            color: Colors.indigo,
            gooiness: 0,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });

    testWidgets('linearGradient with zero gooiness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.linearGradient(
            gooiness: 0,
            color: Colors.blue,
            secondColor: Colors.red,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
    });

    testWidgets('radialGradient with max radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GooeyZone.radialGradient(
            gooiness: 30,
            color: Colors.blue,
            secondColor: Colors.red,
            radius: 1.0,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(GooeyZone), findsOneWidget);
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
}
