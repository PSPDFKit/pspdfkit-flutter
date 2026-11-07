/*
 * Copyright © 2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit.toolbar

import androidx.activity.ComponentActivity
import com.pspdfkit.R
import com.pspdfkit.compose.toolbar.adapter.ToolbarCoordinator
import com.pspdfkit.compose.toolbar.adapter.ToolbarSubscription
import com.pspdfkit.compose.toolbar.state.ContextualToolbarKind
import com.pspdfkit.compose.toolbar.state.ContextualToolbarState
import com.pspdfkit.jetpack.compose.toolbar.nutrientToolbarCoordinator

/**
 * Hides the stylus toggle on the annotation toolbar, the Compose equivalent of the View
 * `AnnotationToolbar.setShouldShowStylusButton(false)`.
 *
 * The SDK adds the toggle after grouping, so no grouping rule can exclude it. It can only be
 * removed from the bar once the bar is shown, so this watches the contextual toolbar and drops the
 * item each time an annotation bar appears. Removing it notifies the listener again, and the guard
 * in [removeFrom] makes that pass a no-op rather than a loop.
 */
object StylusButtonVisibility {

    /**
     * Keeps the stylus toggle off every annotation toolbar [activity] shows, until the returned
     * subscription is closed.
     */
    @JvmStatic
    fun hideIn(activity: ComponentActivity): ToolbarSubscription =
        hideIn(activity.nutrientToolbarCoordinator())

    /**
     * Keeps the stylus toggle off every annotation toolbar [coordinator] shows, until the returned
     * subscription is closed.
     */
    @JvmStatic
    fun hideIn(coordinator: ToolbarCoordinator): ToolbarSubscription =
        coordinator.addContextualToolbarChangeListener { state -> removeFrom(coordinator, state) }

    /** Drops the stylus toggle from [state] if it is an annotation toolbar that still has it. */
    @JvmStatic
    fun removeFrom(coordinator: ToolbarCoordinator, state: ContextualToolbarState?) {
        if (state?.kind != ContextualToolbarKind.Annotation) return
        if (state.items.none { it.id == R.id.pspdf__annotation_toolbar_item_stylus }) return
        coordinator.updateContextualItems { items ->
            items.removeAll { it.id == R.id.pspdf__annotation_toolbar_item_stylus }
        }
    }
}
