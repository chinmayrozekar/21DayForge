//
//  SettingsView.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 21/04/26.
//

import SwiftUI
import PhotosUI

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
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("profileImageData") private var profileImageData: Data?
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var notificationAuthorized = false
    @State private var showingPermissionAlert = false
    @State private var showingNameEditor = false
    @State private var editedName: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var cachedProfileImage: UIImage?

    private var selectedAppearance: Appearance {
        Appearance(rawValue: appearance) ?? .system
    }

    private var profileImage: some View {
        Group {
            if let uiImage = cachedProfileImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .onChange(of: profileImageData) { _, newData in
            if let data = newData, let image = UIImage(data: data) {
                cachedProfileImage = image
            } else {
                cachedProfileImage = nil
            }
        }
        .onAppear {
            if let data = profileImageData, let image = UIImage(data: data) {
                cachedProfileImage = image
            }
        }
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
            // MARK: Profile
            Section {
                HStack(spacing: 16) {
                    profileImage
                        .onTapGesture {
                            editedName = userName
                            showingNameEditor = true
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(userName.isEmpty ? "Your Name" : userName)
                            .font(.headline)
                        Text(userName.isEmpty ? "Tap to set your name" : "Tap to edit")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editedName = userName
                        showingNameEditor = true
                    }

                    Spacer()

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Image(systemName: "camera.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                profileImageData = data
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Profile")
            }

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

            // MARK: Feedback
            Section {
                Button {
                    openFeedbackEmail()
                } label: {
                    HStack {
                        Label("Send Feedback", systemImage: "envelope")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Feedback")
            } footer: {
                Text("Found a bug or have a suggestion? We'd love to hear from you!")
            }

            // MARK: About
            Section {
                LabeledContent("Developer", value: "Chinmay Rozekar")
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Days to form a habit", value: "21")
            } header: {
                Text("About")
            } footer: {
                Text("Proudly made in \u{1F1EE}\u{1F1F3} \u{092D}\u{093E}\u{0930}\u{0924}")
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
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
        .alert("Edit Name", isPresented: $showingNameEditor) {
            TextField("Your name", text: $editedName)
            Button("Save") {
                userName = editedName.trimmingCharacters(in: .whitespaces)
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Email Copied", isPresented: $showingEmailCopied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("No mail app found. The email address has been copied to your clipboard.")
        }
    }

    @State private var showingEmailCopied = false

    private func openFeedbackEmail() {
        let email = "chinmay.rozekar@gmail.com"
        let subject = "21DayForge Feedback"
        let mailto = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject)"

        #if os(iOS)
        guard let url = URL(string: mailto) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIPasteboard.general.string = email
            showingEmailCopied = true
        }
        #endif
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
