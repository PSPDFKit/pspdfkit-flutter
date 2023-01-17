@file:JvmName("Utilities")
package com.pspdfkit.flutter.pspdfkit.util

import android.net.Uri
import java.lang.NumberFormatException
import java.util.Locale

private const val FILE_SCHEME = "file:///"

/**
 * Adds file scheme [FILE_SCHEME] to a provided [documentPath] in case
 * it was missing. E.g: `/sdcard/Download/Document.pdf` becomes
 * `file:///sdcard/Download/Document.pdf`.
 */
fun addFileSchemeIfMissing(documentPath: String): String {
    var result = documentPath
    if (Uri.parse(result).scheme == null) {
        if (result.startsWith("/")) {
            result = documentPath.substring(1)
        }
        result = FILE_SCHEME + result
    }
    return result
}

fun areValidIndexes(value: String, selectedIndexes: MutableList<Int>): Boolean {
    val indexes = value.split(",").toTypedArray()
    try {
        for (index in indexes) {
            if (index.trim { it <= ' ' }.isEmpty()) continue
            selectedIndexes.add(index.trim { it <= ' ' }.toInt())
        }
    } catch (e: NumberFormatException) {
        return false
    }
    return true
}

/**
 * Returns `true` if the document path extension belongs an image document format supported by PSPDFKit for Flutter.
 * Supported extensions are png, jpg, jpeg, tiff and tiff.
 */
fun isImageDocument(documentPath: String): Boolean {
    var extension = ""
    val lastDot = documentPath.lastIndexOf('.')
    if (lastDot != -1) {
        extension = documentPath.substring(lastDot + 1).lowercase(Locale.getDefault())
    }
    return extension == "png" || 
    extension == "jpg" || 
    extension == "jpeg" || 
    extension == "tiff" || 
    extension == "tif"
}


