# Imagin Raw

A lightweight, fast, and native macOS application for managing and organizing RAW photos. Built with SwiftUI and designed as a streamlined alternative to Adobe Bridge.

## Screenshots

### Main Interface
![Main Interface](screenshots/small-thumbs.jpeg)
*Browse your RAW photos with a clean, responsive grid interface*

### Thumbnail Grid View
![Filtered Thumbnails](screenshots/filtered-thumbs.jpeg)
![Thumbnail Grid](screenshots/large-thumbs.jpeg)
*Multiple grid sizes with intelligent thumbnail caching*

![Thumbnail Grid](screenshots/sidebar-closed-1.jpeg)
![Thumbnail Grid](screenshots/sidebar-closed-2.jpeg)
*Double click a folder to view the photos and close the sidebar, to quickly make more space for the previews*

## Features

### 📁 Folder Management
- **Add multiple root folders** from anywhere on your system or external drives
- **Real-time file system monitoring** - automatically detects new photos, deletions, and folder changes
- **Security-scoped bookmarks** - remembers your folders between app launches

### 🖼️ Photo Management
- **RAW format support** for 30+ camera formats:
  - Canon (CR2, CR3, CRW)
  - Nikon (NEF, NRW)
  - Sony (ARW, SRF, SR2)
  - Fujifilm (RAF)
  - Olympus (ORF)
  - Panasonic (RW2)
  - And many more...
- **JPEG, PNG, HEIC, and TIFF** support
- **Smart JPG handling** - automatically hides JPEGs when RAW+JPG pairs exist
- **XMP sidecar files** - reads and writes metadata without modifying original files
- **Adobe Camera Raw (ACR)** file detection

### ⭐ Rating & Labeling (RAW Files Only)
- **5-star rating system** with keyboard shortcuts (1-5)
- **Color-coded labels**:
  - 🔴 Select (6)
  - 🟡 Second (7)
  - 🟢 Approved (8)
  - 🔵 Review (9)
  - 🟣 To Do (0)
- **Remove labels** with keyboard shortcut (-)
- **Mark for deletion** with the shortcut (d). This is not deleting the photos right away, you need to filter them and move them to trash with the right click. This state is not preserver between album changes.
- **XMP metadata storage** - compatible with Adobe Lightroom and Bridge

### 🔍 Filtering & Sorting
- **Filter by label** - show only photos with specific labels
- **Sort options**:
  - By name (alphabetical)
  - By date created

### 🖼️ Viewing Options
- **Quickly switch between 2 grid types**:
  - 3 columns (100px thumbnails) with large preview
  - 4 columns (200px thumbnails) with small preview (portrait previews could still fit well)
- **Intelligent thumbnail caching** with disk persistence

### ⌨️ Keyboard Shortcuts
#### Navigation
- **Arrow Keys** - Navigate between photos
- **Cmd+A** - Select all photos
- **Cmd+Click / Shift+Click** - Multi-select photos

#### Rating & Labeling (RAW files only)
- **1-5** - Set star rating
- **6** - Apply "Select" label
- **7** - Apply "Second" label
- **8** - Apply "Approved" label
- **9** - Apply "Review" label
- **0** - Apply "To Do" label
- **-** - Remove label

#### Other
- **D or Delete** - Mark photo for deletion
- **Return** - Open selected photo(s) in external editor

### 🗑️ File Operations
- **Move to Trash** - Right-click context menu
- **Smart deletion** - automatically removes associated JPG, XMP, and ACR files when deleting RAW photos
- **Thumbnail cache cleanup** - removes cached thumbnails when files are deleted
- **Mark for deletion** - flag photos without actually deleting them

### 🚀 Performance
- **Intelligent thumbnail caching**:
  - Memory cache with LRU eviction
  - Disk cache with organized folder structure
  - Priority-based queue system
- **Background processing** - non-blocking thumbnail generation
- **Optimized RAW decoding** - uses LibRaw for fast embedded JPEG extraction
- **Minimal memory footprint** - efficient handling of large photo libraries

### 🔗 External App Integration
- **Open in external editor** - Photoshop, Lightroom, etc.
- **Reveal in Finder** - quick access to file location
- **Configurable default app** - set your preferred photo editor

## Technical Details

### Built With
- **SwiftUI** - Modern declarative UI framework
- **AppKit** - Native macOS integration
- **LibRaw** - High-performance RAW image decoding
- **FSEvents** - Real-time file system monitoring

### System Requirements
- macOS 14.6 or later
- Apple Silicon or Intel processor

## Installation

Download the latest release from Releases

---

**Note**: This app is designed specifically for photographers who need a fast, lightweight tool for organizing RAW photos without the overhead of Adobe Bridge or Lightroom's catalog system.
