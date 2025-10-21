//
//  ImageProcessingService.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 21/10/2025.
//

import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// MARK: - Error Definition

/// Image processing errors.
enum ImageProcessingError: LocalizedError {
    case decodeFailed
    case resizeFailed
    case encodeFailed
    
    var errorDescription: String? {
        switch self {
        case .decodeFailed:
            return "Failed to decode the input image."
        case .resizeFailed:
            return "Failed to resize the image."
        case .encodeFailed:
            return "Failed to encode the image as JPEG."
        }
    }
}

// MARK: - Image Processing Service

/// Handles image resizing and JPEG encoding on background threads.
actor ImageProcessingService {
    // MARK: - Public API
    
    /// Resizes an image so that its longest side is limited to `maxPixel`, preserving aspect ratio.
    func resizedJPEGData(
        from originalData: Data,
        maxPixel: CGFloat,
        quality: CGFloat = 0.9,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> Data {
        // Run heavy image work in a detached background task
        return try await Task.detached(priority: .userInitiated) {
            // Step 1. Decode
            Self.safeProgress(0.1, onProgress)
            let options: [CFString: Any] = [
                kCGImageSourceShouldAllowFloat: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
            ]
            guard let source = CGImageSourceCreateWithData(originalData as CFData, nil),
                  let cgImage = CGImageSourceCreateImageAtIndex(source, 0, options as CFDictionary) else {
                throw ImageProcessingError.decodeFailed
            }
            
            // Step 2. Compute target size
            Self.safeProgress(0.3, onProgress)
            let width = CGFloat(cgImage.width)
            let height = CGFloat(cgImage.height)
            let longest = max(width, height)
            let scale = min(1.0, maxPixel / longest)
            let newWidth = Int(width * scale)
            let newHeight = Int(height * scale)
            
            // Step 3. Resize with high interpolation quality
            Self.safeProgress(0.6, onProgress)
            guard let colorSpace = cgImage.colorSpace,
                  let context = CGContext(
                    data: nil,
                    width: newWidth,
                    height: newHeight,
                    bitsPerComponent: cgImage.bitsPerComponent,
                    bytesPerRow: 0,
                    space: colorSpace,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                  ) else {
                throw ImageProcessingError.resizeFailed
            }
            
            // Step 4. Encode to JPEG
            Self.safeProgress(0.9, onProgress)
            context.interpolationQuality = .high
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(newWidth), height: CGFloat(newHeight)))
            
            guard let resizedImage = context.makeImage() else {
                throw ImageProcessingError.resizeFailed
            }
            
            // Encode to JPEG
            let data = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
                throw ImageProcessingError.encodeFailed
            }
            
            CGImageDestinationAddImage(destination, resizedImage, [
                kCGImageDestinationLossyCompressionQuality: quality
            ] as CFDictionary)
            
            guard CGImageDestinationFinalize(destination) else {
                throw ImageProcessingError.encodeFailed
            }
            
            Self.safeProgress(1.0, onProgress)
            return data as Data
        }.value
    }
    
    // MARK: - Helpers
    
    /// Dispatches progress updates to the main actor.
    private static func safeProgress(_ value: Double, _ handler: ((Double) -> Void)?) {
        if let handler {
            Task { @MainActor in handler(value) }
        }
    }
}
