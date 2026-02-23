# LearnTurn – Tutor–Student Marketplace

Flutter web app with Firebase backend: landing, auth (email/password + role), student and tutor dashboards, tutor search, bookings, real-time chat, reviews, favorites, and dark mode.

## Setup

1. **Flutter**  
   Install [Flutter](https://flutter.dev) and run:
   ```bash
   flutter pub get
   ```

2. **Firebase**  
   - Create a project at [Firebase Console](https://console.firebase.google.com).  
   - Enable **Authentication** (Email/Password).  
   - Create **Firestore** and **Storage** (and optionally **Cloud Messaging**).  
   - Run:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
   - Replace placeholders in `lib/firebase_options.dart` if you don’t use FlutterFire (e.g. copy from Firebase Console).

3. **Deploy Firestore rules and indexes**  
   From project root:
   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only firestore:indexes
   ```
   (Requires `firebase.json` and Firebase CLI; or create rules/indexes manually in the console.)

4. **Run the app**  
   ```bash
   flutter run
   ```

## Features

- **Landing**: 3 steps (Search tutor → Connect → Start learning), Sign Up / Sign In / Become a Tutor.
- **Auth**: Email/password, role (Student/Tutor) at sign-up; user + role stored in Firestore.
- **Student**: Profile (grade, subjects, schedule, budget, goals), search/filter tutors, tutor cards (photo, name, subjects, rating, rate), session request, chat, favorites, bookings (pending/accepted/completed/cancelled), leave review.
- **Tutor**: Profile (bio, qualifications, subjects, experience, hourly rate, availability, photo via Storage), accept/reject requests, add Zoom/Meet link, chat, session history.
- **Firestore**: `users`, `tutors`, `students`, `bookings`, `reviews`, `chats` (+ `messages` subcollection), `favorites`.
- **Real-time**: Chat and booking lists use Firestore streams.
- **Security**: `firestore.rules` restrict access by role and ownership.
- **UI**: Material 3, DM Sans, dark mode toggle (student dashboard).

## Optional

- **FCM**: `lib/core/services/notification_service.dart` – call `initializeNotifications()` after `Firebase.initializeApp()` to request permission and get the token for server-side push (e.g. booking updates).
- **Stripe**: `flutter_stripe` is in `pubspec.yaml`; wire payment flow in booking/session flow as needed.
- **Video**: Booking has `videoMeetingLink`; tutors can set Zoom/Meet link when accepting.

## Project structure (clean architecture)

- `lib/core/` – theme, constants, router, Firestore/Storage/FCM services, providers.  
- `lib/features/auth/` – landing, login, register, user model, auth provider.  
- `lib/features/student/` – student profile, tutor search, tutor detail, student bookings.  
- `lib/features/tutor/` – tutor profile (with photo upload), tutor bookings.  
- `lib/features/bookings/` – booking model.  
- `lib/features/reviews/` – review model.  
- `lib/features/chat/` – message/chat models, chat list, chat screen.

State: **Riverpod**. Routing: **go_router** with role-based redirect.
