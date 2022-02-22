/*
 *   Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
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

    // Document Interaction Options
    private static final String SCROLL_DIRECTION = "scrollDirection";
    private static final String PAGE_TRANSITION = "pageTransition";
    private static final String ENABLE_TEXT_SELECTION = "enableTextSelection";
    private static final String DISABLE_AUTOSAVE = "disableAutosave";


    // Document Presentation Options
    private static final String PAGE_MODE = "pageMode";
    private static final String SPREAD_FITTING = "spreadFitting";
    private static final String SHOW_PAGE_LABELS = "showPageLabels";
    private static final String START_PAGE = "startPage";
    private static final String DOCUMENT_LABEL_ENABLED = "documentLabelEnabled";
    private static final String FIRST_PAGE_ALWAYS_SINGLE = "firstPageAlwaysSingle";
    private static final String INVERT_COLORS = "invertColors";
    private static final String PASSWORD = "password";
    private static final String GRAY_SCALE = "grayScale";

    // User Interface Options
    private static final String INLINE_SEARCH = "inlineSearch";
    private static final String TOOLBAR_TITLE = "toolbarTitle";
    private static final String SHOW_ACTION_NAVIGATION_BUTTONS = "showActionNavigationButtons";
    private static final String USER_INTERFACE_VIEW_MODE = "userInterfaceViewMode";
    private static final String IMMERSIVE_MODE = "immersiveMode";
    private static final String APPEARANCE_MODE = "appearanceMode";
    private static final String SETTINGS_MENU_ITEMS = "settingsMenuItems";
    private static final String SHOW_SEARCH_ACTION = "showSearchAction";
    private static final String SHOW_OUTLINE_ACTION = "showOutlineAction";
    private static final String SHOW_BOOKMARKS_ACTION = "showBookmarksAction";
    private static final String SHOW_SHARE_ACTION = "showShareAction";
    private static final String SHOW_PRINT_ACTION = "showPrintAction";
    private static final String SHOW_DOCUMENT_INFO_VIEW = "showDocumentInfoView";
    private static final String ENABLE_DOCUMENT_EDITOR = "enableDocumentEditor";
    private static final String DARK_THEME_RESOURCE = "darkThemeResource";
    private static final String DEFAULT_THEME_RESOURCE = "defaultThemeResource";

    // Thumbnail Options
    private static final String SHOW_THUMBNAIL_BAR = "showThumbnailBar";
    private static final String SHOW_THUMBNAIL_GRID_ACTION = "showThumbnailGridAction";

    // Annotation, Forms and Bookmark Options
    private static final String ENABLE_ANNOTATION_EDITING = "enableAnnotationEditing";
    private static final String SHOW_ANNOTATION_LIST_ACTION = "showAnnotationListAction";

    // Deprecated Options
    /**
     * @deprecated This key word was deprecated with PSPDFKit for Fluttter 3.1.
     * Use {@code SCROLL_DIRECTION} instead, which replaces it.
     */
    @Deprecated
    private static final String PAGE_SCROLL_DIRECTION = "pageScrollDirection";
    /**
     * @deprecated This key word was deprecated with PSPDFKit for Fluttter 3.1.
     * Use {@code PAGE_TRANSITION} instead, which replaces it.
     */
    @Deprecated
    private static final String PAGE_SCROLL_CONTINUOUS = "scrollContinuously";
    /**
     * @deprecated This key word was deprecated with PSPDFKit for Fluttter 3.1.
     * Use {@code PAGE_MODE} instead, which replaces it.
     */
    @Deprecated
    private static final String PAGE_LAYOUT_MODE = "pageLayoutMode";
    /**
     * @deprecated This key word was deprecated with PSPDFKit for Fluttter 3.1.
     * Use {@code SPREAD_FITTING} instead, which replaces it.
     */
    @Deprecated
    private static final String FIT_PAGE_TO_WIDTH = "fitPageToWidth";
    /**
     * @deprecated This key word was deprecated with PSPDFKit for Fluttter 3.1.
     * Use {@code SHOW_PAGE_LABELS} instead, which replaces it.
     */
    @Deprecated
    private static final String SHOW_PAGE_NUMBER_OVERLAY = "showPageNumberOverlay";
    /**
     * @deprecated This key word was deprecated with PSPDFKit for Fluttter 3.1.
     * Use {@code DOCUMENT_LABEL_ENABLED} instead, which replaces it.
     */
    @Deprecated
    private static final String SHOW_DOCUMENT_LABEL = "showDocumentLabel";
    /** 
     * @deprecated This key word was deprecated with PSPDFKit for Fluttter 3.1.
     * Use {@code FIRST_PAGE_ALWAYS_SINGLE} instead, which replaces it.
     */
    private static final String IS_FIRST_PAGE_ALWAYS_SINGLE = "isFirstPageAlwaysSingle";
    /** 
     * @deprecated This key word was deprecated with PSPDFKit for Fluttter 3.1.
     * Use {@code SHOW_BOOKMARKS_ACTION} instead, which replaces it.
     */
    private static final String ENABLE_BOOKMARK_LIST = "enableBookmarkList";

    // Document Interaction Values
    private static final String SCROLL_DIRECTION_HORIZONTAL = "horizontal";
    private static final String SCROLL_DIRECTION_VERTICAL = "vertical";
    private static final String PAGE_TRANSITION_SCROLL_PER_SPREAD = "scrollPerSpread";
    private static final String PAGE_TRANSITION_SCROLL_CONTINUOUS = "scrollContinuous";
    private static final String PAGE_TRANSITION_CURL = "curl";
    
    // Document Presentation Values
    private static final String PAGE_MODE_AUTOMATIC = "automatic";
    private static final String PAGE_MODE_SINGLE = "single";
    private static final String PAGE_MODE_DOUBLE = "double";
    private static final String SPREAD_FITTING_FIT = "fit";
    private static final String SPREAD_FITTING_FILL = "fill";
    private static final String SPREAD_FITTING_ADAPTIVE = "adaptive";

    // User Interface Values
    private static final String USER_INTERFACE_VIEW_MODE_AUTOMATIC = "automatic";
    private static final String USER_INTERFACE_VIEW_MODE_AUTOMATIC_BORDER_PAGES = "automaticBorderPages";
    private static final String USER_INTERFACE_VIEW_MODE_AUTOMATIC_NO_FIRST_LAST_PAGE = "automaticNoFirstLastPage";
    private static final String USER_INTERFACE_VIEW_MODE_ALWAYS = "always";
    private static final String USER_INTERFACE_VIEW_MODE_ALWAYS_VISIBLE = "alwaysVisible";
    private static final String USER_INTERFACE_VIEW_MODE_ALWAYS_HIDDEN = "alwaysHidden";
    private static final String USER_INTERFACE_VIEW_MODE_NEVER = "never";
    private static final String APPEARANCE_MODE_DEFAULT = "default";
    private static final String APPEARANCE_MODE_NIGHT = "night";
    private static final String APPEARANCE_MODE_SEPIA = "sepia";
    private static final String SETTINGS_MENU_ITEM_THEME = "theme";
    private static final String SETTINGS_MENU_ITEM_ANDROID_THEME = "androidTheme";
    private static final String SETTINGS_MENU_ITEM_SCREEN_AWAKE = "screenAwake";
    private static final String SETTINGS_MENU_ITEM_ANDROID_SCREEN_AWAKE = "androidScreenAwake";
    private static final String SETTINGS_MENU_ITEM_PAGE_LAYOUT = "pageLayout";
    private static final String SETTINGS_MENU_ITEM_ANDROID_PAGE_LAYOUT = "androidPageLayout";
    private static final String SETTINGS_MENU_ITEM_PAGE_TRANSITION = "pageTransition";
    private static final String SETTINGS_MENU_ITEM_SCROLL_DIRECTION = "scrollDirection";
    private static final String SETTINGS_MENU_ITEM_IOS_APPEARANCE = "iOSAppearance";
    private static final String SETTINGS_MENU_ITEM_IOS_PAGE_MODE = "iOSPageMode";
    private static final String SETTINGS_MENU_ITEM_IOS_SPREAD_FITTING = "iOSSpreadFitting";
    private static final String SETTINGS_MENU_ITEM_IOS_BRIGHTNESS = "iOSBrightness";

    // Thumbnail Options
    private static final String SHOW_THUMBNAIL_BAR_NONE = "none";
    private static final String SHOW_THUMBNAIL_BAR_DEFAULT = "default";
    private static final String SHOW_THUMBNAIL_BAR_FLOATING = "floating";
    private static final String SHOW_THUMBNAIL_BAR_PINNED = "pinned";
    private static final String SHOW_THUMBNAIL_BAR_SCRUBBER_BAR = "scrubberBar";
    private static final String SHOW_THUMBNAIL_BAR_SCROLLABLE = "scrollable";

    @NonNull private final PdfActivityConfiguration.Builder configuration;
    @Nullable private String password = null;

    ConfigurationAdapter(@NonNull Context context,
                         @Nullable HashMap<String, Object> configurationMap) {
        this.configuration = new PdfActivityConfiguration.Builder(context);
        if (configurationMap != null && !configurationMap.isEmpty()) {
            String key = null;

            key = getKeyOfType(configurationMap, PAGE_MODE, String.class);
            if (key != null) {
                configurePageMode((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, PAGE_LAYOUT_MODE, String.class);
            if (key != null) {
                configurePageMode((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, PAGE_TRANSITION, String.class);
            if (key != null) {
                configurePageTransition((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SCROLL_DIRECTION, String.class);
            if (key != null) {
                configurePageScrollDirection((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, PAGE_SCROLL_DIRECTION, String.class);
            if (key != null) {
                configurePageScrollDirection((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, PAGE_SCROLL_CONTINUOUS, Boolean.class);
            if (key != null) {
                configurePageScrollContinuous((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SPREAD_FITTING, String.class);
            if (key != null) {
                configureSpreadFitting((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, FIT_PAGE_TO_WIDTH, Boolean.class);
            if (key != null) {
                configureFitPageToWidth((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, INLINE_SEARCH, Boolean.class);
            if (key != null) {
                configureInlineSearch((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, USER_INTERFACE_VIEW_MODE, String.class);
            if (key != null) {
                configureUserInterfaceViewMode((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, START_PAGE, Integer.class);
            if (key != null) {
                configureStartPage((Integer) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_SEARCH_ACTION, Boolean.class);
            if (key != null) {
                configureShowSearchAction((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, IMMERSIVE_MODE, Boolean.class);
            if (key != null) {
                configureImmersiveMode((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_THUMBNAIL_GRID_ACTION, Boolean.class);
            if (key != null) {
                configureShowThumbnailGridAction((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_OUTLINE_ACTION, Boolean.class);
            if (key != null) {
                configureShowOutlineAction((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_ANNOTATION_LIST_ACTION, Boolean.class);
            if (key != null) {
                configureShowAnnotationListAction((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_PAGE_NUMBER_OVERLAY, Boolean.class);
            if (key != null) {
                configureShowPageLabels((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_PAGE_LABELS, Boolean.class);
            if (key != null) {
                configureShowPageLabels((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_DOCUMENT_LABEL, Boolean.class);
            if (key != null) {
                configureDocumentLabelEnabled((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, DOCUMENT_LABEL_ENABLED, Boolean.class);
            if (key != null) {
                configureDocumentLabelEnabled((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, TOOLBAR_TITLE, String.class);
            if (key != null) {
                configureToolbarTitle((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, GRAY_SCALE, Boolean.class);
            if (key != null) {
                configureGrayScale((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, INVERT_COLORS, Boolean.class);
            if (key != null) {
                configureInvertColors((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, ENABLE_ANNOTATION_EDITING, Boolean.class);
            if (key != null) {
                configureEnableAnnotationEditing((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_SHARE_ACTION, Boolean.class);
            if (key != null) {
                configureShowShareAction((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_PRINT_ACTION, Boolean.class);
            if (key != null) {
                configureShowPrintAction((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, ENABLE_TEXT_SELECTION, Boolean.class);
            if (key != null) {
                configureEnableTextSelection((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_BOOKMARKS_ACTION, Boolean.class);
            if (key != null) {
                configureShowBookmarksAction((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, ENABLE_BOOKMARK_LIST, Boolean.class);
            if (key != null) {
                configureShowBookmarksAction((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, ENABLE_DOCUMENT_EDITOR, Boolean.class);
            if (key != null) {
                configureEnableDocumentEditor((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_THUMBNAIL_BAR, String.class);
            if (key != null) {
                configureShowThumbnailBar((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_DOCUMENT_INFO_VIEW, Boolean.class);
            if (key != null) {
                configureDocumentInfoView((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, APPEARANCE_MODE, String.class);
            if (key != null) {
                configureAppearanceMode((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, DARK_THEME_RESOURCE, String.class);
            if (key != null) {
                configureDarkThemeRes((String) configurationMap.get(key), context);
            }
            key = getKeyOfType(configurationMap, DEFAULT_THEME_RESOURCE, String.class);
            if (key != null) {
                configureDefaultThemeRes((String) configurationMap.get(key), context);
            }
            key = getKeyOfType(configurationMap, SETTINGS_MENU_ITEMS, ArrayList.class);
            if (key != null) {
                configureSettingsMenuItems((ArrayList<?>) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, SHOW_ACTION_NAVIGATION_BUTTONS, Boolean.class);
            if (key != null) {
                configureShowNavigationButtons((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, PASSWORD, String.class);
            if (key != null) {
                this.password = ((String) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, FIRST_PAGE_ALWAYS_SINGLE, Boolean.class);
            if (key != null) {
                configureFirstPageAlwaysSingle((Boolean) configurationMap.get(key));
            }
            key = getKeyOfType(configurationMap, IS_FIRST_PAGE_ALWAYS_SINGLE, Boolean.class);
            if (key != null) {
                configureFirstPageAlwaysSingle((Boolean) configurationMap.get(key));
            }

            key = getKeyOfType(configurationMap, DISABLE_AUTOSAVE, Boolean.class);
            if (key != null) {
                configureAutosaveEnabled(!(Boolean) configurationMap.get(key));
            }
        }
    }

    private void configurePageTransition(@NonNull final String transition) {
        switch (transition) {
            case PAGE_TRANSITION_SCROLL_PER_SPREAD:
                configuration.scrollMode(PageScrollMode.PER_PAGE);
                break;
            case PAGE_TRANSITION_SCROLL_CONTINUOUS:
                configuration.scrollMode(PageScrollMode.CONTINUOUS);
                break;
            case PAGE_TRANSITION_CURL:
                // NO-OP. Only supported on iOS.
                break;
            default:
                throw new IllegalArgumentException("Undefined page transition for " + transition);
        }
    }

    private void configurePageMode(@NonNull final String pageMode) {
        switch (pageMode) {
            case PAGE_MODE_AUTOMATIC:
                configuration.layoutMode(PageLayoutMode.AUTO);
                break;
            case PAGE_MODE_SINGLE:
                configuration.layoutMode(PageLayoutMode.SINGLE);
                break;
            case PAGE_MODE_DOUBLE:
                configuration.layoutMode(PageLayoutMode.DOUBLE);
                break;
            default:
                throw new IllegalArgumentException("Undefined page layout mode for " + pageMode);
        }
    }

    private void configurePageScrollDirection(@NonNull final String pageScrollDirection) {
        switch (pageScrollDirection) {
            case SCROLL_DIRECTION_HORIZONTAL:
                configuration.scrollDirection(PageScrollDirection.HORIZONTAL);
                break;
            case SCROLL_DIRECTION_VERTICAL:
                configuration.scrollDirection(PageScrollDirection.VERTICAL);
                break;
            default:
                throw new IllegalArgumentException("Undefined page scroll direction for " + pageScrollDirection);
        }
    }

    private void configurePageScrollContinuous(final boolean pageScrollContinuous) {
        final PageScrollMode pageScrollMode = pageScrollContinuous ? PageScrollMode.CONTINUOUS : PageScrollMode.PER_PAGE;
        configuration.scrollMode(pageScrollMode);
    }

    private void configureSpreadFitting(@NonNull final String mode) {
        switch (mode) {
            case SPREAD_FITTING_FIT:
                configuration.fitMode(PageFitMode.FIT_TO_WIDTH);
                break;
            case SPREAD_FITTING_FILL:
                configuration.fitMode(PageFitMode.FIT_TO_SCREEN);
                break;
            case SPREAD_FITTING_ADAPTIVE:
                // NO-OP. Only supported on iOS.
                break;
            default:
                throw new IllegalArgumentException("Undefined spread fitting for " + mode);
        }
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
        switch (userInterfaceViewMode) {
            case USER_INTERFACE_VIEW_MODE_AUTOMATIC:
                configuration.setUserInterfaceViewMode(UserInterfaceViewMode.USER_INTERFACE_VIEW_MODE_AUTOMATIC);
                break;
            case USER_INTERFACE_VIEW_MODE_AUTOMATIC_BORDER_PAGES:
            case USER_INTERFACE_VIEW_MODE_AUTOMATIC_NO_FIRST_LAST_PAGE:
                configuration.setUserInterfaceViewMode(UserInterfaceViewMode.USER_INTERFACE_VIEW_MODE_AUTOMATIC_BORDER_PAGES);
                break;
            case USER_INTERFACE_VIEW_MODE_ALWAYS:
            case USER_INTERFACE_VIEW_MODE_ALWAYS_VISIBLE:
                configuration.setUserInterfaceViewMode(UserInterfaceViewMode.USER_INTERFACE_VIEW_MODE_VISIBLE);
                break;
            case USER_INTERFACE_VIEW_MODE_ALWAYS_HIDDEN:
            case USER_INTERFACE_VIEW_MODE_NEVER:
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
        switch (showThumbnailBar) {
            case SHOW_THUMBNAIL_BAR_NONE:
                configuration.setThumbnailBarMode(ThumbnailBarMode.THUMBNAIL_BAR_MODE_NONE);
                break;
            case SHOW_THUMBNAIL_BAR_DEFAULT:
            case SHOW_THUMBNAIL_BAR_FLOATING:
                configuration.setThumbnailBarMode(ThumbnailBarMode.THUMBNAIL_BAR_MODE_FLOATING);
                break;
            case SHOW_THUMBNAIL_BAR_PINNED:
            case SHOW_THUMBNAIL_BAR_SCRUBBER_BAR:
                configuration.setThumbnailBarMode(ThumbnailBarMode.THUMBNAIL_BAR_MODE_PINNED);
                break;
            case SHOW_THUMBNAIL_BAR_SCROLLABLE:
                configuration.setThumbnailBarMode(ThumbnailBarMode.THUMBNAIL_BAR_MODE_SCROLLABLE);
                break;
            default:
                throw new IllegalArgumentException("Undefined thumbnail bar mode for " + showThumbnailBar);
        }
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
            configuration.showPageNumberOverlay();
            configuration.showPageLabels();
        } else {
            configuration.hidePageNumberOverlay();
            configuration.hidePageLabels();
        }
    }

    private void configureDocumentLabelEnabled(boolean documentLabelEnabled) {
        if (documentLabelEnabled) {
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

    private void configureShowBookmarksAction(boolean enableBookmarkList) {
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

    private void configureAppearanceMode(@NonNull String appearanceMode) {
        switch (appearanceMode) {
            case APPEARANCE_MODE_DEFAULT:
                configuration.themeMode(ThemeMode.DEFAULT);
                break;
            case APPEARANCE_MODE_NIGHT:
                configuration.themeMode(ThemeMode.NIGHT);
                break;
            case APPEARANCE_MODE_SEPIA:
                // NO-OP. Only supported on iOS.
                break;
            default:
                throw new IllegalArgumentException("Undefined appearance mode for " + appearanceMode);
        }
    }

    private void configureDarkThemeRes(@NonNull String darkThemeResource, @NonNull Context context) {
        requireNotNullNotEmpty(darkThemeResource, DARK_THEME_RESOURCE);
        checkNotNull(context);

        @StyleRes int darkThemeId = getStyleResourceId(darkThemeResource, context);
        if (darkThemeId != 0) {
            configuration.themeDark(darkThemeId);
        }
    }

    private void configureDefaultThemeRes(@NonNull String defaultThemeResource, @NonNull Context context) {
        requireNotNullNotEmpty(defaultThemeResource, DEFAULT_THEME_RESOURCE);
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
            switch (menuType) {
                case SETTINGS_MENU_ITEM_THEME:
                case SETTINGS_MENU_ITEM_ANDROID_THEME:
                    settingsMenuItemTypes.add(SettingsMenuItemType.THEME);
                break;
                case SETTINGS_MENU_ITEM_SCREEN_AWAKE:
                case SETTINGS_MENU_ITEM_ANDROID_SCREEN_AWAKE:
                    settingsMenuItemTypes.add(SettingsMenuItemType.SCREEN_AWAKE);
                break;
                case SETTINGS_MENU_ITEM_PAGE_LAYOUT:
                case SETTINGS_MENU_ITEM_ANDROID_PAGE_LAYOUT:
                    settingsMenuItemTypes.add(SettingsMenuItemType.PAGE_LAYOUT);
                break;
                case SETTINGS_MENU_ITEM_PAGE_TRANSITION:
                    settingsMenuItemTypes.add(SettingsMenuItemType.PAGE_TRANSITION);
                break;
                case SETTINGS_MENU_ITEM_SCROLL_DIRECTION:
                    settingsMenuItemTypes.add(SettingsMenuItemType.SCROLL_DIRECTION);
                break;
                case SETTINGS_MENU_ITEM_IOS_APPEARANCE:
                case SETTINGS_MENU_ITEM_IOS_BRIGHTNESS:
                case SETTINGS_MENU_ITEM_IOS_PAGE_MODE:
                case SETTINGS_MENU_ITEM_IOS_SPREAD_FITTING:
                    // NO-OP. Only supported on iOS.
                break;
                default:
                    throw new IllegalArgumentException("Undefined settings menu item " + menuType);
            }
        }
        configuration.setSettingsMenuItems(settingsMenuItemTypes);
    }

    private void configureFirstPageAlwaysSingle(final boolean firstPageAlwaysSingle) {
        configuration.firstPageAlwaysSingle(firstPageAlwaysSingle);
    }

    private void configureAutosaveEnabled(boolean autosaveEnabled) {
        configuration.autosaveEnabled(autosaveEnabled);
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
     * When reading configuration options, we check not only for the given configuration string,
     * but also for a string with the `android` prefix. For instance if the user enters
     * `androidPageScrollDirection`, it is considered a valid string equal to `pageScrollDirection`.
     * 
     * When documenting, we always prefer configuration option strings:
     * 
     * - No prefix          : If the key works for both iOS and Android.
     * - `android` prefix   : If the key works only for Android.
     * - `iOS` prefix       : If the key works only for iOS.
     */ 
    private String addAndroidPrefix(String key) {
        // Capitalize the first letter.
        String cap = String.valueOf(key.charAt(0)).toUpperCase() + key.substring(1);
        return "android" + cap;
    }

    @Nullable
    private <T> String getKeyOfType(@NonNull HashMap<String, Object> configurationMap,
                                @NonNull String key,
                                @NonNull Class<T> clazz) {
        if (containsKeyOfType(configurationMap, key, clazz)) {
            return key;
        }
        String prefixedKey = addAndroidPrefix(key);
        if (containsKeyOfType(configurationMap, prefixedKey, clazz)) {
            return prefixedKey;
        }
        return null;
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
