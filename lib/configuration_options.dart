///
///  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
part of pspdfkit;

/// Configuration options available can be set by the Flutter plugin.
///
/// See `main.dart` in the example project to check how they are used.
/// 
const String pageScrollDirection = "pageScrollDirection";
const String pageScrollDirectionHorizontal = "horizontal";
const String pageScrollDirectionVertical = "vertical";

const String pageScrollContinuous = "scrollContinuously";

const String fitPageToWidth = "fitPageToWidth";

const String androidImmersiveMode = "immersiveMode";

const String userInterfaceViewMode = "userInterfaceViewMode";
const String userInterfaceViewModeAutomatic = "automatic";
// Automatic border pages mode is supported on Android only.
const String userInterfaceViewModeAutomaticBorderPages = "automaticBorderPages";
const String userInterfaceViewModeAlwaysVisible = "alwaysVisible";
const String userInterfaceViewModeAlwaysHidden = "alwaysHidden";

const String androidShowSearchAction = "showSearchAction";

const String inlineSearch = "inlineSearch";

const String showThumbnailBar = "showThumbnailBar";
const String showThumbnailBarDefault = "default";
const String showThumbnailBarScrollable = "scrollable";
const String showThumbnailBarNone = "none";

const String androidShowThumbnailGridAction = "showThumbnailGridAction";

const String androidShowOutlineAction = "showOutlineAction";

const String androidShowAnnotationListAction = "showAnnotationListAction";

const String showPageNumberOverlay = "showPageNumberOverlay";

const String showPageLabels = "showPageLabels";

const String showDocumentTitle = "showDocumentTitle";

const String invertColors = "invertColors";

const String grayScale = "grayScale";

const String startPage = "startPage";

const String enableAnnotationEditing = "enableAnnotationEditing";

const String enableTextSelection = "enableTextSelection";

const String enableBookmarkList = "enableBookmarkList";

const String enableDocumentEditor = "enableDocumentEditor";

const String androidShowShareAction = "showShareAction";

const String androidShowPrintAction = "showPrintAction";

const String showDocumentInfoView = "showDocumentInfoView";

const String appearanceMode = "appearanceMode";
const String appearanceModeDefault = "default";
const String appearanceModeNight = "night";
// Sepia mode is only supported on iOS.
const String appearanceModeSepia = "sepia";

const String androidDarkThemeResource = "darkThemeResource";
const String androidDefaultThemeResource = "defaultThemeResource";

const String password = "password";
