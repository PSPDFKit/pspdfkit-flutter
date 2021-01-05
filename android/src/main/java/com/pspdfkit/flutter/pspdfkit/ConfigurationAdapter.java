/*
 *   Copyright © 2018-2021 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */
package com.pspdfkit.flutter.pspdfkit;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StyleRes;

import com.pspdfkit.configuration.activity.PdfActivityConfiguration;
import com.pspdfkit.configuration.activity.ThumbnailBarMode;
import com.pspdfkit.configuration.activity.UserInterfaceViewMode;
import com.pspdfkit.configuration.page.PageFitMode;
import com.pspdfkit.configuration.page.PageLayoutMode;
import com.pspdfkit.configuration.page.PageScrollDirection;
import com.pspdfkit.configuration.page.PageScrollMode;
import com.pspdfkit.configuration.settings.SettingsMenuItemType;
import com.pspdfkit.configuration.sharing.ShareFeatures;
import com.pspdfkit.configuration.theming.ThemeMode;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;

import static com.pspdfkit.flutter.pspdfkit.util.Preconditions.requireNotNullNotEmpty;
import static io.flutter.util.Preconditions.checkNotNull;

class ConfigurationAdapter {
    private static final String LOG_TAG = "ConfigurationAdapter";

    private static final String PAGE_LAYOUT_MODE = "pageLayoutMode";
    private static final String PAGE_LAYOUT_MODE_SINGLE = "single";
    private static final String PAGE_LAYOUT_MODE_DOUBLE = "double";
    private static final String PAGE_LAYOUT_MODE_AUTO = "automatic";
    private static final String PAGE_SCROLL_DIRECTION = "pageScrollDirection";
    private static final String PAGE_SCROLL_DIRECTION_HORIZONTAL = "horizontal";
    private static final String PAGE_SCROLL_DIRECTION_VERTICAL = "vertical";
    private static final String PAGE_SCROLL_CONTINUOUS = "scrollContinuously";
    private static final String FIT_PAGE_TO_WIDTH = "fitPageToWidth";
    private static final String IMMERSIVE_MODE = "immersiveMode";
    private static final String USER_INTERFACE_VIEW_MODE = "userInterfaceViewMode";
    private static final String USER_INTERFACE_VIEW_MODE_AUTOMATIC = "automatic";
    private static final String USER_INTERFACE_VIEW_MODE_AUTOMATIC_BORDER_PAGES = "automaticBorderPages";
    private static final String USER_INTERFACE_VIEW_MODE_ALWAYS_VISIBLE = "alwaysVisible";
    private static final String USER_INTERFACE_VIEW_MODE_ALWAYS_HIDDEN = "alwaysHidden";
    private static final String ANDROID_SHOW_SEARCH_ACTION = "showSearchAction";
    private static final String INLINE_SEARCH = "inlineSearch";
    private static final String SHOW_THUMBNAIL_BAR = "showThumbnailBar";
    private static final String SHOW_THUMBNAIL_BAR_FLOATING = "floating";
    private static final String SHOW_THUMBNAIL_BAR_PINNED = "pinned";
    private static final String SHOW_THUMBNAIL_BAR_SCROLLABLE = "scrollable";
    private static final String SHOW_THUMBNAIL_BAR_NONE = "none";
    private static final String ANDROID_SHOW_THUMBNAIL_GRID_ACTION = "showThumbnailGridAction";
    private static final String ANDROID_SHOW_OUTLINE_ACTION = "showOutlineAction";
    private static final String ANDROID_SHOW_ANNOTATION_LIST_ACTION = "showAnnotationListAction";
    private static final String SHOW_PAGE_NUMBER_OVERLAY = "showPageNumberOverlay";
    private static final String SHOW_PAGE_LABELS = "showPageLabels";
    private static final String SHOW_DOCUMENT_LABEL = "showDocumentLabel";
    private static final String TOOLBAR_TITLE = "toolbarTitle";
    private static final String INVERT_COLORS = "invertColors";
    private static final String GRAY_SCALE = "grayScale";
    private static final String START_PAGE = "startPage";
    private static final String ENABLE_ANNOTATION_EDITING = "enableAnnotationEditing";
    private static final String ENABLE_TEXT_SELECTION = "enableTextSelection";
    private static final String ANDROID_ENABLE_BOOKMARK_LIST = "androidEnableBookmarkList";
    private static final String ANDROID_ENABLE_DOCUMENT_EDITOR = "androidEnableDocumentEditor";
    private static final String ANDROID_SHOW_SHARE_ACTION = "showShareAction";
    private static final String ANDROID_SHOW_PRINT_ACTION = "showPrintAction";
    private static final String SHOW_DOCUMENT_INFO_VIEW = "showDocumentInfoView";
    private static final String APPEARANCE_MODE = "appearanceMode";
    private static final String APPEARANCE_MODE_DEFAULT = "default";
    private static final String APPEARANCE_MODE_NIGHT = "night";
    private static final String ANDROID_DARK_THEME_RESOURCE = "darkThemeResource";
    private static final String ANDROID_DEFAULT_THEME_RESOURCE = "defaultThemeResource";
    private static final String PASSWORD = "password";
    private static final String SETTINGS_MENU_ITEMS = "androidSettingsMenuItems";
    private static final String SHOW_ACTION_NAVIGATION_BUTTONS = "showActionNavigationButtons";
    private static final String IS_FIRST_PAGE_ALWAYS_SINGLE = "isFirstPageAlwaysSingle";

