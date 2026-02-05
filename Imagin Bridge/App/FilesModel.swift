//
//  BrowserModel.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 30.01.2026.
//
import Foundation
import CoreServices

// MARK: - File Monitoring

class FileSystemMonitor {
    private var monitoredFolders: [URL: DispatchSourceFileSystemObject] = [:]
    private let queue = DispatchQueue(label: "file.monitor", qos: .utility)
    weak var delegate: FileSystemMonitorDelegate?

    func startMonitoring(url: URL) {
        // Don't monitor the same folder twice
        if monitoredFolders[url] != nil {
            return
        }

        let fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            print("Failed to open file descriptor for \(url.path)")
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .rename, .delete],
            queue: queue
        )

        source.setEventHandler { [weak self] in
            let events = source.mask
            if events.contains(.write) || events.contains(.rename) {
                Task { @MainActor in
                    self?.delegate?.folderContentsDidChange(at: url)
                }
            }
        }

        source.setCancelHandler {
            close(fileDescriptor)
        }

        source.resume()
        monitoredFolders[url] = source
        print("Started monitoring folder: \(url.path)")
    }

    func stopMonitoring(url: URL) {
        if let source = monitoredFolders.removeValue(forKey: url) {
            source.cancel()
            print("Stopped monitoring folder: \(url.path)")
        }
    }

    func stopAllMonitoring() {
        for (_, source) in monitoredFolders {
            source.cancel()
        }
        monitoredFolders.removeAll()
        print("Stopped all folder monitoring")
    }

    deinit {
        stopAllMonitoring()
    }
}

@MainActor
protocol FileSystemMonitorDelegate: AnyObject {
    func folderContentsDidChange(at url: URL)
}

// MARK: - Security-Scoped Bookmark Management

struct FolderBookmark: Codable {
    let url: URL
    let bookmarkData: Data

    enum CodingKeys: String, CodingKey {
        case url, bookmarkData
    }
}

