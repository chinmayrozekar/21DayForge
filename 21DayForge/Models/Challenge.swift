//
//  Challenge.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import Foundation
import SwiftData

// MARK: - Challenge Status

enum ChallengeStatus: String {
    case upcoming   // startDate is in the future
    case active     // within the 21-day window
    case completed  // all 21 days marked done
    case expired    // past the 21-day window, not all done

    var label: String {
        switch self {
        case .upcoming:  "Upcoming"
        case .active:    "Active"
        case .completed: "Completed"
        case .expired:   "Expired"
        }
    }

    var icon: String {
        switch self {
        case .upcoming:  "clock"
        case .active:    "flame.fill"
        case .completed: "checkmark.seal.fill"
        case .expired:   "exclamationmark.triangle"
        }
    }
}

// MARK: - Challenge Model

@Model
final class Challenge {

    var title: String
    var goal: String
    var startDate: Date
    var dailyStatus: [Bool]
    var createdAt: Date
    var freezeDays: [Bool]?

    // MARK: - Status and Day Calculations

    /// Returns the number of days elapsed since startDate and the current status.
    /// Uses a single set of calendar calculations for efficiency.
    private var dateMetrics: (elapsed: Int, status: ChallengeStatus) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        // startDate is already normalized to startOfDay in init
        let elapsed = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0

        if isComplete {
            return (elapsed, .completed)
        } else if elapsed < 0 {
            return (elapsed, .upcoming)
        } else if elapsed >= 21 {
            return (elapsed, .expired)
        } else {
            return (elapsed, .active)
        }
    }

    var status: ChallengeStatus {
        dateMetrics.status
    }

    // MARK: - Computed Properties

    /// The current day of the challenge (0 if upcoming, 1–21 if active, 21 if past).
    var currentDay: Int {
        let elapsed = dateMetrics.elapsed
        if elapsed < 0 { return 0 }
        return min(elapsed + 1, 21)
    }

    /// The last calendar date of the 21-day window.
    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: 20, to: startDate) ?? startDate
    }

    /// Days remaining in the 21-day window (0 if expired or completed).
    var daysRemaining: Int {
        let metrics = dateMetrics
        if metrics.status == .expired || metrics.status == .completed { return 0 }
        let remaining = 21 - metrics.elapsed
        return max(remaining, 0)
    }

    var isComplete: Bool {
        dailyStatus.allSatisfy { $0 }
    }

    var completedDays: Int {
        dailyStatus.filter { $0 }.count
    }

    var progress: Double {
        Double(completedDays) / 21.0
    }

    /// Whether today's quick-log button should work.
    var isTodayActionable: Bool {
        status == .active
    }

    /// Whether today has been marked as completed.
    var isTodayCompleted: Bool {
        let metrics = dateMetrics
        guard metrics.status == .active || metrics.status == .completed else { return false }
        let index = metrics.elapsed
        guard index >= 0, index < 21 else { return false }
        return dailyStatus[index]
    }

    /// Per-challenge current streak (consecutive completed days ending at currentDay).
    var currentStreak: Int {
        let metrics = dateMetrics
        let end = min(metrics.elapsed + 1, 21)
        guard end > 0 else { return 0 }
        var streak = 0
        for i in stride(from: end - 1, through: 0, by: -1) {
            if dailyStatus[i] {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    /// Longest consecutive completed streak within this challenge.
    var longestStreak: Int {
        var longest = 0
        var current = 0
        for completed in dailyStatus {
            if completed {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
        }
        return longest
    }

    // MARK: - Freeze Days

    var availableFreezeDays: Int {
        freezeDays?.filter { $0 == false }.count ?? 0
    }

    var isTodayFrozen: Bool {
        let metrics = dateMetrics
        guard metrics.status == .active else { return false }
        guard let freezeDays else { return false }
        let index = metrics.elapsed
        guard index >= 0, index < 21 else { return false }
        return freezeDays[index]
    }

    var canUseFreeze: Bool {
        let metrics = dateMetrics
        return metrics.status == .active && availableFreezeDays > 0 && !isTodayCompleted && !isTodayFrozen
    }

    func useFreeze() {
        let metrics = dateMetrics
        guard metrics.status == .active else { return }
        guard availableFreezeDays > 0 else { return }
        guard var freezeDays else { return }
        let index = metrics.elapsed
        guard index >= 0, index < 21 else { return }
        guard !dailyStatus[index] && !freezeDays[index] else { return }
        freezeDays[index] = true
        self.freezeDays = freezeDays
    }

    // MARK: - Initializer

    init(title: String, goal: String = "", startDate: Date = .now) {
        self.title = title
        self.goal = goal
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.dailyStatus = Array(repeating: false, count: 21)
        self.freezeDays = Array(repeating: false, count: 21)
        self.createdAt = .now
    }

    // MARK: - Methods

    /// Toggle completion status for a specific day (0-indexed).
    /// Blocks toggling on upcoming challenges and future days.
    func toggleDay(_ dayIndex: Int) {
        guard dayIndex >= 0, dayIndex < 21 else { return }
        guard status != .upcoming else { return }
        // For active challenges, only allow past and current days
        if status == .active {
            guard dayIndex < currentDay else { return }
        }
        dailyStatus[dayIndex].toggle()
    }

    /// Toggle today's completion status (only works on active challenges).
    func toggleToday() {
        guard status == .active else { return }
        let index = currentDay - 1
        guard index >= 0, index < 21 else { return }
        dailyStatus[index].toggle()
    }

    /// Mark today as completed (only works on active challenges).
    func markTodayComplete() {
        guard status == .active else { return }
        let index = currentDay - 1
        guard index >= 0, index < 21 else { return }
        dailyStatus[index] = true
    }
}
