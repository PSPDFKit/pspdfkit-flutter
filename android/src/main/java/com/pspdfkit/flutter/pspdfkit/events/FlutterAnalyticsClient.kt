package com.pspdfkit.flutter.pspdfkit.events

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import com.pspdfkit.analytics.AnalyticsClient
import com.pspdfkit.flutter.pspdfkit.api.AnalyticsEventsCallback

class FlutterAnalyticsClient(private var eventsCallback: AnalyticsEventsCallback): AnalyticsClient {

    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onEvent(event: String, bundle: Bundle?) {
        mainHandler.post {
            if (bundle != null) {
                val map = bundleToMap(bundle)
                eventsCallback.onEvent(event, map){}
            } else {
                eventsCallback.onEvent(event, null){}
            }
        }
    }

    private fun bundleToMap(bundle: Bundle): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        for (key in bundle.keySet()) {
            val value = when (val obj = bundle.get(key)) {
                // Basic types supported by Flutter
                is String -> obj
                is Boolean -> obj
                is Int -> obj.toLong() // Convert to Long for consistency
                is Long -> obj
                is Float -> obj.toDouble() // Convert to Double for consistency
                is Double -> obj
                
                // Arrays - convert to List
                is BooleanArray -> obj.toList()
                is IntArray -> obj.map { it.toLong() }
                is LongArray -> obj.toList()
                is FloatArray -> obj.map { it.toDouble() }
                is DoubleArray -> obj.toList()
                is Array<*> -> obj.map { convertToFlutterType(it) }
                
                // Nested structures
                is Bundle -> bundleToMap(obj)
                is List<*> -> obj.map { convertToFlutterType(it) }
                is Map<*, *> -> obj.entries.associate { 
                    it.key.toString() to convertToFlutterType(it.value)
                }
                
                // Convert unsupported types to string representation
                else -> obj?.toString()
            }
            if (value != null) {
                map[key] = value
            }
        }
        return map
    }

    private fun convertToFlutterType(value: Any?): Any? {
        return when (value) {
            // Basic types supported by Flutter
            is String, is Boolean, is Long, is Double -> value
            // Convert to supported number types
            is Int -> value.toLong()
            is Float -> value.toDouble()
            is Short -> value.toLong()
            is Byte -> value.toLong()
            is Char -> value.toString()
            
            // Arrays and Collections
            is BooleanArray -> value.toList()
            is IntArray -> value.map { it.toLong() }
            is LongArray -> value.toList()
            is FloatArray -> value.map { it.toDouble() }
            is DoubleArray -> value.toList()
            is Array<*> -> value.map { convertToFlutterType(it) }
            is List<*> -> value.map { convertToFlutterType(it) }
            is Map<*, *> -> value.entries.associate { 
                it.key.toString() to convertToFlutterType(it.value)
            }
            
            // Nested Bundle
            is Bundle -> bundleToMap(value)
            
            // Convert unsupported types to string
            else -> value?.toString()
        }
    }
}