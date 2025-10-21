//
//  FileStorageService.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 21/10/2025.
//

import Foundation

/// Handles saving processed images under the app’s temporary directory (`/tmp/Processed/`).
actor FileStorageService {
    // MARK: - Error Definition
    enum FileStorageError: LocalizedError {
        case cannotCreateFolder
        case writeFailed
        
        var errorDescription: String? {
            switch self {
            case .cannotCreateFolder:
                return "Failed to create storage folder."
            case .writeFailed:
                return "Failed to write JPEG file to disk."
            }
        }
    }
    
    // MARK: - Properties
    private let baseFolderName = "Processed"
    
    // MARK: - Public API
    /// Creates a dedicated subfolder for a specific job.
    func makeJobFolder(named name: String) async throws -> URL {
        let base = try await self.baseFolderURL()
        
        return try await Task.detached(priority: .userInitiated) {
            let jobFolder = base.appending(path: name, directoryHint: .isDirectory)
            if !FileManager.default.fileExists(atPath: jobFolder.path) {
                do {
                    try FileManager.default.createDirectory(at: jobFolder, withIntermediateDirectories: true)
                } catch {
                    throw FileStorageError.cannotCreateFolder
                }
            }
            return jobFolder
        }.value
    }
    
    /// Writes JPEG data atomically to a file.
    func writeJPEG(_ data: Data, to url: URL) async throws {
        try await Task.detached(priority: .userInitiated) {
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                throw FileStorageError.writeFailed
            }
        }.value
    }
    
    // MARK: - Private Helpers
    /// Returns the base folder URL, creating it if needed.
    private func baseFolderURL() async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            let tmp = FileManager.default.temporaryDirectory
            let folder = tmp.appending(path: self.baseFolderName, directoryHint: .isDirectory)
            if !FileManager.default.fileExists(atPath: folder.path) {
                do {
                    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                } catch {
                    throw FileStorageError.cannotCreateFolder
                }
            }
            return folder
        }.value
    }
}
