package com.nutrient.nutrient_flutter_android

import android.os.Bundle
import android.util.Log
import android.view.View
import com.pspdfkit.R
import com.pspdfkit.annotations.configuration.AnnotationConfiguration
import com.pspdfkit.annotations.configuration.AnnotationProperty
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.ui.special_mode.controller.AnnotationTool
import com.pspdfkit.compose.toolbar.adapter.ToolbarSubscription
import com.pspdfkit.compose.toolbar.state.ContextualToolbarKind
import com.pspdfkit.compose.toolbar.state.ContextualToolbarState
import com.pspdfkit.compose.toolbar.state.ToolbarItem
import com.pspdfkit.compose.toolbar.state.ToolbarItemState
import com.pspdfkit.jetpack.compose.toolbar.nutrientToolbarCoordinator
import com.pspdfkit.jetpack.compose.toolbar.setMenuItemGroupingRule
import com.pspdfkit.ui.toolbar.grouping.MenuItemGroupingRule
import java.util.EnumSet

/**
 * [PdfUiFragment] subclass that hosts cross-platform toolbar customization:
 * custom **main-toolbar** items and **annotation-toolbar** (creation / editing)
 * reordering.
 *
 * Custom main-toolbar buttons are published through a toolbar items provider, which the SDK
 * re-runs on every toolbar rebuild, and their taps arrive through an item click listener. The
 * annotation toolbars are contextual; their item layout is set through a [MenuItemGroupingRule]
 * registered on the toolbar coordinator.
 *
 * jnigen cannot subclass Java from Dart, so this lives in Kotlin and is
 * registered from Dart via `PdfUiFragmentBuilder.fragmentClass(...)`. The
 * descriptors and the tap callback are wired by [FragmentContainerPlatformView]
 * once the fragment is attached — Dart never talks to this class directly.
 *
 * Beyond that subclassing blocker, the toolbar work belongs on the native side
 * for two thread reasons that wouldn't be obvious from the call sites:
 * 1. The SDK invokes grouping rules **synchronously on the UI thread** and
 *    consumes the returned `List<MenuItem>` immediately (see
 *    [NutrientMenuGroupingRule]); there's no safe way to block on a Dart
 *    up-call for that result.
 * 2. View/fragment-mutating SDK calls only take effect on the main thread — the
 *    same calls issued from the Dart isolate thread over JNI silently no-op — so
 *    configuring the toolbar and the annotation registry here (already on the
 *    main thread) is the reliable path.
 */
class NutrientPdfUiFragment : PdfUiFragment() {

    /** Grouping rule for the annotation **creation** toolbar (the tool picker). */
    private var annotationCreationGroupingRule: MenuItemGroupingRule? = null

    /** Whether to show the stylus button on the annotation creation toolbar. */
    private var showStylusButton: Boolean = true

    /** Watches the contextual toolbar so the stylus button can be kept hidden. */
    private var contextualToolbarSubscription: ToolbarSubscription? = null

    /**
     * Parsed editing-toolbar items for the selected-annotation toolbar. Captured
     * from `setAnnotationEditingToolbarItems`, but not yet applied: as of 11.3 the
     * editing toolbar is the AnnotationPopupToolbar, customized via
     * setMenuItems(List<PopupToolbarMenuItem>) rather than a MenuItemGroupingRule
     * (follow-up tracked in docs/known-gaps-ledger.md). The editing-property
     * inspector trim in [applyAnnotationConfigurations] still applies.
     */
    @Suppress("unused")
    private var annotationEditingGroupingRule: MenuItemGroupingRule? = null

    /** A configured custom toolbar item. */
    private data class CustomItem(
        val menuId: Int,
        val title: String,
        val disabled: Boolean,
    )

    /** Custom item id → spec, in insertion (toolbar) order. */
    private val customItems = LinkedHashMap<String, CustomItem>()

    // Menu ids are assigned from a monotonic counter rather than from
    // String.hashCode() so two custom ids can never collide (which would
    // silently overwrite an item or misroute a tap). Started high enough to
    // stay clear of any small framework menu ids; the SDK's built-in ids are
    // large R.id resource ints, so there is no overlap from either end.
    private var nextMenuId = 0x00FF_0000

    /**
     * Invoked with the tapped custom item's id. Set by the host platform view;
     * the host marshals the id back to Dart over the per-view method channel.
     */
    var onItemTapped: ((String) -> Unit)? = null

    /**
     * Sets whether to show the stylus button on the annotation creation toolbar.
     */
    fun setShowStylusButton(show: Boolean) {
        showStylusButton = show
        if (view != null) {
            applyStylusButtonVisibility(nutrientToolbarCoordinator().contextualToolbar.value)
        }
    }

