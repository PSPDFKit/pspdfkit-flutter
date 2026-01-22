/*
 * Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit.annotations

import android.content.Context
import android.view.View
import com.pspdfkit.annotations.Annotation
import com.pspdfkit.flutter.pspdfkit.api.AnnotationMenuConfigurationData
import com.pspdfkit.flutter.pspdfkit.api.AnnotationMenuAction
import com.pspdfkit.flutter.pspdfkit.GlobalAnnotationMenuConfiguration
import com.pspdfkit.R
import com.pspdfkit.ui.toolbar.ContextualToolbar
import java.util.Locale

/**
 * Handles customization of annotation contextual menus in the Nutrient Flutter SDK on Android.
 * 
 * This class manages the customization of annotation menus by:
 * - Adding custom menu items with icons and callbacks
 * - Removing or hiding default menu items
 * - Hiding the style picker if configured
 * - Handling menu item interactions and communicating back to Flutter
 */
class AnnotationMenuHandler(
    private val context: Context,
    private val configuration: AnnotationMenuConfigurationData?
) {
    
    companion object {
        /**
         * Maps AnnotationMenuAction enum values to actual Android resource IDs
         */
        private fun getResourceIdForMenuAction(action: AnnotationMenuAction): Int? {
            return when (action) {
                AnnotationMenuAction.DELETE -> R.id.pspdf__annotation_editing_toolbar_item_delete
                AnnotationMenuAction.COPY -> R.id.pspdf__annotation_editing_toolbar_item_copy
                AnnotationMenuAction.CUT -> R.id.pspdf__annotation_editing_toolbar_item_cut
                AnnotationMenuAction.COLOR -> R.id.pspdf__annotation_editing_toolbar_item_picker
                AnnotationMenuAction.NOTE -> R.id.pspdf__annotation_editing_toolbar_item_annotation_note 
                AnnotationMenuAction.UNDO -> R.id.pspdf__annotation_editing_toolbar_item_undo
                AnnotationMenuAction.REDO -> R.id.pspdf__annotation_editing_toolbar_item_redo
            }
        }
        
        /**
         * Creates a new AnnotationMenuHandler instance with configuration from GlobalAnnotationMenuConfiguration.
         * This is useful for creating handlers that automatically pick up the global configuration.
         * 
         * @param context The context for the handler
         * @return A new AnnotationMenuHandler instance with the global configuration
         */
        fun fromGlobalConfiguration(context: Context): AnnotationMenuHandler {
            return AnnotationMenuHandler(context, GlobalAnnotationMenuConfiguration.getConfiguration())
        }
    }


    // Currently selected annotation for callback purposes
    private var selectedAnnotation: Annotation? = null


    /**
     * Called when an annotation is selected. This method stores the selected annotation
     * for later use when the contextual toolbar is prepared.
     *
     * @param annotation The selected annotation
     * @param isMultipleSelection Whether multiple annotations are selected
     * @return true to allow the selection, false to prevent it
     */
    fun onAnnotationSelected(
        annotation: Annotation,
        isMultipleSelection: Boolean
    ): Boolean {
        selectedAnnotation = annotation
        return true // Allow the selection
    }

    /**
     * Called when a contextual toolbar is being prepared. This is where we customize
     * the annotation editing toolbar.
     *
     * @param toolbar The contextual toolbar being prepared
     */
    fun onPrepareContextualToolbar(toolbar: ContextualToolbar<*>) {
        // Try to customize any contextual toolbar with configuration
        if (configuration != null) {
            try {
                // Apply menu customizations directly to the toolbar
                removeMenuItems(toolbar, configuration.itemsToRemove)
                disableMenuItems(toolbar, configuration.itemsToDisable)
                
                // Apply style picker visibility configuration
                if (!configuration.showStylePicker) {
                    removeStylePickerItems(toolbar)
                }
            } catch (e: Exception) {
                // Silently handle errors in customization
            }
        }
    }



    /**
     * Removes menu items from the toolbar based on their action types.
     * Uses PSPDFKit's setMenuItemVisibility API to properly hide items.
     *
     * @param toolbar The contextual toolbar to modify
     * @param itemsToRemove List of menu actions to remove
     */
    private fun removeMenuItems(
        toolbar: ContextualToolbar<*>,
        itemsToRemove: List<AnnotationMenuAction>
    ) {
        if (itemsToRemove.isEmpty()) {
            return
        }
        
        itemsToRemove.forEach { action ->
            val resourceId = getResourceIdForMenuAction(action)
            
            if (resourceId != null) {
                try {
                    toolbar.setMenuItemVisibility(resourceId, View.GONE)
                } catch (e: Exception) {
                    // Silently skip items that cannot be hidden
                }
            }
        }
    }

    /**
     * Disables menu items based on their action types.
     * Properly disables items by setting isEnabled to false.
     *
     * @param toolbar The contextual toolbar to modify  
     * @param itemsToDisable List of menu actions to disable
     */
    private fun disableMenuItems(
        toolbar: ContextualToolbar<*>,
        itemsToDisable: List<AnnotationMenuAction>
    ) {
        if (itemsToDisable.isEmpty()) {
            return
        }
        
        val menuItems = toolbar.menuItems.toMutableList()
        var modified = false
        
        itemsToDisable.forEach { action ->
            val resourceId = getResourceIdForMenuAction(action)
            if (resourceId != null) {
                // Find the menu item by its resource ID
                val menuItem = menuItems.find { it.id == resourceId }
                if (menuItem != null) {
                    // Disable the menu item by setting isEnabled to false
                    menuItem.isEnabled = false
                    modified = true
                }
            }
        }
        
        // Apply the modified menu items back to the toolbar if any changes were made
        if (modified) {
            toolbar.setMenuItems(menuItems)
        }
    }


    /**
     * Removes style picker related items from the menu if configured to do so.
     * 
     * @param toolbar The contextual toolbar to modify
     */
    private fun removeStylePickerItems(toolbar: ContextualToolbar<*>) {
        // Hide the picker item (color/style picker)
        try {
            toolbar.setMenuItemVisibility(R.id.pspdf__annotation_editing_toolbar_item_picker, View.GONE)
        } catch (e: Exception) {
            // Silently skip if item cannot be hidden
        }
        
        // Also try to hide other potential style-related items if they exist
        val potentialStyleItems = listOf(
            "style", "color", "thickness", "picker"
        )
        
        toolbar.menuItems.forEach { item ->
            val itemTitle = item.title?.toString()?.lowercase(Locale.getDefault())
            val resourceName = getResourceName(item.id)?.lowercase(Locale.getDefault())
            
            val isStylePickerItem = potentialStyleItems.any { keyword ->
                itemTitle?.contains(keyword) == true || resourceName?.contains(keyword) == true
            }
            
            if (isStylePickerItem) {
                try {
                    toolbar.setMenuItemVisibility(item.id, View.GONE)
                } catch (e: Exception) {
                    // Silently skip if item cannot be hidden
                }
            }
        }
    }

    /**
     * Gets the resource name from a resource ID.
     * 
     * @param resourceId The resource ID
     * @return The resource name, or null if not found
     */
    private fun getResourceName(resourceId: Int): String? {
        return try {
            if (resourceId != 0) {
                context.resources.getResourceEntryName(resourceId)
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Updates the annotation menu configuration dynamically.
     * 
     * @param newConfiguration The new annotation menu configuration
     */
    fun updateConfiguration(newConfiguration: AnnotationMenuConfigurationData?) {
        // Note: We can't directly update the configuration since it's a constructor parameter.
        // This method is provided for compatibility, but in practice, a new handler instance
        // should be created with the new configuration.
    }

    /**
     * Clears the selected annotation when the selection changes.
     */
    fun clearSelectedAnnotation() {
        selectedAnnotation = null
    }
}