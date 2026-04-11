///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

library nutrient_flutter_web;

// Public API exports
export 'src/nutrient_flutter_web.dart';
export 'src/nutrient_view_web.dart';
export 'src/web_platform_adapter.dart';
export 'src/web_configuration_builder.dart';

// Web SDK bindings - exported for controller implementations
export 'src/nutrient_web_bindings.dart'
    show
        NutrientWebInstance,
        NutrientWebInstanceExtension,
        NutrientWebStatic,
        NutrientWebStaticExtension,
        nutrient,
        pspdfkit;
export 'src/nutrient_web_types.dart';

// Operations - high-level APIs for working with the Web SDK
export 'src/operations/annotation_operations.dart';
export 'src/operations/bookmark_operations.dart';
export 'src/operations/document_operations.dart';
export 'src/operations/form_operations.dart';

// Utilities - shared helpers for Web SDK interop
export 'src/utils/color_utils.dart';
export 'src/utils/immutable_utils.dart';
export 'src/utils/namespace_utils.dart';
