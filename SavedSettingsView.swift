//
//  SavedSettingsView.swift
//  Photo Edit Test
//
//  Created by Jeff Milner on 2025-02-18.
//
 
import SwiftUI
import SwiftData

struct SavedSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: ImageProcessorViewModel 
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.fetchAllSettings(context: modelContext)) { settings in
                    VStack(alignment: .leading) {
                        Text(settings.timestamp, style: .date)
                            .font(.caption)
                        Text(String(format: "B: %.1f • C: %.1f • S: %.2f • M: %.2f • H: %.2f",
                                    settings.brightness,
                                    settings.contrast,
                                    settings.shadows,
                                    settings.midtones,
                                    settings.highlights))
                        .font(.caption2)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.loadSettings(settings)
                        dismiss()
                    }
                }
                .onDelete { indexes in
                    for index in indexes {
                        let settings = viewModel.fetchAllSettings(context: modelContext)[index]
                        modelContext.delete(settings)
                    }
                }
            }
            .navigationTitle("Saved Presets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

//#Preview {
//    SavedSettingsView()
//}