func createSecurityScopedBookmark(for url: URL) -> Data? {
    do {
        let bookmarkData = try url.bookmarkData(
            options: [.withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        return bookmarkData
    } catch {
        print("Failed to create bookmark for \(url): \(error)")
        return nil
    }
}

func restoreSecurityScopedAccess(from bookmarkData: Data) -> URL? {
    var isStale = false
    do {
        let url = try URL(
            resolvingBookmarkData: bookmarkData,
            options: [.withSecurityScope, .withoutUI],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )

        if isStale {
            print("Bookmark data is stale for URL: \(url)")
            // TODO: Handle stale bookmarks by re-requesting access
        }

        // Start accessing the security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to start accessing security-scoped resource: \(url)")
            return nil
        }

        return url
    } catch {
        print("Failed to resolve bookmark: \(error)")
        return nil
    }
}

func loadFolderTree(at url: URL, maxDepth: Int = 2, currentDepth: Int = 0, bookmarkData: Data? = nil) -> FolderItem {
    print("Load folder tree: \(url.path) currentDepth: \(currentDepth)")
    var children: [FolderItem] = []

    let keys: Set<URLResourceKey> = [.isDirectoryKey, .isHiddenKey]
    let fm = FileManager.default

    if let items = try? fm.contentsOfDirectory(
        at: url,
        includingPropertiesForKeys: Array(keys),
        options: [.skipsHiddenFiles]
    ) {
        let sortedFolders = items
            .compactMap { item -> URL? in
                guard let values = try? item.resourceValues(forKeys: keys), values.isDirectory == true else { return nil }
                return item
            }
            .sorted {
                $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending
            }

        for folder in sortedFolders {
            if currentDepth < maxDepth {
                // Load recursively up to maxDepth
                children.append(loadFolderTree(at: folder, maxDepth: maxDepth, currentDepth: currentDepth + 1))
            } else {
                // At maxDepth, just check if this folder has subfolders to determine if it should be expandable
                let hasSubfolders = hasDirectSubfolders(at: folder)
                children.append(FolderItem(
                    url: folder,
                    children: hasSubfolders ? [] : nil // Empty array means "expandable but not loaded", nil means "no children"
                ))
            }
        }
    }

    return FolderItem(
        url: url,
        children: children.isEmpty ? nil : children,
        bookmarkData: bookmarkData
    )
}

func hasDirectSubfolders(at url: URL) -> Bool {
    let keys: Set<URLResourceKey> = [.isDirectoryKey, .isHiddenKey]
    let fm = FileManager.default

    guard let items = try? fm.contentsOfDirectory(
        at: url,
        includingPropertiesForKeys: Array(keys),
        options: [.skipsHiddenFiles]
    ) else { return false }

    // Check if any item is a directory
    for item in items {
        if let values = try? item.resourceValues(forKeys: keys), values.isDirectory == true {
            return true
        }
    }
    return false
}

func loadFolderChildren(for folder: FolderItem) -> [FolderItem] {
    // Load children on demand (2 levels deep from this folder)
    let childTree = loadFolderTree(at: folder.url, maxDepth: 2, currentDepth: 0)
    return childTree.children ?? []
}


func loadPhotos(in folder: FolderItem?) -> [PhotoItem] {
    guard let folder else { return [] }

    let fm = FileManager.default
    let allowed = ["jpg", "jpeg", "png", "heic", "tiff", "tif", "arw", "orf", "rw2",
                   "cr2", "cr3", "crw", "nef", "nrw", "srf", "sr2", "raw", "raf",
                   "pef", "ptx", "dng", "3fr", "fff", "iiq", "mef", "mos", "x3f",
                   "srw", "dcr", "kdc", "k25", "kc2", "mrw", "erf", "bay", "ndd",
                   "sti", "rwl", "r3d"]

    let files = (try? fm.contentsOfDirectory(
        at: folder.url,
        includingPropertiesForKeys: [.creationDateKey],
        options: [.skipsHiddenFiles]
    )) ?? []

    // Separate image files from XMP files
    let imageFiles = files.filter { allowed.contains($0.pathExtension.lowercased()) }
    let xmpFiles = files.filter { $0.pathExtension.lowercased() == "xmp" }

    // Create a dictionary for XMP lookup by base filename
    var xmpLookup: [String: String] = [:]
    for xmpFile in xmpFiles {
        let baseName = xmpFile.deletingPathExtension().lastPathComponent
        if let xmpContent = try? String(contentsOf: xmpFile, encoding: .utf8) {
            xmpLookup[baseName] = xmpContent
        }
    }

    // Create PhotoItems with matched XMP content
    return imageFiles
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
        .map { imageFile in
            let baseName = imageFile.deletingPathExtension().lastPathComponent

            // Get creation date from the file attributes we already retrieved
            let creationDate = (try? imageFile.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date()

            if let xmpContent = xmpLookup[baseName] {
                let xmp = XmpParser.parseMetadata(from: xmpContent)
                return PhotoItem(path: imageFile.path, xmp: xmp, dateCreated: creationDate)
            } else {
                return PhotoItem(path: imageFile.path, xmp: nil, dateCreated: creationDate)
            }
        }
}


@MainActor
final class FilesModel: ObservableObject, FileSystemMonitorDelegate {
    @Published var rootFolders: [FolderItem] = []
    @Published var selectedFolder: FolderItem? {
        didSet {
            // Stop any pending thumbnail requests for the previous folder
            ThumbsManager.shared.stopQueue()
            loadPhotosForSelectedFolder()
        }
    }
    @Published var selectedPhoto: PhotoItem?
    @Published var photos: [PhotoItem] = []

    private let userFoldersKey = "UserManagedFolderBookmarks"
    private var accessedURLs: Set<URL> = []
    private let fileMonitor = FileSystemMonitor()

    init() {
        fileMonitor.delegate = self
        loadUserFolders()
    }

    deinit {
        // Stop file monitoring
        fileMonitor.stopAllMonitoring()

        // Stop accessing all security-scoped resources
        for url in accessedURLs {
            url.stopAccessingSecurityScopedResource()
        }
    }

    // MARK: - FileSystemMonitorDelegate

    func folderContentsDidChange(at url: URL) {
        print("Folder contents changed at: \(url.path)")

        // Find and refresh the affected folder in our tree
        refreshFolderTree(for: url)

        // If this is the currently selected folder, refresh the photos
        if let selectedFolder = selectedFolder, selectedFolder.url == url {
            loadPhotosForSelectedFolder()
        }
    }

    private func refreshFolderTree(for changedURL: URL) {
        // Find the folder in our root folders and refresh it
        for i in 0..<rootFolders.count {
            if let updatedFolder = refreshFolderRecursively(folder: rootFolders[i], changedURL: changedURL) {
                rootFolders[i] = updatedFolder
                break
            }
        }
    }

    private func refreshFolderRecursively(folder: FolderItem, changedURL: URL) -> FolderItem? {
        // Check if this is the folder that changed
        if folder.url == changedURL {
            // Refresh this folder's children
            let refreshedTree = loadFolderTree(at: folder.url, maxDepth: 2, currentDepth: 0, bookmarkData: folder.bookmarkData)
            return refreshedTree
        }

        // Check if the changed URL is a child of this folder
        if changedURL.path.hasPrefix(folder.url.path) {
            // Recursively refresh children
            var updatedChildren: [FolderItem]? = nil
            if let children = folder.children {
                updatedChildren = children.compactMap { child in
                    refreshFolderRecursively(folder: child, changedURL: changedURL)
                }
                // If no children were updated, keep the original children
                if updatedChildren?.isEmpty == true {
                    updatedChildren = children
                }
            }
            return FolderItem(url: folder.url, children: updatedChildren, bookmarkData: folder.bookmarkData)
        }

        return nil // This folder wasn't affected by the change
    }

    func addFolder(at url: URL) {
        // Check if folder already exists
        if rootFolders.contains(where: { $0.url == url }) {
            return
        }

        // Start accessing the security-scoped resource first (this is crucial for fileImporter URLs)
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to start accessing security-scoped resource: \(url)")
            return
        }

        // Create security-scoped bookmark for the selected folder
        guard let bookmarkData = createSecurityScopedBookmark(for: url) else {
            print("Failed to create bookmark for folder: \(url)")
            // Stop accessing if bookmark creation fails
            url.stopAccessingSecurityScopedResource()
            return
        }

        accessedURLs.insert(url)

        // Load the folder tree and add to root folders
        let newFolder = loadFolderTree(at: url, maxDepth: 2, currentDepth: 0, bookmarkData: bookmarkData)
        rootFolders.append(newFolder)

        // Start monitoring the folder for file system changes
        fileMonitor.startMonitoring(url: url)

        // Save to UserDefaults
        saveUserFolders()
    }

    func removeFolder(at url: URL) {
        // Stop monitoring the folder
        fileMonitor.stopMonitoring(url: url)

        // Stop accessing the security-scoped resource
        if accessedURLs.contains(url) {
            url.stopAccessingSecurityScopedResource()
            accessedURLs.remove(url)
        }

        rootFolders.removeAll { $0.url == url }
        saveUserFolders()
    }

    private func loadUserFolders() {
        if let data = UserDefaults.standard.data(forKey: userFoldersKey),
           let folderBookmarks = try? JSONDecoder().decode([FolderBookmark].self, from: data) {

            // Restore folder trees from saved bookmarks
            for bookmark in folderBookmarks {
                // Restore access using the security-scoped bookmark
                if let restoredURL = restoreSecurityScopedAccess(from: bookmark.bookmarkData) {
                    accessedURLs.insert(restoredURL)

                    // Verify the folder still exists before adding it
                    if FileManager.default.fileExists(atPath: restoredURL.path) {
                        let folderTree = loadFolderTree(at: restoredURL, maxDepth: 2, currentDepth: 0, bookmarkData: bookmark.bookmarkData)
                        rootFolders.append(folderTree)

                        // Start monitoring the restored folder for changes
                        fileMonitor.startMonitoring(url: restoredURL)
                    } else {
                        // Folder no longer exists, stop accessing the resource
                        restoredURL.stopAccessingSecurityScopedResource()
                        accessedURLs.remove(restoredURL)
                    }
                } else {
                    print("Failed to restore access for bookmark: \(bookmark.url)")
                }
            }
        }
        // On fresh install, show no folders - user must add them manually
    }

    private func saveUserFolders() {
        let folderBookmarks = rootFolders.compactMap { folder -> FolderBookmark? in
            guard let bookmarkData = folder.bookmarkData else { return nil }
            return FolderBookmark(url: folder.url, bookmarkData: bookmarkData)
        }

        if let data = try? JSONEncoder().encode(folderBookmarks) {
            UserDefaults.standard.set(data, forKey: userFoldersKey)
        }
    }

    func loadChildrenOnDemand(for folder: FolderItem) {
        // Find the folder in our tree and update its children
        updateFolderChildren(folder: folder, in: &rootFolders)
    }

    private func updateFolderChildren(folder: FolderItem, in folders: inout [FolderItem]) {
        for i in 0..<folders.count {
            if folders[i].url == folder.url {
                // Found the folder, load its children
                let updatedChildren = loadFolderChildren(for: folder)
                folders[i] = FolderItem(url: folder.url, children: updatedChildren.isEmpty ? nil : updatedChildren, bookmarkData: folder.bookmarkData)
                return
            } else if let children = folders[i].children {
                // Recursively search in children
                var mutableChildren = children
                updateFolderChildren(folder: folder, in: &mutableChildren)
                folders[i] = FolderItem(url: folders[i].url, children: mutableChildren, bookmarkData: folders[i].bookmarkData)
            }
        }
    }

    private func loadPhotosForSelectedFolder() {
        photos = loadPhotos(in: selectedFolder)
    }
}
