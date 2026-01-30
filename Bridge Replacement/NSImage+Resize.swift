//
//  NSImage+Resize.swift
//  Imagin Bridge
//
//  Created by Cristian Baluta on 29.01.2026.
//

import AppKit

extension NSImage {
    func resized(maxSize: CGFloat) -> NSImage {
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = NSSize(
            width: size.width * ratio,
            height: size.height * ratio
        )

        let image = NSImage(size: newSize)
        image.lockFocus()
        draw(in: NSRect(origin: .zero, size: newSize))
        image.unlockFocus()
        return image
    }
    
    func resizedCG(maxSize: CGFloat) -> NSImage? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        let scale = min(maxSize / width, maxSize / height)
        let newWidth = Int(width * scale)
        let newHeight = Int(height * scale)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        guard let ctx = context else { return nil }

        ctx.interpolationQuality = .high
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        guard let resizedCG = ctx.makeImage() else { return nil }

        return NSImage(cgImage: resizedCG, size: NSSize(width: newWidth, height: newHeight))
    }
}
