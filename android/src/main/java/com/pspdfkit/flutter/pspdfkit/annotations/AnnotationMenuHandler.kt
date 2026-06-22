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
import com.pspdfkit.annotations.Annotation
import com.pspdfkit.flutter.pspdfkit.api.AnnotationMenuConfigurationData
import com.pspdfkit.flutter.pspdfkit.api.AnnotationMenuAction
import com.pspdfkit.flutter.pspdfkit.GlobalAnnotationMenuConfiguration
import com.pspdfkit.R
import com.pspdfkit.ui.toolbar.popup.AnnotationPopupToolbar
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
                AnnotationMenuAction.DELETE -> R.id.pspdf__annotation_popup_toolbar_item_delete
                AnnotationMenuAction.COPY -> R.id.pspdf__annotation_popup_toolbar_item_copy
                AnnotationMenuAction.CUT -> R.id.pspdf__annotation_popup_toolbar_item_cut
                AnnotationMenuAction.COLOR -> R.id.pspdf__annotation_popup_toolbar_item_picker
                AnnotationMenuAction.NOTE -> R.id.pspdf__annotation_popup_toolbar_item_annotation_note
                AnnotationMenuAction.UNDO -> R.id.pspdf__annotation_popup_toolbar_item_undo
                AnnotationMenuAction.REDO -> R.id.pspdf__annotation_popup_toolbar_item_redo
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
     * Called when the annotation popup toolbar is being prepared. This is where we
     * customize the annotation editing menu shown when an annotation is selected.
     *
     * As of Nutrient Android 11.5, the annotation editing toolbar was replaced by the
     * [AnnotationPopupToolbar], so customization happens here via the
     * `OnPreparePopupToolbarListener.onPrepareAnnotationPopupToolbar` callback rather
     * than the contextual toolbar lifecycle.
     *
     * @param toolbar The annotation popup toolbar being prepared
     */
    fun onPrepareAnnotationPopupToolbar(toolbar: AnnotationPopupToolbar) {
        // Try to customize the popup toolbar with configuration
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
     * Removes menu items from the popup toolbar based on their action types.
     * The popup toolbar exposes its items as an immutable list, so removal is done
     * by filtering the items by resource ID.
     *
     * @param toolbar The annotation popup toolbar to modify
     * @param itemsToRemove List of menu actions to remove
     */
    private fun removeMenuItems(
        toolbar: AnnotationPopupToolbar,
        itemsToRemove: List<AnnotationMenuAction>
    ) {
        if (itemsToRemove.isEmpty()) {
            return
        }

        val removeIds = itemsToRemove.mapNotNull { getResourceIdForMenuAction(it) }.toSet()
        if (removeIds.isEmpty()) {
            return
        }
        toolbar.menuItems = toolbar.menuItems.filterNot { it.id in removeIds }
    }

    /**
     * Disables menu items based on their action types.
     * Popup toolbar menu items are immutable, so a disabled copy is substituted for
     * each matching item.
     *
     * @param toolbar The annotation popup toolbar to modify
     * @param itemsToDisable List of menu actions to disable
     */
    private fun disableMenuItems(
        toolbar: AnnotationPopupToolbar,
        itemsToDisable: List<AnnotationMenuAction>
    ) {
        if (itemsToDisable.isEmpty()) {
            return
        }

        val disableIds = itemsToDisable.mapNotNull { getResourceIdForMenuAction(it) }.toSet()
        if (disableIds.isEmpty()) {
            return
        }
        toolbar.menuItems = toolbar.menuItems.map { item ->
            if (item.id in disableIds) item.copy(isEnabled = false) else item
        }
    }


    /**
     * Removes style picker related items from the menu if configured to do so.
     *
     * @param toolbar The annotation popup toolbar to modify
     */
    private fun removeStylePickerItems(toolbar: AnnotationPopupToolbar) {
        val pickerId = R.id.pspdf__annotation_popup_toolbar_item_picker
        // Style-related keywords used to catch any additional style/color items.
        val potentialStyleItems = listOf("style", "color", "thickness", "picker")

        toolbar.menuItems = toolbar.menuItems.filterNot { item ->
            if (item.id == pickerId) {
                return@filterNot true
            }
            val resourceName = getResourceName(item.id)?.lowercase(Locale.getDefault())
            potentialStyleItems.any { keyword -> resourceName?.contains(keyword) == true }
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