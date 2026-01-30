//
//  BrowserModel.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 30.01.2026.
//

func loadFolderTree(at url: URL) -> FolderItem {
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
            children.append(loadFolderTree(at: folder))
        }
    }

    return FolderItem(
        url: url,
        children: children.isEmpty ? nil : children
    )
}


func loadPhotos(in folder: FolderItem?) -> [PhotoItem] {
    guard let folder else { return [] }

    let fm = FileManager.default
    let allowed = ["jpg", "jpeg", "png", "heic", "arw", "orf", "rw2"]

    let files = (try? fm.contentsOfDirectory(
        at: folder.url,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
    )) ?? []

    return files
        .filter { allowed.contains($0.pathExtension.lowercased()) }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
        .map { PhotoItem(path: $0.path) }
}


@MainActor
final class BrowserModel: ObservableObject {
    @Published var rootFolder: FolderItem
    @Published var selectedFolder: FolderItem?
    @Published var selectedPhoto: PhotoItem?

    init() {
        let pictures = FileManager.default.urls(
            for: .picturesDirectory,
            in: .userDomainMask
        ).first!

        self.rootFolder = loadFolderTree(at: pictures)
    }
}
