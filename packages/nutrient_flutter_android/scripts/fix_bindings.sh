#!/bin/bash
# Post-processing script to fix known jnigen bugs in nutrient_android_sdk_bindings.dart
# Run this script after generating bindings with: dart run jnigen --config jnigen.yaml

set -euo pipefail

BINDINGS_FILE="lib/src/bindings/nutrient_android_sdk_bindings.dart"

if [ ! -f "$BINDINGS_FILE" ]; then
    echo "Error: $BINDINGS_FILE not found!" >&2
    exit 1
fi

echo "Fixing known jnigen bugs in $BINDINGS_FILE..."
echo ""

echo '  Applying textual fixes...'
python3 - <<'PY'
from pathlib import Path
import re

path = Path("lib/src/bindings/nutrient_android_sdk_bindings.dart")
text = path.read_text()
fixes_applied = []

# =============================================================================
# Fix 1: Rename conflicting method in LongTermValidationExceptionKt
# =============================================================================
# This method name conflicts with the return type, causing Dart compilation errors
original = "static LongTermValidationException LongTermValidationException("
replacement = "static LongTermValidationException createLongTermValidationException("

if original in text:
    text = text.replace(original, replacement)
    fixes_applied.append("LongTermValidationException method name conflict")
    print(f"  ✓ Fixed LongTermValidationException method name conflict")

# =============================================================================
# Fix 2: Update Response subclasses to pass type parameter
# =============================================================================
# The Response<T> base class requires the type parameter T in fromReference,
# but subclasses don't pass it. The constructor signature is:
#   Response.fromReference(this.T, JReference reference)
# But subclasses have:
#   super.fromReference(reference)
# Need to change to:
#   super.fromReference(const jni$_.JObjectNullableType(), reference)

for class_name in ["Response\\$Error", "Response\\$Loading", "Response\\$SuccessEmpty"]:
    # Pattern matches: super.fromReference(reference);
    # Replace with: super.fromReference(const jni$_.JObjectNullableType(), reference);
    pattern = (
        r'(class\s+' + class_name + r'\s+extends\s+Response<jni\$_\.JObject\?>'
        r'.*?super\.fromReference\()reference(\);)'
    )
    replacement_text = r'\1const jni$_.JObjectNullableType(), reference\2'

    updated, count = re.subn(pattern, replacement_text, text, flags=re.DOTALL)
    if count > 0:
        text = updated
        display_name = class_name.replace("\\", "")
        fixes_applied.append(f"{display_name} type parameter")
        print(f"  ✓ Fixed {display_name} to pass type parameter")

# =============================================================================
# Fix 3: Fix AnnotationCreationToolbar.onMenuItemsGrouped type mismatch
# =============================================================================
# The base class ContextualToolbar has JList<ContextualToolbarMenuItem?> (nullable)
# but the subclass has JList<ContextualToolbarMenuItem> (non-nullable).
# This causes a Dart override error due to covariance rules.

# Find AnnotationCreationToolbar class (extends ContextualToolbar<AnnotationCreationController>)
annotation_toolbar_match = re.search(
    r'(class AnnotationCreationToolbar\s*\n\s*extends ContextualToolbar<AnnotationCreationController>.*?)(?=\nclass |\Z)',
    text,
    re.DOTALL
)

if annotation_toolbar_match:
    class_text = annotation_toolbar_match.group(1)
    original_class_text = class_text

    # Fix parameter type: JList<ContextualToolbarMenuItem> -> JList<ContextualToolbarMenuItem?>
    old_sig = 'jni$_.JList<ContextualToolbarMenuItem> onMenuItemsGrouped(\n    jni$_.JList<ContextualToolbarMenuItem> list,'
    new_sig = 'jni$_.JList<ContextualToolbarMenuItem?> onMenuItemsGrouped(\n    jni$_.JList<ContextualToolbarMenuItem?> list,'

    if old_sig in class_text:
        class_text = class_text.replace(old_sig, new_sig)
        fixes_applied.append("AnnotationCreationToolbar.onMenuItemsGrouped parameter type")
        print(f"  ✓ Fixed AnnotationCreationToolbar.onMenuItemsGrouped parameter type")

    # Fix return type in the method body
    old_return = '.object<jni$_.JList<ContextualToolbarMenuItem>>(\n            const jni$_.JListType<ContextualToolbarMenuItem>(\n                $ContextualToolbarMenuItem$Type()));'
    new_return = '.object<jni$_.JList<ContextualToolbarMenuItem?>>(\n            const jni$_.JListType<ContextualToolbarMenuItem?>(\n                $ContextualToolbarMenuItem$NullableType()));'

    if old_return in class_text:
        class_text = class_text.replace(old_return, new_return)
        fixes_applied.append("AnnotationCreationToolbar.onMenuItemsGrouped return type")
        print(f"  ✓ Fixed AnnotationCreationToolbar.onMenuItemsGrouped return type")

    # Replace the class in the full text if it changed
    if class_text != original_class_text:
        text = text[:annotation_toolbar_match.start()] + class_text + text[annotation_toolbar_match.end():]

