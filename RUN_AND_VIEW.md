# How to see the LearnTurn app

## Run the app (you do this on your machine)

1. **Open a terminal** in the project folder:
   ```bash
   cd c:\Users\geeth\OneDrive\Documents\GitHub\LearnTurn
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run in Chrome:**
   ```bash
   flutter run -d chrome
   ```

4. **Where to look**
   - Chrome should open automatically with the app.
   - If it doesn’t, check the terminal for a line like:
     - `Launching lib\main.dart on Chrome in debug mode...`
     - and a URL such as **http://localhost:XXXXX** (port number varies).
   - Open that URL in your browser to see the app.

## Why you might not see the site

| Issue | What to do |
|-------|------------|
| **Nothing opens** | Manually open Chrome and go to **http://localhost:XXXXX** (use the port printed in the terminal). |
| **Firebase / blank screen** | The app still shows the landing page even if Firebase isn’t configured. If the screen is blank, check the terminal and browser console (F12) for errors. |
| **"Waiting for another flutter command"** | Close any other terminal or IDE that’s running `flutter run`, then run the command again. |
| **Chrome not found** | Run `flutter run` without `-d chrome` and pick a device when asked, or run `flutter run -d edge` for Microsoft Edge. |

## What you’ll see when it works

- **First screen:** LearnTurn landing with “Your path to better grades starts here”, 3 steps (Search tutor, Connect, Start learning), and buttons: **Sign Up**, **Sign In**, **Become a Tutor**.

You can’t “see the site” from a link I give you — it runs locally on your PC at `http://localhost:...` when you run `flutter run -d chrome`.
