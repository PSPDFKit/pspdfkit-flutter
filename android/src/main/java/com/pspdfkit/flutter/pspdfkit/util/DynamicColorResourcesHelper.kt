/*
 * Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
 *
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit.util

import android.app.Activity
import android.content.Context
import android.content.res.loader.ResourcesLoader
import android.content.res.loader.ResourcesProvider
import android.os.Build
import android.os.ParcelFileDescriptor
import android.system.Os
import android.util.Log
import android.view.ContextThemeWrapper
import androidx.annotation.RequiresApi
import io.nutrient.nutrient_flutter.R
import java.io.ByteArrayOutputStream
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Helper for dynamically overriding color resources at runtime.
 *
 * On API 30+, uses [ResourcesLoader] to inject a color value into the
 * resource table, allowing theme attributes that reference
 * `@color/nutrient_flutter_dynamic_bg` to resolve to the runtime value.
 *
 * On API 24-29, falls back to a quantized palette of predefined styles.
 *
 * Approach inspired by Material Components' ColorResourcesTableCreator.
 */
object DynamicColorResourcesHelper {

    private const val TAG = "DynamicColorResHelper"

    /**
     * Creates a themed context with `pspdf__backgroundColor` set to [bgColor].
     *
     * @param base The base context to wrap
     * @param bgColor The ARGB color value for the viewport background
     * @return A [ContextThemeWrapper] with the appropriate theme overlay
     */
    fun createThemedContext(base: Context, bgColor: Int): Context {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            createDynamicThemedContext(base, bgColor)
        } else {
            createFallbackThemedContext(base, bgColor)
        }
    }

    /**
     * Applies the theme overlay directly to the Activity's theme.
     * This is necessary because PSPDFKit's PdfFragment resolves `pspdf__backgroundColor`
     * from the Activity's context, not from the fragment's inflater context.
     *
     * On API 30+, injects a [ResourcesLoader] to override the color resource,
     * then applies the style overlay to the Activity's theme.
     * On API 24-29, applies the closest quantized palette style.
     *
     * @param activity The Activity whose theme to modify
     * @param bgColor The ARGB color value for the viewport background
     */
    fun applyToActivityTheme(activity: Activity, bgColor: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            applyDynamicToActivity(activity, bgColor)
        } else {
            applyFallbackToActivity(activity, bgColor)
        }
    }

    @RequiresApi(Build.VERSION_CODES.R)
    private fun applyDynamicToActivity(activity: Activity, bgColor: Int) {
        try {
            val colorResId = R.color.nutrient_flutter_dynamic_bg
            val loader = createColorResourcesLoader(activity, colorResId, bgColor)
            if (loader != null) {
                activity.resources.addLoaders(loader)
                activity.theme.applyStyle(R.style.NutrientFlutter_DynamicTheme, true)
                Log.d(TAG, "Applied dynamic background to Activity theme: ${String.format("#%08X", bgColor)}")
                return
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to apply dynamic theme to Activity, falling back", e)
        }
        applyFallbackToActivity(activity, bgColor)
    }

    private fun applyFallbackToActivity(activity: Activity, bgColor: Int) {
        val styleResId = getClosestPaletteStyle(bgColor)
        activity.theme.applyStyle(styleResId, true)
        Log.d(TAG, "Applied quantized palette style to Activity theme")
    }

    private fun getClosestPaletteStyle(bgColor: Int): Int {
        val luminance = luminance(bgColor)
        return when {
            luminance > 0.95f -> R.style.NutrientFlutter_Bg_White
            luminance > 0.8f  -> R.style.NutrientFlutter_Bg_LightGray
            luminance > 0.4f  -> R.style.NutrientFlutter_Bg_Gray
            luminance > 0.15f -> R.style.NutrientFlutter_Bg_DarkGray
            luminance > 0.06f -> R.style.NutrientFlutter_Bg_VeryDark
            luminance > 0.02f -> R.style.NutrientFlutter_Bg_NearBlack
            else              -> R.style.NutrientFlutter_Bg_Black
        }
    }

    /**
     * API 30+: Dynamically override the placeholder color resource and apply the theme.
     */
    @RequiresApi(Build.VERSION_CODES.R)
    private fun createDynamicThemedContext(base: Context, bgColor: Int): Context {
        try {
            val wrapper = ContextThemeWrapper(base, R.style.NutrientFlutter_DynamicTheme)

            val colorResId = R.color.nutrient_flutter_dynamic_bg
            val loader = createColorResourcesLoader(base, colorResId, bgColor)
            if (loader != null) {
                wrapper.resources.addLoaders(loader)
                Log.d(TAG, "Applied dynamic background color via ResourcesLoader: ${String.format("#%08X", bgColor)}")
                return wrapper
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to create dynamic themed context, falling back to palette", e)
        }
        return createFallbackThemedContext(base, bgColor)
    }

    /**
     * API 24-29: Select the closest pre-defined style from the quantized palette.
     */
    private fun createFallbackThemedContext(base: Context, bgColor: Int): Context {
        val luminance = luminance(bgColor)
        val styleResId = when {
            luminance > 0.95f -> R.style.NutrientFlutter_Bg_White
            luminance > 0.8f  -> R.style.NutrientFlutter_Bg_LightGray
            luminance > 0.4f  -> R.style.NutrientFlutter_Bg_Gray
            luminance > 0.15f -> R.style.NutrientFlutter_Bg_DarkGray
            luminance > 0.06f -> R.style.NutrientFlutter_Bg_VeryDark
            luminance > 0.02f -> R.style.NutrientFlutter_Bg_NearBlack
            else              -> R.style.NutrientFlutter_Bg_Black
        }
        Log.d(TAG, "Using quantized palette style for luminance $luminance")
        return ContextThemeWrapper(base, styleResId)
    }

    /**
     * Creates a [ResourcesLoader] that overrides a single color resource.
     *
     * Constructs a minimal binary `resources.arsc` table in memory containing
     * just the one color entry, then loads it via [ResourcesProvider].
     */
    @RequiresApi(Build.VERSION_CODES.R)
    private fun createColorResourcesLoader(
        context: Context,
        colorResId: Int,
        colorValue: Int
    ): ResourcesLoader? {
        try {
            val packageName = context.resources.getResourcePackageName(colorResId)
            val entryName = context.resources.getResourceEntryName(colorResId)
            val typeName = context.resources.getResourceTypeName(colorResId)
            val packageId = (colorResId shr 24) and 0xFF
            val typeId = ((colorResId shr 16) and 0xFF)
            val entryId = colorResId and 0xFFFF

            val tableBytes = buildColorResourceTable(
                packageName = packageName,
                packageId = packageId,
                typeName = typeName,
                typeId = typeId,
                entryName = entryName,
                entryId = entryId,
                colorValue = colorValue
            )

            val fd = Os.memfd_create("nutrient_colors.arsc", 0)
            FileOutputStream(fd).use { it.write(tableBytes) }
            val pfd = ParcelFileDescriptor.dup(fd)
            Os.close(fd)

            val loader = ResourcesLoader()
            loader.addProvider(ResourcesProvider.loadFromTable(pfd, null))
            pfd.close()
            return loader
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create color ResourcesLoader", e)
            return null
        }
    }

    /**
     * Builds a minimal binary resources.arsc table with a single color entry.
     *
     * The binary format follows Android's ResourceTypes.h specification:
     * ResTable_header -> ResStringPool -> ResTable_package -> TypeSpec -> Type
     */
    private fun buildColorResourceTable(
        packageName: String,
        packageId: Int,
        typeName: String,
        typeId: Int,
        entryName: String,
        entryId: Int,
        colorValue: Int
    ): ByteArray {
        val out = ByteArrayOutputStream()

        // === Build string pools ===
        // Global string pool (empty - we use entry-level values)
        val globalStringPool = buildStringPool(emptyList())

        // Type string pool: just the type name (e.g., "color")
        val typeStringPool = buildStringPool(listOf(typeName))

        // Key string pool: just the entry name (e.g., "nutrient_flutter_dynamic_bg")
        val keyStringPool = buildStringPool(listOf(entryName))

        // === Build TypeSpec chunk ===
        val typeSpecChunk = buildTypeSpecChunk(typeId, entryId)

        // === Build Type chunk with the color entry ===
        val typeChunk = buildTypeChunk(typeId, entryId, colorValue)

        // === Build Package chunk ===
        val packageChunkPayload = ByteArrayOutputStream()
        packageChunkPayload.write(typeStringPool)
        packageChunkPayload.write(keyStringPool)
        packageChunkPayload.write(typeSpecChunk)
        packageChunkPayload.write(typeChunk)

        val packageChunk = buildPackageChunk(
            packageId,
            packageName,
            typeStringPool.size,
            keyStringPool.size,
            packageChunkPayload.toByteArray()
        )

        // === Build ResTable header ===
        val totalSize = 12 + globalStringPool.size + packageChunk.size
        // ResTable_header: type(2) + headerSize(2) + size(4) + packageCount(4)
        out.write(shortToBytes(0x0002)) // RES_TABLE_TYPE
        out.write(shortToBytes(12))     // header size
        out.write(intToBytes(totalSize))
        out.write(intToBytes(1))        // package count

        out.write(globalStringPool)
        out.write(packageChunk)

        return out.toByteArray()
    }

    /**
     * Builds a ResStringPool chunk.
     */
    private fun buildStringPool(strings: List<String>): ByteArray {
        if (strings.isEmpty()) {
            // Empty string pool: header + 0 strings
            val headerSize = 28
            val chunk = ByteArrayOutputStream()
            chunk.write(shortToBytes(0x0001)) // RES_STRING_POOL_TYPE
            chunk.write(shortToBytes(headerSize))
            chunk.write(intToBytes(headerSize)) // total size (just the header)
            chunk.write(intToBytes(0)) // string count
            chunk.write(intToBytes(0)) // style count
            chunk.write(intToBytes(1 shl 8)) // flags: UTF-8
            chunk.write(intToBytes(0)) // strings start (relative to header)
            chunk.write(intToBytes(0)) // styles start
            return chunk.toByteArray()
        }

        val headerSize = 28
        val stringOffsets = mutableListOf<Int>()
        val stringData = ByteArrayOutputStream()

        for (str in strings) {
            stringOffsets.add(stringData.size())
            val utf8Bytes = str.toByteArray(Charsets.UTF_8)
            // UTF-8 format: charCount(1-2 bytes) + byteCount(1-2 bytes) + data + null
            stringData.write(encodeUtf8Length(str.length))
            stringData.write(encodeUtf8Length(utf8Bytes.size))
            stringData.write(utf8Bytes)
            stringData.write(0) // null terminator
        }

        val offsetsSize = strings.size * 4
        val stringsStart = headerSize + offsetsSize
        val totalSize = stringsStart + stringData.size()

        val chunk = ByteArrayOutputStream()
        chunk.write(shortToBytes(0x0001)) // RES_STRING_POOL_TYPE
        chunk.write(shortToBytes(headerSize))
        chunk.write(intToBytes(totalSize))
        chunk.write(intToBytes(strings.size)) // string count
        chunk.write(intToBytes(0))            // style count
        chunk.write(intToBytes(1 shl 8))      // flags: UTF-8
        chunk.write(intToBytes(stringsStart))  // strings start (relative to chunk start, after header + offsets)
        chunk.write(intToBytes(0))            // styles start

        // String offsets
        for (offset in stringOffsets) {
            chunk.write(intToBytes(offset))
        }

        // String data
        chunk.write(stringData.toByteArray())

        // Pad to 4-byte boundary
        val padding = (4 - (totalSize % 4)) % 4
        for (i in 0 until padding) {
            chunk.write(0)
        }

        // Re-calculate with padding
        val paddedTotal = totalSize + padding
        val result = chunk.toByteArray()
        // Patch the total size
        val buf = ByteBuffer.wrap(result).order(ByteOrder.LITTLE_ENDIAN)
        buf.putInt(4, paddedTotal)
        return result
    }

    /**
     * Builds a ResTable_typeSpec chunk.
     */
    private fun buildTypeSpecChunk(typeId: Int, entryId: Int): ByteArray {
        val headerSize = 8
        val entryCount = entryId + 1
        val totalSize = headerSize + entryCount * 4

        val chunk = ByteArrayOutputStream()
        chunk.write(shortToBytes(0x0202)) // RES_TABLE_TYPE_SPEC_TYPE
        chunk.write(shortToBytes(headerSize))
        chunk.write(intToBytes(totalSize))
        // id(1) + reserved0(1) + reserved1(2) are packed into the header
        // But actually typeSpec header is 8 bytes: type(2)+headerSize(2)+size(4)
        // Then: id(1)+res0(1)+res1(2)+entryCount(4)
        // Total header = 16 bytes
        // Let me fix this...
        return buildTypeSpecChunkCorrect(typeId, entryId)
    }

    private fun buildTypeSpecChunkCorrect(typeId: Int, entryId: Int): ByteArray {
        val headerSize = 16 // ResTable_typeSpec header
        val entryCount = entryId + 1
        val totalSize = headerSize + entryCount * 4

        val chunk = ByteArrayOutputStream()
        chunk.write(shortToBytes(0x0202)) // RES_TABLE_TYPE_SPEC_TYPE
        chunk.write(shortToBytes(headerSize))
        chunk.write(intToBytes(totalSize))
        chunk.write(byteArrayOf(typeId.toByte())) // id
        chunk.write(byteArrayOf(0))               // res0
        chunk.write(shortToBytes(0))              // res1
        chunk.write(intToBytes(entryCount))

        // Config flags for each entry (0 = no special config)
        for (i in 0 until entryCount) {
            chunk.write(intToBytes(0))
        }

        return chunk.toByteArray()
    }

    /**
     * Builds a ResTable_type chunk with one color entry.
     */
    private fun buildTypeChunk(typeId: Int, entryId: Int, colorValue: Int): ByteArray {
        val entryCount = entryId + 1
        // ResTable_type header: type(2)+headerSize(2)+size(4)+id(1)+flags(1)+reserved(2)+entryCount(4)+entriesStart(4)+config(variable)
        // Minimum config size is 64 bytes (ResTable_config)
        val configSize = 64
        val headerSize = 20 + configSize // 20 bytes of header fields + config

        // Entry offsets table
        val offsetsSize = entryCount * 4

        // Entries data: only the last entry (at entryId) has data, others are NO_ENTRY (-1)
        // ResTable_entry: size(2)+flags(2)+key(4) = 8 bytes
        // Res_value: size(2)+res0(1)+dataType(1)+data(4) = 8 bytes
        val entrySize = 8 + 8 // entry header + value

        val entriesStart = headerSize + offsetsSize
        val totalSize = entriesStart + entrySize

        val chunk = ByteArrayOutputStream()
        // Header
        chunk.write(shortToBytes(0x0201)) // RES_TABLE_TYPE_TYPE
        chunk.write(shortToBytes(headerSize))
        chunk.write(intToBytes(totalSize))
        chunk.write(byteArrayOf(typeId.toByte())) // id
        chunk.write(byteArrayOf(0))               // flags
        chunk.write(shortToBytes(0))              // reserved
        chunk.write(intToBytes(entryCount))
        chunk.write(intToBytes(entriesStart))

        // ResTable_config (64 bytes of zeros = default config)
        chunk.write(intToBytes(configSize)) // config.size
        for (i in 0 until configSize - 4) {
            chunk.write(0)
        }

        // Entry offsets - NO_ENTRY for all except our entry
        for (i in 0 until entryCount) {
            if (i == entryId) {
                chunk.write(intToBytes(0)) // offset 0 from entries start
            } else {
                chunk.write(intToBytes(-1)) // NO_ENTRY
            }
        }

        // The actual entry
        // ResTable_entry
        chunk.write(shortToBytes(8))  // size
        chunk.write(shortToBytes(0))  // flags
        chunk.write(intToBytes(0))    // key index in key string pool

        // Res_value
        chunk.write(shortToBytes(8))         // size
        chunk.write(byteArrayOf(0))          // res0
        chunk.write(byteArrayOf(0x1C.toByte())) // dataType: TYPE_INT_COLOR_ARGB8 = 0x1C
        chunk.write(intToBytes(colorValue))  // data: the actual color

        return chunk.toByteArray()
    }

    /**
     * Builds a ResTable_package chunk.
     */
    private fun buildPackageChunk(
        packageId: Int,
        packageName: String,
        typeStringPoolSize: Int,
        keyStringPoolSize: Int,
        payload: ByteArray
    ): ByteArray {
        // Package header: type(2)+headerSize(2)+size(4)+id(4)+name(256)+typeStrings(4)+lastPublicType(4)+keyStrings(4)+lastPublicKey(4)
        val headerSize = 288
        val totalSize = headerSize + payload.size

        val chunk = ByteArrayOutputStream()
        chunk.write(shortToBytes(0x0200)) // RES_TABLE_PACKAGE_TYPE
        chunk.write(shortToBytes(headerSize))
        chunk.write(intToBytes(totalSize))
        chunk.write(intToBytes(packageId))

        // Package name as UTF-16 (128 chars = 256 bytes)
        val nameBytes = ByteArray(256)
        val nameUtf16 = packageName.toByteArray(Charsets.UTF_16LE)
        System.arraycopy(nameUtf16, 0, nameBytes, 0, minOf(nameUtf16.size, 254))
        chunk.write(nameBytes)

        chunk.write(intToBytes(headerSize))                         // typeStrings offset (relative to chunk start)
        chunk.write(intToBytes(0))                                  // lastPublicType
        chunk.write(intToBytes(headerSize + typeStringPoolSize))    // keyStrings offset
        chunk.write(intToBytes(0))                                  // lastPublicKey

        chunk.write(payload)

        return chunk.toByteArray()
    }

    // === Utility methods ===

    private fun luminance(color: Int): Float {
        val r = ((color shr 16) and 0xFF) / 255f
        val g = ((color shr 8) and 0xFF) / 255f
        val b = (color and 0xFF) / 255f
        return 0.2126f * r + 0.7152f * g + 0.0722f * b
    }

    private fun shortToBytes(value: Int): ByteArray {
        return byteArrayOf(
            (value and 0xFF).toByte(),
            ((value shr 8) and 0xFF).toByte()
        )
    }

    private fun intToBytes(value: Int): ByteArray {
        return byteArrayOf(
            (value and 0xFF).toByte(),
            ((value shr 8) and 0xFF).toByte(),
            ((value shr 16) and 0xFF).toByte(),
            ((value shr 24) and 0xFF).toByte()
        )
    }

    private fun encodeUtf8Length(length: Int): ByteArray {
        return if (length > 0x7F) {
            byteArrayOf(
                ((length shr 8) or 0x80).toByte(),
                (length and 0xFF).toByte()
            )
        } else {
            byteArrayOf(length.toByte())
        }
    }
}
