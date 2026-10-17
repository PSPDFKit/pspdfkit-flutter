/*
 * Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
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
import com.pspdfkit.flutter.pspdfkit.util.runCatchingUnlessCancelled
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.launch

@Deprecated("This class is deprecated and will be removed in the future. Please use the new `PspdfkitViewImpl` class instead.")
class PspdfkitPdfGenerator(private val pageAdaptor: PdfPageAdaptor) {

    private val scope = MainScope()

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
        // Collected on the main thread, so we can update the UI.
        scope.launch {
            runCatchingUnlessCancelled {
                PdfProcessor
                    .processDocumentAsync(task, outputFile)
                    .flowOn(Dispatchers.IO)
                    .collect {
                        //Log progress
                        Log.d(
                            "PDF Generation",
                            "generatePdf: Processing page ${it.pagesProcessed + 1} of ${it.totalPages}"
                        )
                    }
            }.getOrElse {
                // Handle the error.
                result.error("Error generating PDF", it.message, null)
                return@launch
            }
            result.success(outputFilePath)
        }
    }

    fun dispose() {
        scope.coroutineContext.cancelChildren()
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