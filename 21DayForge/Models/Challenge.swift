//
//  Challenge.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import Foundation
import SwiftData

@Model
final class Challenge {

    var title: String
    var goal: String
    var startDate: Date
    var dailyStatus: [Bool]
    var createdAt: Date

    // MARK: - Computed Properties

    /// The current day of the challenge (1–21), calculated from the start date.
    var currentDay: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: .now)
        let elapsed = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return min(max(elapsed + 1, 1), 21)
    }

    /// Whether every day in the 21-day challenge has been completed.
    var isComplete: Bool {
        dailyStatus.allSatisfy { $0 }
    }

    /// The total number of days marked as completed.
    var completedDays: Int {
        dailyStatus.filter { $0 }.count
    }

    /// Progress as a fraction from 0.0 to 1.0.
    var progress: Double {
        Double(completedDays) / 21.0
    }

    /// Whether today's entry can still be toggled (i.e. the challenge hasn't ended).
    var isTodayActionable: Bool {
        currentDay <= 21 && !isComplete
    }

    // MARK: - Initializer

    init(title: String, goal: String = "", startDate: Date = .now) {
        self.title = title
        self.goal = goal
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.dailyStatus = Array(repeating: false, count: 21)
        self.createdAt = .now
    }

    // MARK: - Methods

    /// Toggle completion status for a specific day (0-indexed).
    func toggleDay(_ dayIndex: Int) {
        guard dayIndex >= 0, dayIndex < 21 else { return }
        dailyStatus[dayIndex].toggle()
    }

    /// Mark today as completed.
    func markTodayComplete() {
        let index = currentDay - 1
        guard index >= 0, index < 21 else { return }
        dailyStatus[index] = true
    }
}
