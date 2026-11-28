#!/bin/bash

# Script to generate iOS FFI bindings for Nutrient Flutter iOS package
# Usage: ./generate_bindings.sh [OPTIONS]
#
# Options:
#   --skip-build    Skip pod install step (use existing Pods)
#   --help          Show this help message
#
# Examples:
#   ./generate_bindings.sh                # Full generation with pod install
#   ./generate_bindings.sh --skip-build   # Skip pod install, use existing Pods

set -e  # Exit on error

# Parse command line arguments
SKIP_BUILD=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --help)
            echo "Usage: ./generate_bindings.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-build    Skip pod install step (use existing Pods)"
            echo "  --help          Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./generate_bindings.sh                # Full generation with pod install"
            echo "  ./generate_bindings.sh --skip-build   # Skip pod install, use existing Pods"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
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
print_info "  iOS FFI Bindings Generator"
print_info "  Nutrient Flutter iOS Package"
print_info "=========================================="
echo ""

print_info "Step 1: Installing Flutter dependencies..."
flutter pub get
echo ""

print_info "Step 2: Checking for PSPDFKit CocoaPods..."
# Check if PSPDFKit pods are available in local example
if [ ! -d "example/ios/Pods/PSPDFKit/PSPDFKit.xcframework" ] || \
   [ ! -d "example/ios/Pods/PSPDFKit/PSPDFKitUI.xcframework" ]; then
    if [ "$SKIP_BUILD" = true ]; then
        print_error "PSPDFKit CocoaPods not found in local example."
        print_info "Remove --skip-build flag to install pods, or run 'pod install' manually first."
        exit 1
    fi

    print_warning "PSPDFKit CocoaPods not found in local example. Installing..."

    # Check if CocoaPods is installed
    if ! command -v pod &> /dev/null; then
        print_error "CocoaPods not installed. Install it first:"
        print_info "  sudo gem install cocoapods"
        exit 1
    fi

    # Install pods in local example
    cd example/ios
    print_info "Running pod install..."
    pod install --repo-update
    cd - > /dev/null

    print_success "✓ PSPDFKit CocoaPods installed in local example"
else
    if [ "$SKIP_BUILD" = true ]; then
        print_info "Skipping pod install (--skip-build)"
    fi
    print_success "✓ PSPDFKit CocoaPods already available in local example"
fi
echo ""

print_info "Step 3: Generating iOS FFI bindings..."
print_info "This will generate complete bindings for the Nutrient iOS SDK"
print_warning "This process may take 3-5 minutes..."
echo ""

# Determine the simulator SDK root if it is not explicitly provided.
sdkroot="${SDKROOT:-}"
if [ -z "$sdkroot" ]; then
    if command -v xcrun >/dev/null 2>&1; then
        if sdkroot=$(xcrun --sdk iphonesimulator --show-sdk-path 2>/dev/null); then
            :
        else
            sdkroot=""
        fi
    fi
fi

if [ -z "$sdkroot" ]; then
    print_error "Unable to determine the iOS simulator SDK path."
    print_info "Set SDKROOT manually or ensure Xcode command line tools are installed."
    exit 1
fi

print_info "Using SDKROOT=$sdkroot"

