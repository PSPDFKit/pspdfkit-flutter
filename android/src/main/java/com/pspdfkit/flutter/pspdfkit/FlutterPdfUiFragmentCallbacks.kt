package com.pspdfkit.flutter.pspdfkit

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager

class FlutterPdfUiFragmentCallbacks: FragmentManager.FragmentLifecycleCallbacks() {

    override fun onFragmentAttached(
            fm: FragmentManager,
            f: Fragment,
            context: Context
    ) {
        if (f.tag?.contains("PSPDFKit.Fragment") == true) {
            EventDispatcher.getInstance().notifyPdfFragmentAdded()
        }
    }
}