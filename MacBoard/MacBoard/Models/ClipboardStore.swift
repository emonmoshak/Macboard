import Foundation
import CoreData
import SwiftUI

class ClipboardStore: ObservableObject {
    
    // MARK: - Properties
    @Published var items: [ClipboardItem] = []
    @AppStorage("maxItems") var maxItems: Int = 100
    @AppStorage("retentionDays") var retentionDays: Int = 30
    
    // Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MacBoard")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    init() {
        loadItems()
        cleanupOldItems()
    }
    
    // MARK: - CRUD Operations
    
    /// Load all clipboard items from Core Data
    func loadItems() {
        let request: NSFetchRequest<ClipboardItem> = ClipboardItem.fetchRequest()
        
        // Sort by pinned first, then by timestamp (newest first)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ClipboardItem.isPinned, ascending: false),
            NSSortDescriptor(keyPath: \ClipboardItem.timestamp, ascending: false)
        ]
        
        do {
            items = try context.fetch(request)
        } catch {
            print("Error loading items: \(error)")
        }
    }
    
    /// Add a new clipboard item
    func addItem(_ content: String, type: ClipboardItemType) {
        // Check if item already exists (avoid duplicates)
        if let existingItem = items.first(where: { $0.content == content }) {
            // Update timestamp to move to top
            existingItem.timestamp = Date()
            saveContext()
            loadItems()
            return
        }
        
        let newItem = ClipboardItem(context: context, content: content, type: type)
        saveContext()
        loadItems()
        
        // Enforce item limit
        enforceItemLimit()
    }
    
    /// Add item from pasteboard
    func addItem(from pasteboard: NSPasteboard) {
        guard let item = ClipboardItem.from(pasteboard: pasteboard, context: context) else {
            return
        }
        
        // Check for duplicates
        if let existingItem = items.first(where: { $0.content == item.content }) {
            existingItem.timestamp = Date()
            context.delete(item) // Delete the newly created duplicate
            saveContext()
            loadItems()
            return
        }
        
        saveContext()
        loadItems()
        enforceItemLimit()
    }
    
    /// Toggle pin status of an item
    func togglePin(for item: ClipboardItem) {
        item.isPinned.toggle()
        saveContext()
        loadItems()
    }
    
    /// Delete a specific item
    func deleteItem(_ item: ClipboardItem) {
        context.delete(item)
        saveContext()
        loadItems()
    }
    
    /// Clear all items
    func clearAll() {
        let request: NSFetchRequest<NSFetchRequestResult> = ClipboardItem.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            items.removeAll()
        } catch {
            print("Error clearing all items: \(error)")
        }
    }
    
    /// Clear unpinned items only
    func clearUnpinned() {
        let unpinnedItems = items.filter { !$0.isPinned }
        for item in unpinnedItems {
            context.delete(item)
        }
        saveContext()
        loadItems()
    }
    
    // MARK: - Helper Methods
    
    /// Save the Core Data context
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    /// Enforce the maximum number of items (excluding pinned items)
    private func enforceItemLimit() {
        let unpinnedItems = items.filter { !$0.isPinned }
        
        if unpinnedItems.count > maxItems {
            let itemsToDelete = Array(unpinnedItems.suffix(unpinnedItems.count - maxItems))
            for item in itemsToDelete {
                context.delete(item)
            }
            saveContext()
            loadItems()
        }
    }
    
    /// Clean up old items based on retention policy
    private func cleanupOldItems() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date()) ?? Date()
        
        let request: NSFetchRequest<ClipboardItem> = ClipboardItem.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp < %@ AND isPinned == NO", cutoffDate as NSDate)
        
        do {
            let oldItems = try context.fetch(request)
            for item in oldItems {
                context.delete(item)
            }
            if !oldItems.isEmpty {
                saveContext()
                loadItems()
            }
        } catch {
            print("Error cleaning up old items: \(error)")
        }
    }
    
    /// Get items filtered by type
    func items(ofType type: ClipboardItemType) -> [ClipboardItem] {
        return items.filter { $0.itemType == type }
    }
    
    /// Search items by content
    func searchItems(_ searchText: String) -> [ClipboardItem] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - Preview Helper
extension ClipboardStore {
    static var preview: ClipboardStore {
        let store = ClipboardStore()
        
        // Add some sample data for previews
        let sampleItems = [
            ("Hello, World!", ClipboardItemType.text),
            ("https://github.com/username/macboard", ClipboardItemType.text),
            ("Sample code snippet:\nprint('Hello')", ClipboardItemType.text),
            ("/Users/user/Documents/file.txt", ClipboardItemType.fileURL)
        ]
        
        for (content, type) in sampleItems {
            store.addItem(content, type: type)
        }
        
        // Pin the first item
        if let firstItem = store.items.first {
            store.togglePin(for: firstItem)
        }
        
        return store
    }
}