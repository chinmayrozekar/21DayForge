//
//  NotificationManager.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import UserNotifications

enum NotificationManager {

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Schedules a repeating daily notification at the given hour and minute.
    static func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])

        let content = UNMutableNotificationContent()
        content.title = "21DayForge"
        content.body = "Don't break the chain! Log your progress today."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)

        center.add(request)
    }

    /// Removes any scheduled daily reminder.
    static func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
    }
}
