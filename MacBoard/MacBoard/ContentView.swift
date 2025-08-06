import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var clipboardStore: ClipboardStore
    @EnvironmentObject private var clipboardMonitor: ClipboardMonitor
    
    var body: some View {
        VStack {
            // This view is primarily for development/debugging
            // The main app interface is through the menu bar
            
            Text("MacBoard")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Clipboard Manager for macOS")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            // Status information for debugging
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Monitoring:")
                    Text(clipboardMonitor.isMonitoring ? "Active" : "Inactive")
                        .foregroundColor(clipboardMonitor.isMonitoring ? .green : .red)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Items in history:")
                    Text("\(clipboardStore.items.count)")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Current clipboard:")
                    Text(clipboardMonitor.getCurrentClipboardPreview())
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .frame(maxWidth: 400)
            
            // Control buttons
            HStack(spacing: 16) {
                Button(clipboardMonitor.isMonitoring ? "Stop Monitoring" : "Start Monitoring") {
                    clipboardMonitor.toggleMonitoring()
                }
                
                Button("Clear History") {
                    clipboardStore.clearAll()
                }
                .foregroundColor(.red)
            }
            .padding()
            
            // Recent items preview
            if !clipboardStore.items.isEmpty {
                Text("Recent Items")
                    .font(.headline)
                    .padding(.top)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(clipboardStore.items.prefix(5)), id: \.id) { item in
                            HStack {
                                Image(systemName: item.itemType.systemImage)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading) {
                                    Text(item.displayContent)
                                        .lineLimit(1)
                                    Text(item.timestamp, style: .relative)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if item.isPinned {
                                    Image(systemName: "pin.fill")
                                        .foregroundColor(.accentColor)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 200)
            }
            
            Spacer()
            
            // Instructions
            Text("Access MacBoard from the menu bar at the top of your screen")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(ClipboardStore.preview)
        .environmentObject(ClipboardMonitor())
        .frame(width: 600, height: 500)
}