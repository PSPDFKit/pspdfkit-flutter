/*
 * Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */
package com.pspdfkit.flutter.pspdfkit

import android.content.Context
import android.content.ContextWrapper
import android.content.MutableContextWrapper
import android.util.Log
import android.view.View
import androidx.core.net.toUri
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentContainerView
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.commit
import androidx.fragment.app.commitNow
import com.pspdfkit.flutter.pspdfkit.api.CustomToolbarCallbacks
import com.pspdfkit.flutter.pspdfkit.api.NutrientEventsCallbacks
import com.pspdfkit.flutter.pspdfkit.api.NutrientViewCallbacks
import com.pspdfkit.flutter.pspdfkit.api.NutrientViewControllerApi
import com.pspdfkit.flutter.pspdfkit.events.FlutterEventsHelper
import com.pspdfkit.flutter.pspdfkit.toolbar.FlutterMenuGroupingRule
import com.pspdfkit.flutter.pspdfkit.toolbar.FlutterViewModeController
import com.pspdfkit.flutter.pspdfkit.util.addFileSchemeIfMissing
import com.pspdfkit.flutter.pspdfkit.util.isImageDocument
import com.pspdfkit.signatures.storage.DatabaseSignatureStorage
import com.pspdfkit.signatures.storage.SignatureStorage
import com.pspdfkit.ui.PdfFragment
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.ui.PdfUiFragmentBuilder
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.nutrient.data.models.AiAssistantConfiguration
import io.nutrient.domain.ai.AiAssistant
import io.nutrient.domain.ai.standaloneAiAssistant

