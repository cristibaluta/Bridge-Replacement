//
//  SidebarView.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 30.01.2026.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var model: BrowserModel
    @State private var expandedFolders: Set<URL> = []
    @State private var showingFolderPicker = false
    let onDoubleClick: (() -> Void)?

    private let expandedFoldersKey = "ExpandedFolders"
    private let selectedFolderKey = "SelectedFolder"

    var body: some View {
        VStack(spacing: 0) {
            // Main folder list
            List(selection: $model.selectedFolder) {
                ForEach(model.rootFolders) { rootFolder in
                    FolderRowView(
                        folder: rootFolder,
                        expandedFolders: $expandedFolders,
                        selectedFolder: $model.selectedFolder,
                        saveExpandedState: saveExpandedState,
                        onDoubleClick: {
                            onDoubleClick?()
                        },
                        model: model
                    )
                }
                .onDelete(perform: deleteFolders)
            }
            .listStyle(.sidebar)
            .focusable(false)

            // Bottom bar with add button
            HStack {
                Button(action: {
                    showingFolderPicker = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Add folder")

                Spacer()

                Text("\(model.rootFolders.count) folders")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .onAppear {
            loadExpandedState()
            loadSelectedFolder()
        }
        .onChange(of: model.selectedFolder) { _, newValue in
            saveSelectedFolder(newValue)
        }
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    model.addFolder(at: url)
                }
            case .failure(let error):
                print("Failed to select folder: \(error)")
            }
        }
    }

    private func loadExpandedState() {
        if let data = UserDefaults.standard.data(forKey: expandedFoldersKey),
           let urls = try? JSONDecoder().decode([URL].self, from: data) {
            expandedFolders = Set(urls)
        }
    }

    private func saveExpandedState() {
        let urls = Array(expandedFolders)
        if let data = try? JSONEncoder().encode(urls) {
            UserDefaults.standard.set(data, forKey: expandedFoldersKey)
        }
    }

    private func loadSelectedFolder() {
        if let data = UserDefaults.standard.data(forKey: selectedFolderKey),
           let url = try? JSONDecoder().decode(URL.self, from: data) {
            // Find the folder in any of the root folders that matches the saved URL
            for rootFolder in model.rootFolders {
                if let folder = findFolder(url: url, in: rootFolder) {
                    model.selectedFolder = folder
                    return
                }
            }
        }
    }

    private func saveSelectedFolder(_ folder: FolderItem?) {
        if let folder = folder,
           let data = try? JSONEncoder().encode(folder.url) {
            UserDefaults.standard.set(data, forKey: selectedFolderKey)
        }
    }

    private func findFolder(url: URL, in folderItem: FolderItem) -> FolderItem? {
        if folderItem.url == url {
            return folderItem
        }

        if let children = folderItem.children {
            for child in children {
                if let found = findFolder(url: url, in: child) {
                    return found
                }
            }
        }

        return nil
    }

    private func deleteFolders(offsets: IndexSet) {
        for index in offsets {
            let folder = model.rootFolders[index]
            model.removeFolder(at: folder.url)
        }
    }
}
