package com.nutrient.nutrient_flutter_android

import android.content.Context
import android.content.ContextWrapper
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentContainerView
import androidx.fragment.app.FragmentManager
import com.pspdfkit.ui.PdfFragment
import com.pspdfkit.ui.PdfUiFragment
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

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

    // Method channel for callbacks to Dart
    private val methodChannel: MethodChannel? = messenger?.let {
        MethodChannel(it, "com.nutrient.fragment_container.$id")
    }

    // Callback for when PdfFragment becomes available
    var onPdfFragmentReady: ((PdfFragment) -> Unit)? = null

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
         * Sets a callback to be invoked when PdfFragment becomes available.
         * If PdfFragment is already available, the callback is invoked immediately.
         */
        @JvmStatic
        fun setOnPdfFragmentReady(viewId: Int, callback: (PdfFragment) -> Unit) {
            val instance = instances[viewId]
            if (instance == null) {
                android.util.Log.e("FragmentContainer", "No instance found for viewId=$viewId")
                return
            }

            // If PdfFragment is already available, invoke callback immediately
            instance.pdfFragment?.let { callback(it) }
                ?: run { instance.onPdfFragmentReady = callback }
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
                onPdfFragmentReady?.invoke(fragment)
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
                    if (f is PdfUiFragment && f == pdfUiFragment && pdfFragment == null) {
                        checkAndNotifyPdfFragment(f)
                    }
                }

                override fun onFragmentDetached(fm: FragmentManager, f: Fragment) {
                    if (f == pdfUiFragment) {
                        pdfFragment = null
                    }
                }
            },
            true // recursive - monitor all child fragments too
        )
    }

    /**
     * Attaches a fragment to this container.
     * Must be called with a Fragment instance created via JNI.
     * Requires AppCompatActivity for PdfUiFragment.
     */
    /**
     * Unwraps a Context to find the underlying Activity.
     * Platform views receive a ContextWrapper, so we need to unwrap it.
     */
    private fun getActivityFromContext(context: Context): AppCompatActivity? {
        var currentContext = context
        while (currentContext is ContextWrapper) {
            if (currentContext is AppCompatActivity) {
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
                "Could not find AppCompatActivity in context chain"
            )
            return false
        }

        // Store reference to PdfUiFragment if that's what we're attaching
        if (fragment is PdfUiFragment) {
            pdfUiFragment = fragment
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

    override fun getView(): View = containerView

    override fun dispose() {
        instances.remove(id)
        // Fragment cleanup will be handled by FragmentManager
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
