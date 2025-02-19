//
//  ContentView.swift
//  Photo Edit Test
//
//  Created by Jeff Milner on 2025-02-17.
//


import SwiftUI
import PhotosUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ImageProcessorViewModel()
    @State private var showingSavedSettings = false
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $viewModel.imageSelection,
                         matching: .images,
                         photoLibrary: .shared()) {
                Label("Select Photo", systemImage: "photo")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            
            if viewModel.hasImage {
                ScrollView {
                    VStack(spacing: 20) {
                        AdjustmentSlider(
                            value: $viewModel.brightness,
                            range: -1...1,
                            label: "Brightness",
                            format: "%.1f"
                        )
                        
                        AdjustmentSlider(
                            value: $viewModel.contrast,
                            range: 0.5...1.5,
                            label: "Contrast",
                            format: "%.1f"
                        )
                        
                        AdjustmentSlider(
                            value: $viewModel.shadows,
                            range: 0...0.5,
                            label: "Shadows",
                            format: "%.2f",
                            minimumLabel: "Darker",
                            maximumLabel: "Lighter"
                        )
                        
                        AdjustmentSlider(
                            value: $viewModel.midtones,
                            range: 0...1,
                            label: "Midtones",
                            format: "%.2f",
                            minimumLabel: "Darker",
                            maximumLabel: "Lighter"
                        )
                        
                        AdjustmentSlider(
                            value: $viewModel.highlights,
                            range: 0.5...1,
                            label: "Highlights",
                            format: "%.2f",
                            minimumLabel: "Darker",
                            maximumLabel: "Brighter"
                        )
                    }
                    .padding()
                }
                
                if let image = viewModel.processedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .padding()
                        .shadow(radius: 5)
                    
                    VStack {
                        Button("Save to Photos") {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        HStack {
                            Button("Save Preset") {
                                viewModel.saveCurrentSettings(context: modelContext)
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Load Preset") {
                                showingSavedSettings = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                }
            } else if viewModel.isProcessing {
                ProgressView()
                    .scaleEffect(2)
                    .padding()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showingSavedSettings) {
            SavedSettingsView()
                .environmentObject(viewModel)
                .modelContainer(for: PhotoSettings.self)
        }
    }
}

#Preview {
    ContentView()
}
