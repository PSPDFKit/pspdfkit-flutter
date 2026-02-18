/*
 * Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
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
import com.pspdfkit.ai.createAiAssistant
import com.pspdfkit.flutter.pspdfkit.annotations.AnnotationMenuHandler
import com.pspdfkit.flutter.pspdfkit.api.CustomToolbarCallbacks
import com.pspdfkit.flutter.pspdfkit.api.NutrientEventsCallbacks
import com.pspdfkit.flutter.pspdfkit.api.NutrientViewCallbacks
import com.pspdfkit.flutter.pspdfkit.api.NutrientViewControllerApi
import com.pspdfkit.flutter.pspdfkit.events.FlutterEventsHelper
import com.pspdfkit.flutter.pspdfkit.toolbar.FlutterMenuGroupingRule
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
import io.nutrient.domain.ai.AiAssistant


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
    private val nutrientEventsCallbacks: NutrientEventsCallbacks =
        NutrientEventsCallbacks(messenger, "events.callbacks.$id")
    private val widgetCallbacks: NutrientViewCallbacks =
        NutrientViewCallbacks(messenger, "widget.callbacks.$id")
    private val customToolbarCallbacks: CustomToolbarCallbacks =
        CustomToolbarCallbacks(messenger, "customToolbar.callbacks.$id")
    private var annotationMenuHandler: AnnotationMenuHandler? = null
    private var isFragmentAttached = false
    private var methodCallHandler: PSPDFKitWidgetMethodCallHandler? = null

    init {
        fragmentContainerView?.id = View.generateViewId()
        methodChannel = MethodChannel(messenger, "com.nutrient.widget.$id")

        val configurationAdapter = ConfigurationAdapter(context, configurationMap)
        val password = configurationAdapter.password
        val pdfConfiguration = configurationAdapter.build()
        val toolbarGroupingItems: List<Any>? =
            configurationMap?.get("toolbarItemGrouping") as List<Any>?
        val measurementValueConfigurations =
            configurationMap?.get("measurementValueConfigurations") as List<Map<String, Any>>?
        val aiAssistantConfigurationMap = configurationMap?.get("aiAssistant") as Map<String, Any>?
        val annotationMenuConfiguration = configurationAdapter.getAnnotationMenuConfiguration()

        // Initialize annotation menu handler if configuration is provided
        if (annotationMenuConfiguration != null) {
            annotationMenuHandler = AnnotationMenuHandler(
                context,
                annotationMenuConfiguration
            )
            Log.d(
                LOG_TAG,
                "Initialized annotation menu handler"
            )
        }

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

            // Set theme colors BEFORE the fragment is committed so that
            // onGetLayoutInflater() can wrap the context with a themed inflater.
            // This must happen before commitNow() which triggers view creation.
            val themeColors = configurationAdapter.getThemeColors()
            if (themeColors != null) {
                (pdfUiFragment as? FlutterPdfUiFragment)?.setThemeColors(themeColors)
            }

            aiAssistantConfigurationMap?.let {
                setupAiAssistant(context, it)
            }

            fragmentCallbacks = FlutterPdfUiFragmentCallbacks(
                id, methodChannel, measurementValueConfigurations,
                messenger, FlutterWidgetCallback(widgetCallbacks)
            )

            fragmentCallbacks?.let { callbacks ->
                getFragmentActivity(context).supportFragmentManager.registerFragmentLifecycleCallbacks(
                    callbacks,
                    true
                )
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "Error initializing PdfUiFragment", e)
            // Create an empty fragment as fallback
            PdfUiFragmentBuilder.emptyFragment(context).fragmentClass(
                FlutterPdfUiFragment::class.java
            ).configuration(pdfConfiguration).build()
        }

        getFragmentActivity(context).supportFragmentManager.registerFragmentLifecycleCallbacks(
            object : FragmentManager.FragmentLifecycleCallbacks() {
                override fun onFragmentAttached(
                    fm: FragmentManager,
                    f: Fragment,
                    context: Context
                ) {
                    if (f.tag?.contains("Nutrient.Fragment") == true && pdfUiFragment is FlutterPdfUiFragment) {
                        // Set up toolbar grouping rule if available
                        if (toolbarGroupingItems != null) {
                            val groupingRule =
                                FlutterMenuGroupingRule(context, toolbarGroupingItems)
                            val flutterFragment = pdfUiFragment as? FlutterPdfUiFragment
                            flutterFragment?.setToolbarGroupingRule(groupingRule)
                        }

                        // Always set FlutterPdfUiFragment as the contextual toolbar listener
                        // It can handle both toolbar grouping and annotation menu customization
                        val flutterFragment = pdfUiFragment as? FlutterPdfUiFragment
                        flutterFragment?.let { fragment ->
                            fragment.setOnContextualToolbarLifecycleListener(fragment)
                        }

                        // Pass theme colors to the fragment
                        val themeColors = configurationAdapter.getThemeColors()
                        if (themeColors != null) {
                            val flutterFragment = pdfUiFragment as? FlutterPdfUiFragment
                            flutterFragment?.setThemeColors(themeColors)
                        }
                    }

                    // Process custom toolbar items
                    if (customToolbarItems?.isNotEmpty() == true && f is PdfFragment) {
                        val flutterFragment = pdfUiFragment as? FlutterPdfUiFragment
                        flutterFragment?.setCustomToolbarItems(
                            customToolbarItems,
                            customToolbarCallbacks
                        )
                    }

                    // Set up annotation menu handler if configured
                    if (annotationMenuHandler != null && f is PdfFragment) {
                        val flutterFragment = pdfUiFragment as? FlutterPdfUiFragment
                        flutterFragment?.setAnnotationMenuHandler(annotationMenuHandler!!)
                    }

                    // Set up annotation creation button visibility configuration
                    val flutterFragment = pdfUiFragment as? FlutterPdfUiFragment
                    flutterFragment?.setHideAnnotationCreationButton(configurationAdapter.shouldHideAnnotationCreationButton())
                    
                    // Dynamic annotation menu callbacks have been removed
                    // The annotation menu is now configured statically via annotationMenuHandler

                    // Method call handler setup is deferred to onFragmentResumed
                    // because pdfFragment may not be ready during onFragmentAttached

                    if (configurationMap?.contains("signatureSavingStrategy") == true) {
                        try {
                            pdfUiFragment.pdfFragment?.let { configureSignatureStorage(it) }
                        } catch (e: Exception) {
                            Log.e(LOG_TAG, "Error configuring signature storage", e)
                        }
                    }

                }

                override fun onFragmentResumed(fm: FragmentManager, f: Fragment) {
                    // Set up method call handler when fragment is resumed
                    // This ensures pdfFragment is fully initialized
                    if (f.tag?.contains("Nutrient.Fragment") == true && methodCallHandler == null) {
                        try {
                            val pdfFragment = pdfUiFragment.pdfFragment
                            if (pdfFragment != null) {
                                methodCallHandler = PSPDFKitWidgetMethodCallHandler(pdfFragment)
                                methodCallHandler?.let { handler ->
                                    methodChannel.setMethodCallHandler(handler)
                                }
                                Log.d(LOG_TAG, "Method call handler set up successfully in onFragmentResumed")
                            }
                        } catch (e: Exception) {
                            Log.e(LOG_TAG, "Error setting up method call handler in onFragmentResumed", e)
                        }
                    }
                }
            },
            true
        )

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
                        && fragmentActivity.supportFragmentManager.isDestroyed.not()
                    ) {
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
                    getFragmentActivity(context).supportFragmentManager.unregisterFragmentLifecycleCallbacks(
                        it
                    )
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Error unregistering fragment lifecycle callbacks", e)
                }
            }

            // Null out references
            fragmentCallbacks = null
            fragmentContainerView = null
            aiAssistant = null

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
        val flutterEventsHelper =
            FlutterEventsHelper(nutrientEventsCallbacks, annotationMenuHandler)
        pspdfkitViewImpl.setEventDispatcher(flutterEventsHelper)
        NutrientViewControllerApi.setUp(messenger, pspdfkitViewImpl, id.toString())
    }

    // Get Fragment Activity from context with improved error handling
    private fun getFragmentActivity(context: Context): FragmentActivity {
        return when (context) {
            is FragmentActivity -> {
                // Verify the activity is in a valid state for fragment operations
                if (context.isDestroyed || context.isFinishing) {
                    Log.w(
                        LOG_TAG,
                        "Activity is finishing or destroyed, may cause issues with fragment operations"
                    )
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

    private fun configureSignatureStorage(pdfFragment: PdfFragment) {
        // See guides: https://www.nutrient.io/guides/android/signatures/signature-storage/
        // Set the signature storage for the PdfFragment.
        // Set up signature storage if a signature saving strategy is configured
        try {
            val storage: SignatureStorage = DatabaseSignatureStorage
                .withName(context, "nutrient_flutter_signature_storage")
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
        
        if (serverUrl != null && jwt != null && sessionId != null) {
            try {
                // Create AI Assistant with new 10.10+ API and store in companion object
                aiAssistant = createAiAssistant(
                    context = context,
                    documentsDescriptors = emptyList(),
                    serverUrl = serverUrl,
                    sessionId = sessionId,
                    jwtToken = { _ -> jwt }
                )
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Error creating AI Assistant", e)
            }
        } else {
            Log.e(LOG_TAG, "Invalid AI Assistant configuration - serverUrl, jwt, and sessionId are required")
        }
    }

    companion object {
        private const val LOG_TAG = "PSPDFKitPlugin"
        var  aiAssistant: AiAssistant? = null

        // Registry for PdfFragment instances, keyed by view ID.
        // This allows Dart adapters to access the native PdfFragment via JNI.
        private val pdfFragmentRegistry = mutableMapOf<Int, PdfFragment>()

        /**
         * Registers a PdfFragment for a given view ID.
         * Called internally when the fragment is attached.
         */
        @JvmStatic
        fun registerPdfFragment(viewId: Int, fragment: PdfFragment) {
            pdfFragmentRegistry[viewId] = fragment
            Log.d(LOG_TAG, "Registered PdfFragment for view $viewId")
        }

        /**
         * Unregisters the PdfFragment for a given view ID.
         * Called internally when the view is disposed.
         */
        @JvmStatic
        fun unregisterPdfFragment(viewId: Int) {
            pdfFragmentRegistry.remove(viewId)
            Log.d(LOG_TAG, "Unregistered PdfFragment for view $viewId")
        }

        /**
         * Gets the PdfFragment for a given view ID.
         * This method is intended to be called from Dart via JNI.
         *
         * @param viewId The platform view ID
         * @return The PdfFragment instance, or null if not registered
         */
        @JvmStatic
        fun getPdfFragment(viewId: Int): PdfFragment? {
            return pdfFragmentRegistry[viewId]
        }
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
