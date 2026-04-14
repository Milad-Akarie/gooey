import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gooey/src/snapshot_helper.dart';

void main() {
  group('SnapshotHelper', () {
    test('creates instance with layer and pixelRatio', () {
      final layer = ContainerLayer();
      final helper = SnaphshotHelper(layer, pixelRatio: 2.0);

      expect(helper.layer, equals(layer));
      expect(helper.pixelRatio, equals(2.0));
    });

    test('creates instance with default pixelRatio', () {
      final layer = ContainerLayer();
      final helper = SnaphshotHelper(layer);

      expect(helper.pixelRatio, equals(1.0));
    });

    test('accepts various pixelRatio values', () {
      final layer = ContainerLayer();

      expect(SnaphshotHelper(layer, pixelRatio: 0.5).pixelRatio, equals(0.5));
      expect(SnaphshotHelper(layer, pixelRatio: 1.5).pixelRatio, equals(1.5));
      expect(SnaphshotHelper(layer, pixelRatio: 3.0).pixelRatio, equals(3.0));
    });

    test('stores different layer types', () {
      final containerLayer = ContainerLayer();
      final offsetLayer = OffsetLayer();
      final clipLayer = ClipRectLayer();

      expect(SnaphshotHelper(containerLayer).layer, equals(containerLayer));
      expect(SnaphshotHelper(offsetLayer).layer, equals(offsetLayer));
      expect(SnaphshotHelper(clipLayer).layer, equals(clipLayer));
    });

    test('multiple helpers can share same layer', () {
      final layer = ContainerLayer();
      final helper1 = SnaphshotHelper(layer, pixelRatio: 1.0);
      final helper2 = SnaphshotHelper(layer, pixelRatio: 2.0);

      expect(helper1.layer, equals(helper2.layer));
      expect(helper1.pixelRatio, equals(1.0));
      expect(helper2.pixelRatio, equals(2.0));
    });

    test('snapshotAsync returns ui.Image', () async {
      final layer = ContainerLayer();
      final helper = SnaphshotHelper(layer, pixelRatio: 1.0);

      final bounds = Rect.fromLTWH(0, 0, 100, 50);
      final offset = Offset.zero;

      final image = helper.snapshotAsync(bounds, offset);

      expect(image, isA<ui.Image>());
      image.dispose();
    });

    test('snapshotAsync calculates correct dimensions with pixelRatio', () async {
      final layer = ContainerLayer();
      final helper = SnaphshotHelper(layer, pixelRatio: 2.0);

      final bounds = Rect.fromLTWH(0, 0, 100, 50);
      final offset = Offset.zero;

      final image = helper.snapshotAsync(bounds, offset);

      expect(image.width, equals(200));
      expect(image.height, equals(100));
      image.dispose();
    });

    test('snapshotAsync handles non-zero offset', () async {
      final layer = ContainerLayer();
      final helper = SnaphshotHelper(layer, pixelRatio: 1.0);

      final bounds = Rect.fromLTWH(10, 20, 100, 50);
      final offset = const Offset(5, 15);

      final image = helper.snapshotAsync(bounds, offset);

      expect(image, isA<ui.Image>());
      image.dispose();
    });

    test('snapshotAsync applies ceiling to dimensions', () async {
      final layer = ContainerLayer();
      final helper = SnaphshotHelper(layer, pixelRatio: 2.0);

      final bounds = Rect.fromLTWH(0, 0, 100.5, 50.3);
      final offset = Offset.zero;

      final image = helper.snapshotAsync(bounds, offset);

      expect(image.width, equals(201));
      expect(image.height, equals(101));
      image.dispose();
    });

    test('snapshotAsync handles large pixelRatio', () async {
      final layer = ContainerLayer();
      final helper = SnaphshotHelper(layer, pixelRatio: 4.0);

      final bounds = Rect.fromLTWH(0, 0, 10, 10);
      final offset = Offset.zero;

      final image = helper.snapshotAsync(bounds, offset);

      expect(image.width, equals(40));
      expect(image.height, equals(40));
      image.dispose();
    });

    test('snapshotAsync handles small bounds', () async {
      final layer = ContainerLayer();
      final helper = SnaphshotHelper(layer, pixelRatio: 1.0);

      final bounds = Rect.fromLTWH(0, 0, 1, 1);
      final offset = Offset.zero;

      final image = helper.snapshotAsync(bounds, offset);

      expect(image.width, greaterThan(0));
      expect(image.height, greaterThan(0));
      image.dispose();
    });
  });
}
