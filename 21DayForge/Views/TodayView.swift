//
//  TodayView.swift
//  21DayForge
//
//  Created by Chinmay Rozekar on 23/04/26.
//

import SwiftUI
import SwiftData

struct TodayView: View {

    @AppStorage("userName") private var userName: String = ""
    @AppStorage("profileImageData") private var profileImageData: Data?

    @Query private var challenges: [Challenge]

    @State private var uiImage: UIImage?

    // MARK: - Stable computed properties

    private var activeChallenges: [Challenge] {
        challenges.filter { $0.status == .active }
    }

    private var pendingChallenges: [Challenge] {
        activeChallenges.filter { !$0.isTodayCompleted }
    }

    private var completedToday: [Challenge] {
        activeChallenges.filter { $0.isTodayCompleted }
    }

    private var allDoneToday: Bool {
        !activeChallenges.isEmpty && pendingChallenges.isEmpty
    }

    private var todaysShloka: Shloka {
        let daysSinceEpoch = Calendar.current.dateComponents([.day], from: .distantPast, to: .now).day ?? 0
        return shlokaList[daysSinceEpoch % shlokaList.count]
    }

    private var greeting: String {
        userName.isEmpty ? "Today" : "Hi, \(userName)"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Custom header — no NavigationStack needed
                header
                    .padding(.top, 8)

                if activeChallenges.isEmpty {
                    ContentUnavailableView(
                        "No Active Challenges",
                        systemImage: "flame",
                        description: Text("Start a 21-day challenge to see your daily tasks here.")
                    )
                    .padding(.top, 40)
                } else {
                    VStack(spacing: 24) {
                        if !pendingChallenges.isEmpty {
                            challengeSection(title: "Pending", challenges: pendingChallenges)
                        }

                        if allDoneToday {
                            celebrationBanner
                        }

                        if !completedToday.isEmpty {
                            challengeSection(title: "Done", challenges: completedToday)
                        }

                        summaryBar(doneCount: completedToday.count, pendingCount: pendingChallenges.count)
                    }
                }

                DailyShlokaCard(shloka: todaysShloka)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onAppear {
            if uiImage == nil, let data = profileImageData {
                uiImage = UIImage(data: data)
            }
        }
    }

    // MARK: - Header (replaces NavigationStack title + toolbar)

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))

                Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            profileImageView
        }
    }

    // MARK: - Profile Image

    private var profileImageView: some View {
        Group {
            if let img = uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(.secondary.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .padding(.top, 6)
    }

    // MARK: - Challenge Section

    private func challengeSection(title: String, challenges: [Challenge]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            ForEach(challenges) { challenge in
                TodayChallengeCard(challenge: challenge)
            }
        }
    }

    // MARK: - Celebration

    private var celebrationBanner: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.largeTitle)
                .foregroundStyle(.yellow)

            Text("All done for today!")
                .font(.headline)

            Text("You're building great habits. See you tomorrow.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.yellow.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Summary Bar

    private func summaryBar(doneCount: Int, pendingCount: Int) -> some View {
        HStack {
            Label("\(doneCount) done", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)

            Spacer()

            if pendingCount > 0 {
                Label("\(pendingCount) remaining", systemImage: "circle")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.footnote)
        .fontWeight(.medium)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Daily Shloka Card

struct DailyShlokaCard: View {
    let shloka: Shloka

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text(shloka.sanskrit)
                    .font(.system(.body, design: .serif))
                Text(shloka.sanskritLine2)
                    .font(.system(.body, design: .serif))
            }
            .multilineTextAlignment(.center)
            .italic()

            VStack(spacing: 6) {
                Text(shloka.meaning)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Verse \(shloka.verse)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemBackground).opacity(0.5), in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Today Challenge Card

struct TodayChallengeCard: View {

    let challenge: Challenge

    var body: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                    challenge.toggleToday()
                }
            } label: {
                Image(systemName: challenge.isTodayCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundStyle(challenge.isTodayCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(.headline)
                    .strikethrough(challenge.isTodayCompleted, color: .secondary)
                    .foregroundStyle(challenge.isTodayCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    Text("Day \(challenge.currentDay) of 21")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if challenge.currentStreak > 1 {
                        Label("\(challenge.currentStreak)", systemImage: "flame.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: challenge.progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(challenge.progress * 100))")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 36, height: 36)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    TodayView()
        .modelContainer(for: Challenge.self, inMemory: true)
}
