# Functional Specification Document (FSD) - v0.2

This document details the features and functionalities of the Cockatiel Companion application.

---

### Module 1: User & Nest Management

*   **1.1. User Account Creation:**
    *   Users can sign up using email/password or OAuth (Google, Apple).
    *   User profile includes a username and an optional profile picture.

*   **1.2. The Nest System (Household):**
    *   A "Nest" represents the user's household. It contains Caregivers and Birds.
    *   An initial user creates the Nest.
    *   The primary user can invite other family members ("Caregivers") to the Nest via email or a unique link.
    *   All Caregivers in a Nest can view and manage the profiles of all the Birds in the Nest's "Flock."

*   **1.3. Bird Profile Creation (The Flock):**
    *   The "Flock" is the collection of all `Bird` profiles belonging to a Nest.
    *   Users can create multiple bird profiles within their Nest.
    *   **Fields:** Name, Photo, Hatch Date, Gotcha Day, Sex, Color Mutation, Notes/Bio.

---

### Module 2: The Owner's Journey (Guidance)

*   **2.1. The "Pre-Flight Checklist" (Pre-Adoption):**
    *   An interactive guide accessible to all users, even before creating a bird profile.
    *   **Content:** Guides on budgeting, choosing a bird, cage setup, bird-proofing the home, and an essential shopping list.

*   **2.2. The Guided "First 30 Days" Plan:**
    *   An optional, guided onboarding plan triggered when a new bird profile is created.
    *   Provides daily tasks, tips, and learning modules to help users settle in with their new bird.

---

### Module 3: The Care Hub (Daily Management & AI)

*   **3.1. The "Smart" Daily Log:**
    *   An intuitive interface for logging daily information for each bird.
    *   **Metrics:** Diet, Droppings (with photo option), Behavior/Mood tags, Weight, Training Sessions, Out-of-Cage Time.
    *   **Guidance:** Each input will have contextual "info" icons providing recommended ranges and healthy examples (e.g., healthy weight chart, examples of a good diet).

*   **3.2. Health & Wellness Reminders:**
    *   Users can set custom, recurring reminders for cage cleaning, food/water changes, vet appointments, and medication.

*   **3.3. Data Storage Model:**
    *   **Free Tier:** Data is stored locally on the user's device. Includes a feature to backup/restore to the user's personal cloud service (Google Drive, iCloud).
    *   **Premium Tier:** Data is securely synced to our cloud database, enabling multi-device access and the Flock/Shared Care feature.

*   **3.4. AI-Powered Insights (Long-Term Premium Features):**
    *   **AI Health Trend Analysis:** Analyzes logged data to flag potential health concerns proactively.
    *   **AI Enrichment Suggester:** Recommends new toys and activities based on logged behavior.
    *   **AI Symptom Checker (Informational):** A guided questionnaire to help users understand symptoms and when to see a vet. Must include strong "not a vet" disclaimers.

---

### Module 4: The Knowledge Center (The Library)

*   **4.1. Curated Resource Library:**
    *   A searchable library of vetted articles and guides on Health, Nutrition, Behavior, Safety, and Enrichment.

*   **4.2. Curated Video Hub:**
    *   An embedded collection of high-quality, relevant videos from trusted creators.

*   **4.3. Shopping & Gear Hub (The Perch):**
    *   A curated section of recommended products (cages, food, toys) with brief reviews.
    *   Will use affiliate links for monetization, with full disclosure to the user.

---

### Module 5: The Community Aviary (Social Hub)

*   **5.1. Community Forum / Q&A:**
    *   A space for users to ask questions and share answers, organized by topic.

*   **5.2. Photo & Milestone Sharing:**
    *   A social feed for users to share photos and celebrate milestones.

---

### Module 6: Monetization & App Structure

*   **6.1. Freemium Model:**
    *   **Free Tier:** Limited bird profiles (e.g., 2), local data storage, community access, shopping hub access, limited access to the Knowledge Center.
    *   **Premium Tier (Subscription):** Unlimited bird profiles, cloud data sync (enabling Flock feature), full access to the Knowledge Center, and all AI-powered features.