//
//  PhotoItem.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 29.01.2026.
//

import Foundation

struct PhotoItem: Identifiable, Hashable {
    let id: UUID
    let path: String
    let xmp: XmpMetadata?
    let dateCreated: Date

    init(path: String, xmp: XmpMetadata? = nil) {
        self.id = UUID()
        self.path = path
        self.xmp = xmp
        
        // Get file creation date from filesystem
        if let attributes = try? FileManager.default.attributesOfItem(atPath: path),
           let creationDate = attributes[.creationDate] as? Date {
            self.dateCreated = creationDate
        } else {
            // Fallback to current date if file attributes can't be read
            self.dateCreated = Date()
        }
    }

    // Initializer that preserves the existing ID when updating XMP metadata
    init(id: UUID, path: String, xmp: XmpMetadata?, dateCreated: Date) {
        self.id = id
        self.path = path
        self.xmp = xmp
        self.dateCreated = dateCreated
    }
}
