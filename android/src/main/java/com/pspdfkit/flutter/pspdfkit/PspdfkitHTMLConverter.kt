/*
 *   Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

import android.content.Context
import android.net.Uri
import com.pspdfkit.document.html.HtmlToPdfConverter
import com.pspdfkit.flutter.pspdfkit.util.runCatchingUnlessCancelled
import io.flutter.plugin.common.MethodChannel
import java.io.File
import androidx.core.net.toUri
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

@Deprecated("This class is deprecated and will be removed in the future. Please use the new `PspdfkitApiImpl` class instead.")
object PspdfkitHTMLConverter {

    // The conversions run to completion, as nothing ever disposed their subscriptions. The
    // converter does its work off the main thread, and the results go to Flutter on it.
    private val scope = MainScope()

    @JvmStatic
    fun generateFromHtmlString(
        context: Context,
        html: String,
        outputFilePath: String,
        options: Map<String, Any>?,
        results: MethodChannel.Result
    ) {
        val outputFile = File(outputFilePath)// Output file for the converted PDF.

        val converter = if (options?.contains("baseUrl") == true) HtmlToPdfConverter.fromHTMLString(
            context,
            html,
            options["baseUrl"] as String
        ) else HtmlToPdfConverter.fromHTMLString(context, html, options?.get("baseUrl") as String)

        if (options?.contains("enableJavaScript") ==true)
            converter.setJavaScriptEnabled(options["enableJavaScript"] as Boolean)

        if (options?.contains("documentTitle")==true)
            converter.title(options["documentTitle"] as String)

        scope.launch {
            // Perform the conversion.
            runCatchingUnlessCancelled { converter.convertToPdfAsync(outputFile) }.getOrElse {
                results.error("HTML_TO_PDF_ERROR", it.message, null)
                return@launch
            }
            results.success(outputFile.absolutePath)
        }
    }

    @JvmStatic
    fun generateFromHtmlUri(
        context: Context,
        htmlUriString: String,
        outputFilePath: String,
        options: Map<String, Any>?,
        results: MethodChannel.Result
    ) {
        val outputFile = File(outputFilePath)// Output file for the converted PDF.
        val convertor = HtmlToPdfConverter.fromUri(context, htmlUriString.toUri())

        // Configure javascript enabled
        if (options?.contains("enableJavaScript") == true)
            convertor.setJavaScriptEnabled(options["enableJavaScript"] as Boolean)

        // Configure title for the created document.
        if (options?.contains("documentTitle") == true) convertor.title(options["documentTitle"] as String)

        scope.launch {
            // Perform the conversion.
            runCatchingUnlessCancelled { convertor.convertToPdfAsync(outputFile) }.getOrElse {
                // Handle the error.
                results.error("Error converting HTML to PDF", it.message, null)
                return@launch
            }
            // Return the converted document.
            results.success(outputFilePath)
        }
    }
}
