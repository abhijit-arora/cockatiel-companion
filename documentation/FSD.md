# Functional Specification Document (FSD)

- **App Name:** FlockWell (formerly Cockatiel Companion)
- **Document Version:** 0.4
- **Last Updated:** 2025-08-27

This document details the features and functionalities of the FlockWell application.

---

### Module 1: The Aviary (User & Household Management)

*   **1.1. User Account & The Aviary:**
    *   The "Aviary" represents the top-level user account/household.
    *   Users can sign up using email/password or OAuth.
    *   **Aviary Fields:** Vet Contact Details, Emergency Contacts, Household-level notes (e.g., feeding schedule).

*   **1.2. Caregiver Management:**
    *   The primary user can invite other family members ("Caregivers") to their Aviary.
    *   **Caregiver Labels:** The primary user can assign fun, thematic labels to caregivers (e.g., "Mama Birdie," "The Flock Master").
    *   **Architectural Rule:** A user account can only belong to one Aviary at a time. To accept an invitation to another Aviary, a user with an existing Aviary must agree to archive their own.

*   **1.3. Nest Management (Cages):**
    *   A "Nest" represents a physical cage or enclosure.
    *   Users can create multiple Nests within their Aviary.
    *   **Nest Fields:** Name (e.g., "Main Flight Cage"), Photo, Dimensions, Color, Brand/Model, Notes.

*   **1.4. Bird Profile Creation (The Flock):**
    *   The "Flock" is the collection of all `Bird` profiles belonging to an Aviary.
    *   Users can create multiple bird profiles and assign them to a Nest.
    *   **Fields:** Name, Photo, **Species (e.g., Cockatiel, Budgerigar)**, Nest ID, Hatch Date, Gotcha Day, Sex, Color Mutation, Notes/Bio.

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

### Module 5: The Community Aviary (Community & Sharing Hub)

The Community Aviary is a multifaceted social hub designed to foster a supportive and engaging environment for bird owners. It consists of two primary sections: a structured Q&A Forum for problem-solving and a visual "Flock Feed" for social sharing.

*   **5.1. The Two-Tabbed Hub:** The main screen of the module will be organized into two distinct feeds that the user can switch between.

    *   **5.1.1. The Q&A Forum ("Chirps"):** This section is dedicated to structured question-and-answer discussions.
        *   **Posts as "Chirps":** All posts/questions will be thematically referred to as "Chirps."
        *   **Categories:** Chirps will be organized into clear categories to ensure focused discussions (e.g., Health & Wellness, Behavior & Training, Nutrition, Gear, General Chat).
        *   **"+1 / Tell Me Too":** Instead of a simple upvote, Chirps will have a "+1" or "Tell Me Too" button. This allows users to follow a question they are also interested in, increasing its visibility and notifying them of new replies. The original poster's vote is automatically included.
        *   **Replies & "Helpful" Marks:** Any user can reply to a Chirp. Other users can mark a reply as "Helpful" to endorse good advice.
        *   **Best Answer:** The original poster has the ability to mark one reply as the "Best Answer," which will be highlighted and pinned for future readers.
        *   **Media Attachments:** Users can attach one optional photo or short-form video (up to 15 seconds) to their Chirp for context.

    *   **5.1.2. The Flock Feed:** This section is a visual, continuous-scrolling feed for social sharing.
        *   **Content:** The feed will consist exclusively of user-submitted photos and short-form videos (up to 15 seconds) showcasing their birds.
        *   **Interactions:** Users can "Like" (e.g., with a heart icon) and post comments on any item in the feed.

*   **5.2. Community Engagement & Profiles:**

    *   **5.2.1. Community Profiles:** A simple, non-intrusive profile system will be in place. Tapping on a user's thematic label (e.g., "Papa Birdie") will navigate to a page listing that user's public activity (their Chirps, replies, and Flock Feed posts).
    *   **5.2.2. Community Notifications:** To drive re-engagement, users will receive in-app (and eventually push) notifications for key interactions, such as:
        *   "Someone replied to your Chirp."
        *   "Someone liked your photo in the Flock Feed."

*   **5.3. AI-Powered Duplicate Prevention (Q&A Forum Polish):**

    *   To maintain a clean and organized Q&A forum, an AI-powered check will be implemented.
    *   When a user finishes typing a title for a new Chirp, a semantic search will be performed in the background to find existing, similar questions.
    *   If matches are found, the user will be presented with a non-blocking dialog suggesting they view the existing answers before posting a new question.

*   **5.4. Moderation:**

    *   All Chirps, replies, and Flock Feed posts will have a "Report" button.
    *   This will allow users to flag content that is inappropriate, abusive, or contains dangerously incorrect advice.
    *   Reported content will be sent to a queue for review by moderators via the Business & Admin Tools panel.

---

### Module 6: Monetization & App Structure

*   **6.1. Monetization Strategy: A Fair Hybrid Model**
    
    The app will operate on a hybrid model that balances user choice, fairness, and predictable business revenue. It consists of three tiers that directly map to the features defined in this FSD.

    ---
    #### **Tier 1: Free**
    *Goal: Provide core utility and attract a large user base, supported by non-intrusive ads.*
    *   **User & Nest Management (Module 1):** Manage up to 2 bird profiles. Nest/sharing features are disabled.
    *   **Daily Log (Module 3.1):** Full access to all daily log types.
    *   **Data Storage (Module 3.3):** All data is stored locally on the user's device with manual backup/restore.
    *   **Knowledge Center (Module 4):** Limited access (e.g., 3 free articles per month).
    *   **Community (Module 5):** Full access to community forums and social features.
    *   **Advertising:** This tier will be supported by advertisements. Ads may include sponsored posts in feeds or occasional splash screens. Subscribing to "FlockWell Plus" will remove all ads.

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