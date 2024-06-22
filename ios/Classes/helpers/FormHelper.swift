//
//  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation

@objc(FormHelper)
public class FormHelper: NSObject {
    
    @objc public static func convertFormFields(formFields: Array<FormElement>) -> NSArray {
        
        let results: NSArray = formFields.map { (formElement) -> NSDictionary in
                
            let formFieldDictionary: NSMutableDictionary = [
                "name": formElement.name ?? "",
                "isRequired": formElement.isRequired,
                "isReadOnly": formElement.isReadOnly,
                "fullyQualifiedName": formElement.formField?.fullyQualifiedName ?? "",
                "alternateFieldName": formElement.formField?.alternateFieldName ?? "",
                "isNoExport": formElement.formField?.isNoExport,
                "isDirty": formElement.formField?.dirty,
            ]
            
            if(formElement.formField?.type == nil){
                return formFieldDictionary
            }
            
            switch formElement.formField!.type {
            case .pushButton:
                formFieldDictionary["type"] = "PUSHBUTTON"
            case .checkBox:
                formFieldDictionary["type"] = "CHECKBOX"
            case .signature:
                formFieldDictionary["type"] = "SIGNATURE"
            case .text:
                formFieldDictionary["type"] = "TEXT"
            case .listBox:
                formFieldDictionary["type"] = "LISTBOX"
            case .comboBox:
                formFieldDictionary["type"] = "COMBOBOX"
            case .radioButton:
                formFieldDictionary["type"] = "RADIOBUTTON"
            case .unknown:
                formFieldDictionary["type"] = "UNDEFINED"
            }
            return formFieldDictionary
        } as NSArray
     return results
    }
    
}
