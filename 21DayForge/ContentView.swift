//
//  ContentView.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @AppStorage("appearance") private var appearance: String = Appearance.system.rawValue
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboarding: Bool = false

    private var selectedAppearance: Appearance {
        Appearance(rawValue: appearance) ?? .system
    }

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    var body: some View {
        Group {
            #if os(iOS)
            if horizontalSizeClass == .regular {
                SidebarNavigationView()
            } else {
                CompactNavigationView()
            }
            #else
            SidebarNavigationView()
            #endif
        }
        .preferredColorScheme(selectedAppearance.colorScheme)
        .onAppear {
            showOnboarding = !hasCompletedOnboarding
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding, userName: $userName)
        }
    }
}

// MARK: - Sidebar Navigation (iPad / macOS)

struct SidebarNavigationView: View {

    @State private var selectedChallenge: Challenge?

    var body: some View {
        NavigationSplitView {
            ChallengeListView(selectedChallenge: $selectedChallenge, showSettingsButton: true)
        } detail: {
            if let challenge = selectedChallenge {
                ChallengeDetailView(challenge: challenge)
            } else {
                ContentUnavailableView(
                    "Select a Challenge",
                    systemImage: "flame",
                    description: Text("Pick a challenge from the sidebar to view your progress.")
                )
            }
        }
    }
}

// MARK: - Compact Navigation (iPhone)

struct CompactNavigationView: View {

    var body: some View {
        TabView {
            Tab("Today", systemImage: "sun.max.fill") {
                TodayView()
            }

            Tab("Challenges", systemImage: "flame") {
                NavigationStack {
                    ChallengeListView(selectedChallenge: .constant(nil), showSettingsButton: false)
                }
            }

            Tab("Stats", systemImage: "chart.bar") {
                NavigationStack {
                    StatsView()
                }
            }

            Tab("Settings", systemImage: "gearshape") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
    }
}

#Preview("iPhone") {
    CompactNavigationView()
        .modelContainer(for: Challenge.self, inMemory: true)
}

#Preview("iPad / macOS") {
    SidebarNavigationView()
        .modelContainer(for: Challenge.self, inMemory: true)
}
