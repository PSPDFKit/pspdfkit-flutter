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
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuInflater
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.DrawableCompat
import androidx.core.graphics.toColorInt
import androidx.core.view.MenuHost
import androidx.core.view.MenuProvider
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.lifecycle.Lifecycle
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.annotations.AnnotationMenuHandler
import com.pspdfkit.flutter.pspdfkit.api.CustomToolbarCallbacks
import com.pspdfkit.flutter.pspdfkit.util.DynamicColorResourcesHelper
import com.pspdfkit.R
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.ui.toolbar.AnnotationCreationToolbar
import com.pspdfkit.ui.toolbar.AnnotationEditingToolbar
import com.pspdfkit.ui.toolbar.ContextualToolbar
import com.pspdfkit.ui.toolbar.ToolbarCoordinatorLayout
import com.pspdfkit.ui.toolbar.grouping.MenuItemGroupingRule

class FlutterPdfUiFragment : PdfUiFragment(), MenuProvider,
    ToolbarCoordinatorLayout.OnContextualToolbarLifecycleListener {

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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setHasOptionsMenu(true)
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
        val menuHost: MenuHost = requireActivity()
        menuHost.addMenuProvider(this, viewLifecycleOwner, Lifecycle.State.RESUMED)
        return super.onCreateView(inflater, container, savedInstanceState)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupKeyboardInsetListener()
        applyImmediateThemeColors()
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
                pdfFragment?.setBackgroundColor(color)
                Log.d("FlutterPdfUiFragment", "Applied background color")
            }

            // Apply toolbar colors
            val toolbar = view?.findViewById<Toolbar>(R.id.pspdf__toolbar_main)
            if (toolbar != null) {
                colors["toolbar.backgroundColor"]?.let { color ->
                    toolbar.setBackgroundColor(color)
                    Log.d("FlutterPdfUiFragment", "Applied toolbar background color")
                }

                colors["toolbar.iconColor"]?.let { color ->
                    toolbar.navigationIcon?.setTint(color)
                    toolbar.overflowIcon?.setTint(color)
                    toolbar.menu?.let { menu ->
                        for (i in 0 until menu.size()) {
                            menu.getItem(i).icon?.setTint(color)
                        }
                    }
                    Log.d("FlutterPdfUiFragment", "Applied toolbar icon color")
                }

                colors["toolbar.titleColor"]?.let { color ->
                    toolbar.setTitleTextColor(color)
                    Log.d("FlutterPdfUiFragment", "Applied toolbar title color")
                }
            }

            // Apply status bar color
            colors["toolbar.statusBarColor"]?.let { color ->
                activity?.window?.statusBarColor = color
                Log.d("FlutterPdfUiFragment", "Applied status bar color")
            }

            // Apply thumbnail bar background
            colors["thumbnailBar.backgroundColor"]?.let { color ->
                view?.findViewById<View>(R.id.pspdf__activity_thumbnail_bar)?.setBackgroundColor(color)
                view?.findViewById<View>(R.id.pspdf__static_thumbnail_bar)?.setBackgroundColor(color)
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
        activity?.invalidateOptionsMenu()
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
        Log.d("FlutterPdfUiFragment", "Toolbar grouping rule configured")
    }

    /**
     * Sets whether to hide the annotation creation button from the main toolbar.
     *
     * @param hide True to hide the annotation creation button, false to show it.
     */
    fun setHideAnnotationCreationButton(hide: Boolean) {
        this.hideAnnotationCreationButton = hide
        // Invalidate options menu to trigger onPrepareOptionsMenu
        activity?.invalidateOptionsMenu()
    }

    /**
     * Sets the theme colors to be applied to the PDF viewer UI.
     *
     * @param colors A map of theme color keys (in dot notation) to color integers
     */
    fun setThemeColors(colors: HashMap<String, Int>?) {
        this.themeColors = colors
        Log.d("FlutterPdfUiFragment", "Theme colors configured with ${colors?.size ?: 0} colors")
        // If the view is already created, apply immediately
        if (view != null) {
            applyImmediateThemeColors()
        }
    }

    // Store titles for custom toolbar items
    private val customToolbarItemTitles = HashMap<String, String>()

    // Store drawables for custom toolbar items
    private val customToolbarItemDrawables = HashMap<String, Drawable?>()

    private fun getCustomToolbarItemTitle(identifier: String): String {
        return customToolbarItemTitles[identifier] ?: ""
    }

    private fun getCustomToolbarItemDrawable(identifier: String): Drawable? {
        return customToolbarItemDrawables[identifier]
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

            // Extract drawable from the icon name
            if (isAndroidBackButton(identifier)) {
                val backButtonIcon = extractDrawableFromName(
                    activity.applicationContext,
                    iconName,
                    iconColorHex,
                )
                setAndroidBackButton(identifier, backButtonIcon)
                return
            }

            // Store the title for this item
            customToolbarItemTitles[identifier] = title

            // Generate a unique ID for this menu item
            val itemId = identifier.hashCode()
            customToolbarItemIds[identifier] = itemId

            // Load drawable if available
            if (iconName != null) {
                val fragmentContext = activity.applicationContext ?: continue
                val drawable = extractDrawableFromName(fragmentContext, iconName, iconColorHex)
                customToolbarItemDrawables[identifier] = drawable
            }
        }
        // Update the menu
        activity.invalidateOptionsMenu()
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

    private fun extractDrawableFromName(
        fragmentContext: Context,
        iconName: String?,
        iconColorHex: String?
    ): Drawable? {

        var drawable: Drawable? = null

        // Check if the icon name is null
        if (iconName == null) {
            Log.w("FlutterPdfUiFragment", "Icon name is null")
            return null
        }

        try {
            // Try to load from drawable resources (user's custom icons)
            var resourceId = getResourceId(fragmentContext, iconName, "drawable")

            // If not found in drawable, try to load from mipmap (for app icons)
            if (resourceId == 0) {
                resourceId = getResourceId(fragmentContext, iconName, "mipmap")
            }

            // We no longer use predefined icon mappings
            // Users must add their own drawable resources

            if (resourceId != 0) {
                drawable = ContextCompat.getDrawable(fragmentContext, resourceId)?.mutate()
                Log.d("FlutterPdfUiFragment", "Successfully loaded icon: $iconName")
            } else {
                Log.w("FlutterPdfUiFragment", "Could not find icon resource for: $iconName")
            }

            // Apply tint if specified
            if (drawable != null && iconColorHex != null) {
                try {
                    val color = iconColorHex.toColorInt()
                    DrawableCompat.setTint(drawable, color)
                    Log.d(
                        "FlutterPdfUiFragment",
                        "Applied tint color $iconColorHex to icon: $iconName"
                    )
                } catch (e: Exception) {
                    Log.w(
                        "FlutterPdfUiFragment",
                        "Invalid color format for icon $iconName: $iconColorHex",
                        e
                    )
                }
            }
        } catch (e: Exception) {
            Log.e("FlutterPdfUiFragment", "Error loading icon: $iconName", e)
        }
        return drawable
    }


    override fun onCreateMenu(menu: Menu, menuInflater: MenuInflater) {
        // Add all registered custom toolbar items
        for ((identifier, itemId) in customToolbarItemIds) {
            // Only add it if it's not already in the menu
            if (menu.findItem(itemId) == null) {
                // Get the stored configuration for this item
                val title = getCustomToolbarItemTitle(identifier)
                val drawable = getCustomToolbarItemDrawable(identifier)
                menu.add(Menu.NONE, itemId, Menu.NONE, title)
                    .setIcon(drawable)
                    .setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
            }
        }
    }

    override fun onMenuItemSelected(menuItem: MenuItem): Boolean {
        // Check custom toolbar items
        val matchingIdentifier =
            customToolbarItemIds.entries.find { it.value == menuItem.itemId }?.key
        if (matchingIdentifier != null) {
            // Notify Flutter about the tap
            customToolbarCallbacks?.onCustomToolbarItemTapped(matchingIdentifier) {
            }
            return true
        }
        return false
    }

    override fun onPrepareOptionsMenu(menu: Menu) {
        super.onPrepareOptionsMenu(menu)
        // Hide annotation creation button if configured
        if (hideAnnotationCreationButton) {
            hideAnnotationCreationButtonFromMenu(menu)
        }
    }

    private fun hideAnnotationCreationButtonFromMenu(menu: Menu) {
        // First try the options menu approach
        try {
            val resourceId = R.id.pspdf__menu_option_edit_annotations
            if (resourceId != 0) {
                val menuItem = menu.findItem(resourceId)
                if (menuItem != null) {
                    menuItem.isVisible = false
                    return
                }
            }
        } catch (e: Exception) {
            Log.e("FlutterPdfUiFragment", "Error hiding annotation button from menu", e)
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
     * @param icon The drawable icon for the back button
     */
    private fun setAndroidBackButton(identifier: String, icon: Drawable?) {
        val toolbar = view?.findViewById<Toolbar>(R.id.pspdf__toolbar_main)
        toolbar?.navigationIcon = icon
        toolbar?.setNavigationOnClickListener {
            // Handle Android back button action
            customToolbarCallbacks?.onCustomToolbarItemTapped(identifier) {
                // Handle the back button action here
            }
        }
    }


    // Contextual toolbar lifecycle methods for annotation menu customization

    override fun onPrepareContextualToolbar(contextualToolbar: ContextualToolbar<*>) {
        // Handle annotation creation toolbar grouping (existing functionality)
        if (contextualToolbar is AnnotationCreationToolbar && toolbarGroupingRule != null) {
            contextualToolbar.setMenuItemGroupingRule(toolbarGroupingRule)
            Log.d(
                "FlutterPdfUiFragment",
                "Applied toolbar grouping rule to annotation creation toolbar"
            )
        }

        // Apply annotation toolbar theme colors for both annotation toolbars
        if (contextualToolbar is AnnotationCreationToolbar || contextualToolbar is AnnotationEditingToolbar) {
            applyAnnotationToolbarThemeColors(contextualToolbar)
        }

        // For annotation editing toolbar, use only static configuration from GlobalAnnotationMenuConfiguration
        if (contextualToolbar is AnnotationEditingToolbar) {
            val selectedAnnotations = pdfFragment?.selectedAnnotations
            if (!selectedAnnotations.isNullOrEmpty()) {
                val selectedAnnotation = selectedAnnotations.first()
                Log.d(
                    "FlutterPdfUiFragment",
                    "Preparing toolbar for annotation: ${selectedAnnotation.type.name}, UUID: ${selectedAnnotation.uuid}"
                )

                // Use only static configuration from GlobalAnnotationMenuConfiguration
                getEffectiveAnnotationMenuHandler()?.let { handler ->
                    handler.onAnnotationSelected(
                        selectedAnnotation,
                        selectedAnnotations.size > 1
                    )
                    handler.onPrepareContextualToolbar(contextualToolbar)
                    Log.d("FlutterPdfUiFragment", "Applied static annotation menu configuration to toolbar")
                }
                return
            }
        }

        // Handle annotation editing toolbar customization (fallback)
        getEffectiveAnnotationMenuHandler()?.onPrepareContextualToolbar(contextualToolbar)
    }

    override fun onDisplayContextualToolbar(contextualToolbar: ContextualToolbar<*>) {
        // Apply annotation toolbar theme colors when toolbar is displayed
        if (contextualToolbar is AnnotationCreationToolbar || contextualToolbar is AnnotationEditingToolbar) {
            applyAnnotationToolbarThemeColors(contextualToolbar)
        }
    }

    /**
     * Applies annotation toolbar theme colors to a contextual toolbar.
     * This includes background color and icon colors for annotation toolbars.
     */
    private fun applyAnnotationToolbarThemeColors(contextualToolbar: ContextualToolbar<*>) {
        val colors = themeColors ?: return

        try {
            Log.d("FlutterPdfUiFragment", "Applying annotation toolbar colors to ${contextualToolbar.javaClass.simpleName}")

            // Apply annotation toolbar background color
            // ContextualToolbar is a ViewGroup — setBackgroundColor works directly on the view
            colors["annotationToolbar.backgroundColor"]?.let { color ->
                (contextualToolbar as? View)?.setBackgroundColor(color)
                Log.d("FlutterPdfUiFragment", "Applied annotation toolbar background color")
            }

            // Apply icon color tint to toolbar menu items
            // ContextualToolbar has getMenuItems() to access items
            colors["annotationToolbar.iconColor"]?.let { color ->
                try {
                    val menuItems = contextualToolbar.menuItems
                    if (menuItems != null) {
                        for (item in menuItems) {
                            item.icon?.setTint(color)
                        }
                        Log.d("FlutterPdfUiFragment", "Applied annotation toolbar icon color to ${menuItems.size} items")
                    }
                } catch (e: Exception) {
                    Log.w("FlutterPdfUiFragment", "Could not tint annotation toolbar icons via menuItems", e)
                }
                // Also traverse child views to tint any ImageViews
                try {
                    val viewGroup = contextualToolbar as? ViewGroup
                    if (viewGroup != null) {
                        tintAllIcons(viewGroup, color)
                    }
                } catch (e: Exception) {
                    Log.w("FlutterPdfUiFragment", "Could not traverse annotation toolbar children", e)
                }
            }
        } catch (e: Exception) {
            Log.e("FlutterPdfUiFragment", "Error applying annotation toolbar theme colors", e)
        }
    }

    /**
     * Recursively tints all ImageView drawables within a ViewGroup.
     */
    private fun tintAllIcons(viewGroup: ViewGroup, color: Int) {
        for (i in 0 until viewGroup.childCount) {
            val child = viewGroup.getChildAt(i)
            if (child is android.widget.ImageView) {
                child.drawable?.setTint(color)
                child.imageTintList = android.content.res.ColorStateList.valueOf(color)
            } else if (child is ViewGroup) {
                tintAllIcons(child, color)
            }
        }
    }

    override fun onRemoveContextualToolbar(contextualToolbar: ContextualToolbar<*>) {
        // Clear selected annotation when toolbar is removed
        getEffectiveAnnotationMenuHandler()?.clearSelectedAnnotation()
    }
}
