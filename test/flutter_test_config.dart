import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Test configuration file executed before every test file.
///
/// This file is automatically loaded by the Flutter test runner.
/// It sets global [AlchemistConfig] for consistent golden test behavior.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Detect if running in CI environment
  const isRunningInCi = bool.fromEnvironment('CI', defaultValue: false);

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      // Force update goldens only when explicitly requested via --update-goldens
      forceUpdateGoldenFiles: false,
      // Goldens are stored in test/goldens/<platform>/ for platform tests
      // and test/goldens/ci/ for CI tests
      platformGoldensConfig: PlatformGoldensConfig(
        // Disable platform tests on CI to avoid platform-specific flakiness
        enabled: !isRunningInCi,
        // Platform goldens are generated based on the host platform
        // (e.g., macOS, Linux, Windows)
        platforms: {
          HostPlatform.macOS,
          HostPlatform.linux,
          HostPlatform.windows,
        },
      ),
      ciGoldensConfig: CiGoldensConfig(
        // CI tests use Ahem font and obscured text for platform-agnostic output
        obscureText: true,
        // Shadows are replaced with opaque colors in CI to avoid inconsistencies
        renderShadows: false,
      ),
    ),
    run: testMain,
  );
}
