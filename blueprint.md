# Breastfeeding Timer App Blueprint

## Overview

This document outlines the features and design of the Breastfeeding Timer app, a Flutter application designed to help mothers track breastfeeding sessions and solid food feedings.

## Implemented Style, Design, and Features

*   **Timer:** A simple timer to track the duration of each breastfeeding session.
*   **History:** A list of past breastfeeding sessions and solid food feedings, including start time, duration, and breast side. Sessions can be deleted by swiping.
*   **Solid Food Tracking:** Ability to log solid food feedings, including the type of food.
*   **Statistics:** A panel displaying key statistics, such as the time since the last feed, the number of feeds in the last 24 hours, and the percentage of feeds from each breast.
*   **Analysis Screen:** A new screen that displays the average feed duration for today, yesterday, and the last 7 days.
*   **Baby Profile:** A simple profile for the baby, including name and gender, which can be edited.
*   **Data Export:** The ability to export the breastfeeding history as an email.
*   **Settings:** A settings page with links to the privacy policy and terms of use.
*   **Manual Entry:** A dialog to manually add breastfeeding sessions and solid food feedings.
*   **Theme:** A custom theme with a color scheme of deep purple, supporting both light and dark modes.
*   **Typography:** The app uses the Lato font from Google Fonts.
*   **Layout:** The app uses a simple, intuitive layout with a header, timer controls, a stats panel, and a history list.
*   **Icons:** The app uses custom icons for the breast side indicators.
*   **Conditional Paywall:** The subscription/paywall screen is only shown in release builds, allowing for easier debugging and testing.

## Current Plan: Add Feeding Statistics

### Overview
This plan details the implementation of a new screen to display feeding statistics.

### Steps
1.  **Add Statistics Logic:**
    *   Add getters to `HistoryModel` in `lib/providers.dart` to calculate the average feed duration for today, yesterday, and the last 7 days.
2.  **Create Analysis Screen:**
    *   Create a new file `lib/analysis_screen.dart`.
    *   Create a new `AnalysisScreen` widget to display the new statistics.
3.  **Add Navigation:**
    *   Add a button to the `Header` in `lib/main.dart` to navigate to the `AnalysisScreen`.
4.  **Update Blueprint:**
    *   Update the `blueprint.md` file to reflect the changes.
