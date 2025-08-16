# This script prepares a single, timestamped text file to be used as context
# for resuming a conversation with the Gemini AI.

# --- CONFIGURATION ---
$filesToInclude = @(
    "documentation/RESUME_PROMPT.md",
    "documentation/ROADMAP.md",
    "documentation/FSD.md",
    "pubspec.yaml",
    "lib/main.dart",
    "lib/auth_gate.dart",
    "lib/screens/home_screen.dart",
    "lib/screens/auth_screen.dart",
    "lib/screens/profile_screen.dart"
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