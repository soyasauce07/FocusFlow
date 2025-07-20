# FocusFlow - Pomodoro Productivity App

FocusFlow is a minimalist Pomodoro timer app built using Flutter. It helps you stay focused and productive by structuring your work sessions using the Pomodoro Technique.

---

## 🚀 Features

- 25-minute work and 5-minute break timers
- Clean and modern UI with light/dark mode support
- Countdown animation for session progress
- Cross-platform: Works on Android and Web (Chrome)
- Future updates planned: AI-based productivity suggestions

---

## 🛠 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (latest stable)
- **Dart SDK** (comes with Flutter)
- **Android Studio** or **VS Code** with Flutter & Dart plugins
- **Android NDK** version **27.0.12077973** or higher *(required for audio support on Android)*

### Installation & Setup

```bash
# Clone the repository
git clone https://github.com/your-username/focusflow.git
cd focusflow

# Install dependencies
flutter pub get

# (Optional) Connect an Android device
# - Enable USB debugging on your phone
# - Authorize your computer when prompted

flutter devices    # to verify the device is connected

# Run the app on Android device
flutter run

# Or run the app in Chrome (Web)
flutter run -d chrome
