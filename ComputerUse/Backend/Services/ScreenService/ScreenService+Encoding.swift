//
//  ScreenService+Encoding.swift
//  ComputerUseKit
//

import AppKit
import CoreGraphics

extension ScreenService {
    struct EncodedImage {
        let base64: String
        let mediaType: String
    }

    func encodeBase64(image: CGImage) -> EncodedImage {
        let maxSizeBytes = 3 * 1024 * 1024 // 3 MB max

        // Try JPEG compression with quality adjustment
        var quality: CGFloat = 0.85
        var data: Data?
        var currentImage = image

        // First attempt: try with original size
        var lastAttemptData: Data?
        for _ in 0 ..< 10 {
            let rep = NSBitmapImageRep(cgImage: currentImage)
            let jpegData = rep.representation(
                using: .jpeg,
                properties: [.compressionFactor: quality],
            )

            if let jpegData {
                lastAttemptData = jpegData
                if jpegData.count <= maxSizeBytes {
                    data = jpegData
                    break
                }

                // If too large, reduce quality
                quality = max(0.3, quality - 0.1)
            }
        }

        // If still too large, try reducing resolution
        if data == nil || (lastAttemptData?.count ?? 0) > maxSizeBytes {
            let scale: CGFloat = 0.75 // Reduce to 75% of original size
            if let scaledImage = scaleImage(image: image, scale: scale) {
                currentImage = scaledImage
                quality = 0.75

                for _ in 0 ..< 10 {
                    let rep = NSBitmapImageRep(cgImage: currentImage)
                    let jpegData = rep.representation(
                        using: .jpeg,
                        properties: [.compressionFactor: quality],
                    )

                    if let jpegData {
                        if jpegData.count <= maxSizeBytes {
                            data = jpegData
                            break
                        }
                        quality = max(0.3, quality - 0.1)
                    }
                }
            } else if let lastData = lastAttemptData {
                // Use last attempt even if slightly over limit
                data = lastData
            }
        }

        // If JPEG compression succeeded, return jpeg media type
        if let jpegData = data {
            return EncodedImage(
                base64: jpegData.base64EncodedString(),
                mediaType: "image/jpeg",
            )
        }

        // Fallback to PNG if JPEG compression failed
        let rep = NSBitmapImageRep(cgImage: image)
        let pngData = rep.representation(using: .png, properties: [:])
        return EncodedImage(
            base64: pngData?.base64EncodedString() ?? "",
            mediaType: "image/png",
        )
    }

    private func scaleImage(image: CGImage, scale: CGFloat) -> CGImage? {
        let width = Int(CGFloat(image.width) * scale)
        let height = Int(CGFloat(image.height) * scale)

        guard let colorSpace = image.colorSpace else { return nil }
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: image.bitmapInfo.rawValue,
        ) else { return nil }

        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }
}
