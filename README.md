# Project Blueprint

## Overview

This document outlines the architecture, features, and design of the Breastfeeding Tracker mobile application. The app is designed to help parents track breastfeeding sessions, solid food intake, and monitor their baby's feeding patterns.

## Features

### Core Functionality

*   **Breastfeeding Timer:** Users can time feeds for each breast (left or right). The timer displays the duration in real-time.
*   **Manual Entry:** Users can manually log past feeding sessions and solid food intake.
*   **Activity History:** A chronological list of all feeding activities is displayed on the main screen.
*   **Statistics Panel:** Key statistics are displayed, including:
    *   Feeds in the last 24 hours.
    *   Total feeding duration for the current day.
    *   Time since the last feed.
    *   Average feed duration for today, yesterday, and the last 7 days.
    *   Percentage of feeds from the left vs. right breast.

### Monetization

*   **Subscription Model:** The core tracking features are behind a paywall.
*   **Free Trial:** A 7-day free trial is offered to new users to allow them to experience the app's full functionality.
*   **In-App Purchases:** The app uses the `in_app_purchase` package to handle subscriptions.

### Notifications

*   **Feed Reminders:** A background task runs periodically to check the time since the last feed. If it exceeds 5 hours, a local notification is sent to remind the user.

## Architecture

*   **State Management:** The app uses the `provider` package for state management, with `ChangeNotifier` to manage the state of the timer, history, and purchases.
*   **Data Persistence:** The `shared_preferences` package is used to persist the activity history, subscription status, and trial information locally on the device.
*   **Background Processing:** The `workmanager` package is used to schedule and run background tasks for sending feed reminders.
*   **UI:** The app is built with Flutter and follows Material Design principles. It includes a dark mode and uses custom fonts from the `google_fonts` package.

## Code Structure

*   `lib/main.dart`: The main entry point of the application, containing the root widget, theme definition, and provider setup.
*   `lib/providers.dart`: Contains the `ChangeNotifier` classes (`TimerModel`, `HistoryModel`) that manage the application's state.
*   `lib/models.dart`: Defines the data models for `Activity`, `FeedSession`, and `SolidFeed`.
*   `lib/widgets.dart`: Contains reusable UI components, such as the `StatsPanel` and `ManualEntryDialog`.
*   `lib/purchase_provider.dart`: Manages the in-app purchase logic, including product loading, subscription status, and handling purchases.
*   `lib/paywall_screen.dart`: A screen that is displayed to non-subscribed users, prompting them to start a trial or purchase a subscription.
*   `lib/notification_service.dart`: A service class to handle the creation and display of local notifications.

## Testing

*   `test/widget_test.dart`: Contains widget tests for the main application UI, ensuring that core functionality like the timer works as expected.

