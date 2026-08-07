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

// Events
export 'src/events/nutrient_event.dart';

// Controller & document interfaces
export 'src/interfaces/nutrient_controller_interface.dart';
export 'src/interfaces/nutrient_instant_controller.dart';
export 'src/interfaces/nutrient_document_interface.dart';
export 'src/interfaces/annotation_manager_interface.dart';
export 'src/interfaces/bookmark_manager_interface.dart';
export 'src/interfaces/form_manager_interface.dart';

// Enums used by the public API (e.g. Nutrient.processAnnotations) that live in
// the generated pigeon file. The rest of that file is internal plumbing.
export 'src/api/nutrient_api.g.dart'
    show AnnotationType, AnnotationProcessingMode;

// Models
export 'src/models/page_info.dart';
export 'src/models/bookmark.dart';
export 'src/models/annotation_properties.dart';
export 'src/models/annotation_tool.dart';
export 'src/models/document_save_options.dart';

// Annotation models (hide the Annotation base class to avoid collision with the
// JNI Annotation class in nutrient_flutter_android's bindings; consumers that
// need the Flutter Annotation model should import annotation_models.dart directly
// or use it via nutrient_flutter.dart which exports it without conflicts).
export 'src/models/annotations/annotations.dart' hide Annotation;
export 'src/models/forms/forms.dart';

// Measurements
export 'src/measurements/measurements.dart';

// Typed view configuration (bindings-based views)
export 'src/configuration/nutrient_view_configuration.dart';
export 'src/configuration/toolbar_item.dart';
export 'src/configuration/annotation_editing_item.dart';
export 'src/configuration/signature_creation_configuration.dart';

// Legacy exports (for backwards compatibility)
export 'src/nutrient_flutter_platform.dart';
export 'src/util/document_path_resolver.dart';
export 'src/util/image_document_support.dart';
export 'src/util/instant_jwt.dart';
