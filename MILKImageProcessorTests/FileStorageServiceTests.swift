//
//  FileStorageServiceTests.swift
//  MILKImageProcessorTests
//
//  Created by 阿福 on 21/10/2025.
//

import Foundation
import Testing
@testable import MILKImageProcessor

@Suite("FileStorageService Tests")
struct FileStorageServiceTests {
    
    @Test("Create job folder successfully")
    func testMakeJobFolder() async throws {
        let storage = FileStorageService()
        let jobName = "TestJob_\(UUID().uuidString)"
        let folderURL = try await storage.makeJobFolder(named: jobName)
        
        #expect(FileManager.default.fileExists(atPath: folderURL.path))
        #expect(folderURL.lastPathComponent == jobName)
    }
    
    @Test("Write JPEG successfully")
    func testWriteJPEG() async throws {
        let storage = FileStorageService()
        let jobName = "WriteJob_\(UUID().uuidString)"
        let folderURL = try await storage.makeJobFolder(named: jobName)
        let fileURL = folderURL.appending(path: "test.jpg")
        
        let mockData = Data("mock-jpeg-data".utf8)
        try await storage.writeJPEG(mockData, to: fileURL)
        
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
        
        let readData = try Data(contentsOf: fileURL)
        #expect(readData == mockData)
    }
    
    @Test("Write JPEG should fail for invalid URL")
    func testWriteJPEGFailure() async {
        let storage = FileStorageService()
        let invalidURL = URL(fileURLWithPath: "/dev/null/test.jpg")
        
        do {
            try await storage.writeJPEG(Data(), to: invalidURL)
            Issue.record("Expected to throw, but succeeded")
        } catch {
            #expect(error is FileStorageService.FileStorageError)
            #expect((error as? FileStorageService.FileStorageError) == .writeFailed)
        }
    }
}

