/*
 * PdfViewModeController.java
 *
 *   PSPDFKit
 *
 *   Copyright © 2021-2023 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */
package com.pspdfkit.flutter.pspdfkit.toolbar

import com.pspdfkit.flutter.pspdfkit.PSPDFKitView
import com.pspdfkit.ui.forms.FormEditingBar
import com.pspdfkit.ui.forms.FormEditingBar.OnFormEditingBarLifecycleListener
import com.pspdfkit.ui.special_mode.controller.TextSelectionController
import com.pspdfkit.ui.special_mode.manager.TextSelectionManager.OnTextSelectionModeChangeListener
import com.pspdfkit.ui.toolbar.AnnotationCreationToolbar
import com.pspdfkit.ui.toolbar.AnnotationEditingToolbar
import com.pspdfkit.ui.toolbar.ContextualToolbar
import com.pspdfkit.ui.toolbar.ToolbarCoordinatorLayout.OnContextualToolbarLifecycleListener
import com.pspdfkit.ui.toolbar.grouping.MenuItemGroupingRule

/**
 * Keeps track of the currently active mode and handles updating the toolbar states.
 */
internal class FlutterViewModeController(private val itemGroupingRule: MenuItemGroupingRule?) :
    OnContextualToolbarLifecycleListener {

    override fun onPrepareContextualToolbar(contextualToolbar: ContextualToolbar<*>) {
        if (contextualToolbar is AnnotationCreationToolbar) {
            if (itemGroupingRule != null) {
                contextualToolbar.setMenuItemGroupingRule(itemGroupingRule)
            }
        }
    }

    override fun onDisplayContextualToolbar(contextualToolbar: ContextualToolbar<*>) {

    }

    override fun onRemoveContextualToolbar(contextualToolbar: ContextualToolbar<*>) {
    }
}