    @NonNull private final PdfActivityConfiguration.Builder configuration;
    @Nullable private String password = null;

    ConfigurationAdapter(@NonNull Context context,
                         @Nullable HashMap<String, Object> configurationMap) {
        this.configuration = new PdfActivityConfiguration.Builder(context);
        if (configurationMap != null && !configurationMap.isEmpty()) {
            if (containsKeyOfType(configurationMap, PAGE_LAYOUT_MODE, String.class)) {
                configurePageLayoutMode((String) configurationMap.get(PAGE_LAYOUT_MODE));
            }
            if (containsKeyOfType(configurationMap, PAGE_SCROLL_DIRECTION, String.class)) {
                configurePageScrollDirection((String) configurationMap.get(PAGE_SCROLL_DIRECTION));
            }
            if (containsKeyOfType(configurationMap, PAGE_SCROLL_CONTINUOUS, Boolean.class)) {
                configurePageScrollContinuous((Boolean) configurationMap.get(PAGE_SCROLL_CONTINUOUS));
            }
            if (containsKeyOfType(configurationMap, FIT_PAGE_TO_WIDTH, Boolean.class)) {
                configureFitPageToWidth((Boolean) configurationMap.get(FIT_PAGE_TO_WIDTH));
            }
            if (containsKeyOfType(configurationMap, INLINE_SEARCH, Boolean.class)) {
                configureInlineSearch((Boolean) configurationMap.get(INLINE_SEARCH));
            }
            if (containsKeyOfType(configurationMap, USER_INTERFACE_VIEW_MODE, String.class)) {
                configureUserInterfaceViewMode((String) configurationMap.get(USER_INTERFACE_VIEW_MODE));
            }
            if (containsKeyOfType(configurationMap, START_PAGE, Integer.class)) {
                configureStartPage((Integer) configurationMap.get(START_PAGE));
            }
            if (containsKeyOfType(configurationMap, ANDROID_SHOW_SEARCH_ACTION, Boolean.class)) {
                configureShowSearchAction((Boolean) configurationMap.get(ANDROID_SHOW_SEARCH_ACTION));
            }
            if (containsKeyOfType(configurationMap, IMMERSIVE_MODE, Boolean.class)) {
                configureImmersiveMode((Boolean) configurationMap.get(IMMERSIVE_MODE));
            }
            if (containsKeyOfType(configurationMap, ANDROID_SHOW_THUMBNAIL_GRID_ACTION, Boolean.class)) {
                configureShowThumbnailGridAction((Boolean) configurationMap.get(ANDROID_SHOW_THUMBNAIL_GRID_ACTION));
            }
            if (containsKeyOfType(configurationMap, ANDROID_SHOW_OUTLINE_ACTION, Boolean.class)) {
                configureShowOutlineAction((Boolean) configurationMap.get(ANDROID_SHOW_OUTLINE_ACTION));
            }
            if (containsKeyOfType(configurationMap, ANDROID_SHOW_ANNOTATION_LIST_ACTION, Boolean.class)) {
                configureShowAnnotationListAction((Boolean) configurationMap.get(ANDROID_SHOW_ANNOTATION_LIST_ACTION));
            }
            if (containsKeyOfType(configurationMap, SHOW_PAGE_NUMBER_OVERLAY, Boolean.class)) {
                configureShowPageNumberOverlay((Boolean) configurationMap.get(SHOW_PAGE_NUMBER_OVERLAY));
            }
            if (containsKeyOfType(configurationMap, SHOW_PAGE_LABELS, Boolean.class)) {
                configureShowPageLabels((Boolean) configurationMap.get(SHOW_PAGE_LABELS));
            }
            if (containsKeyOfType(configurationMap, SHOW_DOCUMENT_LABEL, Boolean.class)) {
                configureShowDocumentLabel((Boolean) configurationMap.get(SHOW_DOCUMENT_LABEL));
            }
            if (containsKeyOfType(configurationMap, TOOLBAR_TITLE, String.class)) {
                configureToolbarTitle((String) configurationMap.get(TOOLBAR_TITLE));
            }
            if (containsKeyOfType(configurationMap, GRAY_SCALE, Boolean.class)) {
                configureGrayScale((Boolean) configurationMap.get(GRAY_SCALE));
            }
            if (containsKeyOfType(configurationMap, INVERT_COLORS, Boolean.class)) {
                configureInvertColors((Boolean) configurationMap.get(INVERT_COLORS));
            }
            if (containsKeyOfType(configurationMap, ENABLE_ANNOTATION_EDITING, Boolean.class)) {
                configureEnableAnnotationEditing((Boolean) configurationMap.get(ENABLE_ANNOTATION_EDITING));
            }
            if (containsKeyOfType(configurationMap, ANDROID_SHOW_SHARE_ACTION, Boolean.class)) {
                configureShowShareAction((Boolean) configurationMap.get(ANDROID_SHOW_SHARE_ACTION));
            }
            if (containsKeyOfType(configurationMap, ANDROID_SHOW_PRINT_ACTION, Boolean.class)) {
                configureShowPrintAction((Boolean) configurationMap.get(ANDROID_SHOW_PRINT_ACTION));
            }
            if (containsKeyOfType(configurationMap, ENABLE_TEXT_SELECTION, Boolean.class)) {
                configureEnableTextSelection((Boolean) configurationMap.get(ENABLE_TEXT_SELECTION));
            }
            if (containsKeyOfType(configurationMap, ANDROID_ENABLE_BOOKMARK_LIST, Boolean.class)) {
                configureEnableBookmarkList((Boolean) configurationMap.get(ANDROID_ENABLE_BOOKMARK_LIST));
            }
            if (containsKeyOfType(configurationMap, ANDROID_ENABLE_DOCUMENT_EDITOR, Boolean.class)) {
                configureEnableDocumentEditor((Boolean) configurationMap.get(ANDROID_ENABLE_DOCUMENT_EDITOR));
            }
            if (containsKeyOfType(configurationMap, SHOW_THUMBNAIL_BAR, String.class)) {
                configureShowThumbnailBar((String) configurationMap.get(SHOW_THUMBNAIL_BAR));
            }
            if (containsKeyOfType(configurationMap, SHOW_DOCUMENT_INFO_VIEW, Boolean.class)) {
                configureDocumentInfoView((Boolean) configurationMap.get(SHOW_DOCUMENT_INFO_VIEW));
            }
            if (containsKeyOfType(configurationMap, APPEARANCE_MODE, String.class)) {
                configureThemeMode((String) configurationMap.get(APPEARANCE_MODE));
            }
            if (containsKeyOfType(configurationMap, ANDROID_DARK_THEME_RESOURCE, String.class)) {
                configureDarkThemeRes((String) configurationMap.get(ANDROID_DARK_THEME_RESOURCE), context);
            }
            if (containsKeyOfType(configurationMap, ANDROID_DEFAULT_THEME_RESOURCE, String.class)) {
                configureDefaultThemeRes((String) configurationMap.get(ANDROID_DEFAULT_THEME_RESOURCE), context);
            }
            if (containsKeyOfType(configurationMap, SETTINGS_MENU_ITEMS, ArrayList.class)) {
                configureSettingsMenuItems((ArrayList<?>) configurationMap.get(SETTINGS_MENU_ITEMS));
            }
            if (containsKeyOfType(configurationMap, SHOW_ACTION_NAVIGATION_BUTTONS, Boolean.class)) {
                configureShowNavigationButtons((Boolean) configurationMap.get(SHOW_ACTION_NAVIGATION_BUTTONS));
            }
            if (containsKeyOfType(configurationMap, PASSWORD, String.class)) {
                this.password = ((String) configurationMap.get(PASSWORD));
            }
            if (containsKeyOfType(configurationMap, IS_FIRST_PAGE_ALWAYS_SINGLE, Boolean.class)) {
                configureFirstPageAlwaysSingle((Boolean) configurationMap.get(IS_FIRST_PAGE_ALWAYS_SINGLE));
            }
        }
    }

