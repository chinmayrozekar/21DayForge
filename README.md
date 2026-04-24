# 21DayForge

A no-nonsense, **free**, open-source 21-day challenge tracker for iOS and macOS.

## Why I Built This

I was tired. Tired of every habit tracker out there locking basic features behind a paywall. Tired of $4.99/month subscriptions just to tick off a checkbox. Tired of bloated apps that do everything except the one thing I needed: **help me stick to a habit for 21 days.**

So I built 21DayForge for myself. And now it's free for you too. No subscriptions. No ads. No "premium tier". Just a clean, focused tool to forge habits that stick.

## What It Does

- **21-Day Challenges** - Create a challenge, commit for 21 days, track your progress
- **One-Tap Daily Check-In** - Mark today as done with a single tap from the Today view
- **Streaks & Stats** - See your current streak, longest streak, and overall progress
- **Heatmap View** - GitHub-style activity heatmap showing your consistency over time
- **Freeze Days** - Life happens. Use freeze days when you need a break without losing your streak
- **Daily Shloka** - A verse from the Bhagavad Gita to start your day with intention
- **iCloud Sync** - Your data syncs across all your Apple devices via CloudKit
- **Dark Mode** - Full support for light, dark, and system appearance
- **iPad & Mac** - Adaptive layout with sidebar navigation on larger screens

## Screenshots

*Coming soon*

## Requirements

- iOS 18.0+ / macOS 15.0+
- Xcode 16.0+
- An Apple ID (free)

## Installation

Since this app isn't on the App Store (I'm not paying Apple $99/year for the privilege), here's how to get it on your device:

1. **Clone the repo**
   ```bash
   git clone https://github.com/chinmayrozekar/21DayForge.git
   ```

2. **Open in Xcode**
   ```bash
   cd 21DayForge
   open 21DayForge.xcodeproj
   ```

3. **Set your team**
   - Select the project in the navigator
   - Under **Signing & Capabilities**, change the Team to your Apple ID

4. **Run on your device**
   - Connect your iPhone via USB
   - Select it from the device picker in Xcode's toolbar
   - Press `Cmd + R`

5. **Trust the developer** (first time only)
   - On your iPhone: **Settings > General > VPN & Device Management**
   - Tap your developer profile and tap **Trust**

> **Note:** With a free Apple ID, you'll need to re-run from Xcode every 7 days to refresh the provisioning profile. Your data is never lost — it just needs re-signing.

## Tech Stack

- **SwiftUI** - Declarative UI
- **SwiftData** - Persistence with CloudKit sync
- **Swift Concurrency** - Modern async/await patterns
- **Zero dependencies** - No third-party packages

## Project Structure

```
21DayForge/
├── Models/
│   ├── Challenge.swift          # Core data model (SwiftData)
│   ├── NotificationManager.swift # Daily reminder notifications
│   └── ShlokaData.swift         # Bhagavad Gita verses
├── Views/
│   ├── TodayView.swift          # Daily overview & quick check-in
│   ├── ChallengeListView.swift  # All challenges list
│   ├── ChallengeDetailView.swift # 21-day grid & progress
│   ├── StatsView.swift          # Streaks & statistics
│   ├── HeatmapView.swift        # GitHub-style activity heatmap
│   ├── NewChallengeView.swift   # Create a challenge
│   ├── EditChallengeView.swift  # Edit a challenge
│   ├── SettingsView.swift       # App settings
│   └── OnboardingView.swift     # First-launch experience
├── ContentView.swift            # Root navigation (TabView / Sidebar)
└── _1DayForgeApp.swift          # App entry point
```

## Roadmap

- [ ] Android port (in the pipeline)
- [ ] Apple Watch companion app
- [ ] Widgets for Home Screen
- [ ] Export/import challenge data
- [ ] Custom challenge durations (7, 14, 30, 60, 90 days)

## Contributing

Contributions are welcome! Whether it's a bug fix, new feature, or the Android port — open an issue or submit a PR.

If you're interested in building the **Android version**, I'd especially love to hear from you.

## License

MIT License - do whatever you want with it. Just don't charge people a subscription for a checkbox app.

---

Built with frustration and SwiftUI by [Chinmay Rozekar](https://github.com/chinmayrozekar)
