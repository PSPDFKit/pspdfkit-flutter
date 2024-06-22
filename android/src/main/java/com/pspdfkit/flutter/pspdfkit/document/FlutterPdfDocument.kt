package com.pspdfkit.flutter.pspdfkit.document

import android.util.Log
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.flutter.pspdfkit.PSPDFKitView
import com.pspdfkit.flutter.pspdfkit.forms.FormHelper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File

class FlutterPdfDocument(
    private val pdfDocument: PdfDocument, messenger: BinaryMessenger,
) : MethodCallHandler {
    init {
        val channel = MethodChannel(messenger, "com.pspdfkit.document.${pdfDocument.uid}")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPageInfo" -> {
                val pageIndex = call.argument<Int>("pageIndex") ?: -1
                if (pageIndex < 0 || pageIndex >= pdfDocument.pageCount) {
                    result.error("InvalidArgument", "pageIndex is required", null)
                } else {
                    try {
                        val pageInfo = getPageInfo(pageIndex)
                        result.success(pageInfo)
                    } catch (e: Exception) {
                        result.error("Error", e.message, null)
                    }
                }
            }
            "getFormFields" -> {
                try {
                    val formFields = pdfDocument.formProvider.formFields
                    val formFieldsMap = FormHelper.formFieldPropertiesToMap(formFields)
                    result.success(formFieldsMap)
                } catch (e: Exception) {
                    result.error("Error", e.message, null)
                }
            }
            "exportPdf" -> {
                try {
                    val fileUrl = pdfDocument.documentSource.fileUri?.path
                    if (fileUrl == null) {
                        result.error("DocumentException", "Document source is not a file", null)
                        return
                    }
                    val data:ByteArray = fileUrl.let { File(it).readBytes() }
                    result.success(data)
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "Error while exporting PDF", e)
                    result.error("DocumentException", e.message, null)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getPageInfo(pageIndex: Int): Map<String, Any?> {
        val pageInfo = mapOf(
            "width" to pdfDocument.getPageSize(pageIndex).width,
            "height" to pdfDocument.getPageSize(pageIndex).height,
            "label" to pdfDocument.getPageLabel(pageIndex, false),
            "index" to pageIndex,
            "rotation" to pdfDocument.getPageRotation(pageIndex)
        )
        return pageInfo
    }

    companion object {
        const val LOG_TAG = "FlutterPdfDocument"
    }
}