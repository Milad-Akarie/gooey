import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gooey/gooey.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Define common constraints for consistent golden image sizing
  const testConstraints = BoxConstraints(maxWidth: 400, maxHeight: 400);

  group('GooeyZone Golden Tests', () {
    goldenTest(
      'solid color with default gooiness',
      fileName: 'gooey_zone_solid_default',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        children: [
          GoldenTestScenario(
            name: 'single blob',
            child: GooeyZone(
              color: Colors.indigo,
              child: const GooeyBlob(
                child: SizedBox(width: 60, height: 60),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'three blobs',
            child: GooeyZone(
              color: Colors.indigo,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'solid color with high gooiness',
      fileName: 'gooey_zone_solid_high_gooiness',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        children: [
          GoldenTestScenario(
            name: 'gooiness_80',
            child: GooeyZone(
              color: Colors.teal,
              gooiness: 80,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'solid color with border',
      fileName: 'gooey_zone_with_border',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        children: [
          GoldenTestScenario(
            name: 'border_2_white',
            child: GooeyZone(
              color: Colors.deepPurple,
              borderWidth: 2.0,
              borderColor: Colors.white,
              child: const GooeyBlob(
                child: SizedBox(width: 60, height: 60),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'linear gradient two-color',
      fileName: 'gooey_zone_linear_gradient_2',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        children: [
          GoldenTestScenario(
            name: 'blue_to_red',
            child: GooeyZone.linearGradient(
              gooiness: 30,
              color: Colors.blue,
              secondColor: Colors.red,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'linear gradient three-color',
      fileName: 'gooey_zone_linear_gradient_3',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        children: [
          GoldenTestScenario(
            name: 'blue_red_green',
            child: GooeyZone.linearGradient(
              gooiness: 30,
              color: Colors.blue,
              secondColor: Colors.red,
              thirdColor: Colors.green,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'radial gradient two-color',
      fileName: 'gooey_zone_radial_gradient_2',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        children: [
          GoldenTestScenario(
            name: 'center_radius_0.5',
            child: GooeyZone.radialGradient(
              gooiness: 30,
              color: Colors.orange,
              secondColor: Colors.purple,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'radial gradient three-color',
      fileName: 'gooey_zone_radial_gradient_3',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        children: [
          GoldenTestScenario(
            name: 'center_radius_0.7',
            child: GooeyZone.radialGradient(
              gooiness: 25,
              color: Colors.pink,
              secondColor: Colors.yellow,
              thirdColor: Colors.cyan,
              radius: 0.7,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'blob with icons',
      fileName: 'gooey_blobs_with_icons',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        children: [
          GoldenTestScenario(
            name: 'icon_row',
            child: GooeyZone(
              color: Colors.green,
              gooiness: 35,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  GooeyBlob(
                    shape: BlobShape.circle(),
                    child: Icon(Icons.add, size: 30, color: Colors.white),
                  ),
                  GooeyBlob(
                    shape: BlobShape.circle(),
                    child: Icon(Icons.share, size: 30, color: Colors.white),
                  ),
                  GooeyBlob(
                    shape: BlobShape.circle(),
                    child: Icon(Icons.edit, size: 30, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'blob shapes circle and rounded',
      fileName: 'gooey_blob_shapes',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        children: [
          GoldenTestScenario(
            name: 'circle_shapes',
            child: GooeyZone(
              color: Colors.orange,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  GooeyBlob(
                    shape: BlobShape.circle(),
                    child: SizedBox(width: 50, height: 50),
                  ),
                  GooeyBlob(
                    shape: BlobShape.circle(),
                    child: SizedBox(width: 50, height: 50),
                  ),
                ],
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'rounded_shapes',
            child: GooeyZone(
              color: Colors.orange,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  GooeyBlob(
                    shape: BlobShape.rounded(12.0),
                    child: SizedBox(width: 50, height: 50),
                  ),
                  GooeyBlob(
                    shape: BlobShape.rounded(12.0),
                    child: SizedBox(width: 50, height: 50),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'cutout blob',
      fileName: 'gooey_cutout_blob',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        children: [
          GoldenTestScenario(
            name: 'cutout_with_normal',
            child: GooeyZone(
              color: Colors.red,
              gooiness: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  GooeyBlob(
                    child: SizedBox(width: 60, height: 60),
                  ),
                  GooeyBlob(
                    cutout: true,
                    child: SizedBox(width: 50, height: 50),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'column blobs vertically',
      fileName: 'gooey_zone_column_blobs',
      constraints: testConstraints,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
        children: [
          GoldenTestScenario(
            name: 'vertical_arrangement',
            child: GooeyZone(
              color: Colors.blue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                  GooeyBlob(child: SizedBox(width: 50, height: 50)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}
