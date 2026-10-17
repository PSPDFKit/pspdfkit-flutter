/*
 *   Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */

package com.nutrient.nutrient_flutter_android

import io.nutrient.domain.ai.AiAssistant

/**
 * Module-local registry for AI Assistants created by the bindings module.
 *
 * This registry is the bindings-module counterpart to the legacy plugin's
 * `FlutterAiAssistantRegistry`. It exists so that bindings-only apps (e.g.
 * the catalog, which does not ship `nutrient_flutter`) can still wire up
 * `AiAssistantProvider` through [NutrientFlutterActivity] without any
 * dependency on the legacy module.
 *
 * Concurrency: all mutating methods are `@Synchronized` so the executor
 * thread that builds assistants (both Instant and standalone) can write
 * safely while the main thread reads from `getAiAssistant()`.
 */
internal object BindingsAiAssistantRegistry {

    private val entries = mutableMapOf<Int, AiAssistant>()
    private var activeViewId: Int? = null

    /**
     * Registers [assistant] for [viewId], terminating any prior assistant
     * for that view. Sets [viewId] as the active view if no view is
     * currently active (common single-view case).
     */
    @JvmStatic
    @Synchronized
    fun register(viewId: Int, assistant: AiAssistant) {
        val previous = entries.put(viewId, assistant)
        if (previous != null && previous !== assistant) {
            try {
                previous.terminate()
            } catch (_: Throwable) {
                // Best-effort cleanup.
            }
        }
        if (activeViewId == null) {
            activeViewId = viewId
        }
    }

    /**
     * Removes and terminates the assistant for [viewId]. If that view was
     * the active view, falls back to the last remaining entry.
     */
    @JvmStatic
    @Synchronized
    fun unregister(viewId: Int) {
        val removed = entries.remove(viewId)
        if (removed != null) {
            try {
                removed.terminate()
            } catch (_: Throwable) {
            }
        }
        if (activeViewId == viewId) {
            activeViewId = entries.keys.lastOrNull()
        }
    }

    /**
     * Sets [viewId] as the foreground view. Pass `null` to clear the
     * active pointer (call from `onPause` when no successor is active yet).
     */
    @JvmStatic
    @Synchronized
    fun setActive(viewId: Int?) {
        activeViewId = viewId
    }

    /** Returns the assistant tied to the currently-active view, or null. */
    @JvmStatic
    @Synchronized
    fun getActiveAssistant(): AiAssistant? = activeViewId?.let { entries[it] }

    /** Returns the assistant for [viewId], or null. */
    @JvmStatic
    @Synchronized
    fun getAssistant(viewId: Int): AiAssistant? = entries[viewId]

    /**
     * Returns the view ID that is currently marked as active, or null.
     * Used by [NutrientFlutterActivity.resolveActivePdfFragment] to find the
     * correct [FragmentContainerPlatformView] for citation navigation.
     */
    @JvmStatic
    @Synchronized
    fun findActiveViewId(): Int? = activeViewId

    @JvmStatic
    @Synchronized
    fun clear() {
        entries.values.forEach {
            try {
                it.terminate()
            } catch (_: Throwable) {
            }
        }
        entries.clear()
        activeViewId = null
    }
}
