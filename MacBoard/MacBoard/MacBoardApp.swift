import SwiftUI
import AppKit

@main
struct MacBoardApp: App {
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @StateObject private var clipboardStore = ClipboardStore()
    
    init() {
        // Connect clipboard monitor to store on app initialization
        // Use async to avoid issues with @StateObject initialization timing
        DispatchQueue.main.async {
            clipboardMonitor.setClipboardStore(clipboardStore)
        }
    }
    
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
                .environmentObject(clipboardMonitor)
        }
        
        // Debug window (hidden by default, can be shown via Window menu)
        Window("MacBoard Debug", id: "debug") {
            ContentView()
                .environmentObject(clipboardMonitor)
                .environmentObject(clipboardStore)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .commandsRemoved()
    }
}

// MARK: - App Delegate for additional macOS integration
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon to make it menu bar only
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep app running even when all windows are closed
        return false
    }
}