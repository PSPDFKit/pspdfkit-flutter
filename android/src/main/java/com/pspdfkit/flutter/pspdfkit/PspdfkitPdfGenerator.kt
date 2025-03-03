/*
 * Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

import android.util.Log
import com.pspdfkit.document.processor.PdfProcessor
import com.pspdfkit.document.processor.PdfProcessorTask
import com.pspdfkit.flutter.pspdfkit.pdfgeneration.PdfPageAdaptor
import io.flutter.plugin.common.MethodChannel
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers
import java.io.File

@Deprecated("This class is deprecated and will be removed in the future. Please use the new `PspdfkitViewImpl` class instead.")
class PspdfkitPdfGenerator(private val pageAdaptor: PdfPageAdaptor) {

    private var disposable: Disposable? = null

    /**
     * Creates a new [PdfProcessorTask] that can be used to process a PDF document.
     */
    fun generatePdf(
        pages: List<HashMap<String, Any>>,
        outputFilePath: String,
        result: MethodChannel.Result
    ) {

        val documentPages = pageAdaptor.parsePages(pages)
        val task = PdfProcessorTask.empty()

        documentPages.forEachIndexed { index, newPage ->
            task.addNewPage(newPage, index)
        }

        val outputFile = File(outputFilePath);
        disposable = PdfProcessor
            .processDocumentAsync(task, outputFile)
            .subscribeOn(Schedulers.io())
            // Publish results on the main thread so we can update the UI.
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({
                //Log progress
                Log.d(
                    "PDF Generation",
                    "generatePdf: Processing page ${it.pagesProcessed + 1} of ${it.totalPages}"
                )
            }, {
                // Handle the error.
                result.error("Error generating PDF", it.message, null)
            }, {
                result.success(outputFilePath)
            })
    }

    fun dispose() {
        disposable?.dispose()
        instance = null
    }

    companion object {

        private var instance: PspdfkitPdfGenerator? = null

        fun getInstance(pageAdaptor: PdfPageAdaptor): PspdfkitPdfGenerator {
            if (instance == null) {
                instance = PspdfkitPdfGenerator(pageAdaptor)
            }
            return instance!!
        }
    }
}