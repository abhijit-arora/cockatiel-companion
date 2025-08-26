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

*   **[ ] Daily Log Auto-Refresh:** The daily log screen does not auto-refresh instantly after a new entry is created or deleted. The `StreamZip` logic needs to be refactored for more responsive UI updates. Manual pull-to-refresh works as a fallback.
*   **[ ] Email Verification Blocked:** The Firebase project is currently blocking email sending actions (verification, password reset). This feature is deferred.
*   **[ ] "Forgot Password" UX:** The app should detect if a user tries to reset a password for a social sign-in account and provide a helpful message.

---
### **Version 1.1: The Polish & Management Update**

The goal of this phase is to refine the user experience and add core management features on top of our existing foundation.

*   **[x] Edit/Delete Log Entries:** Add functionality to the Daily Log screen to edit or delete existing entries. (Completed)
*   **[x] Improved Sign-Up Flow:** Refactored the AuthScreen with a dynamic toggle, validation, and a "Forgot Password" flow. (Completed)
*   **[ ] Nest Management:** Build the UI to create, rename, and manage Nests (cages) within an Aviary.
*   **[ ] Bird-to-Nest Assignment:** Allow users to assign their birds to the Nests they've created. This includes adding a **Species** dropdown to the bird profile creation screen.

---
### **Version 1.2: The Community & Growth Update**

With a polished core app, this phase focuses on user engagement and growth.

*   **[ ] The Community Aviary:** Implement the basic Community Forum / Q&A. (Free Feature)
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
*   **Business & Admin Tools:** A separate web app for content management.
*   **Data Visualization & Trends.** (Plus Feature)
*   **AI-Powered Insights.** (Requires AI Credits)
*   **Pre-Flight Checklist.** (Free Feature)
*   **Social Feed.** (Free Feature)
*   **Species Expansion.** (Core Feature)