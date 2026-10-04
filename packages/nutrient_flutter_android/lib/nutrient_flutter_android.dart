///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

library nutrient_flutter_android;

export 'src/events/android_nutrient_event.dart';
export 'src/nutrient_flutter_android.dart';
export 'src/nutrient_view_android.dart';
export 'src/nutrient_instant_view_android.dart';
export 'src/android_instant_controller.dart';
export 'src/android_platform_adapter.dart';
export 'src/android_configuration_builder.dart';
export 'src/bindings/nutrient_android_sdk_bindings.dart';

// Document & managers
export 'src/document/nutrient_document_android.dart';
export 'src/document/annotation_manager_android.dart';
export 'src/document/bookmark_manager_android.dart';
export 'src/document/form_manager_android.dart';

// JNI interop helpers
export 'src/utils/annotation_provider_blocking.dart';
