//
//  EditChallengeView.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 23/04/26.
//

import SwiftUI
import SwiftData

struct EditChallengeView: View {

    @Bindable var challenge: Challenge
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var goal: String

    init(challenge: Challenge) {
        self.challenge = challenge
        _title = State(initialValue: challenge.title)
        _goal = State(initialValue: challenge.goal)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Challenge") {
                    TextField("Title", text: $title)
                    TextField("Goal (optional)", text: $goal)
                }

                Section("Info") {
                    LabeledContent("Status") {
                        Label(challenge.status.label, systemImage: challenge.status.icon)
                            .foregroundStyle(statusColor)
                    }

                    LabeledContent("Started") {
                        Text(challenge.startDate, format: .dateTime.day().month().year())
                    }

                    LabeledContent("Ends") {
                        Text(challenge.endDate, format: .dateTime.day().month().year())
                    }

                    LabeledContent("Progress") {
                        Text("\(challenge.completedDays) / 21 days")
                    }
                }

                if challenge.status == .expired {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                            Text("This challenge's 21-day window has passed. You can still backfill days you completed.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Challenge")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var statusColor: Color {
        switch challenge.status {
        case .upcoming:  .blue
        case .active:    .orange
        case .completed: .green
        case .expired:   .secondary
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        challenge.title = trimmedTitle
        challenge.goal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        dismiss()
    }
}

#Preview {
    EditChallengeView(
        challenge: Challenge(title: "Morning Run", goal: "5k every day")
    )
    .modelContainer(for: Challenge.self, inMemory: true)
}