path.write_text(text)

print("")
if fixes_applied:
    print(f"✅ Applied {len(fixes_applied)} fix(es):")
    for fix in fixes_applied:
        print(f"   • {fix}")
else:
    print("ℹ No fixes were needed (issues may already be fixed or not present)")
PY

echo ''
echo '  Applying nightly (jni 1.0 / jnigen 0.17) fixes...'
python3 - <<'PY'
from pathlib import Path
import re
import subprocess

bindings = "lib/src/bindings/nutrient_android_sdk_bindings.dart"
path = Path(bindings)
fixes_applied = []

# =============================================================================
# Fix 4: BasePdfUiBuilder is generated with 0 type parameters, but its
# subclasses implement it with one (BasePdfUiBuilder<PdfActivityIntentBuilder?>).
# Strip the spurious type argument from the implements clauses.
# =============================================================================
text = path.read_text()
text, n = re.subn(r'implements BasePdfUiBuilder<[^>]*>',
                  'implements BasePdfUiBuilder', text)
if n:
    path.write_text(text)
    fixes_applied.append(f"BasePdfUiBuilder type argument ({n} usage(s))")
    print(f"  ✓ Stripped BasePdfUiBuilder type argument ({n} usage(s))")

# =============================================================================
# Fix 5: nullable getter / non-null setter mismatch (jnigen 0.17 bug). jnigen
# emits e.g. `Bitmap? get bitmap` paired with `set bitmap(Bitmap bitmap)`, which
# is an invalid getter/setter type pair in Dart. Drive the fix from the analyzer
# so only genuinely-mismatched setters are nullable-ized (the same field name can
# be non-nullable and correct in other classes).
# =============================================================================
res = subprocess.run(
    ["dart", "analyze", "--format=machine", bindings],
    capture_output=True, text=True)
lines = path.read_text().splitlines(keepends=True)
setter_fixes = 0
for diag in (res.stdout + "\n" + res.stderr).splitlines():
    cols = diag.split("|")
    if len(cols) >= 8 and cols[2].upper() == "GETTER_NOT_SUBTYPE_SETTER_TYPES":
        m = re.search(r"getter '(\w+)'", cols[7])
        if not m:
            continue
        name = m.group(1)
        getter_line = int(cols[4]) - 1
        # `set NAME(TYPE PARAM) {` — capture TYPE (grp2) and PARAM (grp4).
        setter_re = re.compile(r'(\bset ' + re.escape(name) + r'\()(.+?)( (\w+)\)\s*\{)')
        # Scan forward to the matching setter, bounded by the next class so we
        # never cross into a same-named setter in another extension type.
        for i in range(getter_line, len(lines)):
            if i > getter_line and lines[i].startswith('extension type '):
                break
            mm = setter_re.search(lines[i])
            if not mm:
                continue
            if not mm.group(2).rstrip().endswith('?'):
                param = mm.group(4)
                lines[i] = setter_re.sub(
                    lambda x: f"{x.group(1)}{x.group(2)}?{x.group(3)}",
                    lines[i], count=1)
                setter_fixes += 1
                # Fix the body: `PARAM.reference` -> nullable-safe form.
                body_re = re.compile(r'(?<![\w?.])' + re.escape(param)
                                     + r'\.reference\b')
                for j in range(i + 1, min(i + 12, len(lines))):
                    if lines[j].lstrip().startswith('set ') or \
                       lines[j].startswith('extension type '):
                        break
                    if body_re.search(lines[j]):
                        lines[j] = body_re.sub(
                            f'{param}?.reference ?? jni$_.jNullReference',
                            lines[j])
                    if lines[j].rstrip() == '  }':
                        break
            break
if setter_fixes:
    path.write_text("".join(lines))
    fixes_applied.append(f"nullable setter params ({setter_fixes})")
    print(f"  ✓ Made {setter_fixes} mismatched setter param(s) nullable")

if not fixes_applied:
    print("ℹ No nightly fixes were needed")
PY

# The fixes above edit the file after jnigen's own format step, so re-format to
# keep CI's `dart format --set-exit-if-changed` check green.
echo ''
echo '  Re-formatting bindings...'
dart format "$BINDINGS_FILE" | tail -1

echo ""
echo "Summary of known issues fixed:"
echo "  1. LongTermValidationExceptionKt: Renamed method to avoid name/type conflict"
echo "  2. Response\$Error/Loading/SuccessEmpty: Pass type parameter to fromReference"
echo "  3. AnnotationCreationToolbar.onMenuItemsGrouped: Fix nullable type mismatch"
echo "  4. BasePdfUiBuilder: Strip spurious type argument (jnigen 0.17)"
echo "  5. Nullable getter / non-null setter mismatch (jnigen 0.17)"
echo ''
