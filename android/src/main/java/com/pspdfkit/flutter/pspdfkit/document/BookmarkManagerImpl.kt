/*
 * Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit.document

import android.util.Log
import com.pspdfkit.bookmarks.Bookmark as NativeBookmark
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.api.Bookmark
import com.pspdfkit.flutter.pspdfkit.api.BookmarkManagerApi
import com.pspdfkit.flutter.pspdfkit.api.NutrientApiError
import com.pspdfkit.flutter.pspdfkit.util.runCatchingUnlessCancelled
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.json.JSONObject

/**
 * Implementation of the BookmarkManagerApi for managing PDF bookmarks on Android.
 *
 * This class bridges the Flutter bookmark API to the PSPDFKit Android SDK's
 * BookmarkProvider. It supports adding, removing, updating, and querying bookmarks.
 */
class BookmarkManagerImpl : BookmarkManagerApi {

    companion object {
        private const val TAG = "BookmarkManagerImpl"
    }

    private var documentId: String? = null
    private val scope = MainScope()

    private val pdfDocument: PdfDocument?
        get() {
            val docId = documentId ?: return null
            return FlutterPdfDocument.documentInstances[docId]?.pdfDocument
        }

    override fun initialize(documentId: String) {
        this.documentId = documentId
        Log.d(TAG, "Initialized BookmarkManager for document: $documentId")
    }

    override fun getBookmarks(callback: (Result<List<Bookmark>>) -> Unit) {
        val document = pdfDocument
        if (document == null) {
            callback(Result.failure(NutrientApiError("Document not found", "Document with ID $documentId not found")))
            return
        }

        scope.launch {
            val bookmarks = runCatchingUnlessCancelled { document.bookmarkProvider.getBookmarksAsync() }.getOrElse { error ->
                Log.e(TAG, "Error getting bookmarks", error)
                callback(Result.failure(NutrientApiError("Failed to get bookmarks", error.message ?: "")))
                return@launch
            }
            callback(Result.success(bookmarks.map { convertToBookmark(it) }))
        }
    }

