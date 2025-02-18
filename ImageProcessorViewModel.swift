//
//  ImageProcessorViewModel.swift
//  Photo Edit Test
//
//  Created by Jeff Milner on 2025-02-18.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Combine
import SwiftData

@MainActor
final class ImageProcessorViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var processedImage: UIImage?
    @Published var isProcessing = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    @Published var brightness: Float = 0.0
    @Published var contrast: Float = 1.0
    @Published var shadows: Float = 0.25
    @Published var midtones: Float = 0.5
    @Published var highlights: Float = 0.75
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet { handleImageSelection() }
    }
    
    // MARK: - Private Properties
    private var originalImage: CIImage?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Public Properties
    var hasImage: Bool {
        processedImage != nil || imageSelection != nil
    }
    
    // MARK: - Setup
    private func setupBindings() {
        Publishers.CombineLatest4($brightness, $contrast, $shadows, $midtones)
            .combineLatest($highlights)
            .debounce(for: .seconds(0.15), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.processPhoto()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Image Handling
    private func handleImageSelection() {
        guard let imageSelection else { return }
        isProcessing = true
        
        Task {
            do {
                guard let imageData = try await imageSelection.loadTransferable(type: Data.self) else {
                    throw ImageError.loadFailed
                }
                try await loadImage(imageData: imageData)
                try await processPhoto()
            } catch {
                showError(error: error)
            }
        }
    }
    
    private func loadImage(imageData: Data) async throws {
        guard let ciImage = CIImage(data: imageData) else {
            throw ImageError.processingFailed
        }
        originalImage = ciImage
    }
    
    // MARK: - Image Processing
    func processPhoto() {
        guard originalImage != nil else { return }
        isProcessing = true
        
        Task {
            do {
                let processedImage = try await applyFilters()
                self.processedImage = processedImage
                self.isProcessing = false
            } catch {
                showError(error: error)
            }
        }
    }
    
    private func applyFilters() async throws -> UIImage {
        guard let originalImage else {
            throw ImageError.processingFailed
        }
        
        let context = CIContext()
        var currentImage = originalImage
        
        // 1. Desaturate
        currentImage = currentImage.applyingFilter("CIColorControls", parameters: [
            kCIInputSaturationKey: 0.0
        ])
        
        // 2. Brightness/Contrast
        currentImage = currentImage.applyingFilter("CIColorControls", parameters: [
            kCIInputBrightnessKey: brightness,
            kCIInputContrastKey: contrast
        ])
        
        // 3. Tone Curve
        currentImage = currentImage.applyingFilter("CIToneCurve", parameters: [
            "inputPoint0": CIVector(x: 0.0, y: 0.0),
            "inputPoint1": CIVector(x: 0.25, y: CGFloat(shadows)),
            "inputPoint2": CIVector(x: 0.5, y: CGFloat(midtones)),
            "inputPoint3": CIVector(x: 0.75, y: CGFloat(highlights)),
            "inputPoint4": CIVector(x: 1.0, y: 1.0)
        ])
        
        guard let cgImage = context.createCGImage(currentImage, from: currentImage.extent) else {
            throw ImageError.renderingFailed
        }
        
        return UIImage(cgImage: cgImage)
    }

    // MARK: - SwiftData Operations
    func saveCurrentSettings(context: ModelContext) {
        let settings = PhotoSettings(
            timestamp: Date(),
            brightness: brightness,
            contrast: contrast,
            shadows: shadows,
            midtones: midtones,
            highlights: highlights
        )
        context.insert(settings)
    }
    
    func loadSettings(_ settings: PhotoSettings) {
        brightness = settings.brightness
        contrast = settings.contrast
        shadows = settings.shadows
        midtones = settings.midtones
        highlights = settings.highlights
    }
    
    func fetchAllSettings(context: ModelContext) -> [PhotoSettings] {
        let descriptor = FetchDescriptor<PhotoSettings>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Error Handling
    func showError(error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        isProcessing = false
    }
    
    func reset() {
        processedImage = nil
        imageSelection = nil
        brightness = 0.0
        contrast = 1.0
        shadows = 0.25
        midtones = 0.5
        highlights = 0.75
    }
}

enum ImageError: LocalizedError {
    case loadFailed
    case processingFailed
    case renderingFailed
    
    var errorDescription: String? {
        switch self {
        case .loadFailed: return "Failed to load image"
        case .processingFailed: return "Image processing failed"
        case .renderingFailed: return "Failed to create final image"
        }
    }
}
