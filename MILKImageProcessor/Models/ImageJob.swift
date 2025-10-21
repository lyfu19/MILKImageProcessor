//
//  ImageJob.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 20/10/2025.
//

import Foundation

/// Describes the current processing state of an image.
enum JobStatus: Equatable {
    case idle
    case processing(progress: Double?)
    case success(ProcessedResult)
    case failure(String)
}

/// Represents a single image processing task.
struct ImageJob: Identifiable, Equatable {
    let id = UUID()
    var originalFilename: String
    var status: JobStatus = .idle
}
