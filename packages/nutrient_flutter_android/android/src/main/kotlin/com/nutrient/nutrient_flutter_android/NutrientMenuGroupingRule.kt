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
 * A [PresetMenuItemGroupingRule] for the annotation **creation** toolbar driven
 * by the cross-platform `setAnnotationToolbarItems` call.
 *
 * Each entry in [items] is either:
 * - a [String] — the [AnnotationTool] enum name of a single tool, or
 * - a [Map] — `{ "representative": name, "items": [name, …] }` for a group.
 *
 * Tool names are the Dart `AnnotationTool` enum identifiers (e.g. `inkPen`,
 * `highlight`, `square`); [idForToolName] maps them to the SDK's
 * `pspdf__annotation_toolbar_item_*` resource ids. Unknown names are
 * skipped. The color picker + undo/redo are always appended, matching the iOS
 * toolbar (which always shows them) and so the toolbar stays usable.
 *
 * Ported from the legacy `FlutterMenuGroupingRule`. jnigen can't subclass the
 * abstract `PresetMenuItemGroupingRule` from Dart, so this lives in Kotlin and
 * is constructed by [NutrientPdfUiFragment]. It would have to be native even if
 * it could be subclassed: the SDK invokes the rule **synchronously on the UI
 * thread** and consumes the returned item list immediately, so there's no safe
 * way to block on a Dart up-call for that result.
 */
class NutrientMenuGroupingRule(
    context: Context,
    items: List<Any?>,
) : PresetMenuItemGroupingRule(context) {

    private val menuItems: MutableList<MenuItem> = ArrayList()

    init {
        for (entry in items) {
            when (entry) {
                is String -> {
                    val id = idForToolName(entry)
                    if (id != INVALID_ID) menuItems.add(MenuItem(id))
                }
                is Map<*, *> -> {
                    val representative = entry["representative"] as? String
                    @Suppress("UNCHECKED_CAST")
                    val subNames = entry["items"] as? List<String> ?: emptyList()
                    val subIds = subNames
                        .map { idForToolName(it) }
                        .filter { it != INVALID_ID }
                        .toIntArray()
                    // The group's anchor must be a dedicated *category* id, NOT a
                    // tool id — anchoring on a tool that's also a sub-item makes
                    // the SDK's style-indicator setup recurse infinitely. Derive
                    // the category from the representative tool; if there's no
                    // category, fall back to listing the tools flat.
                    val categoryId =
                        representative?.let { categoryIdForToolName(it) } ?: INVALID_ID
                    if (categoryId != INVALID_ID && subIds.isNotEmpty()) {
                        menuItems.add(MenuItem(categoryId, subIds))
                    } else {
                        subIds.forEach { menuItems.add(MenuItem(it)) }
                    }
                }
            }
        }

        // Always keep the color picker + undo/redo so the toolbar stays usable
        // (mirrors iOS, which always includes them).
        menuItems.add(MenuItem(R.id.pspdf__annotation_toolbar_item_picker))
        menuItems.add(MenuItem(R.id.pspdf__annotation_toolbar_item_undo))
        menuItems.add(MenuItem(R.id.pspdf__annotation_toolbar_item_redo))
    }

    override fun getGroupPreset(
        @IntRange(from = ContextualToolbar.MIN_TOOLBAR_CAPACITY.toLong()) capacity: Int,
        itemsCount: Int,
    ): List<MenuItem> = menuItems

    override fun areGeneratedGroupItemsSelectable(): Boolean = true

    @IdRes
    private fun idForToolName(name: String): Int = when (name) {
        // Ink
        "inkPen" -> R.id.pspdf__annotation_toolbar_item_ink_pen
        "inkMagic" -> R.id.pspdf__annotation_toolbar_item_magic_ink
        "inkHighlighter" -> R.id.pspdf__annotation_toolbar_item_ink_highlighter
        // Text markup
        "highlight" -> R.id.pspdf__annotation_toolbar_item_highlight
        "underline" -> R.id.pspdf__annotation_toolbar_item_underline
        "squiggly" -> R.id.pspdf__annotation_toolbar_item_squiggly
        "strikeOut" -> R.id.pspdf__annotation_toolbar_item_strikeout
        // Free text
        "freeText" -> R.id.pspdf__annotation_toolbar_item_freetext
        "freeTextCallOut" -> R.id.pspdf__annotation_toolbar_item_freetext_callout
        // Shapes / lines
        "line" -> R.id.pspdf__annotation_toolbar_item_line
        "arrow" -> R.id.pspdf__annotation_toolbar_item_line_arrow
        "square" -> R.id.pspdf__annotation_toolbar_item_square
        "circle" -> R.id.pspdf__annotation_toolbar_item_circle
        "polygon" -> R.id.pspdf__annotation_toolbar_item_polygon
        "polyline" -> R.id.pspdf__annotation_toolbar_item_polyline
        "cloudy" -> R.id.pspdf__annotation_toolbar_item_cloudy
        // Media / misc
        "stamp", "stampImage" -> R.id.pspdf__annotation_toolbar_item_stamp
        "image" -> R.id.pspdf__annotation_toolbar_item_image
        "signature" -> R.id.pspdf__annotation_toolbar_item_signature
        "note" -> R.id.pspdf__annotation_toolbar_item_note
        "sound" -> R.id.pspdf__annotation_toolbar_item_sound
        "eraser" -> R.id.pspdf__annotation_toolbar_item_eraser
        "redaction" -> R.id.pspdf__annotation_toolbar_item_redaction
        // Measurement
        "measurementDistance" -> R.id.pspdf__annotation_toolbar_item_measurement_distance
        "measurementPerimeter" -> R.id.pspdf__annotation_toolbar_item_measurement_perimeter
        "measurementAreaPolygon" -> R.id.pspdf__annotation_toolbar_item_measurement_area_polygon
        "measurementAreaRect" -> R.id.pspdf__annotation_toolbar_item_measurement_area_rect
        "measurementAreaEllipse" -> R.id.pspdf__annotation_toolbar_item_measurement_area_ellipse
        else -> {
            Log.i(LOG_TAG, "Unknown annotation tool '$name' ignored")
            INVALID_ID
        }
    }

    /**
     * Maps a tool name to the SDK's annotation-creation **group/category** id —
     * used as a collapsible group's anchor (a tool id can't anchor a group; see
     * the comment in [init]). Returns [INVALID_ID] when the tool has no category.
     */
    @IdRes
    private fun categoryIdForToolName(name: String): Int = when (name) {
        "highlight", "underline", "squiggly", "strikeOut" ->
            R.id.pspdf__annotation_toolbar_group_markup
        "inkPen", "inkHighlighter", "inkMagic", "freeText", "freeTextCallOut",
        "signature", "note" ->
            R.id.pspdf__annotation_toolbar_group_writing
        "line", "arrow", "square", "circle", "polygon", "polyline", "cloudy",
        "eraser" ->
            R.id.pspdf__annotation_toolbar_group_drawing
        "stamp", "stampImage", "image", "sound" ->
            R.id.pspdf__annotation_toolbar_group_multimedia
        "measurementDistance", "measurementPerimeter", "measurementAreaPolygon",
        "measurementAreaRect", "measurementAreaEllipse" ->
            R.id.pspdf__annotation_toolbar_group_measurement
        else -> INVALID_ID
    }

    private companion object {
        private const val LOG_TAG = "NutrientMenuGroupingRule"
        private const val INVALID_ID = -1
    }
}
