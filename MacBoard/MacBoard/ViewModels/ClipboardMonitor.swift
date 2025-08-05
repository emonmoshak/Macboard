import Foundation
import AppKit
import SwiftUI

class ClipboardMonitor: ObservableObject {
    
    // MARK: - Properties
    @Published var isMonitoring = false
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let pasteboard = NSPasteboard.general
    
    // Dependencies
    private var clipboardStore: ClipboardStore?
    
    // Settings
    @AppStorage("monitoringEnabled") var monitoringEnabled: Bool = true
    @AppStorage("pollInterval") var pollInterval: Double = 0.5 // seconds
    
    // MARK: - Initialization
    init() {
        lastChangeCount = pasteboard.changeCount
        
        if monitoringEnabled {
            startMonitoring()
        }
    }
    
    // MARK: - Monitoring Control
    
    /// Start monitoring the clipboard
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        lastChangeCount = pasteboard.changeCount
        
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        
        print("📋 Started clipboard monitoring")
    }
    
    /// Stop monitoring the clipboard
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        isMonitoring = false
        timer?.invalidate()
        timer = nil
        
        print("📋 Stopped clipboard monitoring")
    }
    
    /// Toggle monitoring on/off
    func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }
    
    // MARK: - Clipboard Checking
    
    /// Check if clipboard content has changed
    private func checkClipboard() {
        let currentChangeCount = pasteboard.changeCount
        
        // Only process if clipboard has actually changed
        guard currentChangeCount != lastChangeCount else { return }
        
        lastChangeCount = currentChangeCount
        processClipboardChange()
    }
    
    /// Process a clipboard change
    private func processClipboardChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Add the new clipboard content to store
            self.clipboardStore?.addItem(from: self.pasteboard)
            
            // Optional: Show notification or visual feedback
            self.showClipboardChangeNotification()
        }
    }
    
    // MARK: - Utility Methods
    
    /// Set the clipboard store dependency
    func setClipboardStore(_ store: ClipboardStore) {
        self.clipboardStore = store
    }
    
    /// Get current clipboard content preview
    func getCurrentClipboardPreview() -> String {
        if let string = pasteboard.string(forType: .string) {
            return string.count > 50 ? String(string.prefix(50)) + "..." : string
        } else if NSImage(pasteboard: pasteboard) != nil {
            return "Image"
        } else if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL], !urls.isEmpty {
            return "File: \(urls.first?.lastPathComponent ?? "Unknown")"
        }
        return "Empty"
    }
    
    /// Copy item back to clipboard
    func copyToClipboard(_ item: ClipboardItem) {
        pasteboard.clearContents()
        
        switch item.itemType {
        case .text:
            pasteboard.setString(item.content, forType: .string)
        case .image:
            if let imageData = item.imageData, let image = NSImage(data: imageData) {
                pasteboard.writeObjects([image])
            }
        case .fileURL:
            let urls = item.content.components(separatedBy: "\n").compactMap { URL(string: $0) }
            pasteboard.writeObjects(urls as [NSPasteboardWriting])
        case .rtf:
            if let rtfData = item.rtfData {
                pasteboard.setData(rtfData, forType: .rtf)
            } else {
                pasteboard.setString(item.content, forType: .string)
            }
        }
        
        // Update our change count to avoid re-capturing what we just set
        lastChangeCount = pasteboard.changeCount
        
        print("📋 Copied to clipboard: \(item.displayContent)")
    }
    
    /// Show a subtle notification when clipboard changes
    private func showClipboardChangeNotification() {
        // This could be enhanced with actual notifications or visual feedback
        // For now, just log to console
        print("📋 New clipboard content detected: \(getCurrentClipboardPreview())")
    }
    
    // MARK: - Settings
    
    /// Update monitoring settings
    func updateSettings(enabled: Bool, interval: Double) {
        monitoringEnabled = enabled
        pollInterval = interval
        
        if enabled && !isMonitoring {
            startMonitoring()
        } else if !enabled && isMonitoring {
            stopMonitoring()
        } else if isMonitoring {
            // Restart with new interval
            stopMonitoring()
            startMonitoring()
        }
    }
}

// MARK: - Clipboard Content Types
extension ClipboardMonitor {
    
    /// Check what types of content are currently in clipboard
    func getClipboardContentTypes() -> [ClipboardItemType] {
        var types: [ClipboardItemType] = []
        
        if pasteboard.string(forType: .string) != nil {
            types.append(.text)
        }
        
        if NSImage(pasteboard: pasteboard) != nil {
            types.append(.image)
        }
        
        if pasteboard.data(forType: .rtf) != nil {
            types.append(.rtf)
        }
        
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL], !urls.isEmpty {
            types.append(.fileURL)
        }
        
        return types
    }
    
    /// Check if clipboard has any supported content
    var hasValidContent: Bool {
        return !getClipboardContentTypes().isEmpty
    }
}