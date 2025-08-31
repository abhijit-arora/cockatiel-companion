# Functional Roadmap - Cockatiel Companion

This document outlines the planned development phases for the application, starting with the Minimum Viable Product (MVP).

---

### **Version 1.0: Minimum Viable Product (Completed)**

The goal of the MVP was to deliver the core value proposition: a single-user, cloud-synced mobile companion for a new bird owner to track their pet's health and well-being.

**Key Features Delivered:**
*   Authentication
*   Multi-User Foundation
*   Bird Profile Management
*   The "Smart" Daily Log
*   Guided Onboarding
*   Care Task Management
*   Curated Knowledge Center
*   Branding & Theming

---

### **Version 1.1: The Polish & Management Update (Completed)**

The goal of this phase is to refine the user experience and add core management features on top of our existing foundation.

*   [x] Edit/Delete Log Entries
*   [x] Improved Sign-Up Flow
*   [x] Nest Management
*   [x] Bird-to-Nest Assignment
*   [x] About FlockWell Screen
*   [x] Guardian & Caregiver Polish

---

### **Version 1.2: The Community & Growth Update (In Progress)**

With a polished core app, this phase focuses on user engagement and growth.

*   [x] Bulk Bird-to-Nest Movement
*   [x] Bird Profile Enhancements
*   [x] In-App Anniversary Reminders
*   [x] Foundational Navigation Refactor
*   [x] Interactive Anniversary Cards

*   **[x] Community Aviary - Phase 1: Core Q&A & Image Support:** (Completed)
    *   [x] User Identity (Aviary Names & User Labels).
    *   [x] Core UI for Chirps (Create, View, List, Reply, Media).

*   **[ ] Community Aviary - Phase 2: Interaction & Sorting (Up Next):**
    *   **[x] "+1 / Tell Me Too" system. (Completed)**
    *   Implement the **"Helpful"** marking system for replies.
    *   Implement the **"Best Answer"** system for the original poster.
    *   Add UI controls to sort the Chirp list.
    *   Add a filter for "Unread" Chirps.

*   **[ ] Community Aviary - Phase 3: Rich Content & Safety:**
    *   Implement video and GIF uploading.
    *   Implement automatic NSFW content moderation.
    *   **Add profile pictures for users and birds. (Addresses `TODO` in `profile_screen.dart`)**

*   **[ ] Community Aviary - Phase 4: The Flock Feed:**
    *   Build the UI for the Flock Feed.
    *   Implement "Like" and "Comment" systems.
    *   Add Community-related notifications.

---

### **Version 1.3: Technical Health & Polish Update**

This phase focuses on improving the long-term stability, maintainability, and overall quality of the codebase.

*   **[ ] Address All Linter Warnings:** Resolve all outstanding IDE warnings (`use_build_context_synchronously`, etc.) to improve code stability.
*   **[ ] Implement Robust Logging & Error Handling:** Replace all development `print()` calls with a proper logging framework and implement user-facing `SnackBar` messages for all `try-catch` blocks.
*   **[ ] Centralize String Constants:** Migrate hardcoded strings into a central `lib/core/constants.dart` file.
*   **[ ] Refactor User Identity Logic:** Create a `UserService` to centralize the logic for fetching a user's `authorLabel`, removing code duplication.
*   **[ ] Implement Invitation Decline Logic:** Add the ability for users to decline pending caregiver invitations. (Addresses `TODO` in `pending_invitations_card.dart`).
*   **[ ] Implement Droppings Image Upload:** Add the ability for users to attach a photo to a droppings log entry. (Addresses `TODO` in `droppings_log_dialog.dart`).
*   **[ ] Email Verification & Password Reset Polish:**
    *   [ ] Resolve Firebase project block on email sending actions.
    *   [ ] Improve "Forgot Password" UX for social sign-in accounts.

---

### **Business & Admin Tools (Post-MVP)**

This is a separate web application for managing the app's content and configuration.

*   [ ] V1: Content Management (CRUD for Knowledge Center).
*   [ ] V2: Configuration Management.

---

### **Future Versions: "The Nest Egg" (Long-Term Goals)**

These are major features to be prioritized after the core app is feature-complete.

*   Premium Features ("FlockWell Plus" & "AI Credits").
*   Power-User Logging.
*   Data Visualization & Trends.
*   AI-Powered Insights.
*   Pre-Flight Checklist.
*   Live Community Chat (Deferred).
*   In-App Video Editing Tools (Deferred).
*   Automated Media Compression.
*   Species Expansion.