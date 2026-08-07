package com.nutrient.nutrient_flutter_android

import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentContainerView
import androidx.fragment.app.FragmentManager
import com.pspdfkit.ai.createAiAssistant
import com.pspdfkit.ai.createAiAssistantForInstant
import com.pspdfkit.ui.DocumentDescriptor
import com.pspdfkit.ui.PdfFragment
import com.pspdfkit.ui.PdfUiFragment
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.nutrient.domain.ai.AiAssistant
import java.util.concurrent.Executors

/**
 * Simple platform view that provides an empty FragmentContainerView.
 * The Fragment will be added from Dart side using JNI bindings.
 */
class FragmentContainerPlatformView(
    private val context: Context,
    private val id: Int,
    messenger: BinaryMessenger? = null
) : PlatformView {
    private val containerView: FragmentContainerView = FragmentContainerView(context).apply {
        // Generate a unique ID for this container so fragments can be attached to it
        this.id = View.generateViewId()
    }

    // Store references to attached fragments
    private var pdfUiFragment: PdfUiFragment? = null
    private var pdfFragment: PdfFragment? = null

    // Custom main-toolbar item descriptors pending application to the fragment.
    // Held here so items set before the fragment attaches (or set while a
    // previous fragment was active) are re-applied to the current fragment.
    private var pendingToolbarItems: List<Map<String, Any?>>? = null

    // Annotation creation / editing toolbar descriptors, same pending semantics.
    private var pendingAnnotationToolbarItems: List<Any?>? = null
    private var pendingAnnotationEditingItems: List<Any?>? = null

    // Stylus button visibility, same pending semantics.
    private var pendingShowStylusButton: Boolean? = null

    // Method channel for callbacks to Dart. Also accepts incoming calls from
    // Dart — currently `setupInstantAiAssistant` (built and registered when
    // NutrientInstantView mounts with an AI Assistant config) and
    // `teardownInstantAiAssistant` (called on dispose).
    private val methodChannel: MethodChannel? = messenger?.let {
        MethodChannel(it, "com.nutrient.fragment_container.$id").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "setupInstantAiAssistant" -> {
                        val args = call.arguments as? Map<*, *>
                        val instantServerUrl = args?.get("instantServerUrl") as? String
                        val instantJwt = args?.get("instantJwt") as? String
                        val aiServerUrl = args?.get("aiServerUrl") as? String
                        val aiJwt = args?.get("aiJwt") as? String
                        val sessionId = args?.get("sessionId") as? String
                        if (instantServerUrl == null || instantJwt == null ||
                            aiServerUrl == null || aiJwt == null || sessionId == null) {
                            result.error(
                                "InvalidArgs",
                                "setupInstantAiAssistant missing required arguments",
                                null
                            )
                        } else {
                            val ok = setupInstantAiAssistant(
                                viewId = id,
                                instantServerUrl = instantServerUrl,
                                instantJwt = instantJwt,
                                aiServerUrl = aiServerUrl,
                                aiJwt = aiJwt,
                                sessionId = sessionId,
                                context = context
                            )
                            result.success(ok)
                        }
                    }
                    "teardownInstantAiAssistant" -> {
                        teardownInstantAiAssistant(id)
                        result.success(true)
                    }
                    "setMainToolbarItems" -> {
                        val args = call.arguments as? Map<*, *>
                        val rawItems = args?.get("items") as? List<*>
                        val items = rawItems
                            ?.filterIsInstance<Map<*, *>>()
                            ?.map { entry ->
                                entry.entries
                                    .mapNotNull { (k, v) ->
                                        (k as? String)?.let { it to v }
                                    }
                                    .toMap()
                            }
                            ?: emptyList()
                        pendingToolbarItems = items
                        applyToolbarItems()
                        result.success(true)
                    }
                    "setAnnotationToolbarItems" -> {
                        val args = call.arguments as? Map<*, *>
                        pendingAnnotationToolbarItems =
                            (args?.get("items") as? List<*>)?.toList() ?: emptyList()
                        applyAnnotationToolbarItems()
                        result.success(true)
                    }
                    "setAnnotationEditingToolbarItems" -> {
                        val args = call.arguments as? Map<*, *>
                        pendingAnnotationEditingItems =
                            (args?.get("items") as? List<*>)?.toList() ?: emptyList()
                        applyAnnotationEditingItems()
                        result.success(true)
                    }
                    "setShowStylusButton" -> {
                        val args = call.arguments as? Map<*, *>
                        val show = args?.get("show") as? Boolean
                        if (show == null) {
                            // Don't coerce to the native default: a Dart-side
                            // type regression would then look like the command
                            // worked while doing nothing.
                            result.error(
                                "InvalidArgs",
                                "setShowStylusButton requires a boolean 'show' argument",
                                null
                            )
                        } else {
                            pendingShowStylusButton = show
                            applyShowStylusButton()
                            result.success(true)
                        }
                    }
                    "setupStandaloneAiAssistant" -> {
                        val args = call.arguments as? Map<*, *>
                        val aiServerUrl = args?.get("aiServerUrl") as? String
                        val aiJwt = args?.get("aiJwt") as? String
                        val sessionId = args?.get("sessionId") as? String
                        if (aiServerUrl == null || aiJwt == null || sessionId == null) {
                            result.error(
                                "InvalidArgs",
                                "setupStandaloneAiAssistant missing required arguments",
                                null
                            )
                        } else {
                            val ok = setupStandaloneAiAssistant(
                                viewId = id,
                                aiServerUrl = aiServerUrl,
                                aiJwt = aiJwt,
                                sessionId = sessionId,
                                context = context
                            )
                            result.success(ok)
                        }
                    }
                    // Note: zoomTo (and other view-mutating PdfFragment calls)
                    // are now driven from Dart via AndroidAdapter.runOnMainThread,
                    // which executes the JNI call on the platform/main thread —
                    // so the per-view channel no longer needs a zoomToRect hop.
                    else -> result.notImplemented()
                }
            }
        }
    }

    // Callbacks for when PdfFragment becomes available. A list, not a single
    // slot — multiple call sites (citation navigation hook, AI Assistant
    // setup) all want to be notified, and an overwrite-style API drops the
    // earlier listener silently. See review comment on PR #53248.
    private val onPdfFragmentReadyCallbacks = mutableListOf<(PdfFragment) -> Unit>()

    companion object {
        // Store instances by view ID so they can be accessed from Dart via JNI
        private val instances = mutableMapOf<Int, FragmentContainerPlatformView>()

        @JvmStatic
        fun getInstance(viewId: Int): FragmentContainerPlatformView? = instances[viewId]

        @JvmStatic
        fun getPdfFragment(viewId: Int): PdfFragment? {
            return instances[viewId]?.pdfFragment
        }

        /**
         * Registers a callback to be invoked when PdfFragment becomes
         * available. If the fragment is already available the callback fires
         * synchronously. Multiple callbacks may be registered for the same
         * view; each is invoked once when the fragment becomes ready.
         */
        @JvmStatic
        fun setOnPdfFragmentReady(viewId: Int, callback: (PdfFragment) -> Unit) {
            val instance = instances[viewId]
            if (instance == null) {
                android.util.Log.e("FragmentContainer", "No instance found for viewId=$viewId")
                return
            }

            val existing = instance.pdfFragment
            if (existing != null) {
                callback(existing)
            } else {
                instance.onPdfFragmentReadyCallbacks.add(callback)
            }
        }

        @JvmStatic
        fun attachFragment(viewId: Int, fragment: Fragment): Boolean {
            val instance = instances[viewId]
            if (instance == null) {
                android.util.Log.e("FragmentContainer", "No instance found for viewId=$viewId")
                return false
            }

            return instance.attachFragmentInternal(fragment)
        }

        /**
         * Builds an AI Assistant for the Instant document hosted in [viewId] and
         * publishes it to the FlutterAiAssistantRegistry so the host activity's
         * AiAssistantProvider implementation can return it to the SDK.
         *
         * The layer JWT comes from the JWT the caller already passed to
         * NutrientInstantView (`instantJwt`). The Android SDK's
         * `createAiAssistantForInstant` re-fetches the descriptor from that JWT
         * to extract the document id / layer / sourcePdfSha — see
         * `AiAssistantHelpers.kt:188-205` upstream — so we don't need to wait for
         * the document to load.
         */
        // Single-thread executor: the underlying SDK call hits Document Engine
        // synchronously to fetch the Instant document descriptor, which can
        // take hundreds of ms. Running it on the main thread ANRs the app.
        private val aiAssistantExecutor by lazy { Executors.newSingleThreadExecutor() }

        @JvmStatic
        fun setupInstantAiAssistant(
            viewId: Int,
            instantServerUrl: String,
            instantJwt: String,
            aiServerUrl: String,
            aiJwt: String,
            sessionId: String,
            context: Context
        ): Boolean {
            // Defer construction until the host fragment has loaded the Instant
            // document. createAiAssistantForInstant calls
            // InstantDocumentDescriptor.openDocument(jwt) internally, which
            // contends with the host fragment's own document load — building
            // eagerly while the fragment is mid-load deadlocks both. The
            // network call itself happens on the executor so the platform
            // channel returns immediately and the UI thread is not blocked.
            setOnPdfFragmentReady(viewId) { _ ->
                aiAssistantExecutor.execute {
                    try {
                        val assistant = createAiAssistantForInstant(
                            context = context,
                            instantServerUrl = instantServerUrl,
                            documentLayerJwts = listOf(instantJwt),
                            aiAssistantServerUrl = aiServerUrl,
                            sessionId = sessionId,
                            jwtToken = { _ -> aiJwt }
                        )
                        publishAssistant(viewId, assistant)
                        Log.d(LOG_TAG, "AI Assistant (Instant) registered for view $viewId")
                        notifyAiAssistantReady(viewId)
                    } catch (e: Throwable) {
                        Log.e(LOG_TAG, "Error creating AI Assistant for Instant document", e)
                        // Surface the failure to Dart so the UI can react
                        // (hide the AI toolbar button, show a banner, etc.).
                        // Class name only — never the JWT or server URL.
                        notifyAiAssistantFailed(viewId, e.javaClass.simpleName)
                    }
                }
            }
            return true
        }

        /**
         * Dispatches an `onInstantAiAssistantReady` event on the view's
         * platform-view method channel. Marshalled to the main thread because
         * Flutter's platform channels require it.
         */
        private fun notifyAiAssistantReady(viewId: Int) {
            val instance = instances[viewId] ?: return
            instance.containerView.post {
                instance.methodChannel?.invokeMethod("onInstantAiAssistantReady", null)
            }
        }

        /**
         * Dispatches an `onInstantAiAssistantFailed` event with a non-sensitive
         * error code (the exception's simple name). The Dart side maps this
         * back to a user-actionable error path (e.g. hiding the AI button).
         */
        private fun notifyAiAssistantFailed(viewId: Int, errorCode: String) {
            val instance = instances[viewId] ?: return
            instance.containerView.post {
                instance.methodChannel?.invokeMethod(
                    "onInstantAiAssistantFailed",
                    mapOf("errorCode" to errorCode)
                )
            }
        }

        /**
         * Builds an AI Assistant for a standalone (non-Instant) document hosted
         * in [viewId] and publishes it to both [BindingsAiAssistantRegistry] and
         * the legacy FlutterAiAssistantRegistry.
         *
         * Unlike the Instant path, standalone assistant creation requires a real
         * loaded [com.pspdfkit.document.PdfDocument] so that [createAiAssistant]
         * can read the document's permanent ID. We therefore defer construction
         * until the PdfFragment is ready (which is guaranteed by the Dart side
         * only invoking this after `_checkAndNotifyDocumentLoaded` completes),
         * and still add a small retry loop to guard against the narrow race where
         * [PdfFragment.getDocument] returns null for a few hundred ms (image docs
         * converting to PDF asynchronously).
         */
        @JvmStatic
        fun setupStandaloneAiAssistant(
            viewId: Int,
            aiServerUrl: String,
            aiJwt: String,
            sessionId: String,
            context: Context
        ): Boolean {
            setOnPdfFragmentReady(viewId) { fragment ->
                aiAssistantExecutor.execute {
                    // Guard: PdfDocument may still be loading for image documents.
                    // Poll up to 5 s (25 × 200 ms) before giving up.
                    var document = fragment.document
                    var attempts = 0
                    while (document == null && attempts < 25) {
                        try {
                            Thread.sleep(200)
                        } catch (_: InterruptedException) {
                            Thread.currentThread().interrupt()
                            return@execute
                        }
                        document = fragment.document
                        attempts++
                    }

                    if (document == null) {
                        Log.e(
                            LOG_TAG,
                            "setupStandaloneAiAssistant: document still null after retries for view $viewId"
                        )
                        notifyAiAssistantFailed(viewId, "DocumentNotReady")
                        return@execute
                    }

                    try {
                        val assistant = createAiAssistant(
                            context = context,
                            documentsDescriptors = listOf(DocumentDescriptor.fromDocument(document)),
                            serverUrl = aiServerUrl,
                            sessionId = sessionId,
                            jwtToken = { _ -> aiJwt }
                        )
                        publishAssistant(viewId, assistant)
                        Log.d(LOG_TAG, "AI Assistant (standalone) registered for view $viewId")
                        notifyAiAssistantReady(viewId)
                    } catch (e: Throwable) {
                        Log.e(LOG_TAG, "Error creating AI Assistant for standalone document", e)
                        notifyAiAssistantFailed(viewId, e.javaClass.simpleName)
                    }
                }
            }
            return true
        }

        /**
         * Removes the AI Assistant registered for [viewId]. Triggered when the
         * widget disposes. The registry calls `terminate()` internally to release
         * the socket; this happens whether the customer triggered dispose or the
         * widget was destroyed by a configuration change.
         */
        @JvmStatic
        fun teardownInstantAiAssistant(viewId: Int) {
            unpublishAssistant(viewId)
        }

        /**
         * Publishes [assistant] to both the module-local
         * [BindingsAiAssistantRegistry] (always) and the legacy
         * `FlutterAiAssistantRegistry` from `nutrient_flutter` (best-effort,
         * reflective). Apps that ship only the bindings module get the local
         * registry; apps that ship both modules get both.
         */
        private fun publishAssistant(viewId: Int, assistant: AiAssistant) {
            // Always register in the bindings-local registry so NutrientFlutterActivity
            // (bindings-only apps) can resolve the assistant via getAiAssistant().
            BindingsAiAssistantRegistry.register(viewId, assistant)

            // Secondary: also publish to the legacy module's registry for apps
            // that ship both `nutrient_flutter` and `nutrient_flutter_android`.
            try {
                val registry = registryInstance() ?: return
                val method = registry.javaClass.getMethod(
                    "register",
                    Int::class.javaPrimitiveType,
                    AiAssistant::class.java
                )
                method.invoke(registry, viewId, assistant)
            } catch (e: Throwable) {
                Log.e(LOG_TAG, "AI Assistant: could not publish to legacy registry", e)
            }
        }

        private fun unpublishAssistant(viewId: Int) {
            // Always unregister from the local registry.
            BindingsAiAssistantRegistry.unregister(viewId)

            // Best-effort: also remove from the legacy module's registry.
            try {
                val registry = registryInstance() ?: return
                val method = registry.javaClass.getMethod(
                    "unregister",
                    Int::class.javaPrimitiveType
                )
                method.invoke(registry, viewId)
            } catch (e: Throwable) {
                Log.e(LOG_TAG, "AI Assistant: could not unregister from legacy registry", e)
            }
        }

        /**
         * Marks [viewId] as the foreground view in both AI Assistant registries,
         * or clears the pointer when [viewId] is null. Called from fragment
         * resume/pause lifecycle so the host activity's `getAiAssistant()` returns
         * the assistant tied to the fragment that opened the AI dialog.
         */
        private fun setActiveInRegistry(viewId: Int?) {
            // Always update the local bindings registry (serves NutrientFlutterActivity).
            BindingsAiAssistantRegistry.setActive(viewId)

            // Best-effort: also update the legacy module's registry.
            try {
                val registry = registryInstance() ?: return
                val method = registry.javaClass.getMethod(
                    "setActive",
                    java.lang.Integer::class.java
                )
                method.invoke(registry, viewId)
            } catch (e: Throwable) {
                Log.e(LOG_TAG, "AI Assistant: could not set active view in legacy registry", e)
            }
        }

        private fun registryInstance(): Any? {
            return try {
                val cls = Class.forName(
                    "com.pspdfkit.flutter.pspdfkit.ai.FlutterAiAssistantRegistry"
                )
                cls.getField("INSTANCE").get(null)
            } catch (_: ClassNotFoundException) {
                // nutrient_flutter not in the APK — should never happen because
                // nutrient_flutter_android depends on it through pubspec, but
                // fail gracefully if the user pruned dependencies.
                null
            }
        }

        // Cross-module bridge: NutrientInstantView's PdfFragment must also be
        // registered with PSPDFKitView's process-wide registry so the host
        // activity's `navigateTo` (used by AI Assistant citation taps) can
        // resolve it via the existing `getActivePdfFragment()` lookup.
        // Without this, citations on NutrientInstantView silently do nothing.
        private fun publishFragmentToHostRegistry(viewId: Int, fragment: PdfFragment) {
            try {
                val cls = Class.forName("com.pspdfkit.flutter.pspdfkit.PSPDFKitView")
                val method = cls.getMethod(
                    "registerPdfFragment",
                    Int::class.javaPrimitiveType,
                    PdfFragment::class.java
                )
                method.invoke(null, viewId, fragment)
            } catch (_: ClassNotFoundException) {
                // Legacy nutrient_flutter plugin not in the APK (e.g. a
                // bindings-only app) — the host registry only exists for the
                // AI Assistant cross-module bridge, so there's nothing to do.
            } catch (e: Throwable) {
                Log.e(LOG_TAG, "Could not publish PdfFragment to host registry", e)
            }
        }

        private fun unpublishFragmentFromHostRegistry(viewId: Int) {
            try {
                val cls = Class.forName("com.pspdfkit.flutter.pspdfkit.PSPDFKitView")
                val method = cls.getMethod(
                    "unregisterPdfFragment",
                    Int::class.javaPrimitiveType
                )
                method.invoke(null, viewId)
            } catch (_: ClassNotFoundException) {
                // Legacy nutrient_flutter plugin not in the APK — see above.
            } catch (e: Throwable) {
                Log.e(LOG_TAG, "Could not unregister PdfFragment from host registry", e)
            }
        }

        private const val LOG_TAG = "FragmentContainer"
    }

    init {
        instances[id] = this
        setupFragmentLifecycleMonitoring()
    }

    /**
     * Checks if PdfFragment is available and notifies listeners if found.
     */
    private fun checkAndNotifyPdfFragment(pdfUiFragment: PdfUiFragment) {
        // Skip if we already have the fragment or view not yet created
        if (pdfFragment != null || pdfUiFragment.view == null) {
            return
        }

        try {
            // Access the underlying PdfFragment
            val fragment = pdfUiFragment.pdfFragment
            if (fragment != null) {
                pdfFragment = fragment
                // Cross-module publish so host activity's navigateTo (used by
                // AI Assistant citation taps) can resolve this fragment.
                publishFragmentToHostRegistry(id, fragment)
                // Drain in-order, copy first so a callback that re-registers
                // doesn't mutate the list mid-iteration.
                val pending = onPdfFragmentReadyCallbacks.toList()
                onPdfFragmentReadyCallbacks.clear()
                for (cb in pending) {
                    try {
                        cb(fragment)
                    } catch (t: Throwable) {
                        Log.e(LOG_TAG, "onPdfFragmentReady callback threw", t)
                    }
                }
                methodChannel?.invokeMethod("onPdfFragmentReady", null)
            }
        } catch (e: Exception) {
            // Fragment not fully initialized yet - will retry on next lifecycle callback
            if (e !is NullPointerException) {
                android.util.Log.e(
                    "FragmentContainer",
                    "Error checking PdfFragment: ${e.message}",
                    e
                )
            }
        }
    }

    /**
     * Sets up fragment lifecycle monitoring to detect when PdfFragment becomes available.
     * This mirrors the pattern from PSPDFKitView.kt lines 154-229.
     */
    private fun setupFragmentLifecycleMonitoring() {
        val activity = getActivityFromContext(context) ?: run {
            android.util.Log.w(
                "FragmentContainer",
                "Cannot setup lifecycle monitoring - no activity found"
            )
            return
        }

        activity.supportFragmentManager.registerFragmentLifecycleCallbacks(
            object : FragmentManager.FragmentLifecycleCallbacks() {
                override fun onFragmentAttached(
                    fm: FragmentManager,
                    f: Fragment,
                    context: Context
                ) {
                    if (f is PdfUiFragment && f == pdfUiFragment) {
                        checkAndNotifyPdfFragment(f)
                    }
                }

                override fun onFragmentResumed(fm: FragmentManager, f: Fragment) {
                    if (f is PdfUiFragment && f == pdfUiFragment) {
                        if (pdfFragment == null) {
                            checkAndNotifyPdfFragment(f)
                        }
                        // Foreground this view in the AI Assistant registry so
                        // its assistant wins ties when multiple views coexist.
                        setActiveInRegistry(id)
                    }
                }

                override fun onFragmentPaused(fm: FragmentManager, f: Fragment) {
                    if (f is PdfUiFragment && f == pdfUiFragment) {
                        // Don't fight other views on the same activity — only
                        // clear the active pointer if it was us. Another view
                        // resuming next will re-set the pointer to itself.
                        setActiveInRegistry(null)
                    }
                }

                override fun onFragmentDetached(fm: FragmentManager, f: Fragment) {
                    if (f == pdfUiFragment) {
                        pdfFragment = null
                        unpublishFragmentFromHostRegistry(id)
                    }
                }
            },
            true // recursive - monitor all child fragments too
        )
    }

    /**
     * Attaches a fragment to this container.
     * Must be called with a Fragment instance created via JNI.
     * Requires FragmentActivity for PdfUiFragment.
     */
    /**
     * Unwraps a Context to find the underlying Activity.
     * Platform views receive a ContextWrapper, so we need to unwrap it.
     */
    private fun getActivityFromContext(context: Context): FragmentActivity? {
        var currentContext = context
        while (currentContext is ContextWrapper) {
            if (currentContext is FragmentActivity) {
                return currentContext
            }
            currentContext = currentContext.baseContext
        }
        return null
    }

    private fun attachFragmentInternal(fragment: Fragment): Boolean {
        val activity = getActivityFromContext(context)
        if (activity == null) {
            android.util.Log.e(
                "FragmentContainer",
                "Could not find FragmentActivity in context chain"
            )
            return false
        }

        // Store reference to PdfUiFragment if that's what we're attaching
        if (fragment is PdfUiFragment) {
            pdfUiFragment = fragment
            // Wire the tap callback and replay any items set before attach.
            applyToolbarItems()
            applyAnnotationToolbarItems()
            applyAnnotationEditingItems()
            applyShowStylusButton()
        }

        try {
            activity.supportFragmentManager
                .beginTransaction()
                .replace(containerView.id, fragment)
                .commitAllowingStateLoss()
            return true
        } catch (e: Exception) {
            android.util.Log.e("FragmentContainer", "Error attaching fragment: ${e.message}", e)
            return false
        }
    }

    /**
     * Forwards the pending custom main-toolbar items to the attached
     * [NutrientPdfUiFragment] and wires its tap callback back to Dart. No-op
     * unless the current fragment is a [NutrientPdfUiFragment] (i.e. the Dart
     * side registered the custom fragment class via `fragmentClass(...)`).
     */
    private fun applyToolbarItems() {
        val fragment = pdfUiFragment as? NutrientPdfUiFragment ?: return
        fragment.onItemTapped = { itemId -> onMainToolbarItemTapped(itemId) }
        pendingToolbarItems?.let { fragment.setCustomToolbarItems(it) }
    }

    /** Forwards the pending annotation **creation** toolbar items to the fragment. */
    private fun applyAnnotationToolbarItems() {
        val fragment = pdfUiFragment as? NutrientPdfUiFragment ?: return
        pendingAnnotationToolbarItems?.let { fragment.setAnnotationToolbarItems(it) }
    }

    /** Forwards the pending annotation **editing** toolbar items to the fragment. */
    private fun applyAnnotationEditingItems() {
        val fragment = pdfUiFragment as? NutrientPdfUiFragment ?: return
        pendingAnnotationEditingItems?.let { fragment.setAnnotationEditingToolbarItems(it) }
    }

    /** Forwards the pending stylus button visibility to the fragment. */
    private fun applyShowStylusButton() {
        val fragment = pdfUiFragment as? NutrientPdfUiFragment ?: return
        pendingShowStylusButton?.let { fragment.setShowStylusButton(it) }
    }

    /**
     * Dispatches a custom main-toolbar tap (by item id) to Dart over the
     * per-view method channel. Posted to the view so the channel call lands on
     * the main thread, as Flutter platform channels require.
     */
    private fun onMainToolbarItemTapped(itemId: String) {
        containerView.post {
            methodChannel?.invokeMethod("onMainToolbarItemTapped", mapOf("id" to itemId))
        }
    }

    override fun getView(): View = containerView

    override fun dispose() {
        instances.remove(id)
        // Mirror the dispose of the AI Assistant + cross-module fragment
        // publish: unhook this view's PdfFragment from the host registry so
        // navigateTo doesn't keep returning a stale reference after the view
        // is gone.
        unpublishFragmentFromHostRegistry(id)
        onPdfFragmentReadyCallbacks.clear()

        val activity = getActivityFromContext(context)
        val fragment = pdfUiFragment

        // Synchronously remove the fragment so its onDestroy lifecycle runs
        // before the next platform view attaches. Without this, a new
        // NutrientInstantView for the same document can hit the previous
        // fragment's still-active sync coordinator, producing
        // "ALREADY_SYNCING" warnings and a same-descriptor race.
        if (activity != null && fragment != null && !activity.isFinishing) {
            try {
                activity.supportFragmentManager
                    .beginTransaction()
                    .remove(fragment)
                    .commitNowAllowingStateLoss()
            } catch (e: Exception) {
                android.util.Log.e(
                    "FragmentContainer",
                    "Error removing fragment on dispose: ${e.message}",
                    e
                )
            }
        }
        pdfUiFragment = null
        pdfFragment = null
    }
}

class FragmentContainerViewFactory(
    private val messenger: BinaryMessenger
) : io.flutter.plugin.platform.PlatformViewFactory(
    io.flutter.plugin.common.StandardMessageCodec.INSTANCE
) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return FragmentContainerPlatformView(context, id, messenger)
    }
}
