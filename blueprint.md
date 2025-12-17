# Baby Tracker App Blueprint

## Overview

A Flutter application designed to help new parents track their baby's feeding schedule and growth. The app is designed to be simple, intuitive, and focused on the essential features that parents need.

## Features

### Core Functionality

*   **Feeding Timer:** A timer to track the duration of breastfeeding sessions for each breast (left and right).
*   **Manual Entry:** Manually add feeding sessions (breastfeeding and solid food).
*   **Feeding History:** A chronological list of all feeding activities.
*   **Statistics:**
    *   Last feed time
    *   Time since last feed
    *   Number of feeds in the last 24 hours
    *   Total feeding duration today
    *   Average feeding duration (today, yesterday, last 7 days)
    *   Total feeding duration per side (left/right) today

### User Interface

*   **Theming:** Light and dark mode support with a user-facing theme toggle.
*   **Customization:**
    *   Set the baby's name.
    *   Add a photo of the baby.
*   **Visualizations:** A circular progress indicator to visualize the percentage of feeding time for each breast.

## Current Change: Remove Unused Code

*   **Removed `PrivacyPolicyPage` and `TermsOfUsePage`:** These pages were defined in `lib/settings_page.dart` but were not being used in the app.
*   **Simplified `SettingsPage`:** The `SettingsPage` was updated to display a "No settings available" message, as there are no longer any settings to display.
