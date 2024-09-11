/*
*   Copyright © 2024 PSPDFKit GmbH. All rights reserved.
*
*   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
*   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
*   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
*   This notice may not be removed from this file.
*/

package com.pspdfkit.flutter.pspdfkit.toolbar

import android.content.Context
import android.util.Log
import androidx.annotation.IdRes
import androidx.annotation.IntRange
import com.pspdfkit.flutter.pspdfkit.R
import com.pspdfkit.ui.toolbar.ContextualToolbar
import com.pspdfkit.ui.toolbar.grouping.presets.MenuItem
import com.pspdfkit.ui.toolbar.grouping.presets.PresetMenuItemGroupingRule

/**
 * A menu item grouping rule that displays only the menu items configured via the menuItemGrouping prop.
 */
class FlutterMenuGroupingRule(context: Context, menuItems: List<Any>) :
    PresetMenuItemGroupingRule(context) {
    private val items: MutableList<MenuItem> = ArrayList()

    init {
        for (i in menuItems.indices) {
            val menuItem: Any = menuItems[i]
            if (menuItem is Map<*, *>) {
                val key = menuItem["key"] as String
                val group = getIdFromName(key)
                if (group == INVALID_ID) {
                    continue
                }
                val subItems: List<Map<String,Any>> = menuItem["items"] as List<Map<String,Any>>
                val ids = collectItemIds(subItems)
                // Remove the first item from the list of items, as it will be displayed as a single item.
                items.add(MenuItem(group, ids))
            } else if (menuItem is String) {
                val id = getIdFromName(menuItem)
                if (id == INVALID_ID) {
                    continue
                }
                items.add(MenuItem(id))
            }
        }
        // Add colour picker, undo and redo to the end of the list, as iOS always include these items.
        items.add(MenuItem(R.id.pspdf__annotation_creation_toolbar_item_picker))
        items.add(MenuItem(R.id.pspdf__annotation_creation_toolbar_item_undo))
        items.add(MenuItem(R.id.pspdf__annotation_creation_toolbar_item_redo))
    }

    private fun collectItemIds(items: List<Any>): IntArray {
        val itemIds: MutableList<Int> = ArrayList()
        for (i in items.indices) {
            val id = getIdFromName(items[i] as String)
            if (id == INVALID_ID) {
                continue
            }
            itemIds.add(id)
        }
        val ids = IntArray(itemIds.size)
        for (i in itemIds.indices) {
            ids[i] = itemIds[i]
        }
        return ids
    }

    @IdRes
    private fun getIdFromName(name: String): Int {
        when (name) {
            "markup" -> return R.id.pspdf__annotation_creation_toolbar_group_markup
            "writing" -> return R.id.pspdf__annotation_creation_toolbar_group_writing
            "highlight" -> return R.id.pspdf__annotation_creation_toolbar_item_highlight
            "squiggly" -> return R.id.pspdf__annotation_creation_toolbar_item_squiggly
            "strikeout" -> return R.id.pspdf__annotation_creation_toolbar_item_strikeout
            "underline" -> return R.id.pspdf__annotation_creation_toolbar_item_underline
            "freeText" -> return R.id.pspdf__annotation_creation_toolbar_item_freetext
            "freeTextCallout" -> return R.id.pspdf__annotation_creation_toolbar_item_freetext_callout
            "signature" -> return R.id.pspdf__annotation_creation_toolbar_item_signature
            "pen" -> return R.id.pspdf__annotation_creation_toolbar_item_ink_pen
            "highlighter" -> return R.id.pspdf__annotation_creation_toolbar_item_ink_highlighter
            "note" -> return R.id.pspdf__annotation_creation_toolbar_item_note
            "drawing" -> return R.id.pspdf__annotation_creation_toolbar_group_drawing
            "multimedia" -> return R.id.pspdf__annotation_creation_toolbar_group_multimedia
            "image" -> return R.id.pspdf__annotation_creation_toolbar_item_image
            "camera" -> return R.id.pspdf__annotation_creation_toolbar_item_camera
            "stamp" -> return R.id.pspdf__annotation_creation_toolbar_item_stamp
            "line" -> return R.id.pspdf__annotation_creation_toolbar_item_line
            "arrow" -> return R.id.pspdf__annotation_creation_toolbar_item_line_arrow
            "square" -> return R.id.pspdf__annotation_creation_toolbar_item_square
            "circle" -> return R.id.pspdf__annotation_creation_toolbar_item_circle
            "polygon" -> return R.id.pspdf__annotation_creation_toolbar_item_polygon
            "polyline" -> return R.id.pspdf__annotation_creation_toolbar_item_polyline
            "eraser" -> return R.id.pspdf__annotation_creation_toolbar_item_eraser
            "redaction" -> return R.id.pspdf__annotation_creation_toolbar_item_redaction
            "magicInk" -> return R.id.pspdf__annotation_creation_toolbar_item_magic_ink
            "undoRedo" -> return R.id.pspdf__annotation_creation_toolbar_group_undo_redo
            "undo" -> return R.id.pspdf__annotation_creation_toolbar_item_undo
            "redo" -> return R.id.pspdf__annotation_creation_toolbar_item_redo
            "measurement" -> return R.id.pspdf__annotation_creation_toolbar_group_measurement
            "measurementTool" -> return R.id.pspdf__annotation_creation_toolbar_item_measurement
            "distance" -> return R.id.pspdf__annotation_creation_toolbar_item_measurement_distance
            "perimeter" -> return R.id.pspdf__annotation_creation_toolbar_item_measurement_perimeter
            "areaPolygon" -> return R.id.pspdf__annotation_creation_toolbar_item_measurement_area_polygon
            "areaSquare" -> return R.id.pspdf__annotation_creation_toolbar_item_measurement_area_rect
            "areaCircle" -> return R.id.pspdf__annotation_creation_toolbar_item_measurement_area_ellipse
            "scaleCalibration" -> return R.id.pspdf__annotation_creation_toolbar_item_measurement_scale_calibration
            "cloudy" -> return R.id.pspdf__annotation_creation_toolbar_item_cloudy
            "cloudyCircle" -> return R.id.pspdf__annotation_creation_toolbar_item_cloudy_circle
            "cloudySquare" -> return R.id.pspdf__annotation_creation_toolbar_item_cloudy_square
            "cloudyPolygon" -> return R.id.pspdf__annotation_creation_toolbar_item_cloudy_polygon
            "dashedCircle" -> return R.id.pspdf__annotation_creation_toolbar_item_dashed_circle
            "dashedSquare" -> return R.id.pspdf__annotation_creation_toolbar_item_dashed_square
            "dashedPolygon" -> return R.id.pspdf__annotation_creation_toolbar_item_dashed_polygon
            "sound" -> return R.id.pspdf__annotation_creation_toolbar_item_sound
            "instantCommentMarker" -> return R.id.pspdf__annotation_creation_toolbar_item_instant_comment_marker
            "instantHighlightComment" -> return R.id.pspdf__annotation_creation_toolbar_item_instant_highlight_comment
            "markupTool" -> return R.id.pspdf__annotation_creation_toolbar_group_markup
            "multimediaTool" -> return R.id.pspdf__annotation_creation_toolbar_group_multimedia
            "undoRedoTool" -> return R.id.pspdf__annotation_creation_toolbar_group_undo_redo
            "writingTool" -> return R.id.pspdf__annotation_creation_toolbar_group_writing
            "drawingTool" -> return R.id.pspdf__annotation_creation_toolbar_group_drawing
            "link" -> return R.id.pspdf__link_creator_dialog_edit_text
        }
        Log.i(TAG, String.format("Received unknown menu item %s.", name))
        return INVALID_ID
    }

    override fun getGroupPreset(
        @IntRange(from = ContextualToolbar.MIN_TOOLBAR_CAPACITY.toLong()) capacity: Int,
        itemsCount: Int
    ): List<MenuItem> {
        return items
    }

    override fun areGeneratedGroupItemsSelectable(): Boolean {
        return true
    }

    companion object {
        private const val TAG = "ReactGroupingRule"
        private const val INVALID_ID = -1
    }
}