    /**
     * Replaces the custom main-toolbar items with [items] (each a map with an
     * `id`, optional `title`, and optional `disabled` flag). Re-callable to add,
     * remove, enable, or disable items dynamically. Duplicate ids are ignored
     * (first one wins) so a collision can't silently clobber an earlier item.
     */
    fun setCustomToolbarItems(items: List<Map<String, Any?>>) {
        customItems.clear()

        for (item in items) {
            val id = item["id"] as? String ?: continue
            if (customItems.containsKey(id)) {
                Log.w(LOG_TAG, "Duplicate custom toolbar item id '$id' ignored")
                continue
            }
            val title = item["title"] as? String ?: id
            val disabled = item["disabled"] as? Boolean ?: false
            customItems[id] = CustomItem(nextMenuId++, title, disabled)
        }

        // Re-run the provider so the new items reach the toolbar.
        if (view != null) {
            invalidateToolbarItems()
        }
    }

    override fun onResume() {
        super.onResume()
        // The SDK rebuilds the toolbar menu across lifecycle transitions; make
        // sure our items survive a return to the foreground.
        if (customItems.isNotEmpty() && view != null) {
            invalidateToolbarItems()
        }
    }

    /**
     * Publishes the custom items to the main toolbar and routes their taps.
     *
     * The View menu hooks this used to rely on (`onGenerateMenuItemIds` plus per-item
     * `MenuItem.setOnMenuItemClickListener`) are gone with the Compose toolbars. Items are now
     * declared through a provider that runs on every rebuild, so they survive lifecycle
     * transitions without the previous re-application dance, and taps arrive by item id.
     *
     * The listener is installed once and reads [customItems] on each tap, so replacing the items
     * never leaves a stale mapping behind.
     */
    private fun installCustomToolbarItems() {
        setToolbarItemsProvider { defaultItems ->
            defaultItems + customItems.map { (id, spec) ->
                ToolbarItem.Button(
                    actionId = "$CUSTOM_ACTION_PREFIX$id",
                    id = spec.menuId,
                    contentDescription = spec.title,
                    state = ToolbarItemState(isEnabled = !spec.disabled),
                    overflowBehavior = ToolbarItem.OverflowBehavior.AlwaysShow,
                )
            }
        }
        setOnToolbarItemClickListener { itemId ->
            // Returning false leaves every id we did not add to the SDK's own handling.
            val item = customItems.entries.firstOrNull { it.value.menuId == itemId }
            if (item == null) {
                false
            } else {
                onItemTapped?.invoke(item.key)
                true
            }
        }
    }

