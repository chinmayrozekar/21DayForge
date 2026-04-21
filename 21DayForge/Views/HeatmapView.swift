//
//  HeatmapView.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import SwiftUI

/// A GitHub-style contribution heatmap showing daily completions across all challenges.
struct HeatmapView: View {

    let challenges: [Challenge]

    private let cellSize: CGFloat = 14
    private let cellSpacing: CGFloat = 3
    private let weeksToShow = 16
    private let calendar = Calendar.current
    private let dayLabels = ["", "Mon", "", "Wed", "", "Fri", ""]

    /// Aggregated completions per calendar date.
    private var completionMap: [Date: Int] {
        var map: [Date: Int] = [:]
        for challenge in challenges {
            for (index, completed) in challenge.dailyStatus.enumerated() where completed {
                if let date = calendar.date(byAdding: .day, value: index, to: challenge.startDate) {
                    let normalized = calendar.startOfDay(for: date)
                    map[normalized, default: 0] += 1
                }
            }
        }
        return map
    }

    /// The grid of weeks (columns) x days (rows), starting from `weeksToShow` weeks ago.
    private var weeks: [[Date]] {
        let today = calendar.startOfDay(for: .now)

        // Find the most recent Sunday (start of the current week column)
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = weekday - 1 // Sunday = 1
        guard let currentWeekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else {
            return []
        }

        var result: [[Date]] = []
        for weekOffset in (0..<weeksToShow).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: currentWeekStart) else {
                continue
            }
            var week: [Date] = []
            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                    week.append(calendar.startOfDay(for: date))
                }
            }
            result.append(week)
        }
        return result
    }

    /// Month labels positioned at the first week where that month starts.
    private var monthLabels: [(String, Int)] {
        var labels: [(String, Int)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        var lastMonth = -1

        for (weekIndex, week) in weeks.enumerated() {
            guard let firstDay = week.first else { continue }
            let month = calendar.component(.month, from: firstDay)
            if month != lastMonth {
                labels.append((formatter.string(from: firstDay), weekIndex))
                lastMonth = month
            }
        }
        return labels
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity")
                .font(.headline)

            // Month labels
            HStack(spacing: 0) {
                // Spacer for day labels column
                Color.clear
                    .frame(width: 30)

                GeometryReader { geo in
                    let totalWidth = geo.size.width
                    let columnWidth = totalWidth / CGFloat(weeksToShow)

                    ForEach(monthLabels, id: \.1) { label, weekIndex in
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .position(
                                x: CGFloat(weekIndex) * columnWidth + columnWidth / 2,
                                y: 6
                            )
                    }
                }
                .frame(height: 14)
            }

            // Grid
            HStack(alignment: .top, spacing: 0) {
                // Day-of-week labels
                VStack(alignment: .trailing, spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { row in
                        Text(dayLabels[row])
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .frame(width: 26, height: cellSize)
                    }
                }

                // Heatmap cells
                HStack(spacing: cellSpacing) {
                    ForEach(0..<weeks.count, id: \.self) { weekIndex in
                        VStack(spacing: cellSpacing) {
                            ForEach(0..<7, id: \.self) { dayIndex in
                                let date = weeks[weekIndex][dayIndex]
                                let count = completionMap[date] ?? 0
                                let isFuture = date > calendar.startOfDay(for: .now)

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(cellColor(count: count, isFuture: isFuture))
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 4) {
                Spacer()
                Text("Less")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                ForEach(0..<5, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(legendColor(level: level))
                        .frame(width: 12, height: 12)
                }

                Text("More")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Color Helpers

    private func cellColor(count: Int, isFuture: Bool) -> Color {
        if isFuture {
            return Color.secondary.opacity(0.08)
        }
        switch count {
        case 0:  return Color.secondary.opacity(0.12)
        case 1:  return Color.green.opacity(0.35)
        case 2:  return Color.green.opacity(0.55)
        case 3:  return Color.green.opacity(0.75)
        default: return Color.green.opacity(0.95)
        }
    }

    private func legendColor(level: Int) -> Color {
        switch level {
        case 0:  return Color.secondary.opacity(0.12)
        case 1:  return Color.green.opacity(0.35)
        case 2:  return Color.green.opacity(0.55)
        case 3:  return Color.green.opacity(0.75)
        default: return Color.green.opacity(0.95)
        }
    }
}

#Preview {
    HeatmapView(challenges: [])
        .padding()
}
