//
//  ProcessingViewModelTests.swift
//  MILKImageProcessorTests
//
//  Created by 阿福 on 21/10/2025.
//

import Testing
@testable import MILKImageProcessor

@MainActor
struct ProcessingViewModelTests {
    
    @Test("startProcessing() runs without crashing when no selection")
    func testStartProcessingWithNoItems() async throws {
        let vm = ProcessingViewModel()
        // should simply return, not crash or throw
        await vm.startProcessing()
        #expect(vm.jobs.isEmpty)
    }
    
    @Test("reset() clears jobs and selections")
    func testResetClearsState() async throws {
        let vm = ProcessingViewModel()
        vm.selectedItems = []
        vm.jobs = [ImageJob(originalFilename: "mock")]
        
        vm.reset()
        
        #expect(vm.jobs.isEmpty)
        #expect(vm.selectedItems.isEmpty)
    }
}

