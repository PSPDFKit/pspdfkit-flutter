package com.pspdfkit.flutter.pspdfkit.forms

import com.pspdfkit.flutter.pspdfkit.api.FormFieldData
import com.pspdfkit.flutter.pspdfkit.api.PdfFormFieldTypes
import com.pspdfkit.forms.CheckBoxFormField
import com.pspdfkit.forms.ComboBoxFormField
import com.pspdfkit.forms.FormField
import com.pspdfkit.forms.FormType
import com.pspdfkit.forms.ListBoxFormField
import com.pspdfkit.forms.RadioButtonFormField
import com.pspdfkit.forms.TextFormField
import com.pspdfkit.internal.forms.getFormatString
import com.pspdfkit.internal.forms.getInputFormat

object FormHelper {

    private val formFieldTypeMap: Map<FormType, PdfFormFieldTypes> = mapOf(
        FormType.TEXT to PdfFormFieldTypes.TEXT,
        FormType.CHECKBOX to PdfFormFieldTypes.CHECKBOX,
        FormType.RADIOBUTTON to PdfFormFieldTypes.RADIO_BUTTON,
        FormType.LISTBOX to PdfFormFieldTypes.LIST_BOX,
        FormType.COMBOBOX to PdfFormFieldTypes.COMBO_BOX,
        FormType.SIGNATURE to PdfFormFieldTypes.SIGNATURE,
        FormType.PUSHBUTTON to PdfFormFieldTypes.BUTTON,
        FormType.UNDEFINED to PdfFormFieldTypes.UNKNOWN
    )

    @JvmStatic
    fun formFieldPropertiesToMap(formFields: List<FormField>): List<Map<String, Any>> {
        val formFieldsList: MutableList<Map<String, Any>> = mutableListOf()
        // Extract the common form fields properties.
        for (formField in formFields) {
            val formFieldsMap: MutableMap<String, Any> = mutableMapOf()
            formFieldsMap["name"] = formField.name
            formFieldsMap["fullyQualifiedName"] = formField.fullyQualifiedName
            formFieldsMap["type"] = formField.type.name
            formFieldsMap["isDirty"] = formField.isDirty
            formFieldsMap["isRequired"] = formField.isRequired
            formFieldsMap["isReadOnly"] = formField.isReadOnly
            formFieldsMap["isNoExport"] = !formField.isExported
            formFieldsMap["alternateFieldName"] = formField.alternateFieldName
            formFieldsMap["mappingName"] = formField.mappingName
            formFieldsMap["annotation"] = formField.formElement.annotation.toInstantJson()
            formFieldsMap["inputFormatString"] = formField.formElement.getFormatString() ?: ""
            formFieldsMap["inputFormat"] = formField.formElement.getInputFormat().name

            // Extract the specific form field properties.
            formFieldsMap.putAll(getSpecificFormFieldProperties(formField, formFieldsMap))
            formFieldsList.add(formFieldsMap)
        }
        return formFieldsList
    }

    fun formFieldsToFormFieldData(formFields: List<FormField>):List<FormFieldData> {
        val formFieldsList: MutableList<FormFieldData> = mutableListOf()
        // Extract the common form fields properties.
        for (formField in formFields) {
            val formFieldData: FormFieldData = FormFieldData(
               name = formField.name,
               fullyQualifiedName =  formField.fullyQualifiedName,
               type = formFieldTypeMap[formField.type] ?: PdfFormFieldTypes.UNKNOWN,
                isDirty = formField.isDirty,
                isRequired = formField.isRequired,
                isReadOnly = formField.isReadOnly,
                isExported = formField.isExported,
                alternativeFieldName = formField.alternateFieldName,
                annotations = formField.formElement.annotation.toInstantJson(),
            )
            formFieldsList.add(formFieldData)
        }
        return formFieldsList
    }

    @JvmStatic
    private fun getSpecificFormFieldProperties(
        formField: FormField,
        map: MutableMap<String, Any>
    ): Map<String, Any> {

        when (formField.type) {
            FormType.TEXT -> {
                val textFormField = formField as TextFormField
                map["text"] = textFormField.formElement.text ?: ""
                map["isMultiline"] = textFormField.formElement.isMultiLine
                map["isPassword"] = textFormField.formElement.isPassword
                map["isRichText"] = textFormField.formElement.isRichText
                map["isComb"] = textFormField.formElement.isComb
                map["isFileSelect"] = textFormField.formElement.isFileSelect
                map["isSpellCheckEnabled"] = textFormField.formElement.isSpellCheckEnabled
                map["isScrollEnabled"] = textFormField.formElement.isScrollEnabled
                map["annotations"] = textFormField.formElement.annotation.toInstantJson()
            }

            FormType.CHECKBOX -> {
                val checkBoxFormField = formField as CheckBoxFormField
                map["isChecked"] = checkBoxFormField.formElement.isSelected
            }

            FormType.RADIOBUTTON -> {
                val radioButtonFormField = formField as RadioButtonFormField
                map["isSelected"] = radioButtonFormField.formElement.isSelected
            }

            FormType.LISTBOX -> {
                val listBoxFormField = formField as ListBoxFormField
                val formOptions: List<Map<String, Any>> = listBoxFormField.formElement.options.map {
                    mapOf(
                        "value" to it.value,
                        "label" to it.label
                    )
                }
                map["defaultValues"] = listBoxFormField.formElement.selectedIndexes
                map["options"] = formOptions
            }

            FormType.COMBOBOX -> {
                val comboBoxFormField = formField as ComboBoxFormField
                val formOptions: List<Map<String, Any>> =
                    comboBoxFormField.formElement.options.map {
                        mapOf(
                            "value" to it.value,
                            "label" to it.label
                        )
                    }
                map["defaultValues"] = comboBoxFormField.formElement.selectedIndexes
                map["options"] = formOptions
            }

            FormType.SIGNATURE -> {

            }

            FormType.PUSHBUTTON -> {

            }
            FormType.UNDEFINED -> {

            }
        }
        return map
    }

}