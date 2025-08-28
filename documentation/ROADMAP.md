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
### **Technical Debt & Minor Bugs**

*   **[x] Daily Log Auto-Refresh:** Implemented auto-refresh on both creating and editing log entries. (Completed)
*   **[x] Home Screen Auto-Refresh:** Implemented pull-to-refresh and auto-refresh on return from profile screen. (Completed)
*   **[ ] Email Verification Blocked:** The Firebase project is currently blocking email sending actions (verification, password reset). This feature is deferred.
*   **[ ] "Forgot Password" UX:** The app should detect if a user tries to reset a password for a social sign-in account and provide a helpful message.

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

*   **[ ] Interactive Anniversary Cards (Up Next):**
    *   Allow users to swipe-to-dismiss upcoming anniversary reminders from the home screen to give them more control over their dashboard.

*   **[ ] Community Aviary - Phase 1: The Q&A Forum:**
    *   Build the core UI for the categorized Q&A hub ("Chirps").
    *   Implement functionality to create, view, and reply to Chirps.
    *   Implement the "Best Answer" and "Helpful" marking systems.

*   **[ ] Community Aviary - Phase 2: The Flock Feed:**
    *   Build the UI for the vertical-scrolling social feed.
    *   Implement functionality to upload and display photos and short-form videos.
    *   Implement the "Like" and "Comment" systems.

*   **[ ] Community Aviary - Phase 3: Polish & Engagement:**
    *   Implement the AI-powered "Similar Questions" check.
    *   Build the Community Profile pages.
    *   Add Community-related notifications (new replies, likes, etc.).

*   **[ ] Caregiver Permissions & Roles (Phase 2):**
    *   Implement a role-based system for the Guardian to manage permissions (e.g., Flock Leader, Flock Member, Nest Sitter).

*   **[ ] Social Sign-In (Apple):** Implement Sign in with Apple to complete our social login options.
*   **[ ] Ad Integration:** Integrate an ad provider (e.g., Google AdMob) to display simple ads for free-tier users.
*   **[ ] The Shopping & Gear Hub:** Launch the affiliate link-driven "Perch." (Free Feature)

---

### **Business & Admin Tools (Post-MVP)**

This is a separate web application for managing the app's content and configuration.

*   **[ ] V1: Content Management:** An admin panel (web-based) to perform Create, Read, Update, and Delete (CRUD) operations on the "Knowledge Center" resources.
*   **[ ] V2: Configuration Management:** Add the ability to manage app-wide settings, user roles, and other configurations from the admin panel.

---

### **Future Versions: "The Nest Egg" (Long-Term Goals)**

These are major features to be prioritized after the core app is feature-complete.

*   **Premium Features:** Launch the "FlockWell Plus" subscription and "AI Credits" models.
*   **Power-User Logging:** Implement "Shared Activities" and "Batch Metric Entry".
*   **Data Visualization & Trends:** A new section for viewing graphs and filtered lists of log data over time. (Plus Feature)
*   **AI-Powered Insights:** Implement all features under FSD section 3.4. (Requires AI Credits)
*   **Pre-Flight Checklist:** Implement the pre-adoption module (FSD 2.1). (Free Feature)
*   **Live Community Chat:** Implement a real-time text chat feature. (Deferred due to high complexity and moderation costs).
*   **Species Expansion:** Architect the app to begin adding other bird species (Parakeets, Conures, etc.). (Core Feature)
*   **Business & Admin Tools:** A separate web application for managing the app's content and configuration.