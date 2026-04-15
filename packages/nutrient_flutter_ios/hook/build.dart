///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/src/cbuilder/compiler_resolver.dart';

const objCFlags = ['-x', 'objective-c', '-fobjc-arc'];
const objCxxFlags = ['-x', 'objective-c++', '-fobjc-arc'];

const assetName = 'nutrient_flutter_ios.dylib';

final logger = Logger('')
  ..level = Level.INFO
  ..onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    final codeConfig = input.config.code;
    final os = codeConfig.targetOS;
    if (os != OS.iOS) {
      // Only iOS is supported for this plugin.
      return;
    }

    if (codeConfig.linkModePreference == LinkModePreference.static) {
      throw UnsupportedError('LinkModePreference.static is not supported.');
    }

    final packageName = input.packageName;
    final assetPath = input.outputDirectory.resolve(assetName);
    final classesDir = Directory.fromUri(
      input.packageRoot.resolve('ios/Classes/'),
    );
    final target = toTargetTriple(codeConfig);

    // Collect all .m/.mm files from ios/Classes/ to compile into the dylib.
    // Swift files are compiled by CocoaPods and resolve via -undefined dynamic_lookup.
    final mFiles = <String>[];
    final mmFiles = <String>[];
    final hFiles = <String>[];
    for (final file in classesDir.listSync(recursive: true)) {
      if (file is File) {
        final path = file.path;
        if (path.endsWith('.m')) mFiles.add(path);
        if (path.endsWith('.mm')) mmFiles.add(path);
        if (path.endsWith('.h')) hFiles.add(path);
      }
    }

    final sysroot = sdkPath(codeConfig);
    final minVersion = minOSVersion(codeConfig);

    // PSPDFKit xcframework path - resolved from the consuming app's Pods dir.
    // At runtime PSPDFKit symbols resolve via -undefined dynamic_lookup.
    final sdk = codeConfig.iOS.targetSdk == IOSSdk.iPhoneOS
        ? 'ios-arm64'
        : 'ios-arm64_x86_64-simulator';
    final podsRoot = _findPodsRoot(input.outputDirectory);
    if (podsRoot == null) {
      throw Exception(
        'Cannot locate PSPDFKit Pods directory. '
        'Run `pod install` in the consuming app\'s ios/ directory first.',
      );
    }
    final pspdfkitFramework = '$podsRoot/PSPDFKit/PSPDFKit.xcframework/$sdk';
    final pspdfkitUIFramework =
        '$podsRoot/PSPDFKit/PSPDFKitUI.xcframework/$sdk';
    final instantFramework = '$podsRoot/Instant/Instant.xcframework/$sdk';

    final baseFlags = <String>[
      '-isysroot',
      sysroot,
      '-target',
      target,
      minVersion,
      '-I',
      classesDir.path,
      '-F',
      pspdfkitFramework,
      '-F',
      pspdfkitUIFramework,
      '-F',
      instantFramework,
      '-I',
      '$pspdfkitFramework/PSPDFKit.framework/Headers',
      '-I',
      '$pspdfkitUIFramework/PSPDFKitUI.framework/Headers',
      '-I',
      '$instantFramework/Instant.framework/Headers',
    ];
    final mFlags = [...baseFlags, ...objCFlags];
    final mmFlags = [...baseFlags, ...objCxxFlags];
    final linkFlags = baseFlags;

    final builder = await Builder.create(input, input.packageRoot.toFilePath());

    final objectFiles = await Future.wait(<Future<String>>[
      for (final src in mFiles) builder.buildObject(src, mFlags),
      for (final src in mmFiles) builder.buildObject(src, mmFlags),
    ]);
    await builder.linkLib(objectFiles, assetPath.toFilePath(), linkFlags);

    output.dependencies.addAll(mFiles.map(Uri.file));
    output.dependencies.addAll(mmFiles.map(Uri.file));
    output.dependencies.addAll(hFiles.map(Uri.file));

    output.assets.code.add(
      CodeAsset(
        package: packageName,
        name: assetName,
        file: assetPath,
        linkMode: DynamicLoadingBundled(),
      ),
    );
  });
}

