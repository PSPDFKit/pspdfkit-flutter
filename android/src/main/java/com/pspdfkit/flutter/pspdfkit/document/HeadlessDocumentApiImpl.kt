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
import com.pspdfkit.flutter.pspdfkit.api.BookmarkManagerApi
import com.pspdfkit.flutter.pspdfkit.api.HeadlessDocumentApi
import com.pspdfkit.flutter.pspdfkit.api.HeadlessDocumentOpenOptions
import com.pspdfkit.flutter.pspdfkit.api.NutrientApiError
import com.pspdfkit.flutter.pspdfkit.api.PdfDocumentApi
import com.pspdfkit.flutter.pspdfkit.util.runCatchingUnlessCancelled
import io.flutter.plugin.common.BinaryMessenger
import java.util.UUID
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.launch

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

    private val scope = MainScope()

    /**
     * Opens a document from the given path without displaying a viewer.
     *
     * This method loads a PDF document using PdfDocumentLoader and registers it with
     * a unique document ID. A PdfDocumentApi channel is set up for the document using
     * the document ID as a channel suffix, allowing Flutter to communicate with this
     * specific document instance. A BookmarkManagerApi channel is set up alongside it,
     * using "<documentId>_bookmark_manager" as the suffix.
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

            // Load document asynchronously; the SDK loads it off the main thread.
            scope.launch {
                val pdfDocument = runCatchingUnlessCancelled {
                    PdfDocumentLoader.openDocumentAsync(context, documentSource)
                }.getOrElse { throwable ->
                    callback(
                        Result.failure(
                            NutrientApiError(
                                "DocumentOpenError",
                                "Failed to open document: ${throwable.message}",
                                throwable.stackTraceToString()
                            )
                        )
                    )
                    return@launch
                }

                // Generate unique document ID
                val documentId = UUID.randomUUID().toString()

                // The bookmark manager looks the document up in the registry by ID,
                // so it can be created before the document is registered.
                val bookmarkManager = BookmarkManagerImpl()
                bookmarkManager.initialize(documentId)

                // Create FlutterPdfDocument wrapper with documentId, binaryMessenger and
                // bookmarkManager for proper cleanup in closeDocument
                val flutterPdfDocument = FlutterPdfDocument(pdfDocument, documentId, binaryMessenger, bookmarkManager)

                // Register document in the global registry
                FlutterPdfDocument.registerDocument(documentId, flutterPdfDocument)

                // Setup PdfDocumentApi channel with documentId as suffix
                PdfDocumentApi.setUp(binaryMessenger, flutterPdfDocument, documentId)

                // Setup BookmarkManagerApi with the same suffix the Dart side uses
                BookmarkManagerApi.setUp(binaryMessenger, bookmarkManager, "${documentId}_bookmark_manager")

                // Return document ID to Flutter
                callback(Result.success(documentId))
            }
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
        // Cancels the loads in progress, and leaves the scope usable.
        scope.coroutineContext.cancelChildren()
    }
}
