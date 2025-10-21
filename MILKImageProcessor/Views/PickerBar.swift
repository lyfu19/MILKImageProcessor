//
//  PickerBar.swift
//  MILKImageProcessor
//
//  Created by 阿福 on 21/10/2025.
//

import SwiftUI
import PhotosUI

/// Bottom action bar for selecting photos and starting processing.
struct PickerBar: View {
    @Binding var selection: [PhotosPickerItem]
    let onStart: () -> Void
    let onReset: () -> Void
    var isProcessing: Bool
    
    var body: some View {
        HStack {
            // Photo picker (up to 10 images)
            DeferredPhotosPicker(
                title: "Select Photos",
                selection: $selection,
                maxSelectionCount: 10,
                matching: .images,
                disabled: isProcessing
            )
            
            Spacer()
            
            // Show actions when selection is not empty
            if !selection.isEmpty {
                Button("Start Processing", action: onStart)
                    .disabled(isProcessing)
                    .layoutPriority(1)
                Button("Reset", action: onReset)
                    .disabled(isProcessing)
                    .foregroundColor(.red)
                    .layoutPriority(1)
            }
        }
        .buttonStyle(.bordered)
        .lineLimit(1)               // Prevent text clipping
        .minimumScaleFactor(0.8)    // Adjust text for smaller widths
    }
}

#Preview {
    @Previewable @State var selection: [PhotosPickerItem] = []
    @Previewable @State var isProcessing = false
    PickerBar(
        selection: $selection,
        onStart: {
            print("Start Processing with \(selection.count) photos")
        },
        onReset: {
            selection.removeAll()
        },
        isProcessing: isProcessing
    )
}