    private void configureShowPageNumberOverlay(boolean showPageNumberOverlay) {
        if (showPageNumberOverlay) {
            configuration.showPageNumberOverlay();
        } else {
            configuration.hidePageNumberOverlay();
        }
    }

    private void configurePageLayoutMode(@NonNull final String pageLayoutMode) {
        requireNotNullNotEmpty(pageLayoutMode, "pageLayoutMode");
        switch (pageLayoutMode) {
            case PAGE_LAYOUT_MODE_AUTO:
                configuration.layoutMode(PageLayoutMode.AUTO);
                break;
            case PAGE_LAYOUT_MODE_SINGLE:
                configuration.layoutMode(PageLayoutMode.SINGLE);
                break;
            case PAGE_LAYOUT_MODE_DOUBLE:
                configuration.layoutMode(PageLayoutMode.DOUBLE);
                break;
            default:
                throw new IllegalArgumentException("Undefined page layout mode for " + pageLayoutMode);
        }
    }

    private void configurePageScrollDirection(@NonNull final String pageScrollDirection) {
        requireNotNullNotEmpty(pageScrollDirection, "pageScrollDirection");
        if (pageScrollDirection.equals(PAGE_SCROLL_DIRECTION_HORIZONTAL)) {
            configuration.scrollDirection(PageScrollDirection.HORIZONTAL);
        } else if (pageScrollDirection.equals(PAGE_SCROLL_DIRECTION_VERTICAL)) {
            configuration.scrollDirection(PageScrollDirection.VERTICAL);
        }
    }

