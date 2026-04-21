//
//  ChallengeListView.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import SwiftUI
import SwiftData

struct ChallengeListView: View {

    @Query(sort: \Challenge.createdAt, order: .reverse)
    private var challenges: [Challenge]

    @Environment(\.modelContext) private var modelContext
    @Binding var selectedChallenge: Challenge?
    @State private var showingNewChallenge = false
    @State private var showingSettings = false

    var body: some View {
        List(selection: $selectedChallenge) {
            if challenges.isEmpty {
                ContentUnavailableView(
                    "Start Your Journey",
                    systemImage: "flame",
                    description: Text("Tap + to create your first 21-day challenge.")
                )
            } else {
                ForEach(challenges) { challenge in
                    NavigationLink(value: challenge) {
                        ChallengeRow(challenge: challenge)
                    }
                }
                .onDelete(perform: deleteChallenges)
            }
        }
        .navigationDestination(for: Challenge.self) { challenge in
            ChallengeDetailView(challenge: challenge)
        }
        .navigationTitle("21DayForge")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewChallenge = true
                } label: {
                    Label("New Challenge", systemImage: "plus")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showingNewChallenge) {
            NewChallengeView()
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingSettings = false }
                        }
                    }
            }
        }
    }

    private func deleteChallenges(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(challenges[index])
        }
    }
}

// MARK: - Challenge Row

struct ChallengeRow: View {

    let challenge: Challenge

    var body: some View {
        HStack(spacing: 12) {
            // Day counter circle
            ZStack {
                Circle()
                    .stroke(challenge.isComplete ? Color.green : Color.accentColor, lineWidth: 3)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: challenge.progress)
                    .stroke(challenge.isComplete ? Color.green : Color.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))

                Text("\(challenge.currentDay)")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundStyle(challenge.isComplete ? .green : .primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(challenge.isComplete ? "Completed!" : "Day \(challenge.currentDay) of 21")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if challenge.isComplete {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ChallengeListView(selectedChallenge: .constant(nil))
    }
    .modelContainer(for: Challenge.self, inMemory: true)
}
