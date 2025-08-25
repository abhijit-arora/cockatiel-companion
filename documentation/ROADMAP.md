# Functional Roadmap - Cockatiel Companion

This document outlines the planned development phases for the application, starting with the Minimum Viable Product (MVP).

---

### **Version 1.0: The Minimum Viable Product (MVP)**

The goal of the MVP is to deliver the core value proposition to our target user: **a new cockatiel owner who needs guidance and a simple way to track their bird's health.** We will focus on the single-user experience first.

**Core Modules & Features for MVP:**

*   **Module 1: User & Bird Profile**
    *   **1.1. User Account & The Aviary:**
        *   The "Aviary" represents the top-level user account or household. It contains all Caregivers, Nests, and Birds.
        *   Users can sign up using email/password or OAuth.
        *   **Email Verification:** Users who sign up with an email/password must verify their email address by clicking a link before gaining full access to the app.
    *   **[x] 1.3a. Create and list bird profiles.** (Completed)
    *   **[x] 1.3b. View and edit an existing bird profile.**

*   **Module 2: The Owner's Journey**
    *   **[x] 2.2. The Guided "First 30 Days" Plan.** This is a key feature for our target user.

*   **Module 3: The Care Hub**
    *   **[x] 3.1. The "Smart" Daily Log. (Completed)**
    *   **[x] 3.2. Health & Wellness Reminders.**

*   **Module 4: The Knowledge Center**
    *   **[x] 4.1. Curated Resource Library.** We will start with a foundational set of ~20 high-quality articles covering the most common new-owner questions.

---

### Technical Debt & Minor Bugs

*   **[ ] Daily Log Refresh:** The daily log screen does not always auto-refresh instantly after a new entry is saved. Requires a manual pull-to-refresh or a second action.
*   **[ ] Improved "Forgot Password" UX:** The app should detect if a user tries to reset a password for a social sign-in account and provide a helpful message.

---

### **Version 1.1: The Growth & Community Foundation Update**

The goal of this phase is to reduce friction for new users and build the core technical foundations for multi-user and community features.

*   **[ ] Edit/Delete Log Entries:** Add functionality to the Daily Log screen to edit or delete existing entries.
*   **[ ] Improved Sign-Up Flow:** Refactor the AuthScreen to have a clearer, distinct sign-up process (e.g., a toggle or separate dialog). (Completed)
*   **[ ] Email Verification:** Implement the email verification flow for new email/password sign-ups.
*   **[ ] Social Sign-In:** Implement frictionless login with Google & Apple.
*   **[ ] Aviary & Nest Hierarchy:** Implement the full data model for Aviaries (households) and Nests (cages).
*   **[ ] Caregiver Invitations:** Build the UI and logic for adding other users to an Aviary. (Plus Feature)
*   **[ ] Ad Integration:** Integrate an ad provider (e.g., Google AdMob) to display simple ads for free-tier users.

---

### **Version 1.2: The Community & Commerce Update**

With the user and data models in place, this phase focuses on building engagement and testing monetization.

*   **[ ] The Community Aviary:** Implement the basic Community Forum / Q&A. (Free Feature)
*   **[ ] The Shopping & Gear Hub:** Launch the affiliate link-driven "Perch." (Free Feature)
*   **[ ] Power-User Logging:**
    *   Implement "Shared Activities" for multi-bird logging.
    *   Implement "Batch Metric Entry" for efficiency.
*   **[ ] Premium Subscription:** Launch the "FlockWell Plus" subscription to remove ads and unlock premium features.

---

### **Business & Admin Tools (Post-MVP)**

This is a separate web application for managing the app's content and configuration.

*   **[ ] V1: Content Management:** An admin panel (web-based) to perform Create, Read, Update, and Delete (CRUD) operations on the "Knowledge Center" resources.
*   **[ ] V2: Configuration Management:** Add the ability to manage app-wide settings, user roles, and other configurations from the admin panel.

---

### **Future Versions: "The Nest Egg" (Long-Term Goals)**

These are major features to be prioritized after the core app is feature-complete.

*   **[ ] Data Visualization & Trends:** A new section for viewing graphs and filtered lists of log data over time. (Plus Feature)
*   **[ ] AI-Powered Insights:** Implement all features under FSD section 3.4. (Requires AI Credits)
*   **[ ] Pre-Flight Checklist:** Implement the pre-adoption module (FSD 2.1). (Free Feature)
*   **[ ] Social Feed:** Implement the photo & milestone sharing feed (FSD 5.2). (Free Feature)
*   **[ ] Species Expansion:** Architect the app to begin adding other bird species (Parakeets, Conures, etc.). (Core Feature)