package com.nutrient.nutrient_flutter_android

import android.content.Context
import android.util.Log
import androidx.annotation.IdRes
import androidx.annotation.IntRange
import com.pspdfkit.R
import com.pspdfkit.ui.toolbar.ContextualToolbar
import com.pspdfkit.ui.toolbar.grouping.presets.MenuItem
import com.pspdfkit.ui.toolbar.grouping.presets.PresetMenuItemGroupingRule

/**
 * A [PresetMenuItemGroupingRule] for the annotation **editing** toolbar (shown
 * when an annotation is selected), driven by the cross-platform
 * `setAnnotationEditingToolbarItems` call.
 *
 * Each entry in [items] is an [AnnotationEditingItem] enum name. The style
 * properties (`color`, `opacity`, `thickness`, …) all live behind the single
 * style **picker** button, so they collapse to one picker entry (which opens the
 * inspector); the `note` and `delete` actions map to their toolbar buttons.
 * Unknown names are skipped.
 */
class NutrientEditingMenuGroupingRule(
    context: Context,
    items: List<Any?>,
) : PresetMenuItemGroupingRule(context) {

    private val menuItems: MutableList<MenuItem> = ArrayList()

    init {
        // Dedupe the picker — many style props map to the same picker button.
        val seen = LinkedHashSet<Int>()
        for (entry in items) {
            val id = (entry as? String)?.let { idForEditingItem(it) } ?: INVALID_ID
            if (id != INVALID_ID && seen.add(id)) {
                menuItems.add(MenuItem(id))
            }
        }
    }

    override fun getGroupPreset(
        @IntRange(from = ContextualToolbar.MIN_TOOLBAR_CAPACITY.toLong()) capacity: Int,
        itemsCount: Int,
    ): List<MenuItem> = menuItems

    override fun areGeneratedGroupItemsSelectable(): Boolean = true

    @IdRes
    private fun idForEditingItem(name: String): Int = when (name) {
        // Style properties all open via the picker (their availability inside the
        // picker is controlled separately by supported-properties config).
        "color", "fillColor", "outlineColor", "opacity", "thickness",
        "blendMode", "font", "borderStyle", "lineEnds" ->
            R.id.pspdf__annotation_popup_toolbar_item_picker
        "note" -> R.id.pspdf__annotation_popup_toolbar_item_annotation_note
        "delete" -> R.id.pspdf__annotation_popup_toolbar_item_delete
        else -> {
            Log.i(LOG_TAG, "Unknown annotation editing item '$name' ignored")
            INVALID_ID
        }
    }

    private companion object {
        private const val LOG_TAG = "NutrientEditingMenuGroupingRule"
        private const val INVALID_ID = -1
    }
}
