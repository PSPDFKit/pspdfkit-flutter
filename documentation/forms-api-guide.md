# Working with Forms

Read AcroForm fields as strongly-typed models and fill them in — no hand-parsed
JSON required.

The form API hangs off a loaded document's controller:
`controller.document.forms`. The typed methods (`getFormFields`,
`getFormField`) return [`PdfFormField`](../../nutrient_flutter_platform_interface/lib/src/models/forms/form_field.dart)
models; value get/set works by a field's **fully-qualified name**.

```dart
import 'package:nutrient_flutter/bindings.dart';
```

## Reading form fields

```dart
final forms = controller.document.forms;

// All form fields as typed models.
final fields = await forms.getFormFields();

for (final field in fields) {
  print('${field.fullyQualifiedName} — ${field.type} '
      '(required: ${field.isRequired}, readOnly: ${field.isReadOnly})');
}

// A single field by name (null if not found or of an unrecognized type).
final PdfFormField? name = await forms.getFormField('name_field');
```

Every `PdfFormField` exposes these common properties:

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String?` | The field's partial name |
| `fullyQualifiedName` | `String?` | The full dotted path — use this for value get/set |
| `alternativeFieldName` | `String?` | Human-readable label |
| `type` | `PdfFormFieldTypes` | The field type (see below) |
| `isRequired` | `bool?` | Field must be filled |
| `isReadOnly` | `bool?` | Field can't be edited |
| `isNoExport` | `bool?` | Excluded from export/submit |
| `isDirty` | `bool?` | Has unsaved changes |

## Field types

`PdfFormField.fromMap` parses each field into its concrete subclass — switch on
`field.type` or pattern-match the runtime type to reach the type-specific fields:

| Model | `PdfFormFieldTypes` | Type-specific fields |
|-------|---------------------|----------------------|
| `PdfTextFormField` | `text` | `text`, `defaultValue` |
| `CheckBoxFormField` | `checkbox` | `isChecked` |
| `RadioButtonFormField` | `radioButton` | `isSelected` |
| `ComboBoxFormField` | `comboBox` | `options`, `selectedIndices`, `values` |
| `ListBoxFormField` | `listBox` | `options`, `values` |
| `SignatureFormField` | `signature` | — |
| `ButtonFormField` | `button` | — |

```dart
final field = await forms.getFormField('agree_checkbox');
if (field is CheckBoxFormField) {
  print('checked: ${field.isChecked}');
} else if (field is PdfTextFormField) {
  print('text: ${field.text}');
} else if (field is ComboBoxFormField) {
  print('selected: ${field.selectedIndices}');
}
```

## Reading and setting values

Values are addressed by a field's `fullyQualifiedName`:

```dart
// Read the current value.
final String? value = await forms.getFormFieldValue('name_field');

// Set a value — returns true if the field was found and updated.
final ok = await forms.setFormFieldValue('Jane Doe', 'name_field');
```

> `setFormFieldValue` takes a `String`, so it maps cleanly onto **text fields**.
> Checkbox and radio-button fields accept their on/off export value as a string;
> a typed value-setter for multi-select (combo/list box) fields is a tracked
> follow-up. To read the current state of non-text fields, use the typed models
> above (`isChecked`, `selectedIndices`).

To clear a field, set an empty string:

```dart
await forms.setFormFieldValue('', 'name_field');
```

## Reacting to form changes

`controller.events` is a `Stream<NutrientEvent>` with typed filters. A field
edit surfaces the updated field:

```dart
controller.events.formFieldUpdated.listen((event) {
  final PdfFormField? field = event.formField;
  if (field != null) {
    print('Updated ${field.fullyQualifiedName}');
  }
});
```

For the full event catalogue and buffering semantics, see
[Working with Events](events-api-guide.md).

## Escape hatch: raw JSON

When you need a field shape the typed models don't cover yet, drop down to the
JSON transport the typed layer is built on:

```dart
final allJson = await forms.getFormFieldsJson();
final oneJson = await forms.getFormFieldJson('name_field');
```

## Platform support

Form field read, value get/set, and the `formFieldUpdated` event are supported
on all platforms:

| Operation | Android | iOS | Web |
|-----------|---------|-----|-----|
| `getFormFields` / `getFormField` | ✅ | ✅ | ✅ |
| `getFormFieldValue` / `setFormFieldValue` | ✅ | ✅ | ✅ |
| `formFieldUpdated` event | ✅ | ✅ | ✅ |

## See Also

- [Example: form_filling_example.dart](../catalog/lib/examples/form_filling_example.dart)
- [Working with Annotations](annotations-api-guide.md) — the parallel typed read/write API for annotations
- [Typed Annotations: cross-platform design](typed-annotations-cross-platform.md) — how the typed layer maps to each platform
