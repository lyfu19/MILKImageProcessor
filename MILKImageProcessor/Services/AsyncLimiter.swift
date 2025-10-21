//
//  AsyncLimiter.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 21/10/2025.
//

import Foundation

// MARK: - AsyncLimiter
/// A lightweight actor-based concurrency limiter.
/// Ensures no more than `limit` tasks run concurrently.
actor AsyncLimiter {
    // MARK: - Properties
    private let limit: Int
    private var inFlight = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []
    
    // MARK: - Initialization
    init(limit: Int) {
        self.limit = max(1, limit)
    }
    
    // MARK: - Public API
    /// Acquires a slot, suspending if the limit is reached.
    func acquire() async {
        if inFlight < limit {
            inFlight += 1
            return
        }
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            waiters.append(continuation)
        }
    }
    
    /// Releases a slot, resuming the next waiting task if available.
    func release() {
        if let first = waiters.first {
            waiters.removeFirst()
            first.resume()
        } else {
            inFlight = max(0, inFlight - 1)
        }
    }
}
