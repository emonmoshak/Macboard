import SwiftUI
import ServiceManagement

struct PreferencesView: View {
    @EnvironmentObject private var clipboardStore: ClipboardStore
    
    // Settings stored in UserDefaults via @AppStorage
    @AppStorage("maxItems") private var maxItems: Int = 100
    @AppStorage("retentionDays") private var retentionDays: Int = 30
    @AppStorage("monitoringEnabled") private var monitoringEnabled: Bool = true
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("pollInterval") private var pollInterval: Double = 0.5
    @AppStorage("showNotifications") private var showNotifications: Bool = true
    @AppStorage("globalHotkey") private var globalHotkey: String = "⌘⇧V"
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)
            
            storageTab
                .tabItem {
                    Label("Storage", systemImage: "internaldrive")
                }
                .tag(1)
            
            hotkeyTab
                .tabItem {
                    Label("Hotkeys", systemImage: "keyboard")
                }
                .tag(2)
            
            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(3)
        }
        .frame(width: 500, height: 400)
    }
    
    // MARK: - General Tab
    private var generalTab: some View {
        Form {
            Section(header: Text("Clipboard Monitoring")) {
                Toggle("Enable clipboard monitoring", isOn: $monitoringEnabled)
                    .help("Monitor clipboard changes and save history")
                
                if monitoringEnabled {
                    VStack(alignment: .leading) {
                        Text("Poll interval: \(pollInterval, specifier: "%.1f") seconds")
                        Slider(value: $pollInterval, in: 0.1...2.0, step: 0.1)
                            .help("How often to check for clipboard changes")
                    }
                }
            }
            
            Section(header: Text("Startup")) {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .help("Automatically start MacBoard when you log in")
                    .onChange(of: launchAtLogin) { newValue in
                        setLaunchAtLogin(enabled: newValue)
                    }
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Show clipboard change notifications", isOn: $showNotifications)
                    .help("Show a brief notification when new items are copied")
            }
        }
        .padding()
    }
    
    // MARK: - Storage Tab
    private var storageTab: some View {
        Form {
            Section(header: Text("History Limits")) {
                VStack(alignment: .leading) {
                    Text("Maximum items: \(maxItems)")
                    Slider(value: Binding(
                        get: { Double(maxItems) },
                        set: { maxItems = Int($0) }
                    ), in: 10...500, step: 10)
                    .help("Maximum number of items to keep in history")
                }
                
                VStack(alignment: .leading) {
                    Text("Retention period: \(retentionDays) days")
                    Slider(value: Binding(
                        get: { Double(retentionDays) },
                        set: { retentionDays = Int($0) }
                    ), in: 1...365, step: 1)
                    .help("Automatically delete items older than this many days")
                }
            }
            
            Section(header: Text("Storage Management")) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current items: \(clipboardStore.items.count)")
                        Text("Pinned items: \(clipboardStore.items.filter(\.isPinned).count)")
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button("Clear Unpinned Items") {
                            clipboardStore.clearUnpinned()
                        }
                        .foregroundColor(.orange)
                        
                        Button("Clear All Items") {
                            clipboardStore.clearAll()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Hotkey Tab
    private var hotkeyTab: some View {
        Form {
            Section(header: Text("Global Shortcuts")) {
                HStack {
                    Text("Show clipboard history:")
                    Spacer()
                    Text(globalHotkey)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(4)
                        .font(.system(.body, design: .monospaced))
                }
                
                Text("Press the key combination you want to use")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // TODO: Implement hotkey recording
                Button("Record New Hotkey") {
                    // This would open a hotkey recording interface
                }
                .disabled(true) // Placeholder for now
            }
            
            Section(header: Text("Quick Actions")) {
                Toggle("Auto-paste on selection", isOn: .constant(false))
                    .help("Automatically paste selected items to active application")
                    .disabled(true) // Future feature
            }
        }
        .padding()
    }
    
    // MARK: - About Tab
    private var aboutTab: some View {
        VStack(spacing: 20) {
            Image(systemName: "clipboard")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("MacBoard")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("A lightweight macOS clipboard manager")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Link("GitHub Repository", destination: URL(string: "https://github.com/username/macboard")!)
                Link("Report an Issue", destination: URL(string: "https://github.com/username/macboard/issues")!)
            }
            .font(.footnote)
            
            Spacer()
            
            Text("Built with ❤️ using Swift and SwiftUI")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    private func setLaunchAtLogin(enabled: Bool) {
        // This would integrate with LaunchAtLogin library
        // For now, just a placeholder
        if enabled {
            print("Enabling launch at login")
        } else {
            print("Disabling launch at login")
        }
    }
}

// MARK: - Preference Sections
struct PreferenceSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Settings Row
struct SettingsRow<Content: View>: View {
    let label: String
    let help: String?
    let content: Content
    
    init(_ label: String, help: String? = nil, @ViewBuilder content: () -> Content) {
        self.label = label
        self.help = help
        self.content = content()
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.body)
                
                if let help = help {
                    Text(help)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            content
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview
struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
            .environmentObject(ClipboardStore.preview)
    }
}