# Baby Tracker App Blueprint

## Overview

A Flutter application for tracking a baby's feeding sessions. It allows for timing feeds for each breast, manually adding feed entries, and viewing a history of feeding sessions. The app also provides statistics on feeding patterns.

## Style and Design

*   **Theme:** Material 3 with a Deep Purple seed color for both light and dark modes.
*   **Typography:** Google Fonts Oswald, Roboto, and Open Sans for a clean and modern look.
*   **Layout:** 
    *   **AppBar:** Contains a CircleAvatar for an image, the app title, and action buttons for theme toggling, sharing, and settings.
    *   **Main Body:** Features large, circular buttons for 'L' and 'R' feeds, a central '+' button for manual entries, a statistics panel, and a list of historical entries.
    *   **Buttons:** ElevatedButton with rounded corners and a consistent color scheme.

## Features

*   **Theme Toggle:** Switch between light and dark modes.
*   **Timer:** Time feeding sessions for the left and right breast.
*   **Manual Entry:** Manually add feeding sessions with a date, time, duration, and breast side selector.
*   **History:** View a list of all past feeding sessions, with options to edit or delete each entry.
*   **Statistics:** A comprehensive statistics panel displaying:
    *   Feeds in the last 24 hours.
    *   Total feeding duration for the current day.
    *   Time since the last feed.
    *   Average feed duration for today, yesterday, and the last 7 days.

## Current Plan

- The layout has been updated as per the user's request.
- All analysis errors have been resolved.
- The next step is to implement the edit functionality for the history list entries.
