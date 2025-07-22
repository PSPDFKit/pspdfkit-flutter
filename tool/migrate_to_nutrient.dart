#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

/// Migration script to update PSPDFKit Flutter to Nutrient Flutter
///
/// Usage: dart migrate_to_nutrient.dart [options] [path]
///
/// Options:
///   --dry-run     Show what would be changed without making changes
///   --help        Show this help message
///   --legacy      Keep legacy imports (use pspdfkit_flutter.dart)
///
/// Path: Directory to migrate (defaults to current directory)

void main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final help = args.contains('--help');
  final legacy = args.contains('--legacy');
  final updateApis = args.contains('--update-apis');

  if (help) {
    print('''
Nutrient Flutter Migration Tool

This tool helps migrate your Flutter project from PSPDFKit to Nutrient.

Usage: dart migrate_to_nutrient.dart [options] [path]

Options:
  --dry-run     Show what would be changed without making changes
  --help        Show this help message
  --legacy      Keep legacy imports (use pspdfkit_flutter.dart instead of nutrient_flutter.dart)
  --update-apis Replace Nutrient/NutrientView/NutrientViewController with Nutrient equivalents

Path: Directory to migrate (defaults to current directory)

What this tool does:
1. Updates pubspec.yaml dependency from pspdfkit_flutter to nutrient_flutter
2. Updates import statements in all .dart files
3. Optionally migrates to new Nutrient APIs (with --update-apis flag):
   - Class names (Nutrient → Nutrient, NutrientView → NutrientView, etc.)
   - Enum prefixes (AppearanceMode. → AppearanceMode., etc.)
   - Callback parameter names (onViewCreated → onViewCreated, etc.)
   - Web toolbar classes and types

Example:
  dart migrate_to_nutrient.dart                    # Migrate current directory
  dart migrate_to_nutrient.dart --dry-run          # Preview changes
  dart migrate_to_nutrient.dart --legacy lib/      # Use legacy imports
  dart migrate_to_nutrient.dart --update-apis      # Also update API names
''');
    return;
  }

  // Get the directory to process
  final pathArgs = args.where((arg) => !arg.startsWith('--')).toList();
  final pathArg = pathArgs.isEmpty ? null : pathArgs.first;
  final directory = Directory(pathArg ?? '.');

  if (!directory.existsSync()) {
    print('Error: Directory ${directory.path} does not exist');
    exit(1);
  }

  print('🔄 Migrating PSPDFKit Flutter to Nutrient Flutter');
  print('📁 Directory: ${directory.absolute.path}');
  print(
      '🔍 Mode: ${dryRun ? "Dry run (no changes will be made)" : "Live migration"}');
  print(
      '📦 Import style: ${legacy ? "Legacy (pspdfkit_flutter.dart)" : "New (nutrient_flutter.dart)"}');
  print(
      '🔧 API updates: ${updateApis ? "Yes (will update class names)" : "No (imports only)"}');
  print('');

  var changedFiles = 0;
  var totalFiles = 0;

  // Collect all files first to avoid race conditions
  final allFiles = <File>[];
  await for (final entity in directory.list(recursive: true)) {
    if (entity is File) {
      allFiles.add(entity);
    }
  }

  // Process pubspec.yaml files
  final pubspecFiles =
      allFiles.where((file) => file.path.endsWith('pubspec.yaml')).toList();
  for (final file in pubspecFiles) {
    totalFiles++;
    try {
      final changes = await processPubspecFile(file, dryRun);
      if (changes > 0) changedFiles++;
    } catch (e) {
      print('Error processing ${file.path}: $e');
    }
  }

  // Process Dart files
  final dartFiles = allFiles
      .where((file) =>
          file.path.endsWith('.dart') &&
          !file.path.contains('.dart_tool') &&
          !file.path.contains('build/'))
      .toList();

  for (final file in dartFiles) {
    totalFiles++;
    try {
      final changes = await processDartFile(file, dryRun, legacy, updateApis);
      if (changes > 0) changedFiles++;
    } catch (e) {
      print('Error processing ${file.path}: $e');
    }
  }

  print('');
  print('✅ Migration complete!');
  print('📊 Processed $totalFiles files, modified $changedFiles files');

  if (dryRun) {
    print('');
    print('ℹ️  This was a dry run. No files were actually modified.');
    print('   Run without --dry-run to apply changes.');
  } else if (changedFiles > 0) {
    print('');
    print('📝 Next steps:');
    print('   1. Run: flutter clean');
    print('   2. Run: flutter pub get');
    print('   3. Restart your IDE');
    print('   4. Test your application');

    if (!legacy) {
      print('');
      print('🔄 Next: Migrate to new Nutrient APIs');
      print('   Run: dart migrate_to_nutrient.dart --update-apis');
      print('   This will:');
      print('   - Replace Nutrient with Nutrient');
      print('   - Replace NutrientView with NutrientView');
      print('   - Replace NutrientViewController with NutrientViewController');
    }
  }
}

