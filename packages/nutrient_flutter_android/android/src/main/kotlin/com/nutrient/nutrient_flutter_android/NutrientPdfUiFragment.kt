package com.nutrient.nutrient_flutter_android

import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import androidx.appcompat.widget.Toolbar
import com.pspdfkit.R
import com.pspdfkit.annotations.configuration.AnnotationConfiguration
import com.pspdfkit.annotations.configuration.AnnotationProperty
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.ui.special_mode.controller.AnnotationTool
import com.pspdfkit.ui.toolbar.AnnotationToolbar
import com.pspdfkit.ui.toolbar.ContextualToolbar
import com.pspdfkit.ui.toolbar.ToolbarCoordinatorLayout
import com.pspdfkit.ui.toolbar.grouping.MenuItemGroupingRule
import java.util.EnumSet

/**
 * [PdfUiFragment] subclass that hosts cross-platform toolbar customization:
 * custom **main-toolbar** items and **annotation-toolbar** (creation / editing)
 * reordering.
 *
 * The embedded [PdfUiFragment] owns its own `pspdf__toolbar_main` and rebuilds
 * its menu on its own schedule, so the only reliable way to inject a custom
 * button is to override [onGenerateMenuItemIds] (to keep the id in the menu
 * across rebuilds) and configure the item directly on the toolbar afterwards.
 * The annotation toolbars are contextual; their item layout is set through a
 * [MenuItemGroupingRule] applied in [onPrepareContextualToolbar].
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
class NutrientPdfUiFragment :
    PdfUiFragment(),
    ToolbarCoordinatorLayout.OnContextualToolbarLifecycleListener {

    /** Grouping rule for the annotation **creation** toolbar (the tool picker). */
    private var annotationCreationGroupingRule: MenuItemGroupingRule? = null

    /** Whether to show the stylus button on the annotation creation toolbar. */
    private var showStylusButton: Boolean = true

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

        // Rebuild the menu so onGenerateMenuItemIds runs with the new ids.
        if (view != null) {
            invalidateMenu()
        }
    }

    override fun onResume() {
        super.onResume()
        // The SDK rebuilds the toolbar menu across lifecycle transitions; make
        // sure our items survive a return to the foreground.
        if (customItems.isNotEmpty() && view != null) {
            invalidateMenu()
        }
    }

    /**
     * v11 menu hook: keeps our custom item ids in the toolbar menu across
     * rebuilds, then schedules the per-item configuration once the menu exists.
     */
    override fun onGenerateMenuItemIds(menuItems: MutableList<Int>): List<Int> {
        for (item in customItems.values) {
            if (!menuItems.contains(item.menuId)) {
                menuItems.add(item.menuId)
            }
        }

        if (customItems.isNotEmpty()) {
            view?.post { configureCustomMenuItems() }
        }

        return menuItems
    }

    /**
     * Configures the custom items directly on the main toolbar's menu after the
     * SDK has built it from [onGenerateMenuItemIds].
     *
     * Taps are routed via a **per-item** [MenuItem.setOnMenuItemClickListener] —
     * deliberately *not* the toolbar-wide `Toolbar.setOnMenuItemClickListener`,
     * which the SDK installs for the built-in items (search, outline, share, …);
     * replacing it would silently drop those clicks. A per-item listener only
     * fires for our button and leaves the SDK's handling of every other item
     * untouched.
     */
    private fun configureCustomMenuItems() {
        val toolbar = view?.findViewById<Toolbar>(R.id.pspdf__toolbar_main) ?: return
        val menu = toolbar.menu ?: return

        for ((id, spec) in customItems) {
            val menuItem: MenuItem =
                menu.findItem(spec.menuId)
                    ?: menu.add(Menu.NONE, spec.menuId, Menu.NONE, spec.title)
            menuItem.title = spec.title
            menuItem.isEnabled = !spec.disabled
            menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
            menuItem.setOnMenuItemClickListener {
                onItemTapped?.invoke(id)
                true
            }
        }

        Log.d(LOG_TAG, "Configured ${customItems.size} custom toolbar item(s)")
    }

    // -------------------------------------------------------------------------
    // Annotation toolbar customization (creation tool picker + editing bar)
    // -------------------------------------------------------------------------

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        // Drive the annotation toolbars' layout via onPrepareContextualToolbar.
        setOnContextualToolbarLifecycleListener(this)
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
        // Re-prepare the toolbar if it's currently visible.
        invalidateOptionsMenuIfReady()
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
        if (view != null) invalidateMenu()
    }

    override fun onPrepareContextualToolbar(toolbar: ContextualToolbar<*>) {
        // Nutrient Android 11.3 merged the annotation creation + editing contextual
        // toolbars into a single AnnotationToolbar. The creation grouping rule still
        // drives its tool layout here.
        //
        // Annotation-editing customization moved to the AnnotationPopupToolbar,
        // which is customized via setMenuItems(List<PopupToolbarMenuItem>) rather
        // than a MenuItemGroupingRule, so [annotationEditingGroupingRule] can no
        // longer be applied to a contextual toolbar. Wiring the editing item list
        // onto the popup toolbar is tracked as a follow-up (see
        // docs/known-gaps-ledger.md); the editing-property inspector trim applied
        // in [applyAnnotationConfigurations] is unaffected and still works.
        if (toolbar is AnnotationToolbar) {
            annotationCreationGroupingRule?.let { toolbar.setMenuItemGroupingRule(it) }
            toolbar.setShouldShowStylusButton(showStylusButton)
        }
    }

    override fun onDisplayContextualToolbar(toolbar: ContextualToolbar<*>) {
        // No-op — layout is applied in onPrepareContextualToolbar.
    }

    override fun onRemoveContextualToolbar(toolbar: ContextualToolbar<*>) {
        // No-op.
    }

    private companion object {
        private const val LOG_TAG = "NutrientPdfUiFragment"

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
