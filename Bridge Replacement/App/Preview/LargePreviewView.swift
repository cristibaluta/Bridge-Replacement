//
//  LargePreviewView.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 30.01.2026.
//

import SwiftUI

struct LargePreviewView: View {
    let photo: PhotoItem
    @State private var preview: NSImage?
    @State private var isLoading = false

    var body: some View {
        VStack {
            if let nsImage = preview {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Text("Failed to load image")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            loadPreview()
        }
        .onChange(of: photo) { _, _ in
            loadPreview()
        }
    }

    private func loadPreview() {
        guard preview == nil else { return }

        isLoading = true

        Task.detached(priority: .userInitiated) {
            let loadedImage = await loadImage(from: photo.path)

            await MainActor.run {
                self.preview = loadedImage
                self.isLoading = false
            }
        }
    }

    private func loadImage(from path: String) async -> NSImage? {
        let url = URL(fileURLWithPath: path)
        let fileExtension = url.pathExtension.lowercased()

        // Define RAW file extensions
        let rawExtensions = ["arw", "orf", "rw2", "cr2", "cr3", "crw", "nef", "nrw",
                           "srf", "sr2", "raw", "raf", "pef", "ptx", "dng", "3fr",
                           "fff", "iiq", "mef", "mos", "x3f", "srw", "dcr", "kdc",
                           "k25", "kc2", "mrw", "erf", "bay", "ndd", "sti", "rwl", "r3d"]

        if rawExtensions.contains(fileExtension) {
            // Load RAW file using RawWrapper
            print("Loading RAW preview for: \(path)")
            guard let data = RawWrapper.shared().extractEmbeddedJPEG(path) else {
                print("Failed to extract embedded JPEG from RAW file: \(path)")
                return nil
            }
            return NSImage(data: data)
        } else {
            // Load regular image file directly from disk
            print("Loading image preview for: \(path)")
            return NSImage(contentsOfFile: path)
        }
    }
}
