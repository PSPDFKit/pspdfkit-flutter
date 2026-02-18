///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Native exports for Android and iOS adapters.
///
/// This file re-exports the actual adapters from the platform-specific packages.
/// It is only imported on native platforms (dart:io available).

export 'package:nutrient_flutter_android/nutrient_flutter_android.dart'
    show AndroidAdapter;
export 'package:nutrient_flutter_ios/nutrient_flutter_ios.dart' show IOSAdapter;
