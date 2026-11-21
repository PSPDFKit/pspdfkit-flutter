/*
 * Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

import android.content.Context
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.ui.graphics.Color
import androidx.core.graphics.toColorInt
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.pspdfkit.compose.toolbar.adapter.ToolbarSubscription
import com.pspdfkit.compose.toolbar.state.ContextualToolbarKind
import com.pspdfkit.compose.toolbar.state.ContextualToolbarState
import com.pspdfkit.compose.toolbar.state.ToolbarIcon
import com.pspdfkit.compose.toolbar.state.ToolbarItem
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.annotations.AnnotationMenuHandler
import com.pspdfkit.flutter.pspdfkit.api.CustomToolbarCallbacks
import com.pspdfkit.flutter.pspdfkit.toolbar.StylusButtonVisibility
import com.pspdfkit.flutter.pspdfkit.util.DynamicColorResourcesHelper
import com.pspdfkit.R
import com.pspdfkit.listeners.OnPreparePopupToolbarListener
import com.pspdfkit.jetpack.compose.toolbar.nutrientToolbarCoordinator
import com.pspdfkit.jetpack.compose.toolbar.setMenuItemGroupingRule
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.ui.toolbar.grouping.MenuItemGroupingRule
import com.pspdfkit.ui.toolbar.popup.AnnotationPopupToolbar

class FlutterPdfUiFragment : PdfUiFragment(), OnPreparePopupToolbarListener {

    // Maps identifier strings to menu item IDs to track custom toolbar items
    private val customToolbarItemIds = HashMap<String, Int>()
    private var customToolbarCallbacks: CustomToolbarCallbacks? = null
    private var customToolbarItems: List<Map<String, Any>>? = null

    // Annotation menu handler for custom contextual menus
    private var annotationMenuHandler: AnnotationMenuHandler? = null

    // Toolbar grouping rule for annotation creation toolbar
    private var toolbarGroupingRule: MenuItemGroupingRule? = null

    // Configuration for hiding annotation creation button
    private var hideAnnotationCreationButton: Boolean = false

    // Theme colors configuration
    private var themeColors: HashMap<String, Int>? = null

    // Whether to show the stylus button on the annotation creation toolbar
    private var showStylusButton: Boolean = true

    // Watches the contextual toolbars: hides the stylus toggle, and clears the selected
    // annotation when a contextual toolbar goes away.
    private var contextualToolbarSubscription: ToolbarSubscription? = null

    // The kind of contextual toolbar shown at the last change, to spot one going away.
    private var shownContextualToolbarKind: ContextualToolbarKind? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        Check if back button was set;
        (activity as AppCompatActivity).supportActionBar?.apply {
            setDisplayHomeAsUpEnabled(true)
            setDisplayShowHomeEnabled(true)
        }
    }

    /**
     * Applies the theme overlay to the Activity's theme before view inflation.
     * PSPDFKit's internal views (including PdfFragment) resolve `pspdf__backgroundColor`
     * from the Activity's theme, so we must modify it there.
     *
     * Theme colors must be set via [setThemeColors] BEFORE the fragment is committed
     * to the FragmentManager, as this method is called during view creation.
     */
    override fun onGetLayoutInflater(savedInstanceState: Bundle?): LayoutInflater {
        val inflater = super.onGetLayoutInflater(savedInstanceState)
        val bgColor = themeColors?.get("backgroundColor") ?: return inflater

        try {
            // Apply the theme overlay to the Activity's theme directly.
            // This is necessary because PdfFragment resolves pspdf__backgroundColor
            // from the Activity context, not from the fragment's inflater context.
            DynamicColorResourcesHelper.applyToActivityTheme(requireActivity(), bgColor)

            // Verify: resolve pspdf__backgroundColor from Activity's theme
            val attrId = requireActivity().resources.getIdentifier(
                "pspdf__backgroundColor", "attr", "com.pspdfkit"
            )
            if (attrId != 0) {
                val tv = android.util.TypedValue()
                val resolved = requireActivity().theme.resolveAttribute(attrId, tv, true)
                Log.d("FlutterPdfUiFragment",
                    "pspdf__backgroundColor resolved=$resolved, type=${tv.type}, data=${String.format("#%08X", tv.data)}")
            } else {
                Log.w("FlutterPdfUiFragment", "pspdf__backgroundColor attr not found in com.pspdfkit package")
                // Try without package qualifier
                val attrId2 = requireActivity().resources.getIdentifier(
                    "pspdf__backgroundColor", "attr", requireActivity().packageName
                )
                Log.d("FlutterPdfUiFragment", "pspdf__backgroundColor in app package: attrId=$attrId2")
            }
        } catch (e: Exception) {
            Log.e("FlutterPdfUiFragment", "Failed to apply theme overlay to activity", e)
        }

        return inflater
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return super.onCreateView(inflater, container, savedInstanceState)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        applyToolbarGroupingRule()
        installCustomToolbarItems()
        contextualToolbarSubscription = nutrientToolbarCoordinator()
            .addContextualToolbarChangeListener(::onContextualToolbarChanged)
        setupKeyboardInsetListener()
        applyImmediateThemeColors()
    }

    override fun onDestroyView() {
        contextualToolbarSubscription?.close()
        contextualToolbarSubscription = null
        super.onDestroyView()
    }

    /**
     * Sets up a keyboard visibility listener using WindowInsetsCompat.
     * When the keyboard appears, applies bottom margin to the pdfFragment's view
     * so the PDF content can scroll to the bottom without being hidden by the keyboard.
     * This modern approach supports keyboard animations on API 30+ and is backported to API 21+.
     */
    private fun setupKeyboardInsetListener() {
        val pdfView = pdfFragment?.view ?: return

        ViewCompat.setOnApplyWindowInsetsListener(pdfView) { v, insets ->
            val imeVisible = insets.isVisible(WindowInsetsCompat.Type.ime())
            val imeHeight = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom

            val params = v.layoutParams as? ViewGroup.MarginLayoutParams
            if (params != null) {
                val newBottomMargin = if (imeVisible) imeHeight else 0
                if (params.bottomMargin != newBottomMargin) {
                    params.bottomMargin = newBottomMargin
                    v.layoutParams = params
                }
            }

            insets
        }
    }

    /**
     * Applies theme colors to views after inflation.
     * Targets specific PSPDFKit internal views by their R.id to ensure
     * consistent theming across the viewer UI.
     */
    private fun applyImmediateThemeColors() {
        val colors = themeColors ?: return

        try {
            // Apply background color.
            // The viewport background is primarily handled by onGetLayoutInflater() which sets
            // pspdf__backgroundColor via ContextThemeWrapper BEFORE views are inflated.
            // These calls handle the root view and PdfFragment's own background API.
            colors["backgroundColor"]?.let { color ->
                view?.setBackgroundColor(color)
                pdfFragment?.backgroundColor = color
                Log.d("FlutterPdfUiFragment", "Applied background color")
            }

            // Apply status bar color
            colors["toolbar.statusBarColor"]?.let { color ->
                activity?.window?.statusBarColor = color
                Log.d("FlutterPdfUiFragment", "Applied status bar color")
            }

            // Apply thumbnail bar background
            colors["thumbnailBar.backgroundColor"]?.let { color ->
                view?.findViewById<View>(R.id.pspdf__activity_thumbnail_bar)?.setBackgroundColor(color)
                Log.d("FlutterPdfUiFragment", "Applied thumbnail bar background color")
            }

            // Apply outline/navigation view background
            colors["navigationTab.backgroundColor"]?.let { color ->
                view?.findViewById<View>(R.id.pspdf__activity_outline_view)?.setBackgroundColor(color)
                Log.d("FlutterPdfUiFragment", "Applied navigation tab background color")
            }

            // Apply search view background
            colors["search.backgroundColor"]?.let { color ->
                view?.findViewById<View>(R.id.pspdf__activity_search_view_modular)?.setBackgroundColor(color)
                Log.d("FlutterPdfUiFragment", "Applied search background color")
            }
        } catch (e: Exception) {
            Log.e("FlutterPdfUiFragment", "Error applying immediate theme colors", e)
        }
    }

    /**
     * Called when the document is loaded. Notifies Flutter that the document has been loaded.
     *
     * @param document The loaded PDF document.
     */
    override fun onDocumentLoaded(document: PdfDocument) {
        super.onDocumentLoaded(document)
        Log.d("FlutterPdfUiFragment", "onDocumentLoaded called, pdfFragment=${pdfFragment != null}")
        // Re-apply theme colors now that the document view is fully initialized.
        // PdfFragment.setBackgroundColor() requires the document to be loaded.
        applyImmediateThemeColors()
        // As of Nutrient Android 11.5 annotation editing moved from a contextual
        // toolbar to the AnnotationPopupToolbar, prepared via this listener.
        pdfFragment?.setOnPreparePopupToolbarListener(this)
        // Notify the Nutrient Flutter plugin that the document has been loaded.
        EventDispatcher.getInstance().notifyDocumentLoaded(document)
    }

    /**
     * Sets the custom toolbar items to be displayed in the toolbar.
     *
     * @param items List of custom toolbar item configurations from Flutter.
     * @param callbacks Callbacks to notify Flutter when a custom toolbar item is tapped.
     */
    fun setCustomToolbarItems(items: List<Map<String, Any>>, callbacks: CustomToolbarCallbacks) {
        this.customToolbarCallbacks = callbacks
        // Clear existing custom items
        customToolbarItemIds.clear()
        androidBackButtons.clear()

        // Process items for Android back button flags
        for (item in items) {
            val identifier = item["identifier"] as? String ?: continue
            val isBackButton = item["isAndroidBackButton"] as? Boolean ?: false

            if (isBackButton) {
                androidBackButtons[identifier] = true
                Log.d("FlutterPdfUiFragment", "Registered $identifier as an Android back button")
            }
        }

        // Add the new items
        this.customToolbarItems = items
    }

    /**
     * Sets the annotation menu handler for customizing contextual annotation menus.
     * Note: The actual menu customization is now handled through annotation selection events
     * in FlutterEventsHelper, not through contextual toolbar lifecycle events.
     *
     * @param handler The annotation menu handler to use for customization
     */
    fun setAnnotationMenuHandler(handler: AnnotationMenuHandler) {
        this.annotationMenuHandler = handler
        Log.d("FlutterPdfUiFragment", "Annotation menu handler configured")
    }



    /**
     * Gets the effective annotation menu handler to use, falling back to global configuration
     * if no widget-specific handler is set.
     *
     * @return The annotation menu handler to use, or null if none available
     */
    private fun getEffectiveAnnotationMenuHandler(): AnnotationMenuHandler? {
        return annotationMenuHandler ?: let {
            // Fall back to global configuration if no widget-specific handler is set
            if (GlobalAnnotationMenuConfiguration.hasConfiguration()) {
                AnnotationMenuHandler.fromGlobalConfiguration(requireContext())
            } else {
                null
            }
        }
    }

    /**
     * Sets the toolbar grouping rule for annotation creation toolbar.
     *
     * @param rule The menu item grouping rule.
     */
    fun setToolbarGroupingRule(rule: MenuItemGroupingRule) {
        this.toolbarGroupingRule = rule
        applyToolbarGroupingRule()
        Log.d("FlutterPdfUiFragment", "Toolbar grouping rule configured")
    }

    /**
     * Registers the annotation creation toolbar's grouping rule with the toolbar coordinator, the
     * Compose replacement for setting it on the View `AnnotationToolbar`.
     */
    private fun applyToolbarGroupingRule() {
        if (view == null) return
        nutrientToolbarCoordinator().setMenuItemGroupingRule(
            requireContext(),
            ContextualToolbarKind.Annotation,
            toolbarGroupingRule,
        )
    }

    /**
     * Sets whether to hide the annotation creation button from the main toolbar.
     *
     * @param hide True to hide the annotation creation button, false to show it.
     */
    fun setHideAnnotationCreationButton(hide: Boolean) {
        this.hideAnnotationCreationButton = hide
        // Re-run the toolbar items provider (only if view is ready)
        if (view != null) {
            invalidateToolbarItems()
        }
    }

    /**
     * Sets whether to show the stylus button on the annotation creation toolbar.
     *
     * @param show True to show the stylus button, false to hide it.
     */
    fun setShowStylusButton(show: Boolean) {
        this.showStylusButton = show
        if (!show && view != null) {
            val coordinator = nutrientToolbarCoordinator()
            StylusButtonVisibility.removeFrom(coordinator, coordinator.contextualToolbar.value)
        }
    }

    /**
     * Sets the theme colors to be applied to the PDF viewer UI.
     *
     * @param colors A map of theme color keys (in dot notation) to color integers
     */
    fun setThemeColors(colors: HashMap<String, Int>?) {
        this.themeColors = colors
        Log.d("FlutterPdfUiFragment", "Theme colors configured with ${colors?.size ?: 0} colors")
        warnAboutUnsupportedToolbarColors(colors)
        // If the view is already created, apply immediately
        if (view != null) {
            applyImmediateThemeColors()
        }
    }

    // Store titles for custom toolbar items
    private val customToolbarItemTitles = HashMap<String, String>()

    // Store icons for custom toolbar items
    private val customToolbarItemIcons = HashMap<String, ToolbarIcon>()

    private fun getCustomToolbarItemTitle(identifier: String): String {
        return customToolbarItemTitles[identifier] ?: ""
    }


    override fun onResume() {
        super.onResume()
        // Add custom toolbar items if they are set
        customToolbarItems?.let { items ->
            addCustomToolbarItems(items)
        }
    }

    /**
     * Adds custom toolbar items based on the configuration from Flutter.
     *
     * @param items The list of custom toolbar item configurations.
     */
    private fun addCustomToolbarItems(items: List<Map<String, Any>>) {
        if (items.isEmpty()) return
        val activity = requireActivity()

        for (itemConfig in items) {
            val identifier = itemConfig["identifier"] as? String ?: continue
            val title = itemConfig["title"] as? String ?: continue
            val iconName = itemConfig["iconName"] as? String
            val iconColorHex = itemConfig["iconColor"] as? String

            // Resolve the icon from the icon name
            if (isAndroidBackButton(identifier)) {
                val backButtonIcon = toolbarIconFromName(
                    activity.applicationContext,
                    iconName,
                    iconColorHex,
                )
                setAndroidBackButton(identifier, title, backButtonIcon)
                continue
            }

            // Store the title for this item
            customToolbarItemTitles[identifier] = title

            // Generate a unique ID for this menu item
            val itemId = identifier.hashCode()
            customToolbarItemIds[identifier] = itemId

            // Resolve the icon if available
            if (iconName != null) {
                val fragmentContext = activity.applicationContext ?: continue
                customToolbarItemIcons[identifier] =
                    toolbarIconFromName(fragmentContext, iconName, iconColorHex)
            }
        }
        // Re-run the toolbar items provider (only if view is ready)
        if (view != null) {
            invalidateToolbarItems()
        }
    }

    /**
     * Helper method to get a resource ID from a resource name.
     * This method handles different resource types and provides better error handling.
     *
     * @param context The context to use for resource lookup
     * @param resourceName The name of the resource to find
     * @param resourceType The type of resource (drawable, mipmap, etc.)
     * @return The resource ID, or 0 if not found
     */
    private fun getResourceId(context: Context, resourceName: String, resourceType: String): Int {
        try {
            val resourceId =
                context.resources.getIdentifier(resourceName, resourceType, context.packageName)
            if (resourceId != 0) {
                Log.d("FlutterPdfUiFragment", "Found $resourceType resource for: $resourceName")
            }
            return resourceId
        } catch (e: Exception) {
            Log.e(
                "FlutterPdfUiFragment",
                "Error getting $resourceType resource ID for: $resourceName",
                e
            )
            return 0
        }
    }

    /**
     * Resolves a custom item's icon from a drawable or mipmap resource name in the app, tinted
     * with [iconColorHex] when given. Falls back to a text-only item when there is no such
     * resource.
     */
    private fun toolbarIconFromName(
        fragmentContext: Context,
        iconName: String?,
        iconColorHex: String?
    ): ToolbarIcon {
        if (iconName == null) {
            Log.w("FlutterPdfUiFragment", "Icon name is null")
            return ToolbarIcon.None
        }

        // Try the drawable resources (the app's custom icons), then mipmap (app icons).
        var resourceId = getResourceId(fragmentContext, iconName, "drawable")
        if (resourceId == 0) {
            resourceId = getResourceId(fragmentContext, iconName, "mipmap")
        }
        if (resourceId == 0) {
            Log.w("FlutterPdfUiFragment", "Could not find icon resource for: $iconName")
            return ToolbarIcon.None
        }

        val tint = iconColorHex?.let { hex ->
            try {
                Color(hex.toColorInt())
            } catch (e: IllegalArgumentException) {
                Log.w("FlutterPdfUiFragment", "Invalid color format for icon $iconName: $hex", e)
                null
            }
        }
        return ToolbarIcon.Resource(resourceId, tint)
    }


    /**
     * Publishes the custom items to the main toolbar and routes their taps, and drops the
     * annotation creation button when it is hidden.
     *
     * The View menu hooks this used to rely on (`onGenerateMenuItemIds` plus a toolbar-wide
     * `setOnMenuItemClickListener`) are gone with the Compose toolbars. The provider runs on
     * every toolbar rebuild and reads the current items, so it only has to be installed once.
     */
    private fun installCustomToolbarItems() {
        setToolbarItemsProvider { defaultItems ->
            val items = if (hideAnnotationCreationButton) {
                defaultItems.filterNot { it.id == R.id.pspdf__menu_option_edit_annotations }
            } else {
                defaultItems
            }
            items + customToolbarItemIds.map { (identifier, itemId) ->
                val icon = customToolbarItemIcons[identifier] ?: ToolbarIcon.None
                ToolbarItem.Button(
                    actionId = "$CUSTOM_ACTION_PREFIX$identifier",
                    id = itemId,
                    contentDescription = getCustomToolbarItemTitle(identifier),
                    icon = icon,
                    // Without an icon the button would render empty, so show its title instead.
                    overflowBehavior = if (icon == ToolbarIcon.None) {
                        ToolbarItem.OverflowBehavior.AlwaysAsText
                    } else {
                        ToolbarItem.OverflowBehavior.AlwaysShow
                    },
                )
            }
        }
        setOnToolbarItemClickListener { itemId ->
            // Returning false leaves every id we did not add to the SDK's own handling.
            val matchingIdentifier = customToolbarItemIds.entries.find { it.value == itemId }?.key
            if (matchingIdentifier != null) {
                customToolbarCallbacks?.onCustomToolbarItemTapped(matchingIdentifier) {}
                true
            } else {
                false
            }
        }
    }

    // Map to track which toolbar items are Android back buttons
    private val androidBackButtons = HashMap<String, Boolean>()

    /**
     * Checks if the given toolbar item identifier is marked as an Android back button.
     *
     * @param identifier The identifier of the toolbar item to check
     * @return True if the item is marked as an Android back button, false otherwise
     */
    private fun isAndroidBackButton(identifier: String): Boolean {
        return androidBackButtons[identifier] == true
    }

    /**
     * Sets the Android back button in the toolbar with the specified identifier and icon.
     *
     * @param identifier The identifier for the back button
     * @param title The accessibility label of the back button
     * @param icon The icon for the back button
     */
    private fun setAndroidBackButton(identifier: String, title: String, icon: ToolbarIcon) {
        setToolbarNavigationIcon(icon, title)
        setOnToolbarNavigationClickListener {
            customToolbarCallbacks?.onCustomToolbarItemTapped(identifier) {}
        }
    }


    /**
     * Reacts to the contextual toolbars the coordinator shows: takes the stylus toggle off the
     * annotation toolbar when it is hidden, and clears the selected annotation once a contextual
     * toolbar goes away, which the View toolbars reported through `onRemoveContextualToolbar`.
     * One bar can replace another without a `null` state in between, so any change of kind
     * counts as the previous bar going away.
     */
    private fun onContextualToolbarChanged(state: ContextualToolbarState?) {
        if (!showStylusButton) {
            StylusButtonVisibility.removeFrom(nutrientToolbarCoordinator(), state)
        }
        val kind = state?.kind
        if (shownContextualToolbarKind != null && kind != shownContextualToolbarKind) {
            getEffectiveAnnotationMenuHandler()?.clearSelectedAnnotation()
        }
        shownContextualToolbarKind = kind
    }

    /**
     * Called when the annotation popup toolbar is being prepared (shown when an
     * annotation is selected). This is where annotation editing menu customization
     * is applied, replacing the pre-11.5 AnnotationEditingToolbar contextual flow.
     */
    override fun onPrepareAnnotationPopupToolbar(popupToolbar: AnnotationPopupToolbar) {
        val selectedAnnotation = popupToolbar.annotations.firstOrNull()
        if (selectedAnnotation != null) {
            Log.d(
                "FlutterPdfUiFragment",
                "Preparing popup toolbar for annotation: ${selectedAnnotation.type.name}, UUID: ${selectedAnnotation.uuid}"
            )
            getEffectiveAnnotationMenuHandler()?.let { handler ->
                handler.onAnnotationSelected(
                    selectedAnnotation,
                    popupToolbar.annotations.size > 1
                )
                handler.onPrepareAnnotationPopupToolbar(popupToolbar)
                Log.d("FlutterPdfUiFragment", "Applied annotation menu configuration to popup toolbar")
            }
        } else {
            getEffectiveAnnotationMenuHandler()?.onPrepareAnnotationPopupToolbar(popupToolbar)
        }
    }

    /**
     * Logs the theme colors this view can no longer apply. The Compose toolbars take their colors
     * from the theme (`pspdf__mainToolbarStyle`, `pspdf__contextualToolbarStyle`). The contextual
     * toolbars have no runtime override. The main toolbar's, `ToolbarCoordinator.setMainToolbarColors`,
     * needs a complete `UiColorScheme`, whose defaults can only be built inside a composition.
     */
    private fun warnAboutUnsupportedToolbarColors(colors: Map<String, Int>?) {
        val unsupported = colors?.keys?.filter { it in UNSUPPORTED_TOOLBAR_COLORS }.orEmpty()
        if (unsupported.isEmpty()) return
        Log.w(
            "FlutterPdfUiFragment",
            "Ignoring ${unsupported.sorted().joinToString()}: toolbar colors aren't applied at " +
                "runtime on Android yet. Theme the toolbars with pspdf__mainToolbarStyle and " +
                "pspdf__contextualToolbarStyle instead."
        )
    }

    private companion object {
        /** Prefix for the action ids of custom items, so they can't collide with the SDK's. */
        private const val CUSTOM_ACTION_PREFIX = "nutrient_flutter_custom_"

        /** Theme color keys for the toolbars, which have no runtime color API on Android. */
        private val UNSUPPORTED_TOOLBAR_COLORS = setOf(
            "toolbar.backgroundColor",
            "toolbar.iconColor",
            "toolbar.titleColor",
            "annotationToolbar.backgroundColor",
            "annotationToolbar.iconColor",
        )
    }
}
