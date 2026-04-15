#!/bin/bash

# Script to generate Android JNI bindings for Nutrient Flutter Android package
# Usage: ./generate_bindings.sh [OPTIONS] [NUTRIENT_VERSION]
#
# Options:
#   --skip-build    Skip building Android artifacts (use existing ones)
#   --help          Show this help message
#
# Arguments:
#   NUTRIENT_VERSION - Optional. Nutrient SDK version (default: 10.9.0)
#
# Examples:
#   ./generate_bindings.sh                    # Use default version 10.9.0
#   ./generate_bindings.sh 10.8.0             # Use specific version
#   ./generate_bindings.sh --skip-build       # Skip build, use existing artifacts
#   ./generate_bindings.sh --skip-build 10.9.0  # Skip build with specific version

set -e  # Exit on error

# Parse command line arguments
SKIP_BUILD=false
NUTRIENT_VERSION="10.9.0"

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
            echo "  NUTRIENT_VERSION - Optional. Nutrient SDK version (default: 10.9.0)"
            echo ""
            echo "Examples:"
            echo "  ./generate_bindings.sh                    # Use default version"
            echo "  ./generate_bindings.sh 10.8.0             # Use specific version"
            echo "  ./generate_bindings.sh --skip-build       # Skip build step"
            echo "  ./generate_bindings.sh --skip-build 10.9.0  # Skip build with version"
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
    print_info "  cd ../nutrient_flutter/example/android && ./gradlew :nutrient_flutter:bundleLibCompileToJarDebug"
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
