//
//  JobCard.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 21/10/2025.
//

import SwiftUI

/// Displays the processing status and results of a single image job.
struct JobCard: View {
    let job: ImageJob
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Filename
            Text(job.originalFilename)
                .font(.headline)
            
            // Content varies by job status
            switch job.status {
            case .idle:
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("Waiting...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            case .processing(let progress):
                HStack {
                    ProgressView(value: progress ?? 0.0)
                    Spacer()
                    Text("Processing...")
                }
            case .success(let result):
                HStack(spacing: 12) {
                    ImageThumb(url: result.thumbnailURL)
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Saved 1024px", systemImage: "checkmark.circle")
                            .foregroundStyle(.green)
                        Text(result.smallURL.path.replacingOccurrences(of: NSTemporaryDirectory(), with: "tmp/"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Label("Saved 256px", systemImage: "checkmark.circle")
                            .foregroundStyle(.green)
                        Text(result.thumbnailURL.path.replacingOccurrences(of: NSTemporaryDirectory(), with: "tmp/"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            case .failure(let msg):
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                    Spacer()
                    Text(msg)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ImageThumb: View {
    let url: URL
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // Placeholder while loading
                Rectangle()
                    .fill(.secondary)
                    .frame(width: 64, height: 64)
                    .overlay(ProgressView())
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .clipped()
                    .cornerRadius(8)
            case .failure:
                // Fallback when loading fails
                Rectangle()
                    .fill(.secondary)
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: "photo"))
            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    JobCard(job: .init(
        originalFilename: "sample_photo.jpg",
        status: .success(.init(
            originalURL: URL(filePath: "/tmp/original.jpg"),
            smallURL: URL(filePath: "/tmp/small.jpg"),
            thumbnailURL: URL(filePath: "/tmp/thumb.jpg")
        ))
    ))
}
