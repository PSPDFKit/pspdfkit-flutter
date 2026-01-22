package com.pspdfkit.flutter.pspdfkit.util

import com.pspdfkit.document.providers.InputStreamDataProvider
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.util.UUID

/** A small in-memory data provider for loading binary data from a byte array.  */
class BinaryDataProvider(private val binaryData: ByteArray) :
    InputStreamDataProvider() {
    private val uuid: UUID = UUID.nameUUIDFromBytes(binaryData)

    override fun openInputStream(): InputStream {
        return ByteArrayInputStream(binaryData)
    }

    override fun getSize(): Long {
        return binaryData.size.toLong()
    }

    override fun getUid(): String {
        return String.format("binary-attachment-%s", uuid.toString())
    }

    override fun getTitle(): String? {
        return null
    }
}
