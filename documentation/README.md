# FlockWell (formerly Cockatiel Companion)

This is the official repository for the FlockWell mobile application, an AI-assisted companion designed to help new and existing bird owners provide the best possible care for their feathered friends.

## Project Vision

To become the indispensable digital companion for every cockatiel owner, transforming the anxiety of new pet parenthood into a confident, joyful, and deeply bonded relationship. We aim to create a world with healthier, happier, and better-understood companion birds.

## Current Status

The project has completed a major **V1.2 (Community & Growth)** development phase. The `main` branch is stable.

Core features currently implemented on the `main` branch include:
- **Full Authentication:** Email/Password, Google Sign-In, and a polished UI.
- **Multi-User Aviary System:** A complete backend for households (Aviaries), cages (Nests), and an invitation system for Caregivers.
- **Complete Bird & Nest Management:** Full CRUD for bird profiles and nests, plus a bulk-move utility.
- **Smart Daily Logging:** A real-time system for logging and viewing daily data with full CRUD functionality.
- **Interactive Q&A Forum:** The "Community Aviary" allows users to post questions with images, reply to others, follow posts (+1), and mark replies as "Helpful".
- **Community Safety:** A full moderation system is in place, allowing users to delete their own content and "Squawk" (report) others' content for admin review.
- **User Engagement Features:** A "Guided 30-Day Plan," anniversary reminders, and a curated "Knowledge Center."
- **Task Management:** An in-app system for tracking recurring "Care Tasks."

## Tech Stack

- **Framework:** Flutter
- **Backend:** Firebase (Auth, Firestore)
- **Platform:** iOS, Android, Web

## Getting Started

This is a standard Flutter project. To run it, ensure you have the Flutter SDK installed, then run `flutterfire configure` to connect to your own Firebase instance, followed by `flutter pub get` and `flutter run`.