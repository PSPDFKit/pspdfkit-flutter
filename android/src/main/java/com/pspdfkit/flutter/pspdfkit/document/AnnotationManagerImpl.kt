///  Copyright © 2025-2026 PSPDFKit GmbH. All rights reserved.
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
import org.json.JSONArray
import org.json.JSONObject
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
                        flagsJson = getAnnotationFlagsJson(annotation),
                        customDataJson = getCustomDataJsonFromAnnotation(annotation),
                        contents = annotation.contents,
                        subject = annotation.subject,
                        creator = annotation.creator,
                        bboxJson = getBboxJson(annotation),
                        note = getAnnotationNote(annotation),
                        inkLinesJson = getInkLinesJsonFromAnnotation(annotation),
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
                    modifiedProperties.customDataJson?.let { customDataJson ->
                        if (customDataJson.isNotEmpty()) {
                            annotation.customData = JSONObject(customDataJson)
                        }
                    }
                    modifiedProperties.flagsJson?.let { flagsJson ->
                        if (flagsJson.isNotEmpty()) {
                            val flags = decodeFlagsJson(flagsJson)
                            updateAnnotationFlags(annotation, flags)
                        }
                    }
                    modifiedProperties.bboxJson?.let { bboxJson ->
                        if (bboxJson.isNotEmpty()) {
                            val bbox = decodeBboxJson(bboxJson)
                            if (bbox.size >= 4) {
                                annotation.boundingBox = android.graphics.RectF(
                                    bbox[0].toFloat(),
                                    bbox[1].toFloat(),
                                    (bbox[0] + bbox[2]).toFloat(),
                                    (bbox[1] + bbox[3]).toFloat()
                                )
                            }
                        }
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

    override fun getAnnotationsJson(
        pageIndex: Long,
        annotationType: String,
        callback: (Result<String>) -> Unit
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

                    // Return as JSON array string
                    val jsonArray = JSONArray()
                    filtered.forEach { annotation ->
                        jsonArray.put(JSONObject(annotation.toInstantJson()))
                    }

                    callback(Result.success(jsonArray.toString()))
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

    override fun searchAnnotationsJson(
        query: String,
        pageIndex: Long?,
        callback: (Result<String>) -> Unit
    ) {
        scope.launch {
            try {

                withContext(Dispatchers.IO) {
                    val jsonArray = JSONArray()

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
                            jsonArray.put(JSONObject(annotation.toInstantJson()))
                        }
                    }

                    callback(Result.success(jsonArray.toString()))
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

    override fun getUnsavedAnnotationsJson(callback: (Result<String>) -> Unit) {
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val jsonArray = JSONArray()

                    for (pageIndex in 0 until pdfDocument.pageCount) {
                        val annotations = pdfDocument.annotationProvider
                            .getAnnotations(pageIndex)
                            .toList()

                        val unsaved = annotations.filter { annotation ->
                            annotation.isModified
                        }

                        unsaved.forEach { annotation ->
                            jsonArray.put(JSONObject(annotation.toInstantJson()))
                        }
                    }

                    callback(Result.success(jsonArray.toString()))
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    /**
     * Gets annotation flags and returns them as a JSON string array.
     */
    private fun getAnnotationFlagsJson(annotation: PspdfkitAnnotation): String {
        val flagsArray = JSONArray()
        val annotationFlags = annotation.flags

        // Check each flag and add to array if set
        if (annotationFlags.contains(AnnotationFlags.INVISIBLE)) {
            flagsArray.put("invisible")
        }
        if (annotationFlags.contains(AnnotationFlags.HIDDEN)) {
            flagsArray.put("hidden")
        }
        if (annotationFlags.contains(AnnotationFlags.PRINT)) {
            flagsArray.put("print")
        }
        if (annotationFlags.contains(AnnotationFlags.NOZOOM)) {
            flagsArray.put("noZoom")
        }
        if (annotationFlags.contains(AnnotationFlags.NOROTATE)) {
            flagsArray.put("noRotate")
        }
        if (annotationFlags.contains(AnnotationFlags.NOVIEW)) {
            flagsArray.put("noView")
        }
        if (annotationFlags.contains(AnnotationFlags.READONLY)) {
            flagsArray.put("readOnly")
        }
        if (annotationFlags.contains(AnnotationFlags.LOCKED)) {
            flagsArray.put("locked")
        }
        if (annotationFlags.contains(AnnotationFlags.TOGGLENOVIEW)) {
            flagsArray.put("toggleNoView")
        }
        if (annotationFlags.contains(AnnotationFlags.LOCKEDCONTENTS)) {
            flagsArray.put("lockedContents")
        }

        return flagsArray.toString()
    }

    /**
     * Decodes flags from JSON string array.
     */
    private fun decodeFlagsJson(json: String): List<String> {
        return try {
            val jsonArray = JSONArray(json)
            (0 until jsonArray.length()).map { jsonArray.getString(it) }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /**
     * Gets bounding box and returns it as a JSON string array [x, y, width, height].
     */
    private fun getBboxJson(annotation: PspdfkitAnnotation): String {
        val bboxArray = JSONArray()
        bboxArray.put(annotation.boundingBox.left.toDouble())
        bboxArray.put(annotation.boundingBox.top.toDouble())
        bboxArray.put(annotation.boundingBox.width().toDouble())
        bboxArray.put(annotation.boundingBox.height().toDouble())
        return bboxArray.toString()
    }

    /**
     * Decodes bbox from JSON string array.
     */
    private fun decodeBboxJson(json: String): List<Double> {
        return try {
            val jsonArray = JSONArray(json)
            (0 until jsonArray.length()).map { jsonArray.getDouble(it) }
        } catch (e: Exception) {
            emptyList()
        }
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
        // Return Instant JSON format type strings
        return when (annotation) {
            is InkAnnotation -> "pspdfkit/ink"
            is HighlightAnnotation -> "pspdfkit/markup/highlight"
            is UnderlineAnnotation -> "pspdfkit/markup/underline"
            is StrikeOutAnnotation -> "pspdfkit/markup/strikeout"
            is SquigglyAnnotation -> "pspdfkit/markup/squiggly"
            is SquareAnnotation -> "pspdfkit/shape/rectangle"
            is CircleAnnotation -> "pspdfkit/shape/ellipse"
            is LineAnnotation -> "pspdfkit/shape/line"
            is PolygonAnnotation -> "pspdfkit/shape/polygon"
            is PolylineAnnotation -> "pspdfkit/shape/polyline"
            is NoteAnnotation -> "pspdfkit/note"
            is FreeTextAnnotation -> "pspdfkit/text"
            is StampAnnotation -> "pspdfkit/stamp"
            is FileAnnotation -> "pspdfkit/file"
            is LinkAnnotation -> "pspdfkit/link"
            is RedactionAnnotation -> "pspdfkit/markup/redaction"
            is WidgetAnnotation -> "pspdfkit/widget"
            is SoundAnnotation -> "pspdfkit/sound"
            is ScreenAnnotation -> "pspdfkit/screen"
            is RichMediaAnnotation -> "pspdfkit/media"
            else -> "pspdfkit/undefined"
        }
    }

    /**
     * Gets ink lines from an InkAnnotation and returns them as a JSON string.
     * Format: [[[x, y, pressure], [x, y, pressure], ...], ...]
     */
    private fun getInkLinesJsonFromAnnotation(annotation: PspdfkitAnnotation): String? {
        return if (annotation is InkAnnotation) {
            val linesArray = JSONArray()
            annotation.lines.forEach { line ->
                val pointsArray = JSONArray()
                line.forEach { point ->
                    val pointArray = JSONArray()
                    pointArray.put(point.x.toDouble())
                    pointArray.put(point.y.toDouble())
                    pointArray.put(1.0) // pressure
                    pointsArray.put(pointArray)
                }
                linesArray.put(pointsArray)
            }
            linesArray.toString()
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

    /**
     * Gets custom data from an annotation and returns it as a JSON string.
     */
    private fun getCustomDataJsonFromAnnotation(annotation: PspdfkitAnnotation): String? {
        val customData = annotation.customData ?: return null
        return customData.toString()
    }

}