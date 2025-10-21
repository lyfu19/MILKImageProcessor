//
//  SelectedPreviewGrid.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 21/10/2025.
//

import SwiftUI
import PhotosUI

/// Displays thumbnails of selected photos with loading placeholders.
struct SelectedPreviewGrid: View {
    let items: [PhotosPickerItem]
    @State private var thumbnails: [UIImage?] = []
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)]) {
            ForEach(thumbnails.indices, id: \.self) { index in
                ZStack {
                    if let image = thumbnails[index] {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .overlay(ProgressView())
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary.opacity(0.3))
                )
                .animation(.easeInOut, value: thumbnails[index] != nil)
            }
        }
        // Reload thumbnails when the selection changes
        .task(id: items) {
            guard !items.isEmpty else {
                thumbnails = []
                return
            }
            
            thumbnails = Array(repeating: nil, count: items.count)
            let limiter = AsyncLimiter(limit: 2)
            
            for (index, item) in items.enumerated() {
                await limiter.acquire()
                Task.detached(priority: .userInitiated) {
                    defer { Task { await limiter.release() } }
                    
                    guard let data = try? await item.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    
                    await MainActor.run {
                        thumbnails[index] = image
                    }
                }
            }
        }
        .animation(.easeInOut, value: thumbnails.compactMap { $0 }.count)
        .padding(.vertical, 10)
    }
}

#Preview {
    SelectedPreviewGrid(items: [])
}
