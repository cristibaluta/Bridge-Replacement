//
//  ThumbCell.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 30.01.2026.
//
import SwiftUI

struct ThumbCell: View {
    let path: String
    let isSelected: Bool
    let size: CGFloat = 100
    @State private var image: NSImage? = nil
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 6) {

            // Thumbnail square
            ZStack {
                Rectangle()
                    .fill(Color(.black))

                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    ProgressView()
                        .scaleEffect(0.6)
                }
            }
            .frame(width: size, height: size)
            .overlay(
                Rectangle()
                    .stroke(isSelected ? Color.blue : .clear, lineWidth: 2)
            )
            .onAppear {
                loadThumbnailIfNeeded()
            }

            // Filename
            Text(path.split(separator: "/").last ?? "")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(width: size)

            Spacer()
        }
    }

    private func loadThumbnailIfNeeded() {
        guard !isLoading else { return }
        isLoading = true

        Task.detached(priority: .userInitiated) {
            // LibRaw operations now run safely on background thread via serial queue
            let data = RawWrapper().extractEmbeddedJPEG(self.path)

            // Switch to main actor only for UI updates
            await MainActor.run {
                if let data = data {
                    let swiftData = data as Data
                    if let nsImage = NSImage(data: swiftData) {
                        self.image = nsImage
                    } else {
                        print("Failed to create NSImage from NSData for path: \(self.path)")
                    }
                }
                self.isLoading = false
            }
        }
    }
}
