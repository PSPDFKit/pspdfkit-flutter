package com.pspdfkit.flutter.pspdfkit.util

import com.pspdfkit.document.providers.InputStreamDataProvider
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.nio.charset.StandardCharsets
import java.util.UUID

/** A small in-memory data provider for loading the Document instant JSON from a string.  */
class DocumentJsonDataProvider(annotationsJson: String) :
    InputStreamDataProvider() {
    private val annotationsJsonBytes: ByteArray = annotationsJson.toByteArray(StandardCharsets.UTF_8)
    private val uuid: UUID = UUID.nameUUIDFromBytes(annotationsJsonBytes)
    override fun openInputStream(): InputStream {
        return ByteArrayInputStream(annotationsJsonBytes)
    }

    override fun getSize(): Long {
        return annotationsJsonBytes.size.toLong()
    }

    override fun getUid(): String {
        return String.format("document-instant-json-%s", uuid.toString())
    }

    override fun getTitle(): String? {
        return null
    }
}
