/*
 * Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
 *
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit.ai

import io.nutrient.domain.ai.AiAssistant

/**
 * Process-wide registry that lets the AI Assistant flow on either the
 * embedded `PSPDFKitView` (standalone PDFs) or the `NutrientInstantView`
 * (Instant documents) hand a built [AiAssistant] to the host activity.
 *
 * The Nutrient Android SDK resolves the assistant by casting the host
 * activity to `AiAssistantProvider` and calling its `getAiAssistant()`
 * (see `PdfFragment.onCreate`). In the Flutter plugin that activity is
 * `FlutterAppCompatActivity`, which delegates to [getActive].
 *
 * The registry tracks one entry per Flutter platform view id, so multiple
 * views in the same process don't fight for a single slot. The "active"
 * assistant is whichever view called [setActive] most recently (typically
 * driven by each view's onResume / onPause hooks). Until a view sets itself
 * active, [register] also bumps the pointer so the common single-view case
 * still works without extra wiring.
 */
object FlutterAiAssistantRegistry {
    private val entries = mutableMapOf<Int, AiAssistant>()
    private var activeViewId: Int? = null

    @JvmStatic
    @Synchronized
    fun register(viewId: Int, assistant: AiAssistant) {
        val previous = entries.put(viewId, assistant)
        // Avoid leaking sockets when a view re-registers (e.g. after a remount).
        if (previous != null && previous !== assistant) {
            try {
                previous.terminate()
            } catch (_: Throwable) {
                // Best-effort cleanup; don't let a buggy terminate() poison
                // the new registration.
            }
        }
        // Treat registration as "this view became active" only when there is
        // no currently-active view. Subsequent registrations on a different
        // view (e.g. a background AI Assistant being built while another
        // foreground view is showing) must not steal the active slot — see
        // PR #53248 review comment on multi-view dispatch.
        if (activeViewId == null) {
            activeViewId = viewId
        }
    }

    @JvmStatic
    @Synchronized
    fun unregister(viewId: Int) {
        val removed = entries.remove(viewId)
        if (removed != null) {
            try {
                removed.terminate()
            } catch (_: Throwable) {
                // Same as above.
            }
        }
        if (activeViewId == viewId) {
            activeViewId = entries.keys.lastOrNull()
        }
    }

    /**
     * Marks [viewId] as the foreground view. Call from each view's
     * `onResume` so `getAiAssistant()` returns the assistant tied to the
     * fragment that opened the AI dialog. A null clears the pointer (call
     * from `onPause` when there's no successor active yet).
     */
    @JvmStatic
    @Synchronized
    fun setActive(viewId: Int?) {
        activeViewId = viewId
    }

    @JvmStatic
    @Synchronized
    fun getActive(): AiAssistant? = activeViewId?.let { entries[it] }

    @JvmStatic
    @Synchronized
    fun get(viewId: Int): AiAssistant? = entries[viewId]

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
