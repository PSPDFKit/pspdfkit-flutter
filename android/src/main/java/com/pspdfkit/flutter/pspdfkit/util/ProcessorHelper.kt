package com.pspdfkit.flutter.pspdfkit.util

import com.pspdfkit.annotations.AnnotationType
import com.pspdfkit.document.DocumentPermissions
import com.pspdfkit.document.DocumentSaveOptions
import com.pspdfkit.document.PdfVersion
import com.pspdfkit.document.processor.PdfProcessorTask
import java.util.EnumSet

object ProcessorHelper {
    fun  extractSaveOptions( options: Map<String, Any>): DocumentSaveOptions {
        val password: String? = options["password"] as String?
        val permissionsList = options["permissions"]as List<String>??: emptyList()
        val incremental = options["incremental"] as Boolean? ?: false
        val pdfVersion = options["pdfVersion"] as String?
        val saveOptions = DocumentSaveOptions(
            password,
            extractPermissions(permissionsList ),
            incremental,
            extractPdfVersion(pdfVersion)
        )
        return saveOptions
    }

    private fun extractPermissions(permissions: List<String>): EnumSet<DocumentPermissions> {
        val documentPermissions = EnumSet.noneOf(DocumentPermissions::class.java)
        for (permission in permissions) {
            when (permission) {
                "printing" -> documentPermissions.add(DocumentPermissions.PRINTING)
                "annotationsAndForms" -> documentPermissions.add(DocumentPermissions.ANNOTATIONS_AND_FORMS)
                "extractAccessibility" -> documentPermissions.add(DocumentPermissions.EXTRACT_ACCESSIBILITY)
                "fillForms" -> documentPermissions.add(DocumentPermissions.FILL_FORMS)
                "extract" -> documentPermissions.add(DocumentPermissions.EXTRACT)
                "assemble" -> documentPermissions.add(DocumentPermissions.ASSEMBLE)
                "printHighQuality" -> documentPermissions.add(DocumentPermissions.PRINT_HIGH_QUALITY)
                "modification" -> documentPermissions.add(DocumentPermissions.MODIFICATION)
            }
        }
        return documentPermissions
    }

    private fun extractPdfVersion(pdfVersion: String?): PdfVersion? {
        return when (pdfVersion) {
            "pdf_1_0" -> PdfVersion.PDF_1_0
            "pdf_1_1" -> PdfVersion.PDF_1_1
            "pdf_1_2" -> PdfVersion.PDF_1_2
            "pdf_1_3" -> PdfVersion.PDF_1_3
            "pdf_1_4" -> PdfVersion.PDF_1_4
            "pdf_1_5" -> PdfVersion.PDF_1_5
            "pdf_1_6" -> PdfVersion.PDF_1_6
            "pdf_1_7" -> PdfVersion.PDF_1_7
            else -> null
        }
    }

    fun reversePdfVersion(pdfVersion: PdfVersion): String? {
        return when (pdfVersion) {
            PdfVersion.PDF_1_0 -> "pdf_1_0"
            PdfVersion.PDF_1_1 -> "pdf_1_1"
            PdfVersion.PDF_1_2 -> "pdf_1_2"
            PdfVersion.PDF_1_3 -> "pdf_1_3"
            PdfVersion.PDF_1_4 -> "pdf_1_4"
            PdfVersion.PDF_1_5 -> "pdf_1_5"
            PdfVersion.PDF_1_6 -> "pdf_1_6"
            PdfVersion.PDF_1_7 -> "pdf_1_7"
        }
    }



    fun reversePermissions(permissions: EnumSet<DocumentPermissions>): List<String> {
        val permissionsList = mutableListOf<String>()
        for (permission in permissions) {
            when (permission) {
                DocumentPermissions.PRINTING -> permissionsList.add("printing")
                DocumentPermissions.ANNOTATIONS_AND_FORMS -> permissionsList.add("annotationsAndForms")
                DocumentPermissions.EXTRACT_ACCESSIBILITY -> permissionsList.add("extractAccessibility")
                DocumentPermissions.FILL_FORMS -> permissionsList.add("fillForms")
                DocumentPermissions.EXTRACT -> permissionsList.add("extract")
                DocumentPermissions.ASSEMBLE -> permissionsList.add("assemble")
                DocumentPermissions.PRINT_HIGH_QUALITY -> permissionsList.add("printHighQuality")
                DocumentPermissions.MODIFICATION -> permissionsList.add("modification")
                else -> permissionsList.add("printing")
            }
        }
        return permissionsList
    }

    @JvmStatic
    fun annotationTypeFromString(annotationType: String): AnnotationType {
        return when (annotationType) {
            "freetext" -> AnnotationType.FREETEXT
            "note" -> AnnotationType.NOTE
            "highlight" -> AnnotationType.HIGHLIGHT
            "underline" -> AnnotationType.UNDERLINE
            "strikeout" -> AnnotationType.STRIKEOUT
            "ink" -> AnnotationType.INK
            "square" -> AnnotationType.SQUARE
            "circle" -> AnnotationType.CIRCLE
            "line" -> AnnotationType.LINE
            "polygon" -> AnnotationType.POLYGON
            "polyline" -> AnnotationType.POLYLINE
            "caret" -> AnnotationType.CARET
            "stamp" -> AnnotationType.STAMP
            "sound" -> AnnotationType.SOUND
            "file" -> AnnotationType.FILE
            "widget" -> AnnotationType.WIDGET
            "screen" -> AnnotationType.SCREEN
            "popup" -> AnnotationType.POPUP
            "watermark" -> AnnotationType.WATERMARK
            "redact" -> AnnotationType.REDACT
            else -> AnnotationType.NONE
        }
    }
    @JvmStatic
    fun processModeFromString(processMode: String): PdfProcessorTask.AnnotationProcessingMode {
        return when (processMode) {
            "flatten" -> PdfProcessorTask.AnnotationProcessingMode.FLATTEN
            "remove" -> PdfProcessorTask.AnnotationProcessingMode.DELETE
            "print" -> PdfProcessorTask.AnnotationProcessingMode.PRINT
            "embed" -> PdfProcessorTask.AnnotationProcessingMode.KEEP
            else -> throw IllegalArgumentException("Unknown process mode: $processMode")
        }
    }

}