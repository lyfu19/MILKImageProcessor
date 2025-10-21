//
//  AsyncLimiterTests.swift
//  MILKImageProcessorTests
//
//  Created by 阿福 on 21/10/2025.
//

import Testing
@testable import MILKImageProcessor

@MainActor
struct AsyncLimiterTests {
    
    @Test("acquire() should respect the concurrency limit")
    func testLimiterRespectsLimit() async throws {
        let limiter = AsyncLimiter(limit: 2)
        let counter = Counter()
        
        await withTaskGroup(of: Void.self) { group in
            // Launch 5 tasks but only allow 2 concurrent at a time
            for _ in 0..<5 {
                group.addTask {
                    await limiter.acquire()
                    await counter.increment()
                    
                    // Simulate some work
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    
                    await counter.decrement()
                    await limiter.release()
                }
            }
        }
        
        // Wait for tasks to finish before checking the result
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify that the maximum concurrent running tasks never exceeded 2
        let maxConcurrent = await counter.maxValue
        #expect(maxConcurrent <= 2)
    }
}

/// A thread-safe counter to track the number of concurrent tasks.
actor Counter {
    private var current = 0
    private(set) var maxValue = 0
    
    func increment() {
        current += 1
        maxValue = max(maxValue, current)
    }
    
    func decrement() {
        current = max(0, current - 1)
    }
}
