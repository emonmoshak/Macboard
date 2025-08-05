import SwiftUI
import AppKit

@main
struct MacBoardApp: App {
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @StateObject private var clipboardStore = ClipboardStore()
    
    var body: some Scene {
        MenuBarExtra("MacBoard", systemImage: "clipboard") {
            MenuBarView()
                .environmentObject(clipboardMonitor)
                .environmentObject(clipboardStore)
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            PreferencesView()
                .environmentObject(clipboardStore)
        }
    }
}

// Menu bar manager to handle global state
class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    
    init() {
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "MacBoard")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    
    @objc func togglePopover() {
        // Handle popover toggle
        print("MacBoard menu clicked")
    }
}