import Foundation
import CoreData
import AppKit

// MARK: - Core Data Entity
@objc(ClipboardItem)
public class ClipboardItem: NSManagedObject, Identifiable {
    
}

// MARK: - Core Data Properties
extension ClipboardItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipboardItem> {
        return NSFetchRequest<ClipboardItem>(entityName: "ClipboardItem")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var content: String
    @NSManaged public var type: String
    @NSManaged public var timestamp: Date
    @NSManaged public var isPinned: Bool
    @NSManaged public var imageData: Data?
    @NSManaged public var rtfData: Data?
}

// MARK: - ClipboardItem Extensions
extension ClipboardItem {
    
    // Computed properties for easier access
    var displayContent: String {
        let maxLength = 100
        if content.count > maxLength {
            return String(content.prefix(maxLength)) + "..."
        }
        return content
    }
    
    var image: NSImage? {
        guard let imageData = imageData else { return nil }
        return NSImage(data: imageData)
    }
    
    var itemType: ClipboardItemType {
        return ClipboardItemType(rawValue: type) ?? .text
    }
    
    // Convenience initializer
    convenience init(context: NSManagedObjectContext, content: String, type: ClipboardItemType) {
        self.init(context: context)
        self.id = UUID()
        self.content = content
        self.type = type.rawValue
        self.timestamp = Date()
        self.isPinned = false
    }
    
    // Create from pasteboard item
    static func from(pasteboard: NSPasteboard, context: NSManagedObjectContext) -> ClipboardItem? {
        // Handle text content
        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            return ClipboardItem(context: context, content: string, type: .text)
        }
        
        // Handle image content
        if let image = NSImage(pasteboard: pasteboard) {
            let item = ClipboardItem(context: context, content: "Image", type: .image)
            item.imageData = image.tiffRepresentation
            return item
        }
        
        // Handle file URLs
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            let urlStrings = urls.map { $0.absoluteString }.joined(separator: "\n")
            return ClipboardItem(context: context, content: urlStrings, type: .fileURL)
        }
        
        return nil
    }
}

// MARK: - ClipboardItemType Enum
enum ClipboardItemType: String, CaseIterable {
    case text = "text"
    case image = "image"
    case fileURL = "fileURL"
    case rtf = "rtf"
    
    var displayName: String {
        switch self {
        case .text:
            return "Text"
        case .image:
            return "Image"
        case .fileURL:
            return "File"
        case .rtf:
            return "Rich Text"
        }
    }
    
    var systemImage: String {
        switch self {
        case .text:
            return "doc.text"
        case .image:
            return "photo"
        case .fileURL:
            return "doc"
        case .rtf:
            return "doc.richtext"
        }
    }
}