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

    /// When false, the settings gear is hidden (iPhone already has a Settings tab).
    var showSettingsButton: Bool = true

    @State private var showingNewChallenge = false
    @State private var showingSettings = false
    @State private var challengeToDelete: Challenge?
    @State private var challengeToEdit: Challenge?

    var body: some View {
        List {
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            challengeToDelete = challenge
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            challengeToEdit = challenge
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .navigationDestination(for: Challenge.self) { challenge in
            ChallengeDetailView(challenge: challenge)
        }
        .navigationTitle("21DayForge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewChallenge = true
                } label: {
                    Label("New Challenge", systemImage: "plus")
                }
            }

            if showSettingsButton {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
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
        .sheet(item: $challengeToEdit) { challenge in
            EditChallengeView(challenge: challenge)
        }
        .confirmationDialog(
            "Delete Challenge",
            isPresented: Binding(
                get: { challengeToDelete != nil },
                set: { if !$0 { challengeToDelete = nil } }
            ),
            presenting: challengeToDelete
        ) { challenge in
            Button("Delete \"\(challenge.title)\"", role: .destructive) {
                withAnimation {
                    modelContext.delete(challenge)
                    if selectedChallenge?.persistentModelID == challenge.persistentModelID {
                        selectedChallenge = nil
                    }
                }
                challengeToDelete = nil
            }
        } message: { challenge in
            Text("This will permanently delete the challenge and all \(challenge.completedDays) days of progress. This can't be undone.")
        }
    }
}

// MARK: - Challenge Row

struct ChallengeRow: View {

    let challenge: Challenge

    var body: some View {
        HStack(spacing: 12) {
            // Quick-log toggle — .borderless prevents NavigationLink from also firing
            Button {
                withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                    challenge.toggleToday()
                }
            } label: {
                Image(systemName: toggleIcon)
                    .font(.title2)
                    .foregroundStyle(toggleColor)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.borderless)
            .disabled(!challenge.isTodayActionable)

            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(subtitleText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Status badge
            statusBadge
        }
        .padding(.vertical, 4)
    }

    private var toggleIcon: String {
        switch challenge.status {
        case .upcoming:  return "clock.circle"
        case .active:    return challenge.isTodayCompleted ? "checkmark.circle.fill" : "circle"
        case .completed: return "checkmark.seal.fill"
        case .expired:   return "xmark.circle"
        }
    }

    private var toggleColor: Color {
        switch challenge.status {
        case .upcoming:  return .blue
        case .active:    return challenge.isTodayCompleted ? .green : .secondary
        case .completed: return .green
        case .expired:   return .secondary
        }
    }

    private var subtitleText: String {
        switch challenge.status {
        case .upcoming:
            return "Starts \(challenge.startDate.formatted(.dateTime.month(.abbreviated).day()))"
        case .active:
            return "Day \(challenge.currentDay) of 21"
        case .completed:
            return "Completed!"
        case .expired:
            return "\(challenge.completedDays)/21 — Expired"
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        Text("\(challenge.completedDays)/21")
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

#Preview {
    NavigationStack {
        ChallengeListView(selectedChallenge: .constant(nil))
    }
    .modelContainer(for: Challenge.self, inMemory: true)
}