    private void configurePageScrollContinuous(final boolean pageScrollContinuous) {
        final PageScrollMode pageScrollMode = pageScrollContinuous ? PageScrollMode.CONTINUOUS : PageScrollMode.PER_PAGE;
        configuration.scrollMode(pageScrollMode);
    }

    private void configureFitPageToWidth(boolean fitPageToWidth) {
        final PageFitMode pageFitMode = fitPageToWidth ? PageFitMode.FIT_TO_WIDTH : PageFitMode.FIT_TO_SCREEN;
        configuration.fitMode(pageFitMode);
    }

    private void configureInlineSearch(boolean inlineSearch) {
        final int searchType = inlineSearch ? PdfActivityConfiguration.SEARCH_INLINE : PdfActivityConfiguration.SEARCH_MODULAR;
        configuration.setSearchType(searchType);
    }

    private void configureStartPage(int startPage) {
        configuration.page(startPage);
    }

    private void configureUserInterfaceViewMode(@NonNull String userInterfaceViewMode) {
        requireNotNullNotEmpty(userInterfaceViewMode, "userInterfaceViewMode");

        switch (userInterfaceViewMode) {
            case USER_INTERFACE_VIEW_MODE_AUTOMATIC:
                configuration.setUserInterfaceViewMode(UserInterfaceViewMode.USER_INTERFACE_VIEW_MODE_AUTOMATIC);
                break;
            case USER_INTERFACE_VIEW_MODE_AUTOMATIC_BORDER_PAGES:
                configuration.setUserInterfaceViewMode(UserInterfaceViewMode.USER_INTERFACE_VIEW_MODE_AUTOMATIC_BORDER_PAGES);
                break;
            case USER_INTERFACE_VIEW_MODE_ALWAYS_VISIBLE:
                configuration.setUserInterfaceViewMode(UserInterfaceViewMode.USER_INTERFACE_VIEW_MODE_VISIBLE);
                break;
            case USER_INTERFACE_VIEW_MODE_ALWAYS_HIDDEN:
                configuration.setUserInterfaceViewMode(UserInterfaceViewMode.USER_INTERFACE_VIEW_MODE_HIDDEN);
                break;
            default:
                throw new IllegalArgumentException("Undefined user interface view mode for " + userInterfaceViewMode);
        }
    }

