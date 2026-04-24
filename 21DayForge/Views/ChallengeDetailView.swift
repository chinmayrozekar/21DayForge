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
    @State private var showingEdit = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                statusBanner
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEdit = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditChallengeView(challenge: challenge)
        }
    }

    // MARK: - Status Banner

    @ViewBuilder
    private var statusBanner: some View {
        switch challenge.status {
        case .upcoming:
            Label(
                "Starts \(challenge.startDate.formatted(.dateTime.month(.wide).day()))",
                systemImage: "clock"
            )
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.blue)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

        case .expired:
            Label(
                "This challenge ended \(challenge.endDate.formatted(.dateTime.month(.abbreviated).day()))",
                systemImage: "exclamationmark.triangle"
            )
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.orange)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

        case .active, .completed:
            EmptyView()
        }
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
                        progressColor,
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

    private var progressColor: Color {
        switch challenge.status {
        case .completed: .green
        case .expired:   .orange
        default:         .accentColor
        }
    }

    // MARK: - 21-Day Grid

    private var dayGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(0..<21, id: \.self) { index in
                let canTap = canToggle(dayIndex: index)

                DayCircle(
                    dayNumber: index + 1,
                    isCompleted: challenge.dailyStatus[index],
                    isCurrent: challenge.status == .active && index + 1 == challenge.currentDay,
                    isFuture: challenge.status == .active && index + 1 > challenge.currentDay,
                    isDisabled: !canTap,
                    isAnimating: animatingDayIndex == index
                )
                .onTapGesture {
                    guard canTap else { return }
                    withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                        challenge.toggleDay(index)
                        animatingDayIndex = index
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        animatingDayIndex = nil
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func canToggle(dayIndex: Int) -> Bool {
        switch challenge.status {
        case .upcoming:
            return false
        case .active:
            return dayIndex < challenge.currentDay
        case .completed, .expired:
            return true // Allow fixing mistakes
        }
    }

    // MARK: - Today Action Button

    @ViewBuilder
    private var todayAction: some View {
        switch challenge.status {
        case .upcoming:
            Label(
                "Challenge hasn't started yet",
                systemImage: "hourglass"
            )
            .font(.headline)
            .foregroundStyle(.secondary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

        case .active:
            let todayIndex = challenge.currentDay - 1
            let isChecked = challenge.dailyStatus[todayIndex]

            HStack(spacing: 12) {
                // Freeze button
                if challenge.canUseFreeze {
                    Button {
                        withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                            challenge.useFreeze()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "snowflake")
                            Text("Freeze (\(challenge.availableFreezeDays))")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }

                // Complete button
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
            }

        case .completed:
            Label("Challenge Complete!", systemImage: "trophy.fill")
                .font(.headline)
                .foregroundStyle(.green)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

        case .expired:
            EmptyView() // Banner above handles messaging
        }
    }

    // MARK: - Details

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabeledContent("Started") {
                Text(challenge.startDate, style: .date)
            }

            LabeledContent("Ends") {
                Text(challenge.endDate, style: .date)
            }

            LabeledContent("Current Streak") {
                HStack(spacing: 4) {
                    Text("\(challenge.currentStreak) days")
                    if challenge.currentStreak >= 3 {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
            }

            LabeledContent("Best Streak") {
                Text("\(challenge.longestStreak) days")
            }

            LabeledContent("Completion") {
                Text("\(Int(challenge.progress * 100))%")
            }

            if challenge.status == .active {
                LabeledContent("Days Remaining") {
                    Text("\(challenge.daysRemaining)")
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Day Circle Component

struct DayCircle: View {

    let dayNumber: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let isFuture: Bool
    let isDisabled: Bool
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
                    .foregroundStyle(isDisabled || isFuture ? .tertiary : .primary)
            }
        }
        .frame(width: 38, height: 38)
        .scaleEffect(isAnimating ? 1.2 : 1.0)
        .opacity(isDisabled && !isCompleted ? 0.5 : 1.0)
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
