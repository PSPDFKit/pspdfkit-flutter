///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Web exports for the NutrientWebAdapter.
///
/// This file re-exports the adapter from the web-specific package.
/// It is only imported on web platforms (dart.library.js_interop available).

export 'package:nutrient_flutter_web/nutrient_flutter_web.dart'
    show NutrientWebAdapter, NutrientWebInstance, NutrientWebInstanceExtension;
