//
//  ContentView.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 20/10/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ProcessingViewModel()
    @State private var isRunning = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if !viewModel.jobs.isEmpty {
                        // Show processing or completed jobs
                        ForEach(viewModel.jobs) { job in
                            JobCard(job: job)
                        }
                    }
                    else if !viewModel.selectedItems.isEmpty {
                        // Show selected photos before processing
                        SelectedPreviewGrid(items: viewModel.selectedItems)
                    }
                    else {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("Select some photos to start processing")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 400)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 80)
            }
            .safeAreaInset(edge: .bottom) {
                // Action bar with picker and controls
                PickerBar(
                    selection: $viewModel.selectedItems,
                    onStart: {
                        Task {
                            isRunning = true
                            defer { isRunning = false }
                            await viewModel.startProcessing()
                        }
                    },
                    onReset: {
                        viewModel.reset()
                    },
                    isProcessing: isRunning
                )
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .overlay(Divider(), alignment: .top)
            }
            .navigationTitle("MILK Image Processor")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isRunning {
                        ProgressView()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
