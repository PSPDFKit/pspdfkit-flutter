/*
 * Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit.document

import android.content.Context
import android.net.Uri
import com.pspdfkit.document.DocumentSource
import com.pspdfkit.document.PdfDocumentLoader
import com.pspdfkit.flutter.pspdfkit.api.HeadlessDocumentApi
import com.pspdfkit.flutter.pspdfkit.api.HeadlessDocumentOpenOptions
import com.pspdfkit.flutter.pspdfkit.api.NutrientApiError
import com.pspdfkit.flutter.pspdfkit.api.PdfDocumentApi
import io.flutter.plugin.common.BinaryMessenger
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers
import java.util.UUID

/**
 * Implementation of HeadlessDocumentApi that provides headless document operations.
 *
 * This implementation allows opening PDF documents without a viewer UI and performing
 * operations like annotation processing, form filling, and document manipulation.
 * Each opened document gets a unique ID and its own PdfDocumentApi channel for
 * isolated communication with Flutter.
 *
 * @param context Android application context for document loading
 * @param binaryMessenger Flutter binary messenger for setting up API channels
 */
class HeadlessDocumentApiImpl(
    private val context: Context,
    private val binaryMessenger: BinaryMessenger
) : HeadlessDocumentApi {

    private var disposable: Disposable? = null

    /**
     * Opens a document from the given path without displaying a viewer.
     *
     * This method loads a PDF document using PdfDocumentLoader and registers it with
     * a unique document ID. A PdfDocumentApi channel is set up for the document using
     * the document ID as a channel suffix, allowing Flutter to communicate with this
     * specific document instance.
     *
     * @param documentPath Path to the PDF document (file path or content:// URI)
     * @param options Optional settings like password for encrypted documents
     * @param callback Callback with Result containing the unique document ID or error
     */
    override fun openDocument(
        documentPath: String,
        options: HeadlessDocumentOpenOptions?,
        callback: (Result<String>) -> Unit
    ) {
        try {
            // Parse the document path as URI
            // If the path is a plain file path (starts with /), convert it to a file:// URI
            val documentUri = if (documentPath.startsWith("/")) {
                Uri.fromFile(java.io.File(documentPath))
            } else {
                Uri.parse(documentPath)
            }

            // Create document source with optional password
            val documentSource = if (options?.password != null) {
                DocumentSource(documentUri, options.password)
            } else {
                DocumentSource(documentUri)
            }

            // Load document asynchronously
            disposable = PdfDocumentLoader.openDocumentAsync(context, documentSource)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                    { pdfDocument ->
                        // Generate unique document ID
                        val documentId = UUID.randomUUID().toString()

                        // Create FlutterPdfDocument wrapper with documentId and binaryMessenger
                        // for proper cleanup in closeDocument
                        val flutterPdfDocument = FlutterPdfDocument(pdfDocument, documentId, binaryMessenger)

                        // Register document in the global registry
                        FlutterPdfDocument.registerDocument(documentId, flutterPdfDocument)

                        // Setup PdfDocumentApi channel with documentId as suffix
                        PdfDocumentApi.setUp(binaryMessenger, flutterPdfDocument, documentId)

                        // Return document ID to Flutter
                        callback(Result.success(documentId))
                    },
                    { throwable ->
                        callback(
                            Result.failure(
                                NutrientApiError(
                                    "DocumentOpenError",
                                    "Failed to open document: ${throwable.message}",
                                    throwable.stackTraceToString()
                                )
                            )
                        )
                    }
                )
        } catch (e: Exception) {
            callback(
                Result.failure(
                    NutrientApiError(
                        "InvalidDocumentPath",
                        "Invalid document path: ${e.message}",
                        e.stackTraceToString()
                    )
                )
            )
        }
    }

    /**
     * Disposes of all resources held by this API implementation.
     * This should be called when the API is no longer needed.
     */
    fun dispose() {
        disposable?.dispose()
    }
}
