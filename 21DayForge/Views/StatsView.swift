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

    private var completionDates: Set<Date> {
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

    var body: some View {
        let dates = completionDates
        let current = calculateCurrentStreak(dates: dates)
        let longest = calculateLongestStreak(dates: dates)
        let active = challenges.filter { $0.status == .active }
        let completed = challenges.filter { $0.status == .completed }

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
                    summaryCards(current: current, longest: longest, activeCount: active.count, completedCount: completed.count)
                    HeatmapView(challenges: challenges)
                    challengeBreakdown
                }
                .padding()
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Summary Cards

    private func summaryCards(current: Int, longest: Int, activeCount: Int, completedCount: Int) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Current Streak",
                value: "\(current)",
                unit: current == 1 ? "day" : "days",
                icon: "flame.fill",
                color: .orange
            )

            StatCard(
                title: "Longest Streak",
                value: "\(longest)",
                unit: longest == 1 ? "day" : "days",
                icon: "trophy.fill",
                color: .yellow
            )

            StatCard(
                title: "Active",
                value: "\(activeCount)",
                unit: activeCount == 1 ? "challenge" : "challenges",
                icon: "figure.run",
                color: .blue
            )

            StatCard(
                title: "Completed",
                value: "\(completedCount)",
                unit: completedCount == 1 ? "challenge" : "challenges",
                icon: "checkmark.seal.fill",
                color: .green
            )
        }
    }

    // MARK: - Challenge Breakdown

    private var challengeBreakdown: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            Text("Challenges")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(challenges) { challenge in
                HStack(spacing: 12) {
                    // Quick-log toggle
                    Button {
                        withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                            challenge.toggleToday()
                        }
                    } label: {
                        Image(systemName: challenge.isTodayCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(challenge.isTodayCompleted ? .green : .secondary)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                    .disabled(!challenge.isTodayActionable)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(challenge.title)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            // Status pill
                            if challenge.status != .active {
                                Text(challenge.status.label)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(statusPillColor(challenge.status).opacity(0.15), in: Capsule())
                                    .foregroundStyle(statusPillColor(challenge.status))
                            }
                        }

                        HStack(spacing: 8) {
                            Text("\(challenge.completedDays)/21 days")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if challenge.currentStreak > 1 {
                                Label("\(challenge.currentStreak)", systemImage: "flame.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
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

    private func statusPillColor(_ status: ChallengeStatus) -> Color {
        switch status {
        case .upcoming:  .blue
        case .active:    .orange
        case .completed: .green
        case .expired:   .secondary
        }
    }

    // MARK: - Streak Calculations

    private func calculateCurrentStreak(dates: Set<Date>) -> Int {
        guard !dates.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: .now)
        var streak = 0
        var checkDate = today

        if !dates.contains(checkDate) {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) {
                checkDate = yesterday
            }
        }

        while dates.contains(checkDate) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previous
        }

        return streak
    }

    private func calculateLongestStreak(dates: Set<Date>) -> Int {
        let sortedDates = dates.sorted()
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
        }

        return longest
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
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(.title, design: .rounded, weight: .bold))

                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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
