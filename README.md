# LearnTurn

A Flutter app to help students find suitable mentors based on skills, interests, and availability. Includes mentor/student profiles, matching, session booking, and feedback with reports. **Now integrated with Firebase Firestore for real-time data persistence.**

## Features
- Mentor profiles: skills, experience, availability, contact
- Student profiles: interests, goals, desired skills
- Matching: suggests mentors for a selected student
- Session booking: create requests; approve/reject
- Feedback: leave ratings/comments; reports with average ratings per mentor
- **Firebase Firestore**: real-time database for persistent storage across sessions

## Firebase Setup

### 1. Create a Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com/)
- Click "Create a project" and name it `learnturn`
- Enable Firestore Database in `test` mode (for development)

### 2. Generate Firebase Configuration
Run the FlutterFire CLI in your project root:
```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```
Select your Firebase project and platforms (e.g., Windows, Web). This generates `lib/firebase_options.dart` with your project credentials.

### 3. Update `lib/firebase_options.dart`
Replace the placeholder values in the generated file with your actual Firebase credentials:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_AUTH_DOMAIN',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

### 4. Run the App
```powershell
cd C:\Users\geeth\Desktop\LearnTurn
flutter pub get
flutter run
```

## Database Schema (Firestore)

Collections auto-created on first use:
- `mentors` – mentor profiles
- `students` – student profiles
- `sessions` – booking requests and status
- `feedbacks` – session feedback and ratings

## How It Works
1. On app start, `HomeScreen` loads data from Firestore
2. If empty, mock data (mentors/students) is seeded automatically
3. Sessions and feedbacks sync to Firestore in real-time
4. Reports aggregate feedback per mentor from Firestore

## Troubleshooting
- **Firebase not initializing**: Check `firebase_options.dart` and ensure your credentials are correct
- **Firestore permission denied**: Use `test` mode rules during development; secure them before production
- **FlutterFire CLI not found**: Run `dart pub global activate flutterfire_cli` first
