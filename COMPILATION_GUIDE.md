# MacBoard Compilation Guide

## 🚀 Quick Start (Remote Mac Session)

### 1. Initial Setup (5 minutes)
```bash
# Clone the repository (if not already done)
git clone [your-repo-url]
cd macboard

# Run verification script
./verify_build.sh
```

### 2. Open in Xcode
1. Double-click `MacBoard/MacBoard.xcodeproj`
2. Wait for Xcode to load the project

### 3. Configure Development Team
1. Select the project in Xcode navigator
2. Go to "Signing & Capabilities" tab
3. Select your Apple ID under "Team"
4. If no team available, add Apple ID in Xcode → Preferences → Accounts

## 🔧 Common Compilation Issues & Fixes

### Issue 1: "Cannot find type 'ClipboardMonitor'"
**Cause:** Missing imports or file not in target
**Fix:**
1. Check all Swift files have proper imports:
   ```swift
   import Foundation
   import SwiftUI
   import AppKit  // For clipboard functionality
   ```
2. Verify all files are added to the Xcode target

### Issue 2: "MenuBarExtra is only available in macOS 13.0 or newer"
**Cause:** Mac running older macOS version
**Fix Options:**
1. **Preferred:** Update to macOS 13.0+
2. **Fallback:** Use traditional NSStatusItem (see below)

### Issue 3: Core Data Model Issues
**Cause:** .xcdatamodeld file not properly configured
**Fix:**
1. Open `MacBoard.xcdatamodeld` in Xcode
2. Verify ClipboardItem entity has all attributes:
   - `id` (UUID)
   - `content` (String)
   - `type` (String)
   - `timestamp` (Date)
   - `isPinned` (Boolean)
   - `imageData` (Binary Data, Optional)
   - `rtfData` (Binary Data, Optional)

### Issue 4: "App Delegate not being called"
**Cause:** SwiftUI app lifecycle doesn't automatically use AppDelegate
**Fix:** Already handled in current code structure

### Issue 5: Clipboard Monitoring Not Working
**Cause:** Missing accessibility permissions
**Fix:**
1. Run the app once
2. Go to System Preferences → Security & Privacy → Privacy → Accessibility
3. Add MacBoard to the list and enable it

## 🔄 Fallback for Older macOS (< 13.0)

If MenuBarExtra doesn't work, replace the app body with:

```swift
var body: some Scene {
    Settings {
        PreferencesView()
            .environmentObject(clipboardStore)
            .environmentObject(clipboardMonitor)
    }
}
```

And create a traditional menu bar manager:

```swift
class TraditionalMenuBarManager: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    
    override init() {
        super.init()
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "MacBoard")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        setupPopover()
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 350, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView())
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}
```

## 🧪 Testing Checklist

### Basic Functionality Test
- [ ] App builds without errors
- [ ] Menu bar icon appears
- [ ] Clicking menu bar shows interface
- [ ] Copy some text → verify it appears in history
- [ ] Pin/unpin functionality works
- [ ] Preferences panel opens
- [ ] App stays running when windows closed

### Clipboard Monitoring Test
- [ ] Copy text → appears in list
- [ ] Copy image → shows as image type
- [ ] Copy file → shows as file type
- [ ] Rapid copying doesn't crash app
- [ ] Duplicates are handled properly

### UI/UX Test
- [ ] Search functionality works
- [ ] Type filtering works
- [ ] Dark mode switching works
- [ ] Hover states work properly
- [ ] Context menus appear on right-click

## 🐛 Debugging Tips

### Console Logs
MacBoard prints debug information to Console. To view:
1. Open Console.app
2. Filter for "MacBoard"
3. Look for clipboard monitoring messages

### Debug Window
The app includes a debug window accessible via Window menu showing:
- Current monitoring status
- Clipboard content preview
- Item count
- Control buttons

### Memory Issues
If app uses too much memory:
1. Check retention settings in preferences
2. Clear old items
3. Restart the app

## 📞 Emergency Fixes

### App Won't Launch
```bash
# Reset all preferences
defaults delete com.macboard.MacBoard

# Clear Core Data store
rm ~/Library/Application\ Support/MacBoard/MacBoard.sqlite*
```

### Clipboard Monitoring Stuck
```swift
// Add to ClipboardMonitor.swift for debugging
print("📋 Change count: \(pasteboard.changeCount), Last: \(lastChangeCount)")
```

### Menu Bar Icon Missing
- Check if app is running in background (Activity Monitor)
- Verify LSUIElement is not set to YES in Info.plist
- Restart SystemUIServer: `killall SystemUIServer`

## ✅ Success Indicators

You'll know the app is working correctly when:
1. ✅ Menu bar icon appears (clipboard symbol)
2. ✅ Clicking shows clipboard history
3. ✅ New copied items appear automatically
4. ✅ App persists between restarts
5. ✅ No crash logs in Console

## 🎯 Performance Targets

- **Memory Usage:** < 50MB
- **CPU Usage:** < 1% when idle
- **Startup Time:** < 2 seconds
- **Response Time:** < 100ms for UI interactions

---

**Need help?** Check the GitHub issues or create a new one with:
- macOS version
- Xcode version
- Complete error messages
- Console logs