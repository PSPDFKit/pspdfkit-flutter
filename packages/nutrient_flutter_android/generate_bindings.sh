#!/bin/bash

# Script to generate Android JNI bindings for Nutrient Flutter Android package
# Usage: ./generate_bindings.sh [OPTIONS] [NUTRIENT_VERSION]
#
# Options:
#   --skip-build    Skip building Android artifacts (use existing ones)
#   --help          Show this help message
#
# Arguments:
#   NUTRIENT_VERSION - Optional. The Nutrient SDK version Gradle builds this
#                      package against: pspdfkit.version in
#                      example/android/local.properties, else the pin in
#                      android/build.gradle. A different version is an error,
#                      because the plugin classes would be built against the
#                      pin while the bindings came from the other version.
#
# Examples:
#   ./generate_bindings.sh                    # Use the pinned version
#   ./generate_bindings.sh 12.1.0             # Check the pin is 12.1.0
#   ./generate_bindings.sh --skip-build       # Skip build, use existing artifacts
#   ./generate_bindings.sh --skip-build 12.1.0  # Skip build with specific version
#
# jnigen is the patched 1.0.1 in ../tools/jnigen (see its README), which reads
# the Kotlin 2.4 metadata the SDK and this plugin are built with. The
# post-processor (scripts/fix_bindings.sh) cleans up the remaining jnigen
# codegen quirks (nullable setter params, BasePdfUiBuilder).
# scripts/update_keep_rules.dart then rewrites the generated R8 keep rules in
# android/consumer-rules.pro for the library classes the bindings name.

set -e  # Exit on error

# Every path below is relative to this package.
cd "$(dirname "$0")"

# Parse command line arguments
SKIP_BUILD=false
NUTRIENT_VERSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --help)
            echo "Usage: ./generate_bindings.sh [OPTIONS] [NUTRIENT_VERSION]"
            echo ""
            echo "Options:"
            echo "  --skip-build    Skip building Android artifacts (use existing ones)"
            echo "  --help          Show this help message"
            echo ""
            echo "Arguments:"
            echo "  NUTRIENT_VERSION - Optional. Must match the version Gradle builds this"
            echo "                     package against (default: that version)"
            echo ""
            echo "Examples:"
            echo "  ./generate_bindings.sh                    # Use the pinned version"
            echo "  ./generate_bindings.sh 12.1.0             # Check the pin is 12.1.0"
            echo "  ./generate_bindings.sh --skip-build       # Skip build step"
            echo "  ./generate_bindings.sh --skip-build 12.1.0  # Skip build with version"
            exit 0
            ;;
        *)
            # Assume it's the version number
            NUTRIENT_VERSION="$1"
            shift
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# The Nutrient SDK version Gradle builds this package against, which is what
# the plugin classes are compiled with: the example's local.properties
# override, else the android/build.gradle pin. The bindings have to come from
# the same version, so it's the default and any other version is refused.
pinned_nutrient_version() {
    local override
    # Parsed the way java.util.Properties reads it: leading spaces, '=' or ':'
    # with spaces around it, and CRLF line endings are all allowed.
    override=$(sed -n 's/^[[:space:]]*pspdfkit\.version[[:space:]]*[=:][[:space:]]*//p' example/android/local.properties 2>/dev/null | tr -d '\r' | sed 's/[[:space:]]*$//' | tail -1)
    if [ -n "$override" ]; then
        echo "$override"
        return
    fi
    sed -n "s/.*getProperty('pspdfkit\.version') ?: '\([^']*\)'.*/\1/p" android/build.gradle | head -1
}

PINNED_VERSION=$(pinned_nutrient_version)
if [ -z "$PINNED_VERSION" ]; then
    print_error "Couldn't read the Nutrient SDK version from android/build.gradle"
    exit 1
fi
if [ -z "$NUTRIENT_VERSION" ]; then
    NUTRIENT_VERSION="$PINNED_VERSION"
