//
//  PspdfkitMeasurementConvertor.swift
//  pspdfkit_flutter
//
//  Created by Cato on 06/04/2023.
//

import Foundation
import PSPDFKit
import PSPDFKitUI

@objc(PspdfkitMeasurementConvertor)
public class PspdfkitMeasurementConvertor :NSObject{

    /**
     * Converts the string representation of a measurement scale to a MeasurementScale enum.
     *
     * @param measurement The string representation of a measurement scale.
     * @return The MeasurementScale enum.
     */
    @objc static public func convertScale(measurement:NSDictionary?) -> MeasurementScale?  {
        
        if (measurement == NSNull()){
            return nil
        }
        
        let valueFrom = measurement!["valueFrom"] as! Double
        let valueTo = measurement!["valueTo"] as! Double
        let unitFrom = measurement!["unitFrom"] as! String
        let unitTo = measurement!["unitTo"] as! String
        let fromUnits: UnitFrom
        
        switch unitFrom {
        case "inch":
            fromUnits = .inch
        case "cm":
            fromUnits = .centimeter
        case "mm":
            fromUnits = .millimeter
        case "pt":
            fromUnits = .point
        default:
            fromUnits = .centimeter
        }

        let toUnits: UnitTo
        
        switch unitTo {
        case "inch":
            toUnits = .inch
        case "cm":
            toUnits = .centimeter
        case "mm":
            toUnits = .millimeter
        case "m":
            toUnits = .meter
        case "km":
            toUnits = .kilometer
        case "yd":
            toUnits = .yard
        case "ft":
            toUnits = .foot
        case "mi":
            toUnits = .mile
        default:
            toUnits = .centimeter
        }

        return MeasurementScale(from: valueFrom, unitFrom: fromUnits, to: valueTo, unitTo: toUnits)
    }
    /**
     * Converts the string representation of a measurement precision to a MeasurementPrecision enum.
     *
     * @param precision The string representation of a measurement precision.
     * @return The MeasurementPrecision enum.
     */
    @objc public static func convertPrecision(precision: NSString?) -> MeasurementPrecision  {
        
        if(precision == NSNull()){
            return .twoDecimalPlaces
        }
        
        switch precision {
        case "oneDP":
            return .oneDecimalPlace
        case "twoDP":
            return .twoDecimalPlaces
        case "threeDP":
            return .threeDecimalPlaces
        case "fourDP":
            return .fourDecimalPlaces
        case "whole":
            return .whole
        default:
            return .twoDecimalPlaces
        }
    }
    
}
