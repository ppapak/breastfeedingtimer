# Breastfeeding Timer App Blueprint

## Overview

This document outlines the features and design of the Breastfeeding Timer app, a Flutter application designed to help mothers track breastfeeding sessions and solid food feedings.

## Implemented Style, Design, and Features

*   **Timer:** A simple timer to track the duration of each breastfeeding session.
*   **History:** A list of past breastfeeding sessions and solid food feedings, including start time, duration, and breast side. Sessions can be deleted by swiping.
*   **Solid Food Tracking:** Ability to log solid food feedings, including the type of food.
*   **Statistics:** A panel displaying key statistics, such as the time since the last feed, the number of feeds in the last 24 hours, and the percentage of feeds from each breast.
*   **Baby Profile:** A simple profile for the baby, including name and gender, which can be edited.
*   **Data Export:** The ability to export the breastfeeding history as an email.
*   **Settings:** A settings page with links to the privacy policy and terms of use.
*   **Manual Entry:** A dialog to manually add breastfeeding sessions and solid food feedings.
*   **Theme:** A custom theme with a color scheme of deep purple, supporting both light and dark modes.
*   **Typography:** The app uses the Lato font from Google Fonts.
*   **Layout:** The app uses a simple, intuitive layout with a header, timer controls, a stats panel, and a history list.
*   **Icons:** The app uses custom icons for the breast side indicators.
*   **Conditional Paywall:** The subscription/paywall screen is only shown in release builds, allowing for easier debugging and testing.

## Current Plan: Conditional Paywall

### Overview
This plan details the implementation of a conditional paywall that is only displayed in release builds of the application.

### Steps
1.  **Import `foundation.dart`:**
    *   Add `import 'package:flutter/foundation.dart';` to `lib/main.dart`.
2.  **Conditional Logic:**
    *   In the `InitialScreen` widget, wrap the `_checkTrialStatus()` call in an `if (kReleaseMode)` block. This ensures that the paywall is only triggered when the app is compiled in release mode.
