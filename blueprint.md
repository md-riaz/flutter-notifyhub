# Blueprint: FCM Push Notification App

## Overview

This document outlines the plan for creating a Flutter application that can receive Firebase Cloud Messaging (FCM) push notifications. The user interface will be a modern interpretation of the provided screenshot, and it will include the full process for handling notifications in both the foreground and background, using mocked data for the API.

## Features & Design

### Core Functionality
- **FCM Integration:** The app will be fully integrated with Firebase Cloud Messaging.
- **Token Generation:** It will generate and display an FCM token, which will serve as the "API KEY".
- **Foreground Notifications:** The app will handle incoming notifications when it is active and in the foreground.
- **Background Notifications:** It will process notifications when the app is in the background or terminated.
- **Notification Permissions:** The app will request the necessary notification permissions from the user.
- **Mock API:** A test submission form will allow users to simulate sending a notification.
- **Notification History:** The app will store and display a history of received notifications.

### UI & Design
- **Modern UI:** The UI will be built using Material 3 principles for a clean and modern aesthetic.
- **Layout:** The layout will be inspired by the screenshot, with cards for displaying the API key, API URL, and the test form.
- **Color Scheme:** A color scheme based on `Colors.deepPurple` will be used to create a visually appealing look.
- **Typography:** `google_fonts` will be used for custom, modern typography.
- **Interactivity:** Buttons will have clear feedback, and text fields will be well-styled.
- **How to Use Dialog:** A dialog will provide instructions on how to use the app.
- **History Screen:** A separate screen will display the notification history.

## Plan

1.  **Setup Firebase & Dependencies:**
    *   Add `firebase_core`, `firebase_messaging`, `provider`, `google_fonts`, `shared_preferences`, and `intl` to the `pubspec.yaml` file.
    *   Configure the Android project to use Firebase by updating the Gradle files.

2.  **Implement FCM Service:**
    *   Create a service to handle FCM token retrieval.
    *   Set up background and foreground message handlers.
    *   Implement logic to request notification permissions.
    *   Store notification history using `shared_preferences`.

3.  **Develop the User Interface:**
    *   Create a `ThemeProvider` to manage light and dark modes.
    *   Build the main screen with a layout similar to the provided image, including sections for the API Key, API URL, and a test form.
    *   Create a `HistoryScreen` to display the notification history.
    *   Create a `HowToUseDialog` to display instructions.
    *   Use a `ChangeNotifier` to manage the application's state (e.g., the FCM token, form inputs, and notification history).

4.  **Connect UI to FCM Service:**
    *   Display the FCM token in the "Your API KEY" section.
    *   Implement the "SUBMIT" button to trigger a mock notification.
    *   Implement the "REFRESH API KEY" button to get a new FCM token.
    *   Load and display the notification history in the `HistoryScreen`.

5.  **Finalize and Test:**
    *   Ensure the app handles notifications correctly in all states (foreground, background, terminated).
    *   Verify that the UI is responsive and visually polished.
