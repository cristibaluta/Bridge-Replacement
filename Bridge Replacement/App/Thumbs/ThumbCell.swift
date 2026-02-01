//
//  ThumbCell.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 30.01.2026.
//
import SwiftUI

struct ThumbCell: View {
    let photo: PhotoItem
    let isSelected: Bool
    let isMultiSelected: Bool
    let onTap: (NSEvent.ModifierFlags) -> Void
    let size: CGFloat = 100
    @State private var thumbnailImage: NSImage?
    @State private var isLoading = false

    private var filename: String {
        URL(fileURLWithPath: photo.path).lastPathComponent
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Rectangle()
                    .fill(Color(.black))

                if let image = thumbnailImage {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
            }
            .frame(width: size, height: size)
            .overlay(
                Rectangle()
                    .stroke(
                        (isSelected || isMultiSelected) ? Color.blue : .clear,
                        lineWidth: 2
                    )
            )
            .onTapGesture {
                // Get current modifier keys from NSApp
                let modifiers = NSApp.currentEvent?.modifierFlags ?? []
                onTap(modifiers)
            }
            .onAppear {
                loadThumbnail()
            }

            // Filename with colored pill background based on label
            Text(filename)
                .font(.system(size: 11))
                .lineLimit(1)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(getLabelBackgroundColor())
                        .opacity(hasLabel() ? 1 : 0)
                )
                .foregroundColor(getLabelTextColor())
                .frame(height: 30)

            Spacer()
        }
    }

    private func loadThumbnail() {
        // Check if already cached in memory
        if let cachedImage = ThumbsManager.shared.getCachedThumbnail(for: photo.path) {
            self.thumbnailImage = cachedImage
            return
        }

        // Load asynchronously (from disk cache or generate new)
        isLoading = true
        ThumbsManager.shared.loadThumbnail(for: photo.path) { [photo] image in
            // Ensure we're updating the right cell
            guard self.photo.path == photo.path else { return }

            self.thumbnailImage = image
            self.isLoading = false
        }
    }

    private func hasLabel() -> Bool {
        return photo.xmp?.label != nil && !photo.xmp!.label!.isEmpty
    }

    private func getLabelBackgroundColor() -> Color {
        guard let label = photo.xmp?.label else { return .clear }

        switch label {
        case "Select":
            return .red
        case "Second":
            return .yellow
        case "Approved":
            return Color(red: 133/255, green: 199/255, blue: 102/255) // Keep existing green
        case "Review":
            return .blue
        case "To Do":
            return .purple
        default:
            return .clear
        }
    }

    private func getLabelTextColor() -> Color {
        guard let label = photo.xmp?.label else { return .primary }

        switch label {
        case "Select":
            return .white
        case "Second":
            return .black
        case "Approved":
            return .black
        case "Review":
            return .white
        case "To Do":
            return .white
        default:
            return .primary
        }
    }
}
