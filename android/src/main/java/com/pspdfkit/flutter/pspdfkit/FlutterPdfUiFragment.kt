/*
 * Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

import android.graphics.Color
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.view.Menu
import android.view.MenuInflater
import android.view.MenuItem
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.DrawableCompat
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.api.CustomToolbarCallbacks
import com.pspdfkit.ui.PdfUiFragment

/**
 * A custom PdfUiFragment that supports custom toolbar items.
 * It extends PdfUiFragment from PSPDFKit and adds functionality for handling custom toolbar items.
 */
class FlutterPdfUiFragment : PdfUiFragment() {

    // Maps identifier strings to menu item IDs to track custom toolbar items
    private val customToolbarItemIds = HashMap<String, Int>()
    private var customToolbarCallbacks: CustomToolbarCallbacks? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        // Enable options menu for the fragment
        setHasOptionsMenu(true)
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
        // Add the new items
        addCustomToolbarItems(items)
    }
    
    override fun onCreateOptionsMenu(menu: Menu, inflater: MenuInflater) {
        super.onCreateOptionsMenu(menu, inflater)
        
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

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        // Check if this is one of our custom toolbar items
        val matchingIdentifier = customToolbarItemIds.entries.find { it.value == item.itemId }?.key
        if (matchingIdentifier != null) {
            // Notify Flutter about the tap
            customToolbarCallbacks?.onCustomToolbarItemTapped(matchingIdentifier){
            }
            return true
        }
        return super.onOptionsItemSelected(item)
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
            
            // Store the title for this item
            customToolbarItemTitles[identifier] = title
            
            // Generate a unique ID for this menu item
            val itemId = identifier.hashCode()
            customToolbarItemIds[identifier] = itemId
            
            // Load drawable if available
            if (iconName != null) {
                val fragmentContext = activity.applicationContext ?: continue
                val resourceId = fragmentContext.resources.getIdentifier(iconName, "drawable", fragmentContext.packageName)
                if (resourceId != 0) {
                    val drawable = ContextCompat.getDrawable(fragmentContext, resourceId)?.mutate()
                    
                    // Apply tint if specified
                    if (drawable != null && iconColorHex != null) {
                        try {
                            val color = Color.parseColor(iconColorHex)
                            DrawableCompat.setTint(drawable, color)
                        } catch (e: Exception) {
                            // Invalid color format, use default
                        }
                    }
                    customToolbarItemDrawables[identifier] = drawable
                }
            }
        }
        // Update the menu
        activity.invalidateOptionsMenu()
    }
}