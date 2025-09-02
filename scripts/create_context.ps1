# This script prepares a single, timestamped text file to be used as context
# for resuming a conversation with the Gemini AI.

# --- CONFIGURATION ---
$filesToInclude = @(
    # Core Documentation
    "documentation/RESUME_PROMPT.md",
    "documentation/VISION.md",
    "documentation/ROADMAP.md",
    "documentation/FSD.md",
    "documentation/CHANGELOG.md",
    "README.md",

    # Project Configuration
    "pubspec.yaml",
    "firestore.rules",
    "functions/index.js",

    # Core App Logic & Constants
    "lib/main.dart",
    "lib/core/constants.dart",
    "lib/core/auth_gate.dart",
    "lib/core/main_screen.dart",

    # Feature: Authentication
    "lib/features/authentication/services/auth_service.dart",
    "lib/features/authentication/screens/auth_screen.dart",

    # Feature: User Services
    "lib/features/user/services/user_service.dart",
    
    # Feature: Home Screen
    "lib/features/home/screens/home_screen.dart",
    "lib/features/home/widgets/pending_invitations_card.dart",

    # Feature: Profile & Settings
    "lib/features/profile/screens/profile_screen.dart", # The Add/Edit Pet screen
    "lib/features/profile/screens/profile_settings_screen.dart",
    "lib/features/profile/widgets/settings_action_button.dart",

    # Feature: Aviary Management
    "lib/features/aviary/screens/aviary_management_screen.dart",
    
    # Feature: Community (Thematic names are okay here as they map to the folder)
    "lib/features/community/screens/community_screen.dart",
    "lib/features/community/screens/chirp_detail_screen.dart",
    "lib/features/community/screens/create_chirp_screen.dart",
    "lib/features/community/screens/flock_feed_screen.dart",
    "lib/features/community/widgets/chirp_list.dart",
    "lib/features/community/widgets/unified_post_card.dart"
)
# --- END OF CONFIGURATION ---

# Get the project's root directory and the scripts directory
$projectRoot = $PSScriptRoot | Split-Path
$scriptsDir = $PSScriptRoot

# Create a timestamp string (e.g., 2025-08-17_14-30-55)
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outputFileName = "context_$timestamp.txt"

# Set the full path for the output file inside the scripts folder
$fullOutputPath = Join-Path -Path $scriptsDir -ChildPath $outputFileName

Write-Host "Creating context file at: $fullOutputPath"

# Create or clear the output file before starting
Clear-Content -Path $fullOutputPath -ErrorAction SilentlyContinue

# Loop through each file and append its content
foreach ($file in $filesToInclude) {
    $fullFilePath = Join-Path -Path $projectRoot -ChildPath $file
    if (Test-Path $fullFilePath) {
        # Add a header to delineate the file
        Add-Content -Path $fullOutputPath -Value "`n--- START OF FILE: $file ---`n"
        # Add the file's content
        Get-Content $fullFilePath | Add-Content -Path $fullOutputPath
        Add-Content -Path $fullOutputPath -Value "`n--- END OF FILE: $file ---`n"
    } else {
        Write-Warning "File not found and will be skipped: $fullFilePath"
    }
}

Write-Host "Context file '$outputFileName' created successfully."
Write-Host "You can now copy the contents of this file into the AI Studio."

# Optional: Open the generated file automatically for convenience
Invoke-Item $fullOutputPath