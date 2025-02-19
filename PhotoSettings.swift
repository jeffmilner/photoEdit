//
//  PhotoSettings.swift
//  Photo Edit Test
//
//  Created by Jeff Milner on 2025-02-18.
//
 
import SwiftData
import Foundation

@Model
final class PhotoSettings {
    var timestamp: Date
    var brightness: Float
    var contrast: Float
    var shadows: Float
    var midtones: Float
    var highlights: Float
        
    init(timestamp: Date, brightness: Float, contrast: Float, shadows: Float, midtones: Float, highlights: Float) {
        self.timestamp = timestamp
        self.brightness = brightness
        self.contrast = contrast
        self.shadows = shadows
        self.midtones = midtones
        self.highlights = highlights
    }
}