# Generate iOS bindings
if SDKROOT="$sdkroot" dart run ffigen --config ffigen_ios.yaml; then
    print_success "✓ Nutrient iOS SDK bindings generated successfully!"

    # Check for remaining issues
    error_count=$(dart analyze lib/src/bindings/nutrient_ios_bindings.dart 2>&1 | grep -c "error -" || true)

    if [ "$error_count" -eq 0 ]; then
        print_success "✓ No errors found in iOS bindings"
    else
        print_warning "⚠ $error_count errors found"
        print_info "Run 'dart analyze lib/src/bindings/nutrient_ios_bindings.dart' for details"
    fi

    # Print statistics
    line_count=$(wc -l < lib/src/bindings/nutrient_ios_bindings.dart)
    file_size=$(du -h lib/src/bindings/nutrient_ios_bindings.dart | cut -f1)
    print_info "Generated file size: $line_count lines ($file_size)"

    echo ""
    print_info "Step 4: Copying native protocol trampoline code..."
    # FFIGen generates a .m file with native Objective-C code for protocol implementations
    # This file must be compiled into the plugin for protocol delegates to work
    NATIVE_CODE_SRC="lib/src/bindings/nutrient_ios_bindings.dart.m"
    NATIVE_CODE_DST="ios/Classes/NutrientIOSBindings.m"

    if [ -f "$NATIVE_CODE_SRC" ]; then
        cp "$NATIVE_CODE_SRC" "$NATIVE_CODE_DST"
        print_success "✓ Native protocol code copied to $NATIVE_CODE_DST"

        # Fix the imports in the generated .m file
        # FFIGen generates relative paths that only work from within this package
        # We need to use framework-style imports that work via CocoaPods
        print_info "Fixing imports in native code..."

        # Replace relative PSPDFKit header paths with framework imports
        sed -i '' 's|#import "../../../example/ios/Pods/PSPDFKit/PSPDFKit.xcframework/ios-arm64_x86_64-simulator/PSPDFKit.framework/Headers/PSPDFKit.h"|#import <PSPDFKit/PSPDFKit.h>|g' "$NATIVE_CODE_DST"
        sed -i '' 's|#import "../../../example/ios/Pods/PSPDFKit/PSPDFKitUI.xcframework/ios-arm64_x86_64-simulator/PSPDFKitUI.framework/Headers/PSPDFKitUI.h"|#import <PSPDFKitUI/PSPDFKitUI.h>|g' "$NATIVE_CODE_DST"

        # Fix NutrientFFI.h import to be relative to Classes directory
        sed -i '' 's|#import "../../../ios/Classes/NutrientFFI.h"|#import "NutrientFFI.h"|g' "$NATIVE_CODE_DST"

        print_success "✓ Imports fixed in $NATIVE_CODE_DST"

        # Remove macOS-only Network.framework types that aren't available on iOS
        # These types (nw_browser_state_t, nw_connection_group_state_t, nw_connection_state_t,
        # nw_ethernet_channel_state_t, nw_listener_state_t) are only available on macOS
        print_info "Removing macOS-only Network.framework types..."

        # Use perl for multi-line pattern replacement to remove the nw_* type blocks
        # Remove _ListenerTrampoline blocks with nw_* types
        perl -i -0pe 's/typedef void  \(\^\w+\)\(nw_\w+_t arg0.*?^\}\n\n//gms' "$NATIVE_CODE_DST"
        # Remove _BlockingTrampoline blocks with nw_* types
        perl -i -0pe 's/typedef void  \(\^\w+\)\(void \* waiter, nw_\w+_t arg0.*?^\}\n\n//gms' "$NATIVE_CODE_DST"

        print_success "✓ macOS-only types removed from $NATIVE_CODE_DST"
    else
        print_warning "⚠ No native protocol code generated (file not found: $NATIVE_CODE_SRC)"
        print_info "  This is normal if no protocols with callbacks are being implemented."
    fi

    echo ""
    print_success "=========================================="
    print_success "  Bindings generation complete!"
    print_success "=========================================="
    echo ""
    print_info "Generated files:"
    print_info "  - lib/src/bindings/nutrient_ios_bindings.dart"
    if [ -f "$NATIVE_CODE_DST" ]; then
        print_info "  - $NATIVE_CODE_DST (protocol trampolines)"
    fi
    echo ""
    print_info "Next steps:"
    print_info "  1. Run 'pod install' in example/ios to rebuild native code"
    print_info "  2. Test protocol delegate implementations"
    echo ""
else
    print_error "Failed to generate iOS bindings"
    exit 1
fi
