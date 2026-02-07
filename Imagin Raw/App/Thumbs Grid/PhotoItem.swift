//
//  PhotoItem.swift
//  Imagin Raw
//
//  Created by Cristian Baluta on 29.01.2026.
//

import Foundation

struct PhotoItem: Identifiable, Hashable {
    let id: UUID
    let path: String
    let xmp: XmpMetadata?
    let dateCreated: Date
    let hasACR: Bool // Indicates if an ACR (Adobe Camera Raw) file exists for this photo
    var toDelete: Bool = false // Transient property, not saved to XMP

    init(path: String, xmp: XmpMetadata? = nil, dateCreated: Date, hasACR: Bool = false) {
        self.id = UUID()
        self.path = path
        self.xmp = xmp
        self.dateCreated = dateCreated
        self.hasACR = hasACR
        self.toDelete = false
    }

    // Initializer that preserves the existing ID when updating XMP metadata
    init(id: UUID, path: String, xmp: XmpMetadata?, dateCreated: Date, hasACR: Bool = false) {
        self.id = id
        self.path = path
        self.xmp = xmp
        self.dateCreated = dateCreated
        self.hasACR = hasACR
        self.toDelete = false
    }

    // Initializer that preserves the existing ID and toDelete state when updating XMP metadata
    init(id: UUID, path: String, xmp: XmpMetadata?, dateCreated: Date, toDelete: Bool, hasACR: Bool = false) {
        self.id = id
        self.path = path
        self.xmp = xmp
        self.dateCreated = dateCreated
        self.toDelete = toDelete
        self.hasACR = hasACR
    }
    
    // Computed property to check if this is a RAW file
    var isRawFile: Bool {
        let rawExtensions = ["arw", "orf", "rw2", "cr2", "cr3", "crw", "nef", "nrw",
                           "srf", "sr2", "raw", "raf", "pef", "ptx", "dng", "3fr",
                           "fff", "iiq", "mef", "mos", "x3f", "srw", "dcr", "kdc",
                           "k25", "kc2", "mrw", "erf", "bay", "ndd", "sti", "rwl", "r3d"]
        let fileExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
        return rawExtensions.contains(fileExtension)
    }
}
