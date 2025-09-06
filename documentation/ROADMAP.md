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
    *   **[x] "Squawk" (Report) & Delete Functionality - Phase 1. (Completed)**
    *   **[x] "Best Answer" system for the original poster. (Completed)**
    *   **[x] UI controls to sort the Chirp list. (Completed)**
    *   Add a filter for "Unread" Chirps.

*   **[ ] Community Aviary - Phase 3: Rich Content & Safety:**
    *   Implement video and GIF uploading.
    *   Implement automatic NSFW content moderation.
    *   **Implement User Avatars (Phase 1):**
        *   [ ] Create a library of pre-made, selectable in-app avatars.
        *   [ ] Allow users to choose an avatar from a new selection screen.
        *   [ ] Display the chosen avatar throughout the community sections.
    *   **(Future) Implement Custom Profile Picture Uploads (Phase 2).**
    *   **Implement "Squawk" (Report Content) Functionality - Phase 2:**
        *   [ ] Design and implement an automated system where a high number of reports can trigger an automatic action (e.g., hiding the content pending review).

*   **[ ] Community Aviary - Phase 4: The Flock Feed (Up Next):**
    *   **[x] Build the foundational UI for the vertical-scrolling Flock Feed. (Completed)**
    *   **[x] Implement the backend and creation flow for Flock Feed posts. (Completed)**
        *   [x] Created a new `community_feed_posts` collection with security rules.
        *   [x] Built the `CreateFeedPostScreen` for composing posts with media and captions.
        *   [x] Implemented a `createFeedPost` Cloud Function to handle post creation and hashtag parsing.
        *   [x] Wired up the `FlockFeedScreen` to a live `StreamBuilder`.
    *   **Implement Core Feed Interactions:**
        *   [ ] Implement "Like" functionality with a secure `toggleFeedPostLike` Cloud Function.
        *   [ ] Implement "Delete" functionality with a `deleteFeedPost` Cloud Function that also removes the associated media from Firebase Storage.
        *   [ ] Wire up the "Squawk" (report) button to our existing `reportContent` Cloud Function.
    *   **[x] Implement the Core Comment System. (Completed)**
        *   [x] Built the UI for the `FeedPostDetailScreen` to view a post and its comments.
        *   [x] Implemented the `addFeedComment` Cloud Function and security rules for posting new comments.
        *   [x] Wired up the UI to post and display comments in real-time, sorted chronologically.
    *   **Implement Comment Interactions:**
        *   [ ] Implement "Like" functionality for comments.
        *   [ ] Add Delete/Report functionality to comments.
    *   Add Community-related notifications for likes and new comments.

---
### **Version 1.3: Technical Health & Polish Update**

This phase focuses on improving the long-term stability, maintainability, and overall quality of the codebase.

*   **[x] Centralize String Constants (Completed)**
*   **[x] Refactor User Identity Logic (Completed)**
*   **[x] Improve Self-Identification in Community Feeds (Completed)**
*   **[x] Address All Linter Warnings (Completed)**
*   **[x] Implement Robust Logging & Error Handling (Completed)**
*   **[x] Implement Invitation Decline Logic (Completed)**
*   **[ ] Implement Droppings Image Upload**
*   **[ ] Refactor Backend Constants & Database Structure:**
    *   [ ] Decouple hardcoded collection names from Cloud Functions into a shared configuration.
    *   [ ] Execute a Firestore data migration to a pet-agnostic schema (e.g., `pets` collection).
    *   [ ] Rename `community_chirps` collection to `community_queries` to align with the generic backend strategy.
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