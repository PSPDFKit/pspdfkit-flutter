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
export 'src/events/nutrient_web_event_data.dart';
export 'src/nutrient_flutter_web.dart';
export 'src/nutrient_view_web.dart';
export 'src/web_platform_adapter.dart';
export 'src/web_configuration_builder.dart';
export 'src/web_toolbar_item.dart';

// Document & managers
export 'src/document/nutrient_document_web.dart';
export 'src/document/annotation_manager_web.dart';
export 'src/document/bookmark_manager_web.dart';
export 'src/document/form_manager_web.dart';

// Web SDK bindings - generated from @nutrient-sdk/viewer/dist/index.d.ts.
// Subclassers should import this with a `nutrient_web` prefix
// (e.g. `nutrient_web.Instance`, `nutrient_web.Rect`, `nutrient_web.Color`)
// to keep the 800+ generated names from leaking into application scope.
//
// `ToolbarItem` / `ToolbarItemType` are hidden so the cross-platform
// `ToolbarItem` + `ToolbarItemType` (re-exported via web_toolbar_item.dart) win
// in this library's public namespace; the web SDK's own types are still
// reachable through the prefixed `nutrient_web.ToolbarItem` / `.ToolbarItemType`.
export 'src/generated/nutrient_web_bindings.g.dart'
    hide ToolbarItem, ToolbarItemType;

// Web SDK namespace shim — `loadInstance`, `unloadInstance`,
// `createViewState`, `createGeometryRect`, `isLoaded`. Import
// with a `sdk` prefix (e.g. `sdk.loadInstance(config)`).
export 'src/web_sdk_namespace.dart';

// Operations - high-level APIs for working with the Web SDK
export 'src/operations/annotation_operations.dart';
export 'src/operations/bookmark_operations.dart';
export 'src/operations/document_operations.dart';
export 'src/operations/form_operations.dart';

// Utilities - shared helpers for Web SDK interop
export 'src/utils/color_utils.dart';
export 'src/utils/immutable_utils.dart';
export 'src/utils/namespace_utils.dart';