    private void configureShowSearchAction(boolean showSearchAction) {
        if (showSearchAction) {
            configuration.enableSearch();
        } else {
            configuration.disableSearch();
        }
    }

    private void configureImmersiveMode(boolean immersiveMode) {
        configuration.useImmersiveMode(immersiveMode);
    }

    private void configureShowThumbnailBar(@NonNull String showThumbnailBar) {
        requireNotNullNotEmpty(showThumbnailBar, "showThumbnailBar");

        ThumbnailBarMode thumbnailBarMode;
        switch (showThumbnailBar) {
            case SHOW_THUMBNAIL_BAR_FLOATING:
                thumbnailBarMode = ThumbnailBarMode.THUMBNAIL_BAR_MODE_FLOATING;
                break;
            case SHOW_THUMBNAIL_BAR_PINNED:
                thumbnailBarMode = ThumbnailBarMode.THUMBNAIL_BAR_MODE_PINNED;
                break;
            case SHOW_THUMBNAIL_BAR_SCROLLABLE:
                thumbnailBarMode = ThumbnailBarMode.THUMBNAIL_BAR_MODE_SCROLLABLE;
                break;
            case SHOW_THUMBNAIL_BAR_NONE:
                thumbnailBarMode = ThumbnailBarMode.THUMBNAIL_BAR_MODE_NONE;
                break;
            default:
                throw new IllegalArgumentException("Undefined thumbnail bar mode for " + showThumbnailBar);
        }
        configuration.setThumbnailBarMode(thumbnailBarMode);
    }

    private void configureShowThumbnailGridAction(boolean showThumbnailGridAction) {
        if (showThumbnailGridAction) {
            configuration.showThumbnailGrid();
        } else {
            configuration.hideThumbnailGrid();
        }
    }

    private void configureShowOutlineAction(boolean showOutlineAction) {
        if (showOutlineAction) {
            configuration.enableOutline();
        } else {
            configuration.disableOutline();
        }
    }

    private void configureShowAnnotationListAction(boolean showAnnotationListAction) {
        if (showAnnotationListAction) {
            configuration.enableAnnotationList();
        } else {
            configuration.disableAnnotationList();
        }
    }

