# Functional Roadmap - Cockatiel Companion

This document outlines the planned development phases for the application, starting with the Minimum Viable Product (MVP).

---

### **Version 1.0: Minimum Viable Product (Completed)**

The goal of the MVP was to deliver the core value proposition: a single-user, cloud-synced mobile companion for a new bird owner to track their pet's health and well-being.

**Key Features Delivered:**
*   **Authentication:** A complete and secure system for user sign-up, email/password login, and Google Sign-In.
*   **Multi-User Foundation:** The full backend architecture for multi-user households ("Aviaries"), shared cages ("Nests"), and invited "Caregivers" has been implemented, including a secure Cloud Function for processing invitations.
*   **Bird Profile Management:** Users can create, view, list, and edit profiles for their birds.
*   **The "Smart" Daily Log:** A real-time, dynamic screen for logging and viewing daily data for each bird across multiple categories (Diet, Droppings, Behavior, Weight). The system uses modular, reusable dialogs for data entry.
*   **Guided Onboarding:** A "First 30 Days" plan that displays a daily tip on the user's home screen based on their first bird's "Gotcha Day".
*   **Care Task Management:** An in-app system for creating and tracking recurring tasks (e.g., "Clean Cage Weekly"), with "Overdue" and "Upcoming" status visibility.
*   **Curated Knowledge Center:** A scalable module for displaying a curated list of external articles and videos, which can be opened in the device's browser.
*   **Branding & Theming:** A full, app-wide visual theme was implemented, including a custom color scheme, logo, and consistent typography.

---
### **Version 1.1: The Polish & Management Update (Completed)**

The goal of this phase is to refine the user experience and add core management features on top of our existing foundation.

*   **[x] Edit/Delete Log Entries:** Implemented full CRUD functionality for all log types on the Daily Log screen. (Completed)
*   **[x] Improved Sign-Up Flow:** Refactored the AuthScreen with a dynamic toggle, validation, and a "Forgot Password" flow. (Completed)
*   **[x] Nest Management:** Built the UI to create, rename, delete, and manage Nests (cages) within an Aviary. (Completed)
*   **[x] Bird-to-Nest Assignment:** Allow users to assign their birds to Nests and add a Species to the bird profile. (Completed)
*   **[x] About FlockWell Screen:** Created a screen to display the app version and a dynamic changelog. (Completed)
*   **[x] Guardian & Caregiver Polish:** Allowed Guardians to set a custom label and fixed critical caregiver permissions. (Completed)

---
### **Version 1.2: The Community & Growth Update (In Progress)**

With a polished core app, this phase focuses on user engagement and growth.

*   **[x] Bulk Bird-to-Nest Movement:** Add a utility to allow users to move multiple birds from one nest to another in a single action. (Completed)
*   **[x] Bird Profile Enhancements:** Added Hatch Day to profiles and display age, anniversary, species, and nest clusters on the home screen. (Completed)
*   **[x] In-App Anniversary Reminders:** Implemented a reliable in-app card to display upcoming anniversary countdowns. (Completed as a pivot from native notifications)
*   **[x] Foundational Navigation Refactor:** Implemented a primary bottom navigation bar, created placeholder screens for Community and Notifications, and de-cluttered the main AppBar. (Completed)
*   **[x] Interactive Anniversary Cards:** Allow users to swipe-to-dismiss upcoming anniversary reminders from the home screen. (Completed)

*   **[x] Community Aviary - Phase 1: Core Q&A & Image Support:** (Completed)
    *   [x] Implemented privacy-first user identity (Aviary Names & User Labels).
    *   [x] Implemented the core UI for creating, viewing, listing, replying to, and displaying media for "Chirps".

*   **[ ] Community Aviary - Phase 2: Interaction & Sorting (Up Next):**
    *   **[x] "+1 / Tell Me Too" system. (Completed)**
    *   **[x] "Helpful" marking system for replies. (Completed)**
    *   **Implement "Squawk" (Report) & Delete Functionality - Phase 1:**
        *   [x] Add a menu to all Chirps and replies.
        *   [x] Display a "Squawk" option for other users' content and a "Delete" option for a user's own content.
        *   [x] Create a dialog for users to select a reason for reporting.
        *   [x] Implement a generic, secure Cloud Function (`reportContent`) to write reports to a `reports` collection for manual admin review.
        *   [x] The reporting action is invisible to other users, and reported content remains visible until a moderator takes action.
    *   Implement the **"Best Answer"** system for the original poster.
    *   Add UI controls to sort the Chirp list.
    *   Add a filter for "Unread" Chirps.

