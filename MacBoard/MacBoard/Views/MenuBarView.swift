import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject private var clipboardStore: ClipboardStore
    @EnvironmentObject private var clipboardMonitor: ClipboardMonitor
    
    @State private var searchText = ""
    @State private var selectedType: ClipboardItemType? = nil
    @State private var showingPreferences = false
    
    private let maxVisibleItems = 10
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            searchBar
            typeFilterBar
            itemsList
            footerView
        }
        .frame(width: 350, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Image(systemName: "clipboard")
                .foregroundColor(.accentColor)
            Text("MacBoard")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Monitoring status indicator
            Circle()
                .fill(clipboardMonitor.isMonitoring ? Color.green : Color.red)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search clipboard history...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Type Filter Bar
    private var typeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedType == nil) {
                    selectedType = nil
                }
                
                ForEach(ClipboardItemType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.displayName,
                        systemImage: type.systemImage,
                        isSelected: selectedType == type
                    ) {
                        selectedType = selectedType == type ? nil : type
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Items List
    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    ForEach(Array(filteredItems.prefix(maxVisibleItems)), id: \.id) { item in
                        ClipboardItemRow(item: item) {
                            copyItem(item)
                        }
                        .contextMenu {
                            contextMenu(for: item)
                        }
                    }
                    
                    if filteredItems.count > maxVisibleItems {
                        Text("\(filteredItems.count - maxVisibleItems) more items...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
    }
    
    // MARK: - Footer
    private var footerView: some View {
        HStack {
            Button("Clear All") {
                clipboardStore.clearAll()
            }
            .buttonStyle(.borderless)
            .foregroundColor(.red)
            
            Spacer()
            
            Button("Preferences") {
                showingPreferences = true
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .sheet(isPresented: $showingPreferences) {
            PreferencesView()
                .environmentObject(clipboardStore)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clipboard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No clipboard history")
                .font(.headline)
            
            Text("Copy something to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
    }
    
    // MARK: - Computed Properties
    private var filteredItems: [ClipboardItem] {
        var items = clipboardStore.items
        
        // Filter by type if selected
        if let selectedType = selectedType {
            items = items.filter { $0.itemType == selectedType }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            items = items.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
        
        return items
    }
    
    // MARK: - Actions
    private func copyItem(_ item: ClipboardItem) {
        clipboardMonitor.copyToClipboard(item)
        
        // Provide visual feedback
        NSApplication.shared.hide(nil) // Hide the menu
    }
    
    private func contextMenu(for item: ClipboardItem) -> some View {
        Group {
            Button(action: { copyItem(item) }) {
                Label("Copy", systemImage: "doc.on.clipboard")
            }
            
            Button(action: { clipboardStore.togglePin(for: item) }) {
                Label(
                    item.isPinned ? "Unpin" : "Pin",
                    systemImage: item.isPinned ? "pin.slash" : "pin"
                )
            }
            
            Divider()
            
            Button(action: { clipboardStore.deleteItem(item) }) {
                Label("Delete", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let systemImage: String?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, systemImage: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Clipboard Item Row
struct ClipboardItemRow: View {
    let item: ClipboardItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Type icon
                Image(systemName: item.itemType.systemImage)
                    .foregroundColor(.accentColor)
                    .frame(width: 20)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.displayContent)
                        .font(.body)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(item.itemType.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(item.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Pin indicator
                if item.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.accentColor)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.clear)
        }
        .buttonStyle(.plain)
        .background(
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
        )
        .onHover { isHovered in
            if isHovered {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

// MARK: - Preview
struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
            .environmentObject(ClipboardStore.preview)
            .environmentObject(ClipboardMonitor())
    }
}