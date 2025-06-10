/*
 * Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
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
import androidx.lifecycle.Lifecycle
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.api.CustomToolbarCallbacks
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.R

class FlutterPdfUiFragment : PdfUiFragment(), MenuProvider {

    // Maps identifier strings to menu item IDs to track custom toolbar items
    private val customToolbarItemIds = HashMap<String, Int>()
    private var customToolbarCallbacks: CustomToolbarCallbacks? = null
    private var customToolbarItems: List<Map<String, Any>>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setHasOptionsMenu(true)
//        Check if back button was set;
        (activity as AppCompatActivity).supportActionBar?.apply {
            setDisplayHomeAsUpEnabled(true)
            setDisplayShowHomeEnabled(true)
        }
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

    /**
     * Called when the document is loaded. Notifies Flutter that the document has been loaded.
     *
     * @param document The loaded PDF document.
     */
    override fun onDocumentLoaded(document: PdfDocument) {
        super.onDocumentLoaded(document)
        // Notify the Flutter PSPDFKit plugin that the document has been loaded.
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
                val drawable = extractDrawableFromName(fragmentContext,iconName, iconColorHex)
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

    private fun extractDrawableFromName(fragmentContext: Context,iconName: String?, iconColorHex:String? ): Drawable? {

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
}