//
//  StatsView.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import SwiftUI
import SwiftData

struct StatsView: View {

    @Query(sort: \Challenge.createdAt, order: .reverse)
    private var challenges: [Challenge]

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            if challenges.isEmpty {
                ContentUnavailableView(
                    "No Challenges Yet",
                    systemImage: "chart.bar",
                    description: Text("Start a 21-day challenge to see your stats here.")
                )
                .padding(.top, 60)
            } else {
                VStack(spacing: 20) {
                    summaryCards
                    HeatmapView(challenges: challenges)
                    challengeBreakdown
                }
                .padding()
            }
        }
        .navigationTitle("Stats")
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        let active = challenges.filter { !$0.isComplete }
        let completed = challenges.filter { $0.isComplete }

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Current Streak",
                value: "\(currentStreak)",
                unit: "days",
                icon: "flame.fill",
                color: .orange
            )

            StatCard(
                title: "Longest Streak",
                value: "\(longestStreak)",
                unit: "days",
                icon: "trophy.fill",
                color: .yellow
            )

            StatCard(
                title: "Active",
                value: "\(active.count)",
                unit: active.count == 1 ? "challenge" : "challenges",
                icon: "figure.run",
                color: .blue
            )

            StatCard(
                title: "Completed",
                value: "\(completed.count)",
                unit: completed.count == 1 ? "challenge" : "challenges",
                icon: "checkmark.seal.fill",
                color: .green
            )
        }
    }

    // MARK: - Challenge Breakdown

    private var challengeBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Challenges")
                .font(.headline)

            ForEach(challenges) { challenge in
                HStack(spacing: 12) {
                    // Mini progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 3)

                        Circle()
                            .trim(from: 0, to: challenge.progress)
                            .stroke(
                                challenge.isComplete ? Color.green : Color.accentColor,
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                    }
                    .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(challenge.title)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("\(challenge.completedDays)/21 days completed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(Int(challenge.progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(challenge.isComplete ? .green : .primary)
                }
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Streak Calculations

    /// Current streak: consecutive days (ending today or yesterday) with at least one completion.
    private var currentStreak: Int {
        let completionDates = allCompletionDates()
        guard !completionDates.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: .now)
        var streak = 0
        var checkDate = today

        // Allow starting from today or yesterday
        if !completionDates.contains(checkDate) {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) {
                checkDate = yesterday
            }
        }

        while completionDates.contains(checkDate) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previous
        }

        return streak
    }

    /// Longest streak of consecutive days with at least one completion.
    private var longestStreak: Int {
        let sortedDates = allCompletionDates().sorted()
        guard !sortedDates.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for i in 1..<sortedDates.count {
            let daysBetween = calendar.dateComponents([.day], from: sortedDates[i - 1], to: sortedDates[i]).day ?? 0
            if daysBetween == 1 {
                current += 1
                longest = max(longest, current)
            } else if daysBetween > 1 {
                current = 1
            }
            // daysBetween == 0 means same day, skip
        }

        return longest
    }

    /// Set of unique dates that have at least one challenge completion.
    private func allCompletionDates() -> Set<Date> {
        var dates: Set<Date> = []
        for challenge in challenges {
            for (index, completed) in challenge.dailyStatus.enumerated() where completed {
                if let date = calendar.date(byAdding: .day, value: index, to: challenge.startDate) {
                    dates.insert(calendar.startOfDay(for: date))
                }
            }
        }
        return dates
    }
}

// MARK: - Stat Card

struct StatCard: View {

    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                Spacer()
            }

            Text(value)
                .font(.system(.title, design: .rounded, weight: .bold))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
    .modelContainer(for: Challenge.self, inMemory: true)
}
