//
//  DeferredPhotosPicker.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 21/10/2025.
//

import SwiftUI
import PhotosUI

/// A PhotosPicker wrapper that delays binding updates to avoid UI freeze
/// when dismissing the picker. Supports reset sync and cancelable delay.
struct DeferredPhotosPicker: View {
    let title: String
    @Binding var selection: [PhotosPickerItem]
    let maxSelectionCount: Int
    let matching: PHPickerFilter
    let disabled: Bool
    
    // Delay (in nanoseconds) before propagating selection updates.
    var propagationDelayNanos: UInt64 = 300_000_000
    
    @State private var internalSelection: [PhotosPickerItem] = []
    @State private var pendingPropagation: Task<Void, Never>?
    
    var body: some View {
        PhotosPicker(
            title,
            selection: $internalSelection,
            maxSelectionCount: maxSelectionCount,
            matching: matching
        )
        .disabled(disabled)
        // Internal → External (debounced with cancel)
        .onChange(of: internalSelection) { _, newValue in
            pendingPropagation?.cancel()
            pendingPropagation = Task { [propagationDelayNanos] in
                if propagationDelayNanos > 0 {
                    try? await Task.sleep(nanoseconds: propagationDelayNanos)
                }
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    selection = newValue
                }
            }
        }
        // External → Internal (sync reset or programmatic change)
        .onChange(of: selection) { _, newValue in
            pendingPropagation?.cancel()
            internalSelection = newValue
        }
    }
}

#Preview {
    @Previewable @State var selection: [PhotosPickerItem] = []
    DeferredPhotosPicker(
        title: "Select Photos",
        selection: $selection,
        maxSelectionCount: 10,
        matching: .images,
        disabled: false,
        propagationDelayNanos: 200_000_000
    )
}
