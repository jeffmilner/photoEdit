//
//  Photo_Edit_TestApp.swift
//  Photo Edit Test
//
//  Created by Jeff Milner on 2025-02-17.
//

import SwiftUI
import SwiftData
 
@main
struct Photo_Edit_TestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PhotoSettings.self)
    }
}
