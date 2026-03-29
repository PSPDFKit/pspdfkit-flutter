///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

library nutrient_flutter_platform_interface;

// Core API
export 'src/nutrient.dart';
export 'src/nutrient_controller.dart';
export 'src/nutrient_view_handle.dart'
    show NutrientViewHandle, NativeInstanceRegistry;
export 'src/nutrient_platform_adapter.dart';
// Configuration removed - all configuration now handled by platform adapters

// Configuration builder interface
export 'src/interfaces/pdf_configuration_builder.dart';

// Typed view configuration (bindings-based views)
export 'src/configuration/nutrient_view_configuration.dart';

// Legacy exports (for backwards compatibility)
export 'src/nutrient_flutter_platform.dart';
export 'src/util/document_path_resolver.dart';