    // -------------------------------------------------------------------------
    // Annotation toolbar customization (creation tool picker + editing bar)
    // -------------------------------------------------------------------------

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        applyAnnotationCreationGroupingRule()
        installCustomToolbarItems()
        // The SDK inserts the stylus toggle into the annotation bar after grouping, so it can
        // only be taken out once that bar is actually shown.
        contextualToolbarSubscription = nutrientToolbarCoordinator()
            .addContextualToolbarChangeListener(::applyStylusButtonVisibility)
    }

    override fun onDestroyView() {
        contextualToolbarSubscription?.close()
        contextualToolbarSubscription = null
        super.onDestroyView()
    }

    /**
     * Sets the annotation **creation** toolbar items (the tool picker). [items]
     * mirrors the cross-platform `setAnnotationToolbarItems`: each entry is a
     * tool-name [String] or a `{representative, items}` group [Map]. Pass an
     * empty list to restore the SDK default.
     */
    fun setAnnotationToolbarItems(items: List<Any?>) {
        annotationCreationGroupingRule =
            if (items.isEmpty()) null else NutrientMenuGroupingRule(requireContext(), items)
        applyAnnotationCreationGroupingRule()
    }

    /** Style properties to keep in the inspector, or null for the SDK default. */
    private var editingSupportedProperties: EnumSet<AnnotationProperty>? = null

    /**
     * Sets the annotation **editing** toolbar items (shown when an annotation is
     * selected). [items] is a list of editing-item name [String]s. Pass an empty
     * list to restore the SDK default.
     *
     * Two levers are applied: the grouping rule controls which toolbar **buttons**
     * appear (style picker / note / delete), and per-tool supported-properties
     * trim the **inspector rows** behind the picker to the listed style controls
     * — so listing `[color, opacity]` shows exactly color + opacity (matching Web
     * and iOS), not just the picker button.
     */
    fun setAnnotationEditingToolbarItems(items: List<Any?>) {
        annotationEditingGroupingRule =
            if (items.isEmpty()) null
            else NutrientEditingMenuGroupingRule(requireContext(), items)
        editingSupportedProperties = supportedPropertiesFor(items)
        applyAnnotationConfigurations()
        invalidateOptionsMenuIfReady()
    }

    /** Maps the editing item names to the inspector's [AnnotationProperty] set. */
    private fun supportedPropertiesFor(items: List<Any?>): EnumSet<AnnotationProperty>? {
        val props = items.mapNotNull { (it as? String)?.let(::propertyForEditingItem) }
        return if (props.isEmpty()) null else EnumSet.copyOf(props)
    }

    private fun propertyForEditingItem(name: String): AnnotationProperty? = when (name) {
        "color" -> AnnotationProperty.COLOR
        "fillColor" -> AnnotationProperty.FILL_COLOR
        "outlineColor" -> AnnotationProperty.OUTLINE_COLOR
        "opacity" -> AnnotationProperty.ANNOTATION_ALPHA
        "thickness" -> AnnotationProperty.THICKNESS
        "font" -> AnnotationProperty.FONT
        "borderStyle" -> AnnotationProperty.BORDER_STYLE
        "lineEnds" -> AnnotationProperty.LINE_ENDS
        "note" -> AnnotationProperty.ANNOTATION_NOTE
        // blendMode / delete have no AnnotationProperty (delete is an action).
        else -> null
    }

    /**
     * Applies [editingSupportedProperties] to the common annotation tools'
     * configurations so the style inspector only shows the listed controls.
     * Needs the document loaded (the registry comes from the inner PdfFragment),
     * so it's also re-run from [onDocumentLoaded].
     *
     * Unlike the grouping rules, this is plain SDK method calls and could in
     * principle run from Dart via jnigen — it stays here only because it needs
     * the inner PdfFragment's registry handle on the main thread, which this
     * fragment already holds; co-locating avoids round-tripping the handle.
     */
    private fun applyAnnotationConfigurations() {
        val props = editingSupportedProperties ?: return
        val ctx = context ?: return
        val registry = pdfFragment?.annotationConfiguration ?: return
        for (tool in EDITABLE_TOOLS) {
            try {
                val config = AnnotationConfiguration.builder(ctx, tool)
                    .setSupportedProperties(props)
                    .build()
                registry.put(tool, config)
            } catch (t: Throwable) {
                // A tool that doesn't accept the property set is skipped, not fatal.
                Log.w(LOG_TAG, "Could not configure $tool: ${t.message}")
            }
        }
    }

    override fun onDocumentLoaded(document: PdfDocument) {
        super.onDocumentLoaded(document)
        // The annotation-configuration registry is only available once a document
        // is loaded; (re)apply any editing-property trim now.
        applyAnnotationConfigurations()
    }

    private fun invalidateOptionsMenuIfReady() {
        if (view != null) invalidateToolbarItems()
    }

    /**
     * Registers the creation toolbar's grouping rule with the toolbar coordinator, which is the
     * Compose replacement for setting it on the View `AnnotationToolbar`.
     *
     * Annotation-editing customization lives on the `AnnotationPopupToolbar`, customized via
     * setMenuItems(List<PopupToolbarMenuItem>) rather than a grouping rule, so
     * [annotationEditingGroupingRule] has nothing to register here. Wiring the editing item
     * list onto the popup toolbar is tracked as a follow-up (see docs/known-gaps-ledger.md);
     * the editing-property inspector trim in [applyAnnotationConfigurations] is unaffected.
     */
    private fun applyAnnotationCreationGroupingRule() {
        if (view == null) return
        nutrientToolbarCoordinator().setMenuItemGroupingRule(
            requireContext(),
            ContextualToolbarKind.Annotation,
            annotationCreationGroupingRule,
        )
    }

    /**
     * Drops the stylus toggle from the annotation bar when the integrator turned it off. The
     * toggle is added by the SDK after grouping, so a grouping rule cannot exclude it; removing
     * it from the shown bar's items is the equivalent of the View
     * `AnnotationToolbar.setShouldShowStylusButton(false)`.
     *
     * Removing the item notifies this listener again, and the guard below makes that pass a
     * no-op rather than a loop.
     */
    private fun applyStylusButtonVisibility(state: ContextualToolbarState?) {
        if (showStylusButton || state?.kind != ContextualToolbarKind.Annotation) return
        if (state.items.none { it.id == R.id.pspdf__annotation_toolbar_item_stylus }) return
        nutrientToolbarCoordinator().updateContextualItems { items ->
            items.removeAll { it.id == R.id.pspdf__annotation_toolbar_item_stylus }
        }
    }

    private companion object {
        private const val LOG_TAG = "NutrientPdfUiFragment"

        /** Prefix for the action ids of custom items, so they cannot collide with the SDK's. */
        private const val CUSTOM_ACTION_PREFIX = "nutrient_flutter_custom_"

        // Common annotation tools the editing-property trim is applied to.
        private val EDITABLE_TOOLS = listOf(
            AnnotationTool.INK,
            AnnotationTool.FREETEXT,
            AnnotationTool.FREETEXT_CALLOUT,
            AnnotationTool.LINE,
            AnnotationTool.SQUARE,
            AnnotationTool.CIRCLE,
            AnnotationTool.POLYGON,
            AnnotationTool.POLYLINE,
            AnnotationTool.HIGHLIGHT,
            AnnotationTool.UNDERLINE,
            AnnotationTool.STRIKEOUT,
            AnnotationTool.SQUIGGLY,
            AnnotationTool.STAMP,
            AnnotationTool.NOTE,
            AnnotationTool.SIGNATURE,
        )
    }
}
