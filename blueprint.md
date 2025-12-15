# Breastfeeding Timer App Blueprint

## Overview

This document outlines the features and design of the Breastfeeding Timer app, a Flutter application designed to help mothers track breastfeeding sessions.

## Implemented Style, Design, and Features

*   **Timer:** A simple timer to track the duration of each breastfeeding session.
*   **History:** A list of past breastfeeding sessions, including start time, duration, and breast side. Sessions can be deleted by swiping.
*   **Statistics:** A panel displaying key statistics, such as the time since the last feed, the number of feeds in the last 24 hours, and the percentage of feeds from each breast.
*   **Baby Profile:** A simple profile for the baby, including name and gender, which can be edited.
*   **Data Export:** The ability to export the breastfeeding history as an email.
*   **Settings:** A settings page with links to the privacy policy and terms of use.
*   **Manual Entry:** A dialog to manually add breastfeeding sessions.
*   **Theme:** A custom theme with a color scheme of green and peach.
*   **Typography:** The app uses the Lato font from Google Fonts.
*   **Layout:** The app uses a simple, intuitive layout with a header, timer controls, a stats panel, and a history list.
*   **Icons:** The app uses custom icons for the breast side indicators.

## Current Plan: Redesign and Manual Entry Update

### Overview
This plan details a complete visual redesign of the application to create a more modern, intuitive, and aesthetically pleasing user experience. It also includes a functional change to the manual entry dialog to make it more user-friendly.

### Steps

1.  **Modernize the Theme:**
    *   **Colors:** Introduce a new, vibrant, and modern color palette. The primary color will be a deep purple, with a complementary lighter shade and accent colors for a clean look. The theme will support both light and dark modes.
    *   **Typography:** Integrate the `google_fonts` package to use the 'Oswald' and 'Roboto' fonts for a more professional and readable text hierarchy.
    *   **Component Styling:** Define custom themes for `AppBar`, `ElevatedButton`, and other components to ensure a consistent and polished look.

2.  **Update Manual Entry Duration Input:**
    *   Modify the `ManualEntryDialog` in `lib/widgets.dart`.
    *   Replace the `TextField` for duration with a `DropdownButtonFormField<int>`.
    *   Populate the dropdown with a list of integers from 0 to 60, representing minutes.
    *   This will provide a more constrained and user-friendly way to input the duration of a manual session.

3.  **Refine Layout and Widgets:**
    *   **Header:** Redesign the header in `lib/main.dart` to be more visually appealing, incorporating the new color scheme and typography.
    *   **Stats Panel:** Re-style the `StatsPanel` to be more modern and visually integrated with the new design.
    *   **History List:** Improve the appearance of the `HistoryList` items in `lib/widgets.dart` to be cleaner and more readable.

4.  **Implement Theme Provider:**
    *   Create a `ThemeProvider` class using the `provider` package to manage the application's theme mode (light, dark, or system).
    *   Add a theme toggle to the UI to allow users to switch between light and dark modes.
