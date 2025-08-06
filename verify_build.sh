#!/bin/bash

# MacBoard Build Verification Script
# Quick compilation test for remote development

set -e

echo "🔍 MacBoard Build Verification"
echo "=============================="

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed or not in PATH"
    echo "   Please install Xcode from the Mac App Store"
    exit 1
fi

echo "✅ Running on macOS with Xcode"

# Navigate to project directory
cd MacBoard

echo "🔨 Testing compilation (build only, no run)..."

# Try to build the project
if xcodebuild -project MacBoard.xcodeproj \
               -scheme MacBoard \
               -configuration Debug \
               -destination 'platform=macOS' \
               build > build_output.log 2>&1; then
    echo "✅ Build succeeded!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Run the app: open the built .app file"
    echo "2. Check menu bar for MacBoard icon"
    echo "3. Test clipboard monitoring by copying text"
    echo ""
    echo "🐛 If issues occur:"
    echo "1. Check Console.app for MacBoard logs"
    echo "2. Verify accessibility permissions if clipboard monitoring doesn't work"
    echo "3. Check the debug window via Window menu"
else
    echo "❌ Build failed!"
    echo ""
    echo "📋 Build errors:"
    tail -20 build_output.log
    echo ""
    echo "💡 Common fixes:"
    echo "1. Set your Apple ID in Xcode Preferences > Accounts"
    echo "2. Select your development team in project settings"
    echo "3. Check macOS version (needs 13.0+ for MenuBarExtra)"
    echo ""
    echo "📄 Full build log saved to: MacBoard/build_output.log"
    exit 1
fi

echo "🎉 Verification complete!"