elif [ "$NUTRIENT_VERSION" != "$PINNED_VERSION" ]; then
    print_error "Nutrient SDK $NUTRIENT_VERSION was requested, but Gradle builds this package against $PINNED_VERSION."
    print_info "Pin $NUTRIENT_VERSION in android/build.gradle and ../nutrient_flutter/android/config.gradle,"
    print_info "or set pspdfkit.version=$NUTRIENT_VERSION in example/android/local.properties."
    exit 1
fi

echo ""
print_info "=========================================="
print_info "  Android JNI Bindings Generator"
print_info "  Nutrient Flutter Android Package"
print_info "=========================================="
echo ""
print_info "Nutrient SDK Version: $NUTRIENT_VERSION"
echo ""

print_info "Step 1: Installing Flutter dependencies..."
flutter pub get
echo ""

print_info "Step 2: Checking for Nutrient SDK in Gradle cache..."
GRADLE_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"

# Find Nutrient SDK JARs (search all Gradle cache versions)
NUTRIENT_API_JAR=$(find "$GRADLE_HOME/caches" -name "jetified-nutrient-${NUTRIENT_VERSION}-api.jar" -type f 2>/dev/null | head -1)
NUTRIENT_RUNTIME_JAR=$(find "$GRADLE_HOME/caches" -name "jetified-nutrient-${NUTRIENT_VERSION}-runtime.jar" -type f 2>/dev/null | head -1)

if [ -z "$NUTRIENT_API_JAR" ]; then
    if [ "$SKIP_BUILD" = true ]; then
        print_error "Nutrient SDK $NUTRIENT_VERSION not found in Gradle cache."
        print_info "Remove --skip-build flag to download the SDK, or run Gradle manually first."
        exit 1
    fi

    print_warning "Nutrient SDK $NUTRIENT_VERSION not found in Gradle cache. Running Gradle to download..."

    # Run Gradle to download dependencies without compiling Flutter code
    cd example/android
    print_info "Running ./gradlew :nutrient_flutter_android:compileDebugKotlin to download Nutrient SDK..."
    ./gradlew :nutrient_flutter_android:compileDebugKotlin 2>&1 | tail -5
    cd - > /dev/null

    # Try finding the JARs again
    NUTRIENT_API_JAR=$(find "$GRADLE_HOME/caches" -name "jetified-nutrient-${NUTRIENT_VERSION}-api.jar" -type f 2>/dev/null | head -1)
    NUTRIENT_RUNTIME_JAR=$(find "$GRADLE_HOME/caches" -name "jetified-nutrient-${NUTRIENT_VERSION}-runtime.jar" -type f 2>/dev/null | head -1)

    if [ -z "$NUTRIENT_API_JAR" ]; then
        print_error "Still cannot find Nutrient SDK $NUTRIENT_VERSION API JAR"
        print_info "Please ensure nutrient_flutter_android/android/build.gradle has version $NUTRIENT_VERSION"
        exit 1
    fi

    print_success "✓ Nutrient SDK downloaded successfully"
else
    print_success "✓ Nutrient SDK $NUTRIENT_VERSION already available"
fi

# Runtime JAR is optional - use API JAR if runtime not available
if [ -z "$NUTRIENT_RUNTIME_JAR" ]; then
    print_warning "Runtime JAR not found, using API JAR only"
    NUTRIENT_RUNTIME_JAR="$NUTRIENT_API_JAR"
fi

print_success "Found Nutrient SDK JARs:"
print_info "  API: $NUTRIENT_API_JAR"
print_info "  Runtime: $NUTRIENT_RUNTIME_JAR"
echo ""

# Check ANDROID_HOME
if [ -z "$ANDROID_HOME" ]; then
    # Try common locations
    if [ -d "$HOME/Library/Android/sdk" ]; then
        export ANDROID_HOME="$HOME/Library/Android/sdk"
    elif [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
    else
        print_error "ANDROID_HOME not set and Android SDK not found in default locations"
        print_info "Please set ANDROID_HOME environment variable"
        exit 1
    fi
fi

print_info "Using ANDROID_HOME: $ANDROID_HOME"
echo ""

# Find the compiled platform classes JAR
ANDROID_PLATFORM_CLASSES="example/build/nutrient_flutter_android/intermediates/aar_main_jar/debug/syncDebugLibJars/classes.jar"

# Find the nutrient_flutter JAR (for PSPDFKitView adapter bridge access)
NUTRIENT_FLUTTER_JAR="../nutrient_flutter/example/build/nutrient_flutter/intermediates/compile_library_classes_jar/debug/bundleLibCompileToJarDebug/classes.jar"

if [ "$SKIP_BUILD" = true ]; then
    print_info "Step 3: Skipping Android platform package build (--skip-build)"
    if [ -f "$ANDROID_PLATFORM_CLASSES" ]; then
        print_success "✓ Using existing platform classes: $ANDROID_PLATFORM_CLASSES"
        # Verify FragmentContainerPlatformView is in the JAR
        if jar tf "$ANDROID_PLATFORM_CLASSES" | grep -q "FragmentContainerPlatformView"; then
            print_success "✓ FragmentContainerPlatformView found in compiled classes"
        else
            print_warning "⚠ FragmentContainerPlatformView not found in JAR"
        fi
    else
        print_warning "⚠ Platform classes JAR not found - will skip FragmentContainerPlatformView binding"
        print_info "Run without --skip-build to build platform classes"
        ANDROID_PLATFORM_CLASSES=""
    fi
else
    print_info "Step 3: Building Android platform package..."
    # Build local example to compile the platform package
    cd example/android
    print_info "Running ./gradlew :nutrient_flutter_android:assembleDebug..."
    ./gradlew :nutrient_flutter_android:assembleDebug --no-daemon 2>&1 | grep -E "(BUILD|FAILED|SUCCESS)" | tail -2
    cd - > /dev/null

    if [ -f "$ANDROID_PLATFORM_CLASSES" ]; then
        print_success "✓ Android platform package built: $ANDROID_PLATFORM_CLASSES"

        # Verify FragmentContainerPlatformView is in the JAR
        if jar tf "$ANDROID_PLATFORM_CLASSES" | grep -q "FragmentContainerPlatformView"; then
            print_success "✓ FragmentContainerPlatformView found in compiled classes"
        else
            print_warning "⚠ FragmentContainerPlatformView not found in JAR"
        fi
    else
        print_warning "⚠ Platform classes JAR not found - will skip FragmentContainerPlatformView binding"
        ANDROID_PLATFORM_CLASSES=""
    fi

    # jnigen.yaml binds PSPDFKitView from the nutrient_flutter plugin, so jnigen
    # stops with "Not found: PSPDFKitView" without its classes. `pub get` writes
    # the example's local.properties (flutter.sdk), which its Gradle build needs.
    print_info "Building the nutrient_flutter plugin classes..."
    (cd ../nutrient_flutter/example && flutter pub get > /dev/null)
    # That example doesn't track a Gradle wrapper script (Flutter writes one on
    # its first build), so a fresh checkout has no ./gradlew there. Run this
    # package's tracked wrapper (same Gradle version) on that project instead.
    # pipefail keeps Gradle's exit status, so a failed build stops here instead
    # of binding a classes JAR left over from an earlier build.
    GRADLEW="$(pwd)/example/android/gradlew"
    if ! (cd ../nutrient_flutter/example/android &&
        set -o pipefail &&
        "$GRADLEW" -p . :nutrient_flutter:bundleLibCompileToJarDebug --no-daemon 2>&1 | grep -E "(BUILD|FAILED|SUCCESS)" | tail -2); then
        print_error "Building the nutrient_flutter plugin classes failed"
        exit 1
    fi
fi
echo ""

print_info "Step 4: Creating temporary config with resolved paths..."

# Check for nutrient_flutter JAR
if [ -f "$NUTRIENT_FLUTTER_JAR" ]; then
    print_success "✓ Found nutrient_flutter JAR: $NUTRIENT_FLUTTER_JAR"
    # Verify PSPDFKitView is in the JAR
    if jar tf "$NUTRIENT_FLUTTER_JAR" | grep -q "PSPDFKitView"; then
        print_success "✓ PSPDFKitView found in nutrient_flutter JAR"
    else
        print_warning "⚠ PSPDFKitView not found in nutrient_flutter JAR"
    fi
else
    print_warning "⚠ nutrient_flutter JAR not found at $NUTRIENT_FLUTTER_JAR"
    print_info "  Building nutrient_flutter first may be required:"
    print_info "  cd ../nutrient_flutter/example/android && ../../../nutrient_flutter_android/example/android/gradlew -p . :nutrient_flutter:bundleLibCompileToJarDebug"
    NUTRIENT_FLUTTER_JAR=""
fi
echo ""

# Create temporary config file with resolved paths
sed -e "s|NUTRIENT_API_JAR_PLACEHOLDER|$NUTRIENT_API_JAR|g" \
    -e "s|NUTRIENT_RUNTIME_JAR_PLACEHOLDER|$NUTRIENT_RUNTIME_JAR|g" \
    -e "s|ANDROID_PLATFORM_CLASSES_PLACEHOLDER|${ANDROID_PLATFORM_CLASSES:-example/build/classes.jar}|g" \
    -e "s|NUTRIENT_FLUTTER_JAR_PLACEHOLDER|${NUTRIENT_FLUTTER_JAR:-../nutrient_flutter/example/build/classes.jar}|g" \
    -e "s|ANDROID_HOME_PLACEHOLDER|$ANDROID_HOME|g" \
    -e "s|10.7.0|$NUTRIENT_VERSION|g" \
    jnigen.yaml > jnigen_resolved.yaml

print_info "Step 5: Generating Android JNI bindings..."
print_info "This will generate bindings for Nutrient Android SDK classes"

if dart run jnigen --config jnigen_resolved.yaml; then
    # Clean up temporary config
    rm -f jnigen_resolved.yaml
    print_success "Android bindings generated successfully!"

    # Apply post-processing fixes for known jnigen bugs
    print_info "Applying post-processing fixes..."
    if ./scripts/fix_bindings.sh; then
        print_success "✓ Post-processing fixes applied"
    else
        print_error "Failed to apply post-processing fixes"
        exit 1
    fi

    # The R8 keep rules for the library classes in the bindings' JNI
    # signatures (android/consumer-rules.pro) follow the bindings.
    print_info "Updating the generated R8 keep rules..."
    if ! dart scripts/update_keep_rules.dart; then
        print_error "Failed to update android/consumer-rules.pro"
        exit 1
    fi

    # Check for remaining issues
    error_count=$(dart analyze lib/src/bindings/nutrient_android_sdk_bindings.dart 2>&1 | grep -c "error -" || true)

    if [ "$error_count" -eq 0 ]; then
        print_success "✓ No errors found in Android bindings"
    else
        print_warning "⚠ $error_count errors found"
        print_info "Run 'dart analyze lib/src/bindings/nutrient_android_sdk_bindings.dart' for details"
    fi

    # Print statistics
    line_count=$(wc -l < lib/src/bindings/nutrient_android_sdk_bindings.dart)
    print_info "Generated file size: $line_count lines"

    echo ""
    print_success "=========================================="
    print_success "  Bindings generation complete!"
    print_success "=========================================="
    echo ""
    print_info "Generated file:"
    print_info "  - lib/src/bindings/nutrient_android_sdk_bindings.dart"
    echo ""
else
    print_error "Failed to generate Android bindings"
    rm -f jnigen_resolved.yaml
    exit 1
fi
