//
//  ChallengeDetailView.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import SwiftUI
import SwiftData

struct ChallengeDetailView: View {

    @Bindable var challenge: Challenge
    @State private var animatingDayIndex: Int?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                dayGrid
                todayAction
                detailsSection
            }
            .padding()
        }
        .navigationTitle(challenge.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: challenge.progress)
                    .stroke(
                        challenge.isComplete ? Color.green : Color.accentColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.5), value: challenge.progress)

                VStack(spacing: 0) {
                    Text("\(challenge.completedDays)")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    Text("of 21")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !challenge.goal.isEmpty {
                Text(challenge.goal)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - 21-Day Grid

    private var dayGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(0..<21, id: \.self) { index in
                DayCircle(
                    dayNumber: index + 1,
                    isCompleted: challenge.dailyStatus[index],
                    isCurrent: index + 1 == challenge.currentDay,
                    isFuture: index + 1 > challenge.currentDay,
                    isAnimating: animatingDayIndex == index
                )
                .onTapGesture {
                    guard index + 1 <= challenge.currentDay else { return }
                    withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                        challenge.toggleDay(index)
                        animatingDayIndex = index
                    }
                    // Reset animation trigger
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        animatingDayIndex = nil
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Today Action Button

    @ViewBuilder
    private var todayAction: some View {
        if challenge.isTodayActionable {
            let todayIndex = challenge.currentDay - 1
            let isChecked = challenge.dailyStatus[todayIndex]

            Button {
                withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                    challenge.toggleDay(todayIndex)
                    animatingDayIndex = todayIndex
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    animatingDayIndex = nil
                }
            } label: {
                Label(
                    isChecked ? "Undo Today" : "Complete Day \(challenge.currentDay)",
                    systemImage: isChecked ? "arrow.uturn.backward" : "checkmark"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(isChecked ? .secondary : .accentColor)
        } else if challenge.isComplete {
            Label("Challenge Complete!", systemImage: "trophy.fill")
                .font(.headline)
                .foregroundStyle(.green)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Details

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabeledContent("Started") {
                Text(challenge.startDate, style: .date)
            }

            LabeledContent("Current Streak") {
                Text("\(currentStreak) days")
            }

            LabeledContent("Completion") {
                Text("\(Int(challenge.progress * 100))%")
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    /// Calculates the current consecutive streak ending at today.
    private var currentStreak: Int {
        var streak = 0
        let end = min(challenge.currentDay, 21)
        for i in stride(from: end - 1, through: 0, by: -1) {
            if challenge.dailyStatus[i] {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
}

// MARK: - Day Circle Component

struct DayCircle: View {

    let dayNumber: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let isFuture: Bool
    let isAnimating: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)

            Circle()
                .strokeBorder(borderColor, lineWidth: isCurrent ? 2.5 : 1)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Text("\(dayNumber)")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(isFuture ? .tertiary : .primary)
            }
        }
        .frame(width: 38, height: 38)
        .scaleEffect(isAnimating ? 1.2 : 1.0)
    }

    private var backgroundColor: Color {
        if isCompleted {
            return .accentColor
        } else if isCurrent {
            return Color.accentColor.opacity(0.1)
        } else {
            return .clear
        }
    }

    private var borderColor: Color {
        if isCompleted {
            return .accentColor
        } else if isCurrent {
            return .accentColor
        } else {
            return Color.secondary.opacity(0.3)
        }
    }
}

#Preview("Day 1 — Fresh") {
    NavigationStack {
        ChallengeDetailView(challenge: Challenge(title: "Morning Meditation", goal: "10 minutes every morning"))
    }
    .modelContainer(for: Challenge.self, inMemory: true)
}

#Preview("Day 11 — Mid-challenge") {
    NavigationStack {
        ChallengeDetailView(challenge: {
            let c = Challenge(
                title: "No Sugar",
                goal: "Zero added sugar for 21 days",
                startDate: Calendar.current.date(byAdding: .day, value: -10, to: .now)!
            )
            // Simulate: completed days 1-8, missed day 9, day 10 pending
            for i in 0..<8 { c.dailyStatus[i] = true }
            return c
        }())
    }
    .modelContainer(for: Challenge.self, inMemory: true)
}

#Preview("Day 21 — Complete") {
    NavigationStack {
        ChallengeDetailView(challenge: {
            let c = Challenge(
                title: "Daily Reading",
                goal: "Read 30 pages every day",
                startDate: Calendar.current.date(byAdding: .day, value: -20, to: .now)!
            )
            for i in 0..<21 { c.dailyStatus[i] = true }
            return c
        }())
    }
    .modelContainer(for: Challenge.self, inMemory: true)
}