    private void configureShowPageLabels(boolean showPageLabels) {
        if (showPageLabels) {
            configuration.showPageLabels();
        } else {
            configuration.hidePageLabels();
        }
    }

    private void configureShowDocumentLabel(boolean showDocumentLabel) {
        if (showDocumentLabel) {
            configuration.showDocumentTitleOverlay();
        } else {
            configuration.hideDocumentTitleOverlay();
        }
    }

    private void configureToolbarTitle(@Nullable String toolbarTitle) {
        configuration.title(toolbarTitle);
    }

    private void configureGrayScale(boolean grayScale) {
        configuration.toGrayscale(grayScale);
    }

    private void configureInvertColors(boolean invertColors) {
        configuration.invertColors(invertColors);
    }

    private void configureEnableAnnotationEditing(boolean enableAnnotationEditing) {
        if (enableAnnotationEditing) {
            configuration.enableAnnotationEditing();
        } else {
            configuration.disableAnnotationEditing();
        }
    }

    private void configureShowShareAction(boolean showShareAction) {
        if (showShareAction) {
            configuration.setEnabledShareFeatures(ShareFeatures.all());
        } else {
            configuration.setEnabledShareFeatures(ShareFeatures.none());
        }
    }

    private void configureShowPrintAction(boolean showPrintAction) {
        if (showPrintAction) {
            configuration.enablePrinting();
        } else {
            configuration.disablePrinting();
        }
    }

    private void configureEnableTextSelection(boolean enableTextSelection) {
        configuration.textSelectionEnabled(enableTextSelection);
    }

    private void configureEnableBookmarkList(boolean enableBookmarkList) {
        if (enableBookmarkList) {
            configuration.enableBookmarkList();
        } else {
            configuration.disableBookmarkList();
        }
    }

    private void configureEnableDocumentEditor(boolean enableDocumentEditor) {
        if (enableDocumentEditor) {
            configuration.enableDocumentEditor();
        } else {
            configuration.disableDocumentEditor();
        }
    }

    private void configureDocumentInfoView(boolean enableDocumentInfoView) {
        if (enableDocumentInfoView) {
            configuration.enableDocumentInfoView();
        } else {
            configuration.disableDocumentInfoView();
        }
    }

    private void configureThemeMode(@NonNull String themeMode) {
        requireNotNullNotEmpty(themeMode, "themeMode");

        ThemeMode result;
        if (themeMode.equals(APPEARANCE_MODE_DEFAULT)) {
            result = ThemeMode.DEFAULT;
        } else if (themeMode.equals(APPEARANCE_MODE_NIGHT)) {
            result = ThemeMode.NIGHT;
        } else {
            throw new IllegalArgumentException("Undefined theme mode for " + themeMode);
        }
        configuration.themeMode(result);
    }

    private void configureDarkThemeRes(@NonNull String darkThemeResource, @NonNull Context context) {
        requireNotNullNotEmpty(darkThemeResource, "darkThemeResource");
        checkNotNull(context);

        @StyleRes int darkThemeId = getStyleResourceId(darkThemeResource, context);
        if (darkThemeId != 0) {
            configuration.themeDark(darkThemeId);
        }
    }

    private void configureDefaultThemeRes(@NonNull String defaultThemeResource, @NonNull Context context) {
        requireNotNullNotEmpty(defaultThemeResource, "defaultThemeResource");
        checkNotNull(context);

        @StyleRes int defaultThemeId = getStyleResourceId(defaultThemeResource, context);
        if (defaultThemeId != 0) {
            configuration.theme(defaultThemeId);
        }
    }

    private void configureShowNavigationButtons(boolean showNavigationButtons) {
        if (showNavigationButtons) {
            configuration.showNavigationButtons();
        } else {
            configuration.hideNavigationButtons();
        }
    }

    private static int getStyleResourceId(@NonNull String styleName, @NonNull Context context) {
        requireNotNullNotEmpty(styleName, "styleName");
        checkNotNull(context);

        int resourceId = context.getResources().getIdentifier(styleName, "style", context.getPackageName());
        if (resourceId == 0) {
            Log.e(LOG_TAG, String.format("Style resource not found for %s", styleName));
        }
        return resourceId;
    }

