///  Copyright © 2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

package com.pspdfkit.flutter.pspdfkit.document

import com.pspdfkit.annotations.Annotation as PspdfkitAnnotation
import com.pspdfkit.annotations.*
import com.pspdfkit.annotations.AnnotationFlags
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.api.AnnotationManagerApi
import com.pspdfkit.flutter.pspdfkit.api.AnnotationProperties
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.UUID

class AnnotationManagerImpl(
    private val pdfDocument: PdfDocument,
) : AnnotationManagerApi {

    private val scope = CoroutineScope(Dispatchers.Main)
    override fun initialize(documentId: String) {

    }


    override fun getAnnotationProperties(
        pageIndex: Long,
        annotationId: String,
        callback: (Result<AnnotationProperties?>) -> Unit
    ) {
        scope.launch {
            try {
                val document = pdfDocument

                withContext(Dispatchers.IO) {
                    val annotations = document.annotationProvider
                        .getAnnotations(pageIndex.toInt())
                        .toList()

                    val annotation = annotations.firstOrNull {
                        it.uuid == annotationId || it.name == annotationId
                    }

                    if (annotation == null) {
                        callback(Result.success(null))
                        return@withContext
                    }

                    // Build AnnotationProperties from the annotation
                    val properties = AnnotationProperties(
                        annotationId = annotation.uuid,
                        pageIndex = pageIndex,
                        strokeColor = annotation.color.toLong(),
                        fillColor = annotation.fillColor.toLong(),
                        opacity = annotation.alpha.toDouble(),
                        lineWidth = annotation.borderWidth.toDouble(),
                        flags = getAnnotationFlags(annotation),
                        customData = null, // Custom data handling will be added later
                        contents = annotation.contents,
                        subject = annotation.subject,
                        creator = annotation.creator,
                        bbox = listOf(
                            annotation.boundingBox.left.toDouble(),
                            annotation.boundingBox.top.toDouble(),
                            annotation.boundingBox.width().toDouble(),
                            annotation.boundingBox.height().toDouble()
                        ),
                        note = getAnnotationNote(annotation),
                        inkLines = getInkLinesFromAnnotation(annotation),
                        fontName = getFontNameFromAnnotation(annotation),
                        fontSize = getFontSizeFromAnnotation(annotation),
                        iconName = getIconNameFromAnnotation(annotation)
                    )

                    callback(Result.success(properties))
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun saveAnnotationProperties(
        modifiedProperties: AnnotationProperties,
        callback: (Result<Boolean>) -> Unit
    ) {
        scope.launch {
            try {
                val document = pdfDocument
                val pageIndex = modifiedProperties.pageIndex.toInt()
                val annotationId = modifiedProperties.annotationId

                withContext(Dispatchers.IO) {
                    val annotations = document.annotationProvider
                        .getAnnotations(pageIndex.toInt())
                        .toList()

                    val annotation = annotations.firstOrNull {
                        it.uuid == annotationId || it.name == annotationId
                    } ?: throw Exception("Annotation not found")

                    // Update only the properties that are not null
                    modifiedProperties.strokeColor?.let {
                        annotation.color = it.toInt()
                    }
                    modifiedProperties.fillColor?.let {
                        annotation.fillColor = it.toInt()
                    }
                    modifiedProperties.opacity?.let {
                        annotation.alpha = it.toFloat()
                    }
                    modifiedProperties.lineWidth?.let {
                        annotation.borderWidth = it.toFloat()
                    }
                    modifiedProperties.contents?.let {
                        annotation.contents = it
                    }
                    modifiedProperties.subject?.let {
                        annotation.subject = it
                    }
                    modifiedProperties.creator?.let {
                        annotation.creator = it
                    }
                    // Custom data handling will be implemented later
                    modifiedProperties.flags?.let {
                        updateAnnotationFlags(annotation, it)
                    }
                    // Note handling will be implemented later

                    // Changes are automatically tracked by PSPDFKit

                    callback(Result.success(true))
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun getAnnotations(
        pageIndex: Long,
        annotationType: String,
        callback: (Result<Any>) -> Unit
    ) {
        scope.launch {
            try {
                val document = pdfDocument

                withContext(Dispatchers.IO) {
                    val annotations = document.annotationProvider
                        .getAnnotations(pageIndex.toInt())
                        .toList()

                    // Filter by type if specified
                    val filtered = if (annotationType != "all") {
                        annotations.filter { annotation ->
                            getAnnotationType(annotation) == annotationType
                        }
                    } else {
                        annotations
                    }

                    // Return as list of JSON strings (similar to FlutterPdfDocument)
                    val annotationJsonList = filtered.map { annotation ->
                        annotation.toInstantJson()
                    }

                    callback(Result.success(annotationJsonList))
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun addAnnotation(
        jsonAnnotation: String,
        jsonAttachment: String?,
        callback: (Result<String>) -> Unit
    ) {
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    // Parse and create the annotation
                    pdfDocument.annotationProvider.createAnnotationFromInstantJsonAsync(jsonAnnotation)
                        .subscribeOn(io.reactivex.rxjava3.schedulers.Schedulers.io())
                        .observeOn(io.reactivex.rxjava3.android.schedulers.AndroidSchedulers.mainThread())
                        .subscribe(
                            { annotation ->
                                // Return the annotation ID
                                val annotationId = annotation.uuid ?: annotation.name ?: UUID.randomUUID().toString()
                                callback(Result.success(annotationId))
                            },
                            { throwable ->
                                callback(Result.failure(Exception("Failed to add annotation: ${throwable.message}")))
                            }
                        )
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun removeAnnotation(
        pageIndex: Long,
        annotationId: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        scope.launch {
            try {

                withContext(Dispatchers.IO) {
                    val annotations = pdfDocument.annotationProvider
                        .getAnnotations(pageIndex.toInt())
                        .toList()

                    val annotation = annotations.firstOrNull {
                        it.uuid == annotationId || it.name == annotationId
                    }

                    if (annotation != null) {
                        pdfDocument.annotationProvider.removeAnnotationFromPage(annotation)
                        callback(Result.success(true))
                    } else {
                        callback(Result.success(false))
                    }
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun searchAnnotations(
        query: String,
        pageIndex: Long?,
        callback: (Result<Any>) -> Unit
    ) {
        scope.launch {
            try {

                withContext(Dispatchers.IO) {
                    val annotationJsonList = mutableListOf<String>()

                    val pages = if (pageIndex != null) {
                        listOf(pageIndex.toInt())
                    } else {
                        (0 until pdfDocument.pageCount).toList()
                    }

                    for (page in pages) {
                        val annotations = pdfDocument.annotationProvider
                            .getAnnotations(page)
                            .toList()

                        val matching = annotations.filter { annotation ->
                            annotation.contents?.contains(query, ignoreCase = true) == true ||
                            getAnnotationNote(annotation)?.contains(query, ignoreCase = true) == true ||
                            annotation.subject?.contains(query, ignoreCase = true) == true
                        }

                        matching.forEach { annotation ->
                            annotationJsonList.add(annotation.toInstantJson())
                        }
                    }

                    callback(Result.success(annotationJsonList))
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun exportXFDF(pageIndex: Long?, callback: (Result<String>) -> Unit) {
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val outputStream = java.io.ByteArrayOutputStream()

                    // If pageIndex is specified, export only annotations from that page
                    val annotationsToExport = if (pageIndex != null) {
                        pdfDocument.annotationProvider.getAnnotations(pageIndex.toInt()).toList()
                    } else {
                        // Export all annotations from all pages
                        emptyList()
                    }

                    com.pspdfkit.document.formatters.XfdfFormatter.writeXfdfAsync(
                        pdfDocument,
                        annotationsToExport,
                        emptyList(), // No form fields to export
                        outputStream
                    )
                        .subscribeOn(io.reactivex.rxjava3.schedulers.Schedulers.io())
                        .observeOn(io.reactivex.rxjava3.android.schedulers.AndroidSchedulers.mainThread())
                        .subscribe(
                            {
                                val xfdfString = outputStream.toString("UTF-8")
                                callback(Result.success(xfdfString))
                            },
                            { throwable ->
                                callback(Result.failure(Exception("Failed to export XFDF: ${throwable.message}")))
                            }
                        )
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun importXFDF(xfdfString: String, callback: (Result<Boolean>) -> Unit) {
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val dataProvider = com.pspdfkit.flutter.pspdfkit.util.DocumentJsonDataProvider(xfdfString)

                    com.pspdfkit.document.formatters.XfdfFormatter.parseXfdfAsync(pdfDocument, dataProvider)
                        .subscribeOn(io.reactivex.rxjava3.schedulers.Schedulers.io())
                        .observeOn(io.reactivex.rxjava3.android.schedulers.AndroidSchedulers.mainThread())
                        .subscribe(
                            { annotations ->
                                // Add parsed annotations to the document
                                for (annotation in annotations) {
                                    pdfDocument.annotationProvider.addAnnotationToPage(annotation)
                                }
                                callback(Result.success(true))
                            },
                            { throwable ->
                                callback(Result.failure(Exception("Failed to import XFDF: ${throwable.message}")))
                            }
                        )
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun getUnsavedAnnotations(callback: (Result<Any>) -> Unit) {
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val annotationJsonList = mutableListOf<String>()

                    for (pageIndex in 0 until pdfDocument.pageCount) {
                        val annotations = pdfDocument.annotationProvider
                            .getAnnotations(pageIndex)
                            .toList()

                        val unsaved = annotations.filter { annotation ->
                            annotation.isModified
                        }

                        unsaved.forEach { annotation ->
                            annotationJsonList.add(annotation.toInstantJson())
                        }
                    }

                    callback(Result.success(annotationJsonList))
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    private fun getAnnotationFlags(annotation: PspdfkitAnnotation): List<String> {
        val flags = mutableListOf<String>()
        val annotationFlags = annotation.flags

        // Check each flag and add to list if set
        if (annotationFlags.contains(AnnotationFlags.INVISIBLE)) {
            flags.add("invisible")
        }
        if (annotationFlags.contains(AnnotationFlags.HIDDEN)) {
            flags.add("hidden")
        }
        if (annotationFlags.contains(AnnotationFlags.PRINT)) {
            flags.add("print")
        }
        if (annotationFlags.contains(AnnotationFlags.NOZOOM)) {
            flags.add("noZoom")
        }
        if (annotationFlags.contains(AnnotationFlags.NOROTATE)) {
            flags.add("noRotate")
        }
        if (annotationFlags.contains(AnnotationFlags.NOVIEW)) {
            flags.add("noView")
        }
        if (annotationFlags.contains(AnnotationFlags.READONLY)) {
            flags.add("readOnly")
        }
        if (annotationFlags.contains(AnnotationFlags.LOCKED)) {
            flags.add("locked")
        }
        if (annotationFlags.contains(AnnotationFlags.TOGGLENOVIEW)) {
            flags.add("toggleNoView")
        }
        if (annotationFlags.contains(AnnotationFlags.LOCKEDCONTENTS)) {
            flags.add("lockedContents")
        }

        return flags
    }

    private fun updateAnnotationFlags(annotation: PspdfkitAnnotation, flags: List<String>) {
        val newFlags = mutableSetOf<AnnotationFlags>()

        // Convert string flags to AnnotationFlags enum
        for (flag in flags) {
            when (flag) {
                "invisible" -> newFlags.add(AnnotationFlags.INVISIBLE)
                "hidden" -> newFlags.add(AnnotationFlags.HIDDEN)
                "print" -> newFlags.add(AnnotationFlags.PRINT)
                "noZoom" -> newFlags.add(AnnotationFlags.NOZOOM)
                "noRotate" -> newFlags.add(AnnotationFlags.NOROTATE)
                "noView" -> newFlags.add(AnnotationFlags.NOVIEW)
                "readOnly" -> newFlags.add(AnnotationFlags.READONLY)
                "locked" -> newFlags.add(AnnotationFlags.LOCKED)
                "toggleNoView" -> newFlags.add(AnnotationFlags.TOGGLENOVIEW)
                "lockedContents" -> newFlags.add(AnnotationFlags.LOCKEDCONTENTS)
            }
        }

        // Set the new flags on the annotation
        annotation.flags = if (newFlags.isEmpty()) {
            java.util.EnumSet.noneOf(AnnotationFlags::class.java)
        } else {
            java.util.EnumSet.copyOf(newFlags)
        }
    }

    private fun getAnnotationType(annotation: PspdfkitAnnotation): String {
        return when (annotation) {
            is InkAnnotation -> "ink"
            is HighlightAnnotation -> "highlight"
            is SquareAnnotation -> "square"
            is CircleAnnotation -> "circle"
            is LineAnnotation -> "line"
            is NoteAnnotation -> "note"
            is FreeTextAnnotation -> "freeText"
            is StampAnnotation -> "stamp"
            is FileAnnotation -> "file"
            else -> "unknown"
        }
    }

    private fun getInkLinesFromAnnotation(annotation: PspdfkitAnnotation): List<List<List<Double>>>? {
        return if (annotation is InkAnnotation) {
            annotation.lines.map { line ->
                line.map { point ->
                    listOf(point.x.toDouble(), point.y.toDouble(), 1.0) // Default pressure
                }
            }
        } else {
            null
        }
    }

    private fun getFontNameFromAnnotation(annotation: PspdfkitAnnotation): String? {
        return if (annotation is FreeTextAnnotation) {
            try {
                annotation.fontName
            } catch (e: Exception) {
                null
            }
        } else {
            null
        }
    }

    private fun getFontSizeFromAnnotation(annotation: PspdfkitAnnotation): Double? {
        return if (annotation is FreeTextAnnotation) {
            try {
                annotation.textSize.toDouble()
            } catch (e: Exception) {
                null
            }
        } else {
            null
        }
    }

    private fun getIconNameFromAnnotation(annotation: PspdfkitAnnotation): String? {
        return if (annotation is NoteAnnotation) {
            annotation.iconName
        } else {
            null
        }
    }

    private fun getAnnotationNote(annotation: PspdfkitAnnotation): String? {
        return when (annotation) {
            is NoteAnnotation -> annotation.contents
            is FreeTextAnnotation -> annotation.contents
            else -> null
        }
    }
}