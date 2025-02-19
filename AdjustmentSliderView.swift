//
//  AdjustmentSliderView.swift
//  Photo Edit Test
//
//  Created by Jeff Milner on 2025-02-18.
//
 
import SwiftUI

struct AdjustmentSlider: View {
    @Binding var value: Float
    let range: ClosedRange<Float>
    let label: String
    let format: String
    var minimumLabel: String? = nil
    var maximumLabel: String? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                Spacer()
                Text(String(format: format, value))
            }
            
            Slider(value: $value, in: range) {
                Text(label)
            } minimumValueLabel: {
                Text(minimumLabel ?? "")
            } maximumValueLabel: {
                Text(maximumLabel ?? "")
            }
        }
    }
}

//#Preview {
//    AdjustmentSliderView()
//}
