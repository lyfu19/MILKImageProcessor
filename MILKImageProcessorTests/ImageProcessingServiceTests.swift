//
//  ImageProcessingServiceTests.swift
//  MILKImageProcessorTests
//
//  Created by 阿福 on 21/10/2025.
//

import Foundation
import CoreGraphics
import UniformTypeIdentifiers
import Testing
import ImageIO
@testable import MILKImageProcessor

@Suite("ImageProcessingService Tests")
struct ImageProcessingServiceTests {
    
    // Helper to make a small test image
    private func makeTestImageData() -> Data {
        let size = CGSize(width: 10, height: 10)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(origin: .zero, size: size))
        let image = context.makeImage()!
        
        let data = NSMutableData()
        let dest = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, image, nil)
        CGImageDestinationFinalize(dest)
        return data as Data
    }
    
    @Test("Resizes and encodes JPEG successfully")
    func testResizedJPEGDataSuccess() async throws {
        let processor = ImageProcessingService()
        let input = makeTestImageData()
        
        var progressValues: [Double] = []
        let data = try await processor.resizedJPEGData(from: input, maxPixel: 5) { progress in
            progressValues.append(progress)
        }
        
        #expect(!data.isEmpty)
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        let type = CGImageSourceGetType(source!)
        #expect(type == UTType.jpeg.identifier as CFString)
        #expect(progressValues.contains(1.0))
    }
    
    @Test("Throws decodeFailed for invalid data")
    func testDecodeFailed() async {
        let processor = ImageProcessingService()
        let invalidData = Data("not-an-image".utf8)
        do {
            _ = try await processor.resizedJPEGData(from: invalidData, maxPixel: 100)
            Issue.record("Expected decodeFailed, but succeeded")
        } catch {
            #expect(error as? ImageProcessingError == .decodeFailed)
        }
    }
    
    @Test("Progress callback reports increasing values")
    func testProgressIncrements() async throws {
        let processor = ImageProcessingService()
        let input = makeTestImageData()
        
        var recorded: [Double] = []
        _ = try await processor.resizedJPEGData(from: input, maxPixel: 10) { value in
            recorded.append(value)
        }
        
        #expect(recorded.count >= 3)
        #expect(recorded.sorted() == recorded)
        #expect(recorded.last == 1.0)
    }
}
