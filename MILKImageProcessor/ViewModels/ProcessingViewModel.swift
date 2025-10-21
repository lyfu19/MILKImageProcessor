//
//  ProcessingViewModel.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 21/10/2025.
//

import SwiftUI
import PhotosUI
import UIKit

/// Handles photo selection, image processing, and file storage.
@Observable
@MainActor
final class ProcessingViewModel {
    // MARK: - State
    var selectedItems: [PhotosPickerItem] = []
    var jobs: [ImageJob] = []
    
    // MARK: - Dependencies
    private let processor = ImageProcessingService()
    private let storage = FileStorageService()
    private let limiter = AsyncLimiter(limit: 2)
    
    // MARK: - Public API
    /// Clears current selections and job results.
    func reset() {
        selectedItems.removeAll()
        jobs.removeAll()
    }
    
    /// Starts processing selected images with concurrency limiting.
    func startProcessing() async {
        // Skip if no photo selected
        guard !selectedItems.isEmpty else { return }
        
        // Initialize job list
        jobs = selectedItems.prefix(10).enumerated().map { index, _ in
            ImageJob(originalFilename: "item_\(index + 1)")
        }
        
        // Process photos concurrently (limited by AsyncLimiter)
        await withTaskGroup(of: Void.self) { group in
            for (index, item) in selectedItems.prefix(10).enumerated() {
                group.addTask { [weak self] in
                    guard let self else { return }
                    await self.processItem(item, index: index)
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    /// Processes a single image with progress tracking and file saving.
    private func processItem(_ item: PhotosPickerItem, index: Int) async {
        await self.limiter.acquire()
        defer { Task { await limiter.release() } }
        
        updateStatus(at: index, to: .processing(progress: nil))
        
        do {
            let data = try await self.loadOriginalData(from: item)
            let jobID = jobs[index].id.uuidString
            
            // Resize: 1024px (first half of progress)
            let small = try await self.processor.resizedJPEGData(from: data, maxPixel: 1024) { progress in
                self.jobs[index].status = .processing(progress: progress * 0.5)
            }
            // Resize: 256px (second half)
            let thumb = try await self.processor.resizedJPEGData(from: data, maxPixel: 256) { progress in
                self.jobs[index].status = .processing(progress: 0.5 + progress * 0.5)
            }
            
            // Save processed images
            let folder = try await self.storage.makeJobFolder(named: jobID)
            let originalURL = folder.appending(path: "original.jpg", directoryHint: .notDirectory)
            let smallURL = folder.appending(path: "small.jpg", directoryHint: .notDirectory)
            let thumbURL = folder.appending(path: "thumb.jpg", directoryHint: .notDirectory)
            
            try await self.storage.writeJPEG(data, to: originalURL)
            try await self.storage.writeJPEG(small, to: smallURL)
            try await self.storage.writeJPEG(thumb, to: thumbURL)
            
            print("Saved successfully:")
            print("Original:", originalURL.path)
            print("Small:", smallURL.path)
            print("Thumb:", thumbURL.path)
            
            // Mark success
            let result = ProcessedResult(originalURL: originalURL, smallURL: smallURL, thumbnailURL: thumbURL)
            updateStatus(at: index, to: .success(result))
        } catch {
            updateStatus(at: index, to: .failure(error.localizedDescription))
        }
    }
    
    /// Loads raw image data from a picker item.
    private func loadOriginalData(from item: PhotosPickerItem) async throws -> Data {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            throw ImageProcessingError.decodeFailed
        }
        return data
    }
    
    /// Updates job status safely on the main actor.
    private func updateStatus(at index: Int, to status: JobStatus) {
        guard jobs.indices.contains(index) else { return }
        jobs[index].status = status
    }
}
