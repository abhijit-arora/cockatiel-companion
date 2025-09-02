# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- **Community Aviary - Phase 2:**
  - Filter for "Unread" Chirps.
- **Community Aviary - Phase 3:**
  - Video and GIF support for posts.
  - Automated NSFW content moderation.
  - Profile pictures for users and birds.
  - "Squawk" (Report Content) Phase 2: Automated actions.
- **Community Aviary - Phase 4 (Flock Feed):**
  - Backend and creation flow for Flock Feed posts.
  - "Like" and "Comment" systems for feed posts.
  - Community-related notifications.

## [1.3.0] - 2025-09-01

### Changed
- **Architectural Vision:** Updated `VISION.md`, `README.md`, and `FSD.md` to reflect the broader multi-pet ecosystem strategy.

### Fixed
- Resolved numerous `use_build_context_synchronously` linter warnings to prevent potential runtime crashes.
- Resolved `avoid_print` linter warnings by implementing user-facing `SnackBar` messages for all `try-catch` blocks.
- Corrected a bug that allowed duplicate pending caregiver invitations.
- Fixed a bug that prevented automatic redirection to the login screen after signing out.

### Added
- **Technical Health:**
  - Implemented a `.gitattributes` file to enforce consistent line endings across the repository.
- **UI & UX Polish:**
  - Created a global "Profile & Settings" page accessible from all main screens, unifying navigation.
  - Improved the caregiver management UI to show the status of all invitations (pending, accepted, declined) and allow dismissal.

## [1.2.0] - 2025-09-01

### Added
- **Community Aviary (Q&A Forum):**
  - **Feature-complete Q&A Forum.**
  - **Best Answer System:** Allows original posters to mark one reply as the definitive solution, which is then pinned to the top.
  - **Content Sorting:** Users can now sort the feed by "Latest Activity," "Most Follows," or "Most Replies". The feed now defaults to sorting by latest activity.
  - **Pull-to-Refresh:** Implemented on all community feeds.
  - **"Helpful" Marking System:** Allows users to endorse helpful replies.
  - **Content Reporting & Deletion ("Squawk"):** Users can now delete their own content and report others' content for manual moderation (Phase 1).
  - **"+1 / Tell Me Too" System:** Allows users to follow questions.
- **UI & UX Polish:**
  - Created a unified `UnifiedPostCard` widget to ensure a consistent design language between the Q&A Forum and the future Flock Feed.
  - **Self-Identification:** The UI now displays "by You" and adds a visual highlight for a user's own content.
- **Bird & Aviary Management:**
  - Utility for bulk-moving birds between nests.
  - Added Hatch Day and Gotcha Day to bird profiles.
- **Home Screen & UI:**
  - Major navigation refactor with a new bottom navigation bar.
  - In-app anniversary reminders with swipe-to-dismiss functionality.
- **Technical Health:**
  - Centralized all user-facing strings into a scalable, theme-aware constants file.
  - Refactored user identity logic into a dedicated `UserService` to remove duplication.

## [1.1.0] - 2025-08-29

### Added
- Guardian & Caregiver custom labels and permission fixes.
- Species and Nest assignment to bird profiles.
- Full CRUD for Nests (cages).
- Improved Auth screen with dynamic toggle and "Forgot Password" flow.
- Full CRUD for all daily log entry types.
- "About FlockWell" screen.

## [1.0.0] - 2025-08-28
- Initial MVP release.