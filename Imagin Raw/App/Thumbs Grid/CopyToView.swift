//
//  CopyToView.swift
//  Imagin Raw
//
//  Created by Cristian Baluta on 10.02.2026.
//

import SwiftUI
import AppKit

struct CopyToView: View {
    @Environment(\.dismiss) private var dismiss
    let photosToCoрy: [PhotoItem]
    let destinationURL: URL

    var body: some View {
        CopyProgressView(
            photosToCoрy: photosToCoрy,
            destinationURL: destinationURL,
            onComplete: {
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
        .frame(minWidth: 500, minHeight: 180)
    }
}

struct CopyProgressView: View {
    let photosToCoрy: [PhotoItem]
    let destinationURL: URL
    let onComplete: () -> Void
    let onCancel: () -> Void

    @State private var copyProgress: Double = 0.0
    @State private var currentFile: String = ""
    @State private var copiedCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var copyError: String?
    @State private var isCancelled = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Copying Files...")
                .font(.headline)

            // Progress bar
            ProgressView(value: copyProgress, total: 1.0)
                .progressViewStyle(.linear)
                .frame(height: 8)

            // Current file and count
            VStack(spacing: 4) {
                HStack {
                    Text("Copying: \(currentFile)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                }

                HStack {
                    Text("\(copiedCount) of \(totalCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }

            // Error message
            if let error = copyError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    Spacer()
                }
            }

            // Cancel button
            HStack {
                Spacer()
                Button(copyError != nil ? "Close" : "Cancel") {
                    if copyError == nil {
                        isCancelled = true
                    }
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .padding(20)
        .frame(minWidth: 500, minHeight: 180)
        .onAppear {
            performCopy()
        }
    }

    private func performCopy() {
        // Count total files to copy (RAW + potential JPGs)
        var filesToCopy: [(source: URL, filename: String)] = []

        for photo in photosToCoрy {
            let photoURL = URL(fileURLWithPath: photo.path)
            let baseName = photoURL.deletingPathExtension().lastPathComponent
            let directory = photoURL.deletingLastPathComponent()

            // Add the RAW file
            filesToCopy.append((source: photoURL, filename: photoURL.lastPathComponent))

            // Check for associated JPG
            for jpgExt in ["jpg", "jpeg", "JPG", "JPEG"] {
                let jpgURL = directory.appendingPathComponent("\(baseName).\(jpgExt)")
                if FileManager.default.fileExists(atPath: jpgURL.path) {
                    filesToCopy.append((source: jpgURL, filename: jpgURL.lastPathComponent))
                    break // Only add the first JPG found
                }
            }
        }

        totalCount = filesToCopy.count
        currentFile = "Preparing..."

        // Perform copy on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            for (index, file) in filesToCopy.enumerated() {
                // Check if cancelled
                if isCancelled {
                    break
                }

                DispatchQueue.main.async {
                    currentFile = file.filename
                }

                let destinationFileURL = destinationURL.appendingPathComponent(file.filename)

                do {
                    // Check if file already exists
                    if FileManager.default.fileExists(atPath: destinationFileURL.path) {
                        // Skip files that already exist
                        DispatchQueue.main.async {
                            copiedCount = index + 1
                            copyProgress = Double(copiedCount) / Double(totalCount)
                        }
                        continue
                    }

                    // Copy the file
                    try FileManager.default.copyItem(at: file.source, to: destinationFileURL)

                    DispatchQueue.main.async {
                        copiedCount = index + 1
                        copyProgress = Double(copiedCount) / Double(totalCount)
                    }
                } catch {
                    DispatchQueue.main.async {
                        copyError = "Failed to copy \(file.filename): \(error.localizedDescription)"
                    }
                    break
                }
            }

            // Complete
            DispatchQueue.main.async {
                if copyError == nil && !isCancelled {
                    // Success - close the dialog after a brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                }
            }
        }
    }
}