internal class PSPDFKitView(
    val context: Context,
    private val id: Int,
    private val messenger: BinaryMessenger,
    documentPath: String? = null,
    configurationMap: HashMap<String, Any>? = null,
    customToolbarItems: List<Map<String, Any>>? = null,
    ) : PlatformView {

    private var fragmentContainerView: FragmentContainerView? = FragmentContainerView(context)
    private val methodChannel: MethodChannel
    private lateinit var pdfUiFragment: PdfUiFragment
    private var fragmentCallbacks: FlutterPdfUiFragmentCallbacks? = null
    private val pspdfkitViewImpl: PspdfkitViewImpl = PspdfkitViewImpl()
    private val nutrientEventsCallbacks: NutrientEventsCallbacks = NutrientEventsCallbacks(messenger, "events.callbacks.$id")
    private val widgetCallbacks: NutrientViewCallbacks = NutrientViewCallbacks(messenger, "widget.callbacks.$id")
    private val customToolbarCallbacks: CustomToolbarCallbacks = CustomToolbarCallbacks(messenger, "customToolbar.callbacks.$id")
    private var isFragmentAttached = false
    private var methodCallHandler: PSPDFKitWidgetMethodCallHandler? = null
    private var aiAssistant: AiAssistant? = null

    init {
        fragmentContainerView?.id = View.generateViewId()
        methodChannel = MethodChannel(messenger, "com.nutrient.widget.$id")

        val configurationAdapter = ConfigurationAdapter(context, configurationMap)
        val password = configurationAdapter.password
        val pdfConfiguration = configurationAdapter.build()
        val toolbarGroupingItems: List<Any>? = configurationMap?.get("toolbarItemGrouping") as List<Any>?
        val measurementValueConfigurations =
            configurationMap?.get("measurementValueConfigurations") as List<Map<String, Any>>?
        val aiAssistantConfigurationMap = configurationMap?.get("aiAssistant") as Map<String, Any>?

        try {
            //noinspection pspdfkit-experimental
            pdfUiFragment = if (documentPath == null) {
                Log.d(LOG_TAG, "Initializing empty PdfUiFragment")
                PdfUiFragmentBuilder.emptyFragment(context).fragmentClass(
                    FlutterPdfUiFragment::class.java
                ).configuration(pdfConfiguration).build()
            } else {
                val uri = addFileSchemeIfMissing(documentPath).toUri()
                Log.d(LOG_TAG, "Loading document from URI: $uri")

                // Validate that the URI is accessible
                try {
                    context.contentResolver.openInputStream(uri)?.close()
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "Document URI may not be accessible: $uri", e)
                    // Continue anyway as PSPDFKit might handle this differently
                }

                val isImageDocument = isImageDocument(documentPath)
                if (isImageDocument) {
                    Log.d(LOG_TAG, "Initializing PdfUiFragment with image document")
                    PdfUiFragmentBuilder.fromImageUri(context, uri).configuration(pdfConfiguration)
                        .fragmentClass(FlutterPdfUiFragment::class.java)
                        .build()
                } else {
                    Log.d(LOG_TAG, "Initializing PdfUiFragment with PDF document")
                    PdfUiFragmentBuilder.fromUri(context, uri)
                        .configuration(pdfConfiguration)
                        .fragmentClass(FlutterPdfUiFragment::class.java)
                        .passwords(password)
                        .build()
                }
            }
            setupAiAssistant(context, aiAssistantConfigurationMap)

            fragmentCallbacks = FlutterPdfUiFragmentCallbacks(methodChannel, measurementValueConfigurations,
                messenger,FlutterWidgetCallback(widgetCallbacks),aiAssistant)

            fragmentCallbacks?.let { callbacks ->
                getFragmentActivity(context).supportFragmentManager.registerFragmentLifecycleCallbacks(callbacks, true)
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error initializing PdfUiFragment", e)
            // Create an empty fragment as fallback
            PdfUiFragmentBuilder.emptyFragment(context).fragmentClass(
                FlutterPdfUiFragment::class.java
            ).configuration(pdfConfiguration).build()
        }

        getFragmentActivity(context).supportFragmentManager.registerFragmentLifecycleCallbacks(object : FragmentManager.FragmentLifecycleCallbacks() {
            override fun onFragmentAttached(
                fm: FragmentManager,
                f: Fragment,
                context: Context
            ) {
                if (f.tag?.contains("Nutrient.Fragment") == true) {
                    if (toolbarGroupingItems != null) {
                        val groupingRule = FlutterMenuGroupingRule(context, toolbarGroupingItems)
                        val flutterViewModeController = FlutterViewModeController(groupingRule)
                       pdfUiFragment.setOnContextualToolbarLifecycleListener(flutterViewModeController)
                    }

                    // Process custom toolbar items
                    if (customToolbarItems?.isNotEmpty() == true && f is PdfFragment) {
                        (pdfUiFragment as FlutterPdfUiFragment).setCustomToolbarItems(
                            customToolbarItems,
                            customToolbarCallbacks
                        )
                    }

                    // Create method call handler to handle Flutter method calls
                    methodCallHandler =
                        pdfUiFragment.pdfFragment?.let { PSPDFKitWidgetMethodCallHandler(it) }

                    // Set up method channel for communication with Flutter
                    methodCallHandler?.let { handler ->
                        methodChannel.setMethodCallHandler(handler)
                    }

                    if (configurationMap?.contains("signatureSavingStrategy") == true) {
                        pdfUiFragment.pdfFragment?.let { configureSignatureStorage(it) }
                    }
                }
            }
        }, true)

        fragmentContainerView?.let {
            it.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
                override fun onViewAttachedToWindow(view: View) {
                    try {
                        val fragmentActivity = getFragmentActivity(context)
                        if (!isFragmentAttached && fragmentActivity.supportFragmentManager.isDestroyed.not()) {
                            fragmentActivity.supportFragmentManager.commitNow {
                                add(it.id, pdfUiFragment)
                                pspdfkitViewImpl.setPdfFragment(pdfUiFragment)
                                setReorderingAllowed(true)
                            }
                            isFragmentAttached = true
                            Log.d(LOG_TAG, "PdfUiFragment attached successfully")
                        }
                    } catch (e: Exception) {
                        Log.e(LOG_TAG, "Error attaching PdfUiFragment", e)
                    }
                }

                override fun onViewDetachedFromWindow(view: View) {
                    try {
                        val fragmentActivity = getFragmentActivity(context)
                        if (isFragmentAttached && fragmentActivity.supportFragmentManager.isDestroyed.not()) {
                            fragmentActivity.supportFragmentManager.commit {
                                remove(pdfUiFragment)
                                pspdfkitViewImpl.setPdfFragment(null)
                                setReorderingAllowed(true)
                            }
                            isFragmentAttached = false
                            Log.d(LOG_TAG, "PdfUiFragment detached successfully")
                        }
                    } catch (e: Exception) {
                        Log.e(LOG_TAG, "Error detaching PdfUiFragment", e)
                    }
                }
            })
        }
    }

    override fun getView(): View {
        return fragmentContainerView
            ?: throw IllegalStateException("Fragment container view can't be null.")
    }

    override fun dispose() {
        try {
            // Safely handle fragment removal if it's still attached
            if (isFragmentAttached) {
                try {
                    val fragmentActivity = getFragmentActivity(context)
                    if (!fragmentActivity.isFinishing && !fragmentActivity.isDestroyed
                        && fragmentActivity.supportFragmentManager.isDestroyed.not()) {
                        fragmentActivity.supportFragmentManager.commit {
                            pdfUiFragment.let { if (it.isAdded) remove(it) }
                            setReorderingAllowed(true)
                        }
                    }
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Error removing fragment during dispose", e)
                }
                isFragmentAttached = false
            }

            // Cleanup other resources
            pspdfkitViewImpl.setPdfFragment(null)
            pspdfkitViewImpl.dispose()

            // Unregister callbacks and listeners
            fragmentCallbacks?.let {
                try {
                    getFragmentActivity(context).supportFragmentManager.unregisterFragmentLifecycleCallbacks(it)
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Error unregistering fragment lifecycle callbacks", e)
                }
            }

            // Null out references
            fragmentCallbacks = null
            fragmentContainerView = null

            // Unregister method channel
            NutrientViewControllerApi.setUp(messenger, null, id.toString())

            Log.d(LOG_TAG, "PSPDFKitView disposed successfully")
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error during PSPDFKitView disposal", e)
        }
    }

    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)
        // Set up the method channel for communication with Flutter.
        val flutterEventsHelper = FlutterEventsHelper(nutrientEventsCallbacks)
        pspdfkitViewImpl.setEventDispatcher(flutterEventsHelper)
        NutrientViewControllerApi.setUp(messenger, pspdfkitViewImpl, id.toString())
    }

    // Get Fragment Activity from context with improved error handling
    private fun getFragmentActivity(context: Context): FragmentActivity {
        return when (context) {
            is FragmentActivity -> {
                // Verify the activity is in a valid state for fragment operations
                if (context.isDestroyed || context.isFinishing) {
                    Log.w(LOG_TAG, "Activity is finishing or destroyed, may cause issues with fragment operations")
                }
                context
            }

            is MutableContextWrapper -> {
                try {
                    getFragmentActivity(context.baseContext)
                } catch (e: IllegalStateException) {
                    throw IllegalStateException("MutableContextWrapper does not contain a valid FragmentActivity: ${e.message}")
                }
            }

            is ContextWrapper -> {
                try {
                    getFragmentActivity(context.baseContext)
                } catch (e: IllegalStateException) {
                    throw IllegalStateException("ContextWrapper does not contain a valid FragmentActivity: ${e.message}")
                }
            }

            else -> {
                throw IllegalStateException("Context is not a FragmentActivity and cannot be unwrapped to one: ${context.javaClass.name}")
            }
        }
    }

    private fun configureSignatureStorage(pdfFragment: PdfFragment){
        // See guides: https://www.nutrient.io/guides/android/signatures/signature-storage/
        // Set the signature storage for the PdfFragment.
        // Set up signature storage if a signature saving strategy is configured
            try {
                val storage: SignatureStorage = DatabaseSignatureStorage
                    .withName(context,"nutrient_flutter_signature_storage")
                pdfFragment.signatureStorage = storage
            } catch (e: Exception) {
                // Log any errors but don't crash the app
                Log.e("FlutterPdfActivity", "Error setting up signature storage: " + e.message)
            }
    }

    private fun setupAiAssistant(
        context: Context,
        configuration: Map<String, Any>?
    ) {
        // Initialize the AiAssistant with the provided parameters
        val serverUrl = configuration?.get("serverUrl") as String?
        val jwt = configuration?.get("jwt") as String?
        val sessionId = configuration?.get("sessionId") as String?
        val userId = configuration?.get("userId") as String?

        if (serverUrl != null && jwt != null) {
            val aiAssistantConfiguration = AiAssistantConfiguration(
                serverUrl = serverUrl,
                jwt = jwt ,
                sessionId = sessionId?: "",
                userId = userId ?: ""
            )
            aiAssistant = standaloneAiAssistant(context, aiAssistantConfiguration)
        } else {
            Log.e(LOG_TAG, "Invalid AI Assistant configuration")
        }
    }

    companion object {
        private const val LOG_TAG = "PSPDFKitPlugin"
    }
}

class PSPDFKitViewFactory(
    private val messenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<*, *>?
        return PSPDFKitView(
            context!!,
            viewId,
            messenger,
            creationParams?.get("document") as String?,
            creationParams?.get("configuration") as HashMap<String, Any>?,
            creationParams?.get("customToolbarItems") as List<Map<String, Any>>?,
        )
    }
}
