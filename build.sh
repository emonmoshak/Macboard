#!/bin/bash

# MacBoard Build Script
# This script helps build and run the MacBoard application

set -e

echo "🛠  MacBoard Build Script"
echo "=========================="

# Function to check if Xcode is installed
check_xcode() {
    if ! command -v xcodebuild &> /dev/null; then
        echo "❌ Xcode is not installed or not in PATH"
        echo "   Please install Xcode from the Mac App Store"
        exit 1
    fi
    echo "✅ Xcode found"
}

# Function to build the project
build_project() {
    echo "🔨 Building MacBoard..."
    
    cd MacBoard
    
    # Build for debug configuration
    xcodebuild -project MacBoard.xcodeproj \
               -scheme MacBoard \
               -configuration Debug \
               -destination 'platform=macOS' \
               build
    
    echo "✅ Build completed successfully"
}

# Function to run the app
run_app() {
    echo "🚀 Running MacBoard..."
    
    # Find the built app
    APP_PATH="$(find ~/Library/Developer/Xcode/DerivedData -name "MacBoard.app" -type d | head -1)"
    
    if [[ -z "$APP_PATH" ]]; then
        echo "❌ Could not find built app. Please build first."
        exit 1
    fi
    
    echo "📱 Launching MacBoard from: $APP_PATH"
    open "$APP_PATH"
}

# Function to clean build artifacts
clean_project() {
    echo "🧹 Cleaning build artifacts..."
    
    cd MacBoard
    
    xcodebuild -project MacBoard.xcodeproj \
               -scheme MacBoard \
               clean
    
    echo "✅ Clean completed"
}

# Function to show help
show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build    - Build the MacBoard application"
    echo "  run      - Run the MacBoard application"
    echo "  clean    - Clean build artifacts"
    echo "  help     - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 run"
    echo "  $0 clean"
}

# Main script logic
case "${1:-build}" in
    "build")
        check_xcode
        build_project
        ;;
    "run")
        check_xcode
        run_app
        ;;
    "clean")
        check_xcode
        clean_project
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

echo "🎉 Done!"