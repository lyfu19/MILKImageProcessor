//
//  ProcessedResult.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 21/10/2025.
//

import Foundation

/// Stores file URLs for all generated image outputs.
struct ProcessedResult: Equatable {
    let originalURL: URL
    let smallURL: URL       // 1024px resized version
    let thumbnailURL: URL   // 256px thumbnail version
}
