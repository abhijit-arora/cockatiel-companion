# FlockWell

This is the official repository for the FlockWell mobile application, the first app in the planned **FlockWell Ecosystem**. It is an AI-assisted companion designed to help new and existing bird owners provide the best possible care for their feathered friends.

## Project Vision

To become the indispensable digital companion for the modern pet parent by creating a suite of specialized, AI-assisted applications (the **FlockWell Ecosystem**). We aim to transform the anxiety of new ownership into a confident, joyful, and deeply bonded relationship.

Our goal is to create a world with healthier, happier, and better-understood companion animals, supported by a thriving community of knowledgeable and confident owners.

## Current Status

The project has completed a major **V1.2 (Community & Growth)** development phase and a significant **V1.3 (Technical Health & Polish)** sprint. The `main` branch is stable and the Q&A section of the Community Aviary is now feature-complete.

Core features currently implemented on the `main` branch include:
- **Full Authentication:** Email/Password, Google Sign-In, and a polished UI.
- **Multi-User Aviary System:** A complete and robust backend for households (Aviaries), cages (Nests), and a full invitation workflow (invite, accept, decline, revoke).
- **Complete Bird & Nest Management:** Full CRUD for bird profiles and nests, plus a bulk-move utility.
- **Smart Daily Logging:** A real-time system for logging and viewing daily data with robust error handling.
- **Feature-Complete Q&A Forum:** The "Community Aviary" allows users to:
    - Post questions with images.
    - Reply to others.
    - Follow posts (`+1 / Tell Me Too`).
    - Mark replies as `Helpful`.
    - Select a `Best Answer` for their questions.
    - Sort the feed by latest activity, follows, or replies.
- **Community Safety & Moderation:** A full moderation system is in place, allowing users to delete their own content and "Squawk" (report) others' content for admin review.
- **Polished User Experience:** Includes a global settings page, consistent navigation, and self-identification UI (e.g., "Posted by You").
- **Task Management & User Guidance:** An in-app system for tracking recurring "Care Tasks" and a "Guided 30-Day Plan."

## Tech Stack

- **Framework:** Flutter
- **Backend:** Firebase (Auth, Firestore)
- **Platform:** iOS, Android, Web

## Getting Started

This is a standard Flutter project. To run it, ensure you have the Flutter SDK installed, then run `flutterfire configure` to connect to your own Firebase instance, followed by `flutter pub get` and `flutter run`.