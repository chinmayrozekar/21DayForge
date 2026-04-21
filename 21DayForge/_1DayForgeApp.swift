//
//  _1DayForgeApp.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import SwiftUI
import SwiftData

@main
struct _1DayForgeApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Challenge.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
