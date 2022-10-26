/*
 *   Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

import android.annotation.SuppressLint
import android.content.Context
import android.net.Uri
import com.pspdfkit.document.html.HtmlToPdfConverter
import io.flutter.plugin.common.MethodChannel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.io.File

object PspdfkitHTMLConverter {

    @JvmStatic
    @SuppressLint("CheckResult")
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
        ) else HtmlToPdfConverter.fromHTMLString(context, html)

        if (options?.contains("enableJavaScript") == true)
            converter.setJavaScriptEnabled(options["enableJavaScript"] as Boolean)

        if (options?.contains("documentTitle") == true)
            converter.title(options["documentTitle"] as String)

        converter
            // Perform the conversion.
            .convertToPdfAsync(outputFile)
            .subscribeOn(Schedulers.io())
            // Publish results on the main thread so we can update the UI.
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { results.success(outputFile.absolutePath) },
                { results.error("HTML_TO_PDF_ERROR", it.message, null) })
    }

    @JvmStatic
    @SuppressLint("CheckResult")
    fun generateFromHtmlUri(
        context: Context,
        htmlUriString: String,
        outputFilePath: String,
        options: Map<String, Any>?,
        results: MethodChannel.Result
    ) {
        val outputFile = File(outputFilePath)// Output file for the converted PDF.
        val convertor = HtmlToPdfConverter.fromUri(context, Uri.parse(htmlUriString))

        // Configure javascript enabled
        if (options?.contains("enableJavaScript") == true)
            convertor.setJavaScriptEnabled(options["enableJavaScript"] as Boolean)

        // Configure title for the created document.
        if (options?.contains("documentTitle") == true) convertor.title(options["documentTitle"] as String)

        convertor
            // Perform the conversion.
            .convertToPdfAsync(outputFile)
            // Subscribe to the conversion result.
            .subscribe({
                // Return the converted document.
                results.success(outputFilePath)
            }, {
                // Handle the error.
                results.error("Error converting HTML to PDF", it.message, null)
            })
    }
}
