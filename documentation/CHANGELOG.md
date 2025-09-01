# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - V1.3 In Progress

### Added
- **Community Aviary (Q&A Forum):**
  - "Best Answer" system for original posters.
  - Content reporting ("Squawk") Phase 2: Automated actions.
  - Sorting and filtering controls for the Chirp list.
  - Video and GIF support for posts.
- **Flock Feed:**
  - UI for the vertical-scrolling social feed.
  - "Like" and "Comment" systems for feed posts.
- **Monetization & Access Control:**
  - Integration with an ad provider.
  - Pet limit enforcement for the free tier.

## [1.2.0] - 2025-09-01

### Added
- **Community Aviary (Q&A Forum):**
  - Launched the foundational Q&A forum.
  - Users can create, view, list, and reply to posts ("Chirps").
  - Image attachment support for Chirps.
  - Privacy-first identity with Aviary Names and User Labels.
  - "+1 / Tell Me Too" system for following questions.
  - "Helpful" marking system for endorsing replies.
  - Content reporting ("Squawk") system for manual moderation (Phase 1).
  - Ability for users to delete their own Chirps and replies.
- **Bird & Aviary Management:**
  - Utility for bulk-moving birds between nests.
  - Added Hatch Day and Gotcha Day to bird profiles.
- **Home Screen & UI:**
  - Major navigation refactor with a new bottom navigation bar.
  - In-app anniversary reminders with swipe-to-dismiss functionality.
  - UI polish for self-identification (e.g., "Posted by You" and card highlighting).
- **Technical Health:**
  - Centralized all user-facing strings into a scalable constants file.
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