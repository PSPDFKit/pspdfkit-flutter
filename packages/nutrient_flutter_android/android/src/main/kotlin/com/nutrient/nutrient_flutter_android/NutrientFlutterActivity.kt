/*
 *   Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */

package com.nutrient.nutrient_flutter_android

import android.graphics.RectF
import android.util.Log
import io.flutter.embedding.android.FlutterAppCompatActivity
import io.nutrient.domain.ai.AiAssistant
import io.nutrient.domain.ai.AiAssistantProvider

/**
 * Ready-made host-activity base class for bindings-only Flutter applications
 * that need AI Assistant support (i.e. apps that use [NutrientDocumentView]
 * directly without the legacy `nutrient_flutter` plugin).
 *
 * Usage
 * -----
 * In your catalog / app Android module create a thin subclass:
 *
 * ```kotlin
 * class MainActivity : NutrientFlutterActivity()
 * ```
 *
 * Then point your `AndroidManifest.xml` at it:
 *
 * ```xml
 * <activity android:name=".MainActivity" ... />
 * ```
 *
 * What this provides
 * ------------------
 * The Nutrient Android SDK's `showAiAssistant` helper (and the internal
 * `AiAssistantDialog`) resolves the assistant by casting the host activity to
 * [AiAssistantProvider] (see `AiAssistantHelpers.kt:44-49`). This class
 * implements that interface and delegates to [BindingsAiAssistantRegistry],
 * which is populated by [FragmentContainerPlatformView] whenever Dart invokes
 * either `setupInstantAiAssistant` or `setupStandaloneAiAssistant` on the
 * per-view method channel.
 *
 * Citation navigation
 * -------------------
 * [navigateTo] is the callback the SDK fires when the user taps a citation in
 * the AI chat panel. It looks up the currently-active [PdfFragment] via
 * [FragmentContainerPlatformView.getPdfFragment] and calls [PdfFragment.setPageIndex]
 * on the main thread so the viewer scrolls to the cited page.
 */
open class NutrientFlutterActivity : FlutterAppCompatActivity(), AiAssistantProvider {

    // -------------------------------------------------------------------------
    // AiAssistantProvider
    // -------------------------------------------------------------------------

    override fun getAiAssistant(): AiAssistant? {
        return BindingsAiAssistantRegistry.getActiveAssistant()
    }

    override fun navigateTo(documentRect: List<RectF>, pageIndex: Int, documentIndex: Int) {
        // Bail out if no assistant is registered — a citation tap can race a
        // view teardown.
        if (BindingsAiAssistantRegistry.getActiveAssistant() == null) {
            Log.w(LOG_TAG, "navigateTo: no active AI assistant")
            return
        }

        // Retrieve the PdfFragment of the view that registered the active
        // assistant (resolveActivePdfFragment matches it via the registry's
        // active viewId; the common single-view case has exactly one entry).
        val fragment = resolveActivePdfFragment()
        if (fragment == null) {
            Log.w(LOG_TAG, "navigateTo: no active PdfFragment")
            return
        }

        // setPageIndex must run on the main thread. This callback arrives on
        // the main thread (it comes from a dialog interaction), but guard anyway.
        runOnUiThread {
            try {
                fragment.setPageIndex(pageIndex, true)
            } catch (e: Exception) {
                Log.e(LOG_TAG, "navigateTo: error setting page index", e)
            }
        }
    }

    // -------------------------------------------------------------------------
    // Internal helpers
    // -------------------------------------------------------------------------

    /**
     * Finds the [com.pspdfkit.ui.PdfFragment] that is currently active.
     *
     * Strategy: iterate [FragmentContainerPlatformView.instances] (the
     * companion object's static map) using [FragmentContainerPlatformView.getPdfFragment].
     * The active assistant in [BindingsAiAssistantRegistry] tells us which viewId
     * to use. If the registry doesn't know a viewId (legacy path), fall back to
     * the last registered fragment.
     *
     * This method is intentionally package-private (internal) — host apps
     * should not need to call it directly.
     */
    internal fun resolveActivePdfFragment(): com.pspdfkit.ui.PdfFragment? {
        // Try to find the fragment for the active view by matching the active
        // assistant. We expose a helper on BindingsAiAssistantRegistry to get
        // the active viewId without duplicating the field.
        val activeFragment = BindingsAiAssistantRegistry.findActiveViewId()?.let { viewId ->
            FragmentContainerPlatformView.getPdfFragment(viewId)
        }
        if (activeFragment != null) return activeFragment

        // Fallback: also check the legacy PSPDFKitView registry in case only
        // the legacy module's fragment is active (apps that ship both modules).
        return try {
            val cls = Class.forName("com.pspdfkit.flutter.pspdfkit.PSPDFKitView")
            val method = cls.getMethod("getActivePdfFragment")
            method.invoke(null) as? com.pspdfkit.ui.PdfFragment
        } catch (_: ClassNotFoundException) {
            null
        } catch (e: Throwable) {
            Log.e(LOG_TAG, "resolveActivePdfFragment: reflection error", e)
            null
        }
    }

    companion object {
        private const val LOG_TAG = "NutrientFlutterActivity"
    }
}
