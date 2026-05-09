# Campus News 📰

Campus News is a modern, high-performance Flutter application designed to keep students informed and connected. It serves as a centralized hub for real-time campus updates, academic news, events, and culture.

## ✨ Features

### For Students
- **Real-time News Feed**: Stay updated with the latest articles and breaking news.
- **Categorized Content**: Browse news by categories like Academics, Sports, Events, Tech, and more.
- **Smart Search**: Quickly find articles using the powerful search functionality.
- **Bookmarks**: Save articles for offline reading or future reference.
- **Personalized Profiles**: Manage your student profile and settings.
- **Instant Notifications**: Get notified as soon as new articles are published.

### For Administrators
- **Admin Dashboard**: A dedicated interface for managing campus news.
- **Article Management**: Create, edit, and delete articles with ease.
- **Draft System**: Save your work as drafts and publish when ready.
- **System Settings**: Configure application parameters and manage the admin profile.

## 🚀 Tech Stack

- **Frontend**: [Flutter](https://flutter.dev/) (3.x)
- **State Management**: [Riverpod](https://riverpod.dev/) with [Flutter Hooks](https://pub.dev/packages/flutter_hooks)
- **Backend**: [Firebase](https://firebase.google.com/)
  - **Authentication**: Secure student and admin login.
  - **Cloud Firestore**: Real-time database for articles, categories, and user data.
  - **Firebase Messaging**: Push notifications for real-time alerts.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Styling**: Google Fonts (Inter), Custom Design System.

## 🛠️ Installation & Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- [Firebase CLI](https://firebase.google.com/docs/cli) configured.
- A Firebase project created in the [Firebase Console](https://console.firebase.google.com/).

### Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Musawenkosi-Moyo/Campus-News.git
   cd Campus-News
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Follow the [FlutterFire installation guide](https://firebase.google.com/docs/flutter/setup) to add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
   - Alternatively, use `flutterfire configure` to automate the setup.

4. **Environment Variables**
   - Add the .env file to the folder before running

5. **Run the Application**
   ```bash
   flutter run
   ```

## Accessing admin portal 
- Use the credential "hazel@admin.nust.ac.zw" password "qwertyuiop"
- Alternative, signup using email ending with @admin.nust.ac.zw

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue for any bugs or feature requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
