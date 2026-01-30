//
//  FolderItem.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 30.01.2026.
//


struct FolderItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    var children: [FolderItem]? = nil
}