    private <T> void configureSettingsMenuItems(@NonNull ArrayList<T> settingsMenuItems) {
        checkNotNull(settingsMenuItems);

        EnumSet<SettingsMenuItemType> settingsMenuItemTypes = EnumSet.noneOf(SettingsMenuItemType.class);
        for (T settingsMenuItem : settingsMenuItems) {
            if (!(settingsMenuItem instanceof String)) {
                throw new IllegalArgumentException("Provided settingMenuItem " + settingsMenuItem + " must be a String.");
            }
            String menuType = (String) settingsMenuItem;
            if (menuType.equalsIgnoreCase("theme")) {
                settingsMenuItemTypes.add(SettingsMenuItemType.THEME);
            } else if (menuType.equalsIgnoreCase("screenAwake")) {
                settingsMenuItemTypes.add(SettingsMenuItemType.SCREEN_AWAKE);
            } else if (menuType.equalsIgnoreCase("pageLayout")) {
                settingsMenuItemTypes.add(SettingsMenuItemType.PAGE_LAYOUT);
            } else if (menuType.equalsIgnoreCase("pageTransition")) {
                settingsMenuItemTypes.add(SettingsMenuItemType.PAGE_TRANSITION);
            } else if (menuType.equalsIgnoreCase("scrollDirection")) {
                settingsMenuItemTypes.add(SettingsMenuItemType.SCROLL_DIRECTION);
            } else {
                throw new IllegalArgumentException("Provided settingMenuItem " + menuType + " is unknown.");
            }
        }
        configuration.setSettingsMenuItems(settingsMenuItemTypes);
    }

    private void configureFirstPageAlwaysSingle(final boolean firstPageAlwaysSingle) {
        configuration.firstPageAlwaysSingle(firstPageAlwaysSingle);
    }

    private <T> boolean containsKeyOfType(@NonNull HashMap<String, Object> configurationMap,
                                          @NonNull String key,
                                          @NonNull Class<T> clazz) {
        if (configurationMap.get(key) != null) {
            checkCast(configurationMap.get(key), clazz, key);
            return true;
        }
        return false;
    }

    private static <T> void checkCast(Object object, Class<T> clazz, String key) {
        if (!clazz.isInstance(object)) {
            throw new ClassCastException(String.format("Value for the key %s must be of type %s.",
                    key, javaToDartTypeConverted(clazz)));
        }
    }

    /**
     * Conversion from Java to Dart type following official specification
     * https://flutter.dev/docs/development/platform-integration/platform-channels#platform-channel-data-types-support-and-codecs
     */
    private static <T> String javaToDartTypeConverted(Class<T> clazz) {
        if (clazz == null) {
            return "null";
        } else if (clazz.isInstance(Boolean.class)) {
            return "bool";
        } else if (clazz.isInstance(Integer.class)) {
            return "int";
        } else if (clazz.isInstance(Long.class)) {
            return "int";
        } else if (clazz.isInstance(Double.class)) {
            return "double";
        } else if (clazz.isInstance(String.class)) {
            return "String";
        } else if (clazz.isInstance(byte[].class)) {
            return "Uint8List";
        } else if (clazz.isInstance(int[].class)) {
            return "Int32List";
        } else if (clazz.isInstance(long[].class)) {
            return "Int64List";
        } else if (clazz.isInstance(double[].class)) {
            return "Float64List";
        } else if (clazz.isInstance(ArrayList.class)) {
            return "List";
        } else if (clazz.isInstance(HashMap.class)) {
            return "Map";
        }
        throw new IllegalArgumentException("Undefined dart type conversion for " + clazz.getName());
    }

    @Nullable
    String getPassword() {
        return password;
    }

    PdfActivityConfiguration build() {
        return configuration.build();
    }
}