    override fun addBookmark(bookmark: Bookmark, callback: (Result<Bookmark>) -> Unit) {
        val document = pdfDocument
        if (document == null) {
            callback(Result.failure(NutrientApiError("Document not found", "Document with ID $documentId not found")))
            return
        }

        try {
            val nativeBookmark = convertToNativeBookmark(bookmark)

            scope.launch {
                runCatchingUnlessCancelled { document.bookmarkProvider.addBookmarkAsync(nativeBookmark) }.getOrElse { error ->
                    Log.e(TAG, "Error adding bookmark", error)
                    callback(Result.failure(NutrientApiError("Failed to add bookmark", error.message ?: "")))
                    return@launch
                }
                // Return the bookmark with the ID assigned
                callback(Result.success(convertToBookmark(nativeBookmark)))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error creating bookmark", e)
            callback(Result.failure(NutrientApiError("Failed to create bookmark", e.message ?: "")))
        }
    }

    override fun removeBookmark(bookmark: Bookmark, callback: (Result<Boolean>) -> Unit) {
        val document = pdfDocument
        if (document == null) {
            callback(Result.failure(NutrientApiError("Document not found", "Document with ID $documentId not found")))
            return
        }

        scope.launch {
            val bookmarks = runCatchingUnlessCancelled { document.bookmarkProvider.getBookmarksAsync() }.getOrElse { error ->
                Log.e(TAG, "Error finding bookmark to remove", error)
                callback(Result.failure(NutrientApiError("Failed to find bookmark", error.message ?: "")))
                return@launch
            }

            // Find the bookmark to remove by matching page index or name
            val pageIndex = parsePageIndexFromAction(bookmark.actionJson)
            val bookmarkToRemove = bookmarks.find { existingBookmark ->
                // Match by page index
                if (pageIndex != null && existingBookmark.pageIndex == pageIndex) {
                    true
                } else {
                    // Fallback to name matching
                    bookmark.name != null && existingBookmark.name == bookmark.name
                }
            }
            if (bookmarkToRemove == null) {
                callback(Result.success(false))
                return@launch
            }

            runCatchingUnlessCancelled { document.bookmarkProvider.removeBookmarkAsync(bookmarkToRemove) }.getOrElse { error ->
                Log.e(TAG, "Error removing bookmark", error)
                callback(Result.failure(NutrientApiError("Failed to remove bookmark", error.message ?: "")))
                return@launch
            }
            callback(Result.success(true))
        }
    }

    override fun updateBookmark(bookmark: Bookmark, callback: (Result<Boolean>) -> Unit) {
        val document = pdfDocument
        if (document == null) {
            callback(Result.failure(NutrientApiError("Document not found", "Document with ID $documentId not found")))
            return
        }

        // PSPDFKit Android doesn't have a direct update method, so we remove and re-add
        removeBookmark(bookmark) { removeResult ->
            if (removeResult.isSuccess) {
                addBookmark(bookmark) { addResult ->
                    if (addResult.isSuccess) {
                        callback(Result.success(true))
                    } else {
                        callback(Result.failure(addResult.exceptionOrNull() ?: Exception("Failed to add updated bookmark")))
                    }
                }
            } else {
                // If remove failed (bookmark didn't exist), just add it
                addBookmark(bookmark) { addResult ->
                    if (addResult.isSuccess) {
                        callback(Result.success(true))
                    } else {
                        callback(Result.failure(addResult.exceptionOrNull() ?: Exception("Failed to add bookmark")))
                    }
                }
            }
        }
    }

    override fun getBookmarksForPage(pageIndex: Long, callback: (Result<List<Bookmark>>) -> Unit) {
        val document = pdfDocument
        if (document == null) {
            callback(Result.failure(NutrientApiError("Document not found", "Document with ID $documentId not found")))
            return
        }

        scope.launch {
            val bookmarks = runCatchingUnlessCancelled { document.bookmarkProvider.getBookmarksAsync() }.getOrElse { error ->
                Log.e(TAG, "Error getting bookmarks for page", error)
                callback(Result.failure(NutrientApiError("Failed to get bookmarks", error.message ?: "")))
                return@launch
            }
            val filteredBookmarks = bookmarks.filter { nativeBookmark ->
                nativeBookmark.pageIndex == pageIndex.toInt()
            }.map { convertToBookmark(it) }
            callback(Result.success(filteredBookmarks))
        }
    }

    override fun hasBookmarkForPage(pageIndex: Long, callback: (Result<Boolean>) -> Unit) {
        getBookmarksForPage(pageIndex) { result ->
            if (result.isSuccess) {
                val bookmarks = result.getOrNull() ?: emptyList()
                callback(Result.success(bookmarks.isNotEmpty()))
            } else {
                callback(Result.failure(result.exceptionOrNull() ?: Exception("Failed to check bookmark")))
            }
        }
    }

    /**
     * Convert a PSPDFKit NativeBookmark to Bookmark for Flutter.
     */
    private fun convertToBookmark(nativeBookmark: NativeBookmark): Bookmark {
        // Android SDK Bookmark uses pageIndex directly, not action
        val pageIndex = nativeBookmark.pageIndex
        val actionJson = if (pageIndex != null) {
            JSONObject().apply {
                put("type", "goTo")
                put("pageIndex", pageIndex)
                put("destinationType", "fitPage")
            }.toString()
        } else {
            null
        }

        return Bookmark(
            pdfBookmarkId = nativeBookmark.uuid, // Use UUID from Android SDK
            name = nativeBookmark.name,
            actionJson = actionJson
        )
    }

    /**
     * Convert Bookmark from Flutter to a PSPDFKit NativeBookmark.
     */
    private fun convertToNativeBookmark(bookmark: Bookmark): NativeBookmark {
        val pageIndex = parsePageIndexFromAction(bookmark.actionJson) ?: 0
        val name = bookmark.name ?: "Page ${pageIndex + 1}"

        // Android SDK Bookmark constructor takes name and pageIndex directly
        return NativeBookmark(name, pageIndex)
    }

    /**
     * Parse the page index from the action JSON.
     */
    private fun parsePageIndexFromAction(actionJson: String?): Int? {
        if (actionJson == null) return null

        return try {
            val json = JSONObject(actionJson)
            if (json.optString("type") == "goTo") {
                json.optInt("pageIndex", -1).takeIf { it >= 0 }
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing action JSON", e)
            null
        }
    }

    /**
     * Clean up resources.
     */
    fun dispose() {
        // Calls already in progress hold their document, so they still finish and reply.
        documentId = null
    }
}