class Builder {
  final String _comp;
  final String _rootDir;
  final Uri _tempOutDir;
  Builder._(this._comp, this._rootDir, this._tempOutDir);

  static Future<Builder> create(BuildInput input, String rootDir) async {
    final resolver = CompilerResolver(
      codeConfig: input.config.code,
      logger: logger,
    );
    return Builder._(
      (await resolver.resolveCompiler()).uri.toFilePath(),
      rootDir,
      input.outputDirectory.resolve('obj/'),
    );
  }

  Future<String> buildObject(String input, List<String> flags) async {
    assert(input.startsWith(_rootDir));
    final relativeInput = input.substring(_rootDir.length);
    final output = '${_tempOutDir.resolve(relativeInput).toFilePath()}.o';
    File(output).parent.createSync(recursive: true);
    await _compile([...flags, '-c', input, '-fpic'], output);
    return output;
  }

  Future<void> linkLib(
    List<String> objects,
    String output,
    List<String> flags,
  ) => _compile([
    '-shared',
    '-Wl,-encryptable',
    '-undefined',
    'dynamic_lookup',
    ...flags,
    ...objects,
  ], output);

  Future<void> _compile(List<String> flags, String output) async {
    final args = [...flags, '-o', output];
    logger.info('Running: $_comp ${args.join(" ")}');
    final proc = await Process.run(_comp, args);
    logger.info(proc.stdout);
    logger.info(proc.stderr);
    if (proc.exitCode != 0) {
      exitCode = proc.exitCode;
      throw Exception('Command failed: $_comp ${args.join(" ")}');
    }
    logger.info('Generated $output');
  }
}

/// Walks up from [outputDirectory] (inside .dart_tool/hooks_runner/…) to find
/// the consuming app's `ios/Pods/` directory. Returns null if not found.
String? _findPodsRoot(Uri outputDirectory) {
  var dir = Directory.fromUri(outputDirectory);
  while (true) {
    final parent = dir.parent;
    if (parent.path == dir.path) break; // filesystem root
    final pods = Directory('${parent.path}/ios/Pods');
    if (pods.existsSync()) return pods.path;
    dir = parent;
  }
  return null;
}

String sdkPath(CodeConfig codeConfig) {
  final String target;
  if (codeConfig.iOS.targetSdk == IOSSdk.iPhoneOS) {
    target = 'iphoneos';
  } else {
    target = 'iphonesimulator';
  }
  return firstLineOfStdout('xcrun', ['--show-sdk-path', '--sdk', target]);
}

String firstLineOfStdout(String cmd, List<String> args) {
  final result = Process.runSync(cmd, args);
  if (result.exitCode != 0) {
    throw Exception(
      'Command "$cmd ${args.join(" ")}" failed with exit code '
      '${result.exitCode}: ${result.stderr}',
    );
  }
  return (result.stdout as String)
      .split('\n')
      .where((line) => line.isNotEmpty)
      .first;
}

String minOSVersion(CodeConfig codeConfig) {
  final targetVersion = codeConfig.iOS.targetVersion;
  return '-mios-version-min=$targetVersion';
}

String toTargetTriple(CodeConfig codeConfig) {
  final architecture = codeConfig.targetArchitecture;
  return appleClangIosTargetFlags[architecture]![codeConfig.iOS.targetSdk]!;
}

const appleClangIosTargetFlags = {
  Architecture.arm64: {
    IOSSdk.iPhoneOS: 'arm64-apple-ios',
    IOSSdk.iPhoneSimulator: 'arm64-apple-ios-simulator',
  },
  Architecture.x64: {IOSSdk.iPhoneSimulator: 'x86_64-apple-ios-simulator'},
};
