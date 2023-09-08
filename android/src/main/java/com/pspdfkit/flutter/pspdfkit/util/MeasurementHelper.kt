package com.pspdfkit.flutter.pspdfkit.util

import com.pspdfkit.annotations.measurements.MeasurementPrecision
import com.pspdfkit.annotations.measurements.Scale

class MeasurementHelper {

    companion object {

        /**
         * Converts the scale map to a [Scale] object.
         *
         * @param scale The scale map.
         * @return The [Scale] object.
         */
        @JvmStatic
        fun convertScale(scale: Map<String, Any>?): Scale? {

            if (scale == null) {
                return null
            }

            val fromValue: Double = requireNotNull(scale["valueFrom"] as Double)
            val toValue: Double = requireNotNull(scale["valueTo"] as Double)
            val unitFromValue: String = requireNotNull(scale["unitFrom"] as String)
            val unitToValue: String = requireNotNull(scale["unitTo"] as String)

            val unitFrom: Scale.UnitFrom = when (unitFromValue) {
                "cm" -> Scale.UnitFrom.CM
                "inch" -> Scale.UnitFrom.IN
                "pt" -> Scale.UnitFrom.PT
                "mm" -> Scale.UnitFrom.MM
                else -> Scale.UnitFrom.CM
            }

            val unitTo: Scale.UnitTo = when (unitToValue) {
                "cm" -> Scale.UnitTo.CM
                "inch" -> Scale.UnitTo.IN
                "pt" -> Scale.UnitTo.PT
                "m" -> Scale.UnitTo.M
                "ft" -> Scale.UnitTo.FT
                "mm" -> Scale.UnitTo.MM
                "km" -> Scale.UnitTo.KM
                "mi" -> Scale.UnitTo.MI
                "yd" -> Scale.UnitTo.YD
                else -> Scale.UnitTo.CM
            }
            return Scale(fromValue.toFloat(), unitFrom, toValue.toFloat(), unitTo)
        }
        /**
         * Converts the precision string to a [MeasurementPrecision] object.
         *
         * @param precision The precision string.
         * @return The [MeasurementPrecision] object.
         */
        @JvmStatic
        fun convertPrecision(precision: String?): MeasurementPrecision? {
            if (precision == null) {
                return null
            }
            val measurementPrecision = when (precision) {
                "oneDP" -> MeasurementPrecision.ONE_DP
                "twoDP" -> MeasurementPrecision.TWO_DP
                "threeDP" -> MeasurementPrecision.THREE_DP
                "fourDP" -> MeasurementPrecision.FOUR_DP
                "whole" -> MeasurementPrecision.WHOLE
                else -> MeasurementPrecision.TWO_DP
            }
            return measurementPrecision
        }
    }
}