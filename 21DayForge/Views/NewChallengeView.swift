//
//  NewChallengeView.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import SwiftUI
import SwiftData

struct NewChallengeView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var goal = ""
    @State private var startDate = Date.now

    @FocusState private var titleFieldFocused: Bool

    private var isStartingInPast: Bool {
        Calendar.current.startOfDay(for: startDate) < Calendar.current.startOfDay(for: .now)
    }

    private var isStartingInFuture: Bool {
        Calendar.current.startOfDay(for: startDate) > Calendar.current.startOfDay(for: .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Challenge") {
                    TextField("Title", text: $title, prompt: Text("e.g. Morning Run"))
                        .focused($titleFieldFocused)

                    TextField("Goal (optional)", text: $goal, prompt: Text("e.g. Run 2 miles every morning"))
                }

                Section {
                    DatePicker("Begins", selection: $startDate, displayedComponents: .date)
                } header: {
                    Text("Start Date")
                } footer: {
                    if isStartingInPast {
                        Text("Starting in the past lets you backfill missed days.")
                    } else if isStartingInFuture {
                        Text("This challenge will appear as \"Upcoming\" until \(startDate.formatted(.dateTime.month(.abbreviated).day())).")
                    }
                }

                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                        Text("You'll track this challenge for 21 consecutive days. Build the habit, one day at a time.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Challenge")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        createChallenge()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                titleFieldFocused = true
            }
        }
    }

    private func createChallenge() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let challenge = Challenge(
            title: trimmedTitle,
            goal: goal.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate
        )
        modelContext.insert(challenge)
        dismiss()
    }
}

#Preview {
    NewChallengeView()
        .modelContainer(for: Challenge.self, inMemory: true)
}
