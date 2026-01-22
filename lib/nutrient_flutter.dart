///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// Export the correct widget based on the platform.
export 'src/widgets/pspdfkit_widget.dart'
    if (dart.library.io) 'src/widgets/pspdfkit_widget.dart'
    if (dart.library.html) 'src/widgets/pspdfkit_widget_web.dart';
export 'src/widgets/nutrient_view.dart'
    if (dart.library.io) 'src/widgets/nutrient_view.dart'
    if (dart.library.html) 'src/widgets/nutrient_view_web.dart';

// All other exports.
export 'src/pdf_configuration.dart';
export 'src/web/nutrient_web_configuration.dart';
export 'src/web/office_conversion_settings.dart';
export 'src/types.dart';
export 'src/web/models/models.dart';
export 'src/configuration_options.dart';
export 'src/toolbar/toolbar.dart';

export 'src/widgets/pspdfkit_widget_controller.dart';
export 'src/measurements/measurements.dart';
export 'src/processor/processor.dart';
export 'src/document/pdf_document.dart';
export 'src/document/headless_pdf_document_native.dart';
// Deprecated: AnnotationManager is no longer exposed as a user-facing API.
// Use annotation management methods directly on PdfDocument instead.
export 'src/document/annotation_manager.dart';
export 'src/document/annotation_properties_extensions.dart';
export 'src/forms/forms.dart';
export 'src/api/nutrient_api.g.dart';

export 'src/annotation_preset_configurations.dart';
export 'src/annotations/annotations.dart';
export 'src/annotations/annotation_menu_configuration.dart';
export 'src/bookmarks/bookmarks.dart';
export 'src/web/models/nutrient_web_events.dart';
export 'src/nutrient.dart';

export 'src/widgets/nutrient_view_controller.dart';
export 'src/ai/ai_assistant_configuration.dart';
export 'src/utils/missing_platform_directory_exception.dart';
