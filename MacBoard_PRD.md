# Product Requirements Document (PRD) – MacBoard

## 🧠 Problem
macOS does not provide a persistent clipboard history. Users can only access the last copied item, losing important information when copying multiple items in succession.

## 🎯 Solution
MacBoard is a lightweight, native macOS clipboard manager that runs in the menu bar and tracks clipboard history. It allows users to search, pin, and access previous clipboard items with a single hotkey.

---

## 🎯 Goals
- Store and display clipboard history
- Provide fast, searchable access
- Run silently in the menu bar
- Launch at startup
- Support text, image, and file URL types
- Allow pinning favorite items
- Provide user preferences (e.g., max items, launch at login)

---

## ❌ Out of Scope (for v1)
- iCloud sync
- Cross-device syncing
- Clipboard sharing
- Rich formatting previews (e.g., HTML, RTF)

---

## 🛠 Core Features
- Clipboard monitoring (text, image, files)
- SQLite/Core Data storage
- Menu bar dropdown UI
- Preferences panel
- Global shortcut (Cmd+Shift+V)
- Clear history
- Pin/unpin entries
- Dark mode support

---

## 👨‍💻 Tech Stack
- Swift 5
- SwiftUI
- AppKit (for menu bar integration)
- Core Data / SQLite
- LaunchAgent (for launch at login)
- Accessibility API (to monitor clipboard)
- Sparkle (for auto updates - optional)

---

## 🧱 Architecture
- MVVM pattern
- ClipboardMonitor.swift: Observes clipboard
- ClipboardStore.swift: Handles data persistence
- MenuBarView.swift: Menu bar UI
- PreferencesView.swift: App settings

---

## ✅ Success Criteria
- Functional menu bar app with clipboard history
- Usable hotkey support
- Lightweight memory usage
- No system crashes or instability
- Positive user feedback

---

## 📅 Timeline (2 weeks)
**Week 1**
- [ ] Setup SwiftUI project
- [ ] Implement clipboard monitoring
- [ ] Store items in Core Data
- [ ] Basic menu bar UI

**Week 2**
- [ ] Add pin/unpin, delete, and clear features
- [ ] Implement Preferences UI
- [ ] Add hotkey support
- [ ] Polish UI, test, and package

