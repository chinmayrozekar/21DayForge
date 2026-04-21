//
//  SettingsView.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import SwiftUI

// MARK: - Appearance

enum Appearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light:  "sun.max.fill"
        case .dark:   "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {

    @AppStorage("appearance") private var appearance: String = Appearance.system.rawValue
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var notificationAuthorized = false
    @State private var showingPermissionAlert = false

    private var selectedAppearance: Appearance {
        Appearance(rawValue: appearance) ?? .system
    }

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return Calendar.current.date(from: components) ?? .now
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = components.hour ?? 9
                reminderMinute = components.minute ?? 0
                if reminderEnabled {
                    NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                }
            }
        )
    }

    var body: some View {
        Form {
            // MARK: Appearance
            Section("Appearance") {
                Picker("Theme", selection: $appearance) {
                    ForEach(Appearance.allCases) { option in
                        Label(option.label, systemImage: option.icon)
                            .tag(option.rawValue)
                    }
                }
                #if os(iOS)
                .pickerStyle(.inline)
                #endif
            }

            // MARK: Notifications
            Section {
                Toggle("Daily Reminder", isOn: $reminderEnabled)
                    .onChange(of: reminderEnabled) { _, enabled in
                        handleReminderToggle(enabled)
                    }

                if reminderEnabled {
                    DatePicker("Remind at", selection: reminderTime, displayedComponents: .hourAndMinute)
                }
            } header: {
                Text("Notifications")
            } footer: {
                if reminderEnabled {
                    Text("You'll get a daily nudge to log your challenge progress.")
                }
            }

            // MARK: About
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Days to form a habit", value: "21")
            }
        }
        .navigationTitle("Settings")
        .task {
            let status = await NotificationManager.authorizationStatus()
            notificationAuthorized = (status == .authorized)
        }
        .alert("Notifications Disabled", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                #if os(iOS)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                #endif
            }
            Button("Cancel", role: .cancel) {
                reminderEnabled = false
            }
        } message: {
            Text("Please enable notifications in Settings to receive daily reminders.")
        }
    }

    private func handleReminderToggle(_ enabled: Bool) {
        if enabled {
            Task {
                let status = await NotificationManager.authorizationStatus()

                switch status {
                case .authorized:
                    NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                case .notDetermined:
                    let granted = await NotificationManager.requestAuthorization()
                    if granted {
                        NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                    } else {
                        await MainActor.run { reminderEnabled = false }
                    }
                default:
                    await MainActor.run { showingPermissionAlert = true }
                }
            }
        } else {
            NotificationManager.cancelDailyReminder()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
