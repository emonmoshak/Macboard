# MacBoard
**Your clipboard, supercharged.**

A lightweight, native macOS clipboard manager that runs in the menu bar and tracks clipboard history with instant access and powerful features.

## 🎯 Overview

MacBoard solves the fundamental problem of macOS's limited clipboard functionality by providing persistent clipboard history that's always accessible. Built with Swift and SwiftUI, it feels completely native while offering advanced features like pinning, search, and global hotkeys.

## ✨ Key Features

- 🧾 **Clipboard History** - Never lose copied content again
- 📌 **Pin Favorites** - Keep important items at the top
- ⌨️ **Global Hotkey** - Instant access with Cmd+Shift+V
- 🎨 **Native Design** - Follows macOS design principles
- 🌙 **Dark Mode** - Full system theme support
- 🚀 **Launch at Login** - Always ready when you need it
- 🧼 **Smart Cleanup** - Auto-clear old items
- 🔒 **Privacy First** - All data stored locally

## 🎯 Target Users

- Students and professionals who copy/paste frequently
- Developers managing code snippets and commands
- Anyone who needs quick access to clipboard history

## 🛠 Tech Stack

- **Language:** Swift 5
- **UI Framework:** SwiftUI
- **Integration:** AppKit (NSStatusItem for menu bar)
- **Storage:** Core Data / SQLite
- **Architecture:** MVVM pattern

## 📋 Project Status

**Current Phase:** Planning & Documentation Complete

**Implementation Timeline (2 weeks):**

**Week 1**
- [ ] Setup SwiftUI project structure
- [ ] Implement clipboard monitoring with NSPasteboard
- [ ] Core Data integration for persistence
- [ ] Basic menu bar UI

**Week 2**
- [ ] Pin/unpin and delete functionality
- [ ] Preferences panel
- [ ] Global hotkey support (Cmd+Shift+V)
- [ ] UI polish and testing

## 🏗 Architecture

```
MacBoard/
├── Models/
│   ├── ClipboardItem.swift      # Data model
│   └── ClipboardStore.swift     # Core Data manager
├── Views/
│   ├── MenuBarView.swift        # Main dropdown UI
│   └── PreferencesView.swift    # Settings panel
├── ViewModels/
│   └── ClipboardMonitor.swift   # Clipboard observation
└── Utilities/
    ├── HotkeyManager.swift      # Global shortcuts
    └── LaunchManager.swift      # Startup integration
```

## 🎨 Design Philosophy

- **Minimal UI:** Always out of the way, accessible when needed
- **Native Feel:** Follows macOS Human Interface Guidelines
- **Privacy First:** No cloud sync, all data stays local
- **Performance:** Lightweight memory usage, no system lag

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/username/macboard.git
cd macboard

# Open in Xcode
open MacBoard.xcodeproj
```

## 📖 Documentation

- [Product Requirements Document](MacBoard_PRD.md) - Detailed feature specifications
- [Implementation Plan](implementation.md) - Technical roadmap and stages  
- [UI/UX Design](MacBoard_UI_UX.md) - Design guidelines and user experience

## 🎯 Success Criteria

- ✅ Functional menu bar app with clipboard history
- ✅ Responsive hotkey support (Cmd+Shift+V)
- ✅ Lightweight memory usage (<50MB)
- ✅ Zero system crashes or instability
- ✅ Native macOS look and feel

## 🛑 Out of Scope (v1)

- iCloud sync across devices
- Rich formatting previews (HTML, RTF)
- Cross-platform support
- Clipboard sharing between users

## 🔮 Future Enhancements

- 🔍 Search functionality across history
- 🏷 Smart categorization (Text, Links, Code)
- ☁️ Optional encrypted iCloud sync
- 📱 iOS companion app

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with Swift and SwiftUI
- Inspired by the need for better clipboard management on macOS
- Following Apple's Human Interface Guidelines

---

**MacBoard** - Making clipboard management effortless on macOS.