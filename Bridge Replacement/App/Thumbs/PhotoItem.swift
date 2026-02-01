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
    var toDelete: Bool = false // Transient property, not saved to XMP

    init(path: String, xmp: XmpMetadata? = nil, dateCreated: Date) {
        self.id = UUID()
        self.path = path
        self.xmp = xmp
        self.dateCreated = dateCreated
        self.toDelete = false
    }

    // Initializer that preserves the existing ID when updating XMP metadata
    init(id: UUID, path: String, xmp: XmpMetadata?, dateCreated: Date) {
        self.id = id
        self.path = path
        self.xmp = xmp
        self.dateCreated = dateCreated
        self.toDelete = false
    }

    // Initializer that preserves the existing ID and toDelete state when updating XMP metadata
    init(id: UUID, path: String, xmp: XmpMetadata?, dateCreated: Date, toDelete: Bool) {
        self.id = id
        self.path = path
        self.xmp = xmp
        self.dateCreated = dateCreated
        self.toDelete = toDelete
    }
}
