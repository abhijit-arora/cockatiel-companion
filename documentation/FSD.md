# Functional Specification Document (FSD) - v0.2

This document details the features and functionalities of the Cockatiel Companion application.

---

### Module 1: The Aviary (User & Household Management)

*   **1.1. User Account & The Aviary:**
    *   The "Aviary" represents the top-level user account or household. It contains all Caregivers, Nests, and Birds.
    *   Users can sign up using email/password or OAuth.

*   **1.2. Caregiver Management:**
    *   The primary user can invite other family members ("Caregivers") to their Aviary.
    *   All Caregivers in an Aviary can view and manage all Nests and Birds within it.

*   **1.3. Nest Management (Cages):**
    *   A "Nest" represents a physical cage or enclosure.
    *   Users can create multiple Nests within their Aviary (e.g., "Main Flight Cage," "Sleeping Cage").
    *   Each bird profile will be assigned to a specific Nest.

*   **1.4. Bird Profile Creation (The Flock):**
    *   The "Flock" is the collection of all `Bird` profiles belonging to an Aviary.
    *   Users can create multiple bird profiles and assign them to a Nest.
    *   **Fields:** Name, Photo, Nest ID, Hatch Date, Gotcha Day, Sex, Color Mutation, Notes/Bio.

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

*   **6.1. Monetization Strategy: A Fair Hybrid Model**
    
    The app will operate on a hybrid model that balances user choice, fairness, and predictable business revenue. It consists of three tiers that directly map to the features defined in this FSD.

    ---
    #### **Tier 1: Free**
    *Goal: Provide core utility and attract a large user base.*
    *   **User & Nest Management (Module 1):** Manage up to 2 bird profiles. Nest/sharing features are disabled.
    *   **Daily Log (Module 3.1):** Full access to all daily log types.
    *   **Data Storage (Module 3.3):** All data is stored locally on the user's device with manual backup/restore.
    *   **Knowledge Center (Module 4):** Limited access (e.g., 3 free articles per month).
    *   **Community (Module 5):** Full access to community forums and social features.

    ---
    #### **Tier 2: FlockWell Plus (Subscription)**
    *Goal: Provide unlimited core features and convenience for a predictable monthly/annual fee.*
    *   **User & Nest Management (Module 1):** Unlocks unlimited bird profiles and enables the full "Nest" system for sharing with caregivers.
    *   **Data Storage (Module 3.3):** Enables secure, automatic cloud sync for all data across multiple devices.
    *   **Knowledge Center (Module 4):** Grants unlimited access to all articles and resources.
    *   **Health & Wellness Reminders (Module 3.2):** Unlocks advanced, customizable health and care reminders.
    *   **Data Visualization (Future):** Unlocks non-AI charts and trend analysis tools.

    ---
    #### **Tier 3: AI Credits (Consumable Purchase)**
    *Goal: Provide fair, pay-for-what-you-use access to features with high operational costs.*
    *   These are a separate purchase from the "Plus" subscription. Users can buy packs of "AI Credits."
    *   **AI-Powered Insights (Module 3.4):** Credits are spent on a per-use basis for features like:
        *   AI Droppings Analysis from a photo.
        *   AI Symptom Checker consultation.
        *   Generating detailed weekly AI Behavior Reports.
    *   **Cloud Storage for Media:** While data sync is part of "Plus," storing large amounts of photos/videos will be tied to a separate, affordable storage plan (e.g., pay per 10GB). This ensures heavy users pay proportionally for their storage costs.