*   **[ ] Community Aviary - Phase 3: Rich Content & Safety:**
    *   Implement video and GIF uploading.
    *   Implement automatic NSFW content moderation.
    *   **Add profile pictures for users and birds.**
    *   **Implement "Squawk" (Report Content) Functionality - Phase 2:**
        *   [ ] Design and implement an automated system where a high number of reports can trigger an automatic action (e.g., hiding the content pending review).

*   **[ ] Community Aviary - Phase 4: The Flock Feed:**
    *   Build the UI for the vertical-scrolling Flock Feed.
    *   Implement the "Like" and "Comment" systems.
    *   Add Community-related notifications.

---
### **Version 1.3: Technical Health & Polish Update**

This phase focuses on improving the long-term stability, maintainability, and overall quality of the codebase.

*   **[x] Centralize String Constants:** Migrated all hardcoded UI strings into a central `constants.dart` file with a scalable, thematic architecture. (Completed)
*   **[x] Refactor User Identity Logic:** Created a `UserService` to centralize the logic for fetching a user's `authorLabel`, removing code duplication. (Completed)
*   **[x] Improve Self-Identification in Community Feeds:**
    *   [x] Display a "by You" label instead of the full author label for the current user's own Chirps and replies.
    *   [x] Apply a subtle background highlight to the cards of the current user's Chirps and replies to improve scannability.
*   **[ ] Address All Linter Warnings:** Resolve all outstanding IDE warnings (`use_build_context_synchronously`, etc.) to improve code stability.
*   **[ ] Implement Robust Logging & Error Handling:** Replace all development `print()` calls with a proper logging framework and implement user-facing `SnackBar` messages for all `try-catch` blocks.
*   **[ ] Implement Invitation Decline Logic:** Add the ability for users to decline pending caregiver invitations. (Addresses `TODO` in `pending_invitations_card.dart`).
*   **[ ] Implement Droppings Image Upload:** Add the ability for users to attach a photo to a droppings log entry. (Addresses `TODO` in `droppings_log_dialog.dart`).
*   **[ ] Refactor Backend Constants & Database Structure:**
    *   [ ] Decouple hardcoded collection names (e.g., 'birds') from Cloud Functions into a shared configuration.
    *   [ ] Plan and execute a Firestore data migration to a pet-agnostic schema (e.g., a `pets` collection with a `type` field).
*   **[ ] Global Access to User Actions:** Create a unified "Settings" or "Profile" page accessible from a main navigation point to house actions like Sign Out, Manage Aviary, etc.
*   **[ ] Email Verification & Password Reset Polish:**
    *   [ ] Resolve Firebase project block on email sending actions.
    *   [ ] Improve "Forgot Password" UX for social sign-in accounts.

---
### **Business & Admin Tools (Post-MVP)**

(Content Unchanged)

---

### **Future Versions: "The Nest Egg" (Long-Term Goals)**

These are major features to be prioritized after the core app is feature-complete.

*   **Premium Features ("FlockWell Plus" & "AI Credits"):**
    *   [ ] Implement the "FlockWell Plus" subscription and unlock associated features.
    *   [ ] Build the "AI Credits" consumable purchase model.
    *   [ ] Implement the free-tier pet limit.
*   **AI-Powered Insights:**
    *   [ ] Implement AI Duplicate Chirp Detection to reduce repeat questions.
    *   [ ] Implement other features under FSD section 3.4.
*   **Community Enhancements:**
    *   [ ] **V2.0: Public Aviary Profiles:** Evolve the app into a social network by allowing users to visit each other's public Aviary profiles, view their Flock, and perform social interactions (e.g., "likes," "pokes"). This will require a major focus on privacy controls and security rules.
    *   [ ] Implement threaded (nested) replies in the Q&A Forum.
    *   [ ] Implement user mentions (@username) that trigger notifications.
    *   [ ] Implement a "Hide Chirp" or "Not Interested" feature to allow users to customize their feeds.
*   **Power-User Logging...**
*   **Data Visualization & Trends...**
*   **Pre-Flight Checklist...**
*   **Live Community Chat (Deferred)...**
*   **In-App Video Editing Tools (Deferred)...**
*   **Automated Media Compression...**
*   **Species Expansion...**