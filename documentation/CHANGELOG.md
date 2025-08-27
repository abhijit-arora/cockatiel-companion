# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - V1.1 In Progress

### Added
- **Authentication:**
  - Initial email/password sign-up and login.
  - `AuthGate` for session management.
  - Google Sign-In functionality.
  - Refactored Auth screen with a dynamic Login/Sign Up toggle and a "Forgot Password" flow.
- **Data Architecture:**
  - Implemented a multi-user model with Aviaries (households), Nests (cages), and Caregivers.
  - Created a secure Cloud Function to handle caregiver invitations.
- **Bird & Nest Management:**
  - Full CRUD (Create, Read, Update, Delete) for bird profiles.
  - Full CRUD for Nests, including safety checks for deletion.
- **Daily Logging:**
  - A real-time, multi-source screen for viewing daily logs.
  - Modular dialogs for logging Diet, Droppings, Behavior, and Weight.
  - Full CRUD functionality for all individual log entries.
- **Task Management:**
  - In-app system to create and track recurring "Care Tasks".
  - Dynamic "Tasks Due Today" summary on the home screen.
- **User Engagement:**
  - "Guided 30-Day Plan" with daily tips for new birds.
  - "Knowledge Center" for viewing curated external resources.
- **UI & Branding:**
  - Implemented a full, app-wide visual theme with a custom color scheme and typography.
  - Integrated a custom logo and branding across the app.
- **Project Tooling:**
  - Added scripts and prompts for seamless AI session resumption.

## [0.0.1] - 2025-08-16
- Project inception.