Future<int> processPubspecFile(File file, bool dryRun) async {
  final content = await file.readAsString();
  var newContent = content;
  var changes = 0;

  // Replace pspdfkit_flutter dependency with nutrient_flutter
  final depRegex = RegExp(r'(\s+)pspdfkit_flutter:\s*(.+)');
  if (depRegex.hasMatch(content)) {
    newContent = newContent.replaceAllMapped(depRegex, (match) {
      changes++;
      return '${match.group(1)}nutrient_flutter: ${match.group(2)}';
    });
  }

  if (changes > 0) {
    print('📄 ${file.path}');
    print('   Updated dependency: pspdfkit_flutter → nutrient_flutter');

    if (!dryRun) {
      await file.writeAsString(newContent);
    }
  }

  return changes;
}

Future<int> processDartFile(
    File file, bool dryRun, bool legacy, bool updateApis) async {
  final content = await file.readAsString();
  var newContent = content;
  var changes = 0;

  // Track what imports were found
  var foundImports = <String>[];

  // Replace package imports
  final importRegex =
      RegExp(r'''import\s+['"]package:pspdfkit_flutter/([\w/]+\.dart)['"];''');
  newContent = newContent.replaceAllMapped(importRegex, (match) {
    final importPath = match.group(1)!;
    foundImports.add(importPath);
    changes++;

    if (legacy) {
      // Keep using pspdfkit_flutter.dart with nutrient package
      if (importPath == 'pspdfkit_flutter.dart' ||
          importPath == 'pspdfkit.dart') {
        return "import 'package:nutrient_flutter/pspdfkit_flutter.dart';";
      }
    } else {
      // Migrate to new nutrient_flutter.dart
      if (importPath == 'pspdfkit_flutter.dart' ||
          importPath == 'pspdfkit.dart') {
        return "import 'package:nutrient_flutter/nutrient_flutter.dart';";
      }
    }

    // For other imports, just update the package name
    return "import 'package:nutrient_flutter/$importPath';";
  });

  // Also handle export statements
  final exportRegex =
      RegExp(r'''export\s+['"]package:pspdfkit_flutter/([\w/]+\.dart)['"];''');
  newContent = newContent.replaceAllMapped(exportRegex, (match) {
    final exportPath = match.group(1)!;
    changes++;

    if (legacy) {
      if (exportPath == 'pspdfkit_flutter.dart' ||
          exportPath == 'pspdfkit.dart') {
        return "export 'package:nutrient_flutter/pspdfkit_flutter.dart';";
      }
    } else {
      if (exportPath == 'pspdfkit_flutter.dart' ||
          exportPath == 'pspdfkit.dart') {
        return "export 'package:nutrient_flutter/nutrient_flutter.dart';";
      }
    }

    return "export 'package:nutrient_flutter/$exportPath';";
  });

  // Update API names if requested
  if (updateApis) {
    final originalContent = newContent;

    // Replace Nutrient class with Nutrient class
    // Use word boundaries to avoid replacing parts of other identifiers
    newContent = newContent.replaceAllMapped(RegExp(r'\bPspdfkit\b'), (match) {
      return 'Nutrient';
    });

    // Replace NutrientView with NutrientView
    newContent =
        newContent.replaceAllMapped(RegExp(r'\bPspdfkitWidget\b'), (match) {
      return 'NutrientView';
    });

    // Replace NutrientViewController with NutrientViewController
    newContent = newContent
        .replaceAllMapped(RegExp(r'\bPspdfkitWidgetController\b'), (match) {
      return 'NutrientViewController';
    });

    // Replace enum prefixes (remove Pspdfkit prefix from enum values)
    newContent =
        newContent.replaceAll('PspdfkitAppearanceMode.', 'AppearanceMode.');
    newContent =
        newContent.replaceAll('PspdfkitScrollDirection.', 'ScrollDirection.');
    newContent =
        newContent.replaceAll('PspdfkitPageTransition.', 'PageTransition.');
    newContent =
        newContent.replaceAll('PspdfkitSpreadFitting.', 'SpreadFitting.');
    newContent = newContent.replaceAll(
        'PspdfkitUserInterfaceViewMode.', 'UserInterfaceViewMode.');
    newContent =
        newContent.replaceAll('PspdfkitThumbnailBarMode.', 'ThumbnailBarMode.');
    newContent =
        newContent.replaceAll('PspdfkitPageLayoutMode.', 'PageLayoutMode.');
    newContent =
        newContent.replaceAll('PspdfkitAutoSaveMode.', 'AutoSaveMode.');

    newContent = newContent.replaceAll('PspdfkitZoomMode.', 'ZoomMode.');
    newContent =
        newContent.replaceAll('PspdfkitToolbarPlacement.', 'ToolbarPlacement.');
    newContent =
        newContent.replaceAll('PspdfkitToolbarMenuItems.', 'ToolbarMenuItems.');
    newContent = newContent.replaceAll('PspdfkitSidebarMode.', 'SidebarMode.');
    newContent = newContent.replaceAll(
        'PspdfkitShowSignatureValidationStatusMode.',
        'ShowSignatureValidationStatusMode.');
    newContent = newContent.replaceAll(
        'PspdfkitSignatureSavingStrategy.', 'SignatureSavingStrategy.');
    newContent = newContent.replaceAll(
        'PspdfkitSignatureCreationMode.', 'SignatureCreationMode.');
    newContent = newContent.replaceAll('PspdfkitAndroidSignatureOrientation.',
        'NutrientAndroidSignatureOrientation.');
    newContent = newContent.replaceAll(
        'PspdfkitWebInteractionMode.', 'NutrientWebInteractionMode.');

    // Replace web toolbar items
    newContent = newContent
        .replaceAllMapped(RegExp(r'\bPspdfkitWebToolbarItem\b'), (match) {
      return 'NutrientWebToolbarItem';
    });
    newContent = newContent.replaceAll(
        'PspdfkitWebToolbarItemType.', 'NutrientWebToolbarItemType.');

    // Replace web annotation toolbar items
    newContent = newContent.replaceAllMapped(
        RegExp(r'\bPspdfkitWebAnnotationToolbarItem\b'), (match) {
      return 'NutrientWebAnnotationToolbarItem';
    });
    newContent = newContent.replaceAll('PspdfkitWebAnnotationToolbarItemType.',
        'NutrientWebAnnotationToolbarItemType.');

    // Replace callback types
    newContent = newContent.replaceAllMapped(
        RegExp(r'\bPspdfkitWidgetCreatedCallback\b'), (match) {
      return 'NutrientViewCreatedCallback';
    });
    newContent = newContent.replaceAllMapped(
        RegExp(r'\bPspdfkitDocumentLoadedCallback\b'), (match) {
      return 'NutrientDocumentLoadedCallback';
    });

    // Replace other legacy class names
    newContent = newContent.replaceAllMapped(
        RegExp(r'\bPspdfkitAnnotationsExampleWidget\b'), (match) {
      return 'NutrientAnnotationsExampleWidget';
    });

    // Replace method channel class
    newContent = newContent
        .replaceAllMapped(RegExp(r'\bMethodChannelPspdfkitFlutter\b'), (match) {
      return 'MethodChannelNutrientFlutter';
    });

    // Replace callback parameter names
    newContent = newContent
        .replaceAllMapped(RegExp(r'\bonPspdfkitWidgetCreated\b'), (match) {
      return 'onViewCreated';
    });
    newContent = newContent.replaceAllMapped(RegExp(r'\bonPdfDocumentLoaded\b'),
        (match) {
      return 'onDocumentLoaded';
    });
    newContent =
        newContent.replaceAllMapped(RegExp(r'\bonPdfDocumentError\b'), (match) {
      return 'onDocumentError';
    });
    newContent =
        newContent.replaceAllMapped(RegExp(r'\bonPdfDocumentSaved\b'), (match) {
      return 'onDocumentSaved';
    });

    // Replace Nutrient callback method names
    newContent = newContent.replaceAll(
        'Nutrient.pspdfkitDocumentLoaded', 'Nutrient.onDocumentLoaded');

    // Check if any API changes were made
    if (newContent != originalContent) {
      changes++;
    }
  }

  if (changes > 0) {
    print('📄 ${file.path}');
    for (final import in foundImports) {
      print('   Updated import: $import');
    }

    if (updateApis) {
      // Check what API changes were made
      if (content.contains('Pspdfkit.') || content.contains('Pspdfkit ')) {
        print('   Updated API: Pspdfkit → Nutrient');
      }
      if (content.contains('PspdfkitWidget')) {
        print('   Updated API: PspdfkitWidget → NutrientView');
      }
      if (content.contains('PspdfkitWidgetController')) {
        print(
            '   Updated API: PspdfkitWidgetController → NutrientViewController');
      }

      // Check for enum prefix changes
      final enumPrefixes = [
        'PspdfkitAppearanceMode.',
        'PspdfkitScrollDirection.',
        'PspdfkitPageTransition.',
        'PspdfkitSpreadFitting.',
        'PspdfkitUserInterfaceViewMode.',
        'PspdfkitThumbnailBarMode.',
        'PspdfkitPageLayoutMode.',
        'PspdfkitAutoSaveMode.',
        'PspdfkitToolbarPlacement.',
        'PspdfkitZoomMode.',
        'PspdfkitToolbarMenuItems.',
        'PspdfkitSidebarMode.',
        'PspdfkitShowSignatureValidationStatusMode.',
        'PspdfkitSignatureSavingStrategy.',
        'PspdfkitSignatureCreationMode.',
        'PspdfkitAndroidSignatureOrientation.',
        'PspdfkitWebInteractionMode.',
        'PspdfkitWebAnnotationToolbarItemType.'
      ];

      for (final prefix in enumPrefixes) {
        if (content.contains(prefix)) {
          final enumName =
              prefix.replaceAll('Nutrient', '').replaceAll('.', '');
          print('   Updated enum: $prefix → $enumName.');
        }
      }

      // Check for web toolbar changes
      if (content.contains('PspdfkitWebToolbarItem')) {
        print(
            '   Updated API: PspdfkitWebToolbarItem → NutrientWebToolbarItem');
      }
      if (content.contains('PspdfkitWebToolbarItemType.')) {
        print(
            '   Updated API: PspdfkitWebToolbarItemType. → NutrientWebToolbarItemType.');
      }

      // Check for web annotation toolbar changes
      if (content.contains('PspdfkitWebAnnotationToolbarItem')) {
        print(
            '   Updated API: PspdfkitWebAnnotationToolbarItem → NutrientWebAnnotationToolbarItem');
      }
      if (content.contains('PspdfkitWebAnnotationToolbarItemType.')) {
        print(
            '   Updated API: PspdfkitWebAnnotationToolbarItemType. → NutrientWebAnnotationToolbarItemType.');
      }

      // Check for callback type changes
      if (content.contains('PspdfkitWidgetCreatedCallback')) {
        print(
            '   Updated API: PspdfkitWidgetCreatedCallback → NutrientViewCreatedCallback');
      }
      if (content.contains('PspdfkitDocumentLoadedCallback')) {
        print(
            '   Updated API: PspdfkitDocumentLoadedCallback → NutrientDocumentLoadedCallback');
      }

      // Check for other class changes
      if (content.contains('PspdfkitAnnotationsExampleWidget')) {
        print(
            '   Updated API: PspdfkitAnnotationsExampleWidget → NutrientAnnotationsExampleWidget');
      }
      if (content.contains('MethodChannelPspdfkitFlutter')) {
        print(
            '   Updated API: MethodChannelPspdfkitFlutter → MethodChannelNutrientFlutter');
      }

      // Check for callback parameter name changes
      if (content.contains('onPspdfkitWidgetCreated')) {
        print('   Updated callback: onPspdfkitWidgetCreated → onViewCreated');
      }
      if (content.contains('onPdfDocumentLoaded')) {
        print('   Updated callback: onPdfDocumentLoaded → onDocumentLoaded');
      }
      if (content.contains('onPdfDocumentError')) {
        print('   Updated callback: onPdfDocumentError → onDocumentError');
      }
      if (content.contains('onPdfDocumentSaved')) {
        print('   Updated callback: onPdfDocumentSaved → onDocumentSaved');
      }

      // Check for Nutrient callback method changes
      if (content.contains('Nutrient.pspdfkitDocumentLoaded')) {
        print(
            '   Updated callback: Nutrient.pspdfkitDocumentLoaded → Nutrient.documentLoaded');
      }
    }

    if (!dryRun) {
      await file.writeAsString(newContent);
    }
  }

  return changes;
}
