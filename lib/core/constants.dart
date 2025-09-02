// lib/core/constants.dart

// ===========================================================================
// This file is the single source of truth for all user-facing strings and
// asset paths in the application.
//
// ARCHITECTURE GOAL:
// The variable names are GENERIC (e.g., "household", "post").
// The string values are THEMATIC (e.g., "'Aviary'", "'Chirp'").
// This allows us to re-theme the app for a different pet (like dogs)
// by only changing the values in this file, without touching the app's logic.
// ===========================================================================

// ===========================================================================
// SECTION 1: CORE APP & THEMATIC STRINGS
// ===========================================================================
class AppStrings {
  // --- App Info ---
  static const String appName = 'FlockWell';
  static const String appTagline = 'Your AI-assisted companion for raising happy and healthy birds.';

  // --- Thematic Concepts (MODIFIABLE FOR NEW PETS) ---
  /// A group of users and their pets (e.g., a household).
  static const String household = 'Aviary';
  /// The collection of a user's pets.
  static const String petGroup = 'Flock';
  /// A physical enclosure for pets.
  static const String enclosure = 'Nest';
  /// A community forum post.
  static const String post = 'Chirp';
  /// The primary user/owner.
  static const String primaryOwner = 'Guardian';
  /// An invited user with shared access.
  static const String secondaryUser = 'Caregiver';

  // --- Anniversaries (MODIFIABLE FOR NEW PETS) ---
  /// The day the pet was born/hatched.
  static const String birthDay = 'Hatch Day';
  /// The day the pet was acquired by the owner.
  static const String adoptionDay = 'Gotcha Day';

  // --- Community Interaction ---
  static const String followPost = 'Tell Me Too';
  static const String followingPost = 'Following';
  static const String beFirstToReply = 'Be the first to reply!';
  static const String addReplyHint = 'Add a reply...';
  static const String postNotFound = 'Chirp not found.';
  static const String noPostsInCategory = 'No Chirps in this category yet. Be the first to post!';
  static const String reportReceived = 'Squawk received. Our moderators will review it shortly.';
  static const String reportError = 'Error: Could not send Squawk.';
  static const String confirmDeletePost = 'Are you sure you want to permanently delete this Chirp and all of its replies?';
  static const String confirmDeleteReply = 'Are you sure you want to permanently delete this reply?';
  static const String deletePostError = 'Error: Could not delete Chirp.';
  static const String deleteReplyError = 'Error: Could not delete reply.';
  
  // --- Common Nouns & Placeholders ---
  static const String defaultHouseholdName = 'An Aviary';
  static const String unnamedPet = 'Unnamed Bird';
  static const String unnamedEnclosure = 'Unnamed Nest';
  static const String anonymous = 'Anonymous';
  static const String unknown = 'Unknown';
  static const String noTitle = 'No Title';
  static const String noDescription = 'No description';
  static const String unspecifiedContext = 'Unspecified';
  static const String unknownSource = 'Unknown Source';
  static const String untitledTask = 'Untitled Task';
  static const String noDueDate = 'No due date set';

  // --- Form & Validation Messages ---
  static const String emailValidation = 'Please enter a valid email';
  static const String passwordLengthValidation = 'Password must be at least 6 characters';
  static const String passwordMismatchValidation = 'Passwords do not match';
  static const String nameValidation = 'Please enter a name';
  static const String titleValidation = 'Please enter a title';
  static const String labelValidation = 'Please enter a label.';
  static const String numberValidation = 'Enter a number';
  static const String categoryValidation = 'Please select a category';
  static const String moodValidation = 'Please select an Overall Mood.';
  static const String foodTypeValidation = 'Please select a food type.';
  static const String consumptionLevelValidation = 'Please select a consumption level.';
  static const String droppingsValidation = 'Please select Color and Consistency.';
  static const String weightValidation = 'Please enter a weight.';
  static const String validNumberValidation = 'Please enter a valid number.';
  static const String petNameValidation = 'Please enter your bird\'s name.';
  static const String enclosureValidation = 'Please select a Nest for your bird.';
  static const String speciesValidation = 'Please select your bird\'s species.';

  // --- Status & Feedback Messages ---
  static const String loadingData = 'Loading data...';
  static const String errorLoadingData = 'Error loading data.';
  static const String noDataFound = 'No data found.';
  static const String somethingWentWrong = 'Something went wrong.';
  static const String genericError = 'An error occurred.';
  static const String errorPrefix = 'Error:';
  static const String passwordResetSuccess = 'Password reset email sent! Please check your inbox.';
  static const String mustBeLoggedInToAccept = 'You must be logged in to accept.';
  static const String mustBeLoggedInToPost = 'You must be logged in to post.';
  static const String loginToViewCommunity = 'Please log in to see the community.';
  static const String defaultSuccessMessage = 'Success!';
  static const String reminderDismissedSuffix = "'s reminder dismissed.";
  static const String entryDeleted = 'Entry deleted.';
  static const String deleteError = 'Error: Could not delete entry.';
  static const String failedToSaveTask = 'Failed to save task';
  static const String failedToSignInWithGoogle = 'Failed to sign in with Google';
  static const String couldNotLaunch = 'Could not launch';
  static const String noPetsYet = 'You have no birds yet. Add one to get started!';
  static const String noEnclosuresCreated = 'No Nests created yet.';
  static const String noPetsInEnclosure = 'No birds found in this Nest.';
  static const String noCareTasks = 'No care tasks scheduled.';
  static const String noResourcesFound = 'No resources found.';
  static const String noLogEntries = 'No entries logged for this day.';
  static const String unknownLogType = 'Unknown log type';
  static const String notificationInboxComingSoon = 'Notification Inbox Coming Soon!';
  static const String primaryOwnerLabelUpdated = 'Guardian label updated!';
  static const String firstEnclosureCreated = 'Your first Nest has been created!';
  static const String enclosureCreated = 'has been created!';
  static const String createEnclosureError = 'Error: Could not create the Nest.';
  static const String noUserLoggedIn = 'No user logged in';
  static const String noDestinationOrPetsSelected = 'No destination Nest or no birds selected.';
  static const String petsMovedSuccessfully = 'bird(s) moved successfully!';
  static const String movePetsError = 'An error occurred. Could not move birds.';
  static const String selectSourceEnclosure = 'Please select a source Nest.';
  static const String droppingsObservation = 'Droppings Observation';
  
  // --- Invitation Messages ---
  static const String invitationSent = 'Invitation sent to';
  static const String invitationError = 'Error: Could not send invitation.';
  static const String invitationPending = 'Invitation Pending...';
  static const String defaultCaregiverLabel = 'a Caregiver';
  static const String invitationMessagePart1 = 'You\'ve been invited to be "';
  static const String invitationMessagePart2 = '" in an Aviary!';
  
  // --- Dynamic String Components ---
  static const String orSeparator = 'OR';
  static const String petCountSuffix = 'bird(s)';
  static const String selectedFile = 'Selected:';
  static const String noFileSelected = 'No file selected.';

  // --- Anniversary Dynamic Strings ---
  static const String anniversaryTodayPrefix = "It's today! Happy";
  static const String anniversaryTodaySuffix = "!";
  static const String anniversarySingularPrefix = "day to go until their";
  static const String anniversaryPluralPrefix = "days to go until their";
  static const String anniversarySuffix = "!";
  static const String yearOld = 'year old';
  static const String yearsOld = 'years old';
  static const String monthOld = 'month old';
  static const String monthsOld = 'months old';
  static const String dayOld = 'day old';
  static const String daysOld = 'days old';
  static const String yearWithYou = 'year with you';
  static const String yearsWithYou = 'years with you';
  static const String monthWithYou = 'month with you';
  static const String monthsWithYou = 'months with you';
  static const String dayWithYou = 'day with you';
  static const String daysWithYou = 'days with you';
  static const String newPet = 'New!';

  // --- Onboarding & Tips ---
  static const String tipOfTheDay = 'Tip of the Day';
  static const String noTipContent = 'No tip content available.';
  
  // --- Care Tasks ---
  static const String taskStatusUpcoming = 'Upcoming';
  static const String taskStatusOverdue = 'Overdue';
  static const String allTasksUpToDate = 'All tasks are up to date!';
  static const String tapToViewAllTasks = 'Tap to view all tasks';

  // --- Daily Log Subtitles ---
  static const String logDietSubtitle = 'Tap to log food intake';
  static const String logDroppingsSubtitle = 'Tap to log health observations';
  static const String logBehaviorSubtitle = 'Tap to log behavior';
  static const String logWeightSubtitle = 'Tap to log weight';
  static const String updateError = 'Error: Could not update entry.';
  static const String saveError = 'Error: Could not save entry.';

  // --- Notifications ---
  static const String upcomingBirthDayTitle = 'Upcoming Hatch Day! 🎂';
  static const String upcomingBirthDayBodyPart1 = 'Get ready to celebrate!';
  static const String upcomingBirthDayBodyPart2 = '\'s Hatch Day is in one week.';
  static const String upcomingAdoptionDayTitle = 'Upcoming Gotcha Day! 🎉';
  static const String upcomingAdoptionDayBodyPart1 = '\'s Gotcha Day is in one week!';
  static const String upcomingAdoptionDayBodyPart2 = 'Time to celebrate your journey together.';

  // --- Dialog & Hint Text ---
  static const String resetPasswordInstructions = 'Enter your email address to receive a password reset link.';
  static const String householdNameExample = 'e.g., The Blue Angels';
  static const String householdNameUniquenessNotice = 'This name must be unique and is visible to the community.';
  static const String secondaryUserLabelHint = 'e.g., Mama Birdie, The Flock Master';
  static const String confirmEarlyCompletion = 'This task is not due yet. Are you sure you want to mark it as complete ahead of schedule?';
  static const String confirmEnclosureDeletion = 'Are you sure you want to delete this Nest?';
  static const String confirmLogDeletionMessage = 'Are you sure you want to delete this log entry? This action cannot be undone.';
  static const String taskTitleHint = 'e.g., Weekly Cage Deep Clean';
  static const String recurrencePrompt = 'This task repeats every...';
  static const String selectFoodTypeHint = 'Select Food Type';
  static const String selectContextHint = 'Select Context (Optional)';
  static const String dontHaveAccount = 'Don\'t have an account? Sign Up';
  static const String alreadyHaveAccount = 'Already have an account? Login';
  static const String householdNameSubtitle = 'This name is visible to the community';
  static const String cannotDeleteLastEnclosure = 'You cannot delete your last Nest.';
  static const String cannotDeleteEnclosureWithPets = 'You cannot delete a Nest that has birds in it.';
  static const String householdNotFound = 'Aviary not found.';
}

// ===========================================================================
// SECTION 2: BUTTON LABELS
// ===========================================================================
class ButtonLabels {
  // --- Common Actions ---
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String add = 'Add';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String post = 'Post';
  static const String reply = 'Reply';
  static const String invite = 'Invite';
  static const String create = 'Create';
  static const String confirm = 'Confirm';

  // --- Screen/Feature Specific ---
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String createAccount = 'Create Account';
  static const String sendLink = 'Send Link';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String addNewEnclosure = 'Add a New Nest';
  static const String bulkMovePets = 'Bulk Move Birds';
  static const String moveSelectedPets = 'Move Selected Birds';
  static const String sendInvite = 'Send Invite';
  static const String saveTask = 'Save Task';
  static const String addPhotoOptional = 'Add Photo (Optional)';
  static const String gallery = 'Gallery';
  static const String camera = 'Camera';
  static const String decline = 'Decline';
  static const String acceptInvite = 'Accept Invite';
  static const String saveProfile = 'Save Profile';
  static const String report = 'Squawk'; // The button text
  static const String submitReport = 'Submit Squawk';
}

// ===========================================================================
// SECTION 3: SCREEN TITLES
// ===========================================================================
class ScreenTitles {
  // --- Main Navigation ---
  static const String homePage = 'Your Flock';
  static const String community = 'Community Aviary';
  static const String notifications = 'Notifications';
  static const String knowledgeCenter = 'Knowledge Center';
  static const String careTasks = 'Care Tasks';
  static const String aboutApp = 'About FlockWell';

  // --- Authentication ---
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String resetPassword = 'Reset Password';

  // --- Household (Aviary) Management ---
  static const String manageHousehold = 'Manage Your Aviary';
  static const String setPublicHouseholdName = 'Set Public Aviary Name';
  static const String bulkMovePets = 'Bulk Move Birds';
  static const String inviteSecondaryUser = 'Invite a Caregiver';
  
  // --- Pet (Bird) & Enclosure (Nest) Management ---
  static const String addPet = 'Add to Your Flock';
  static const String editPet = 'Edit Profile';
  static const String addNewEnclosure = 'Add New Nest';
  static const String renameEnclosure = 'Rename Nest';

  // --- Daily Log ---
  static const String dailyLog = 'Daily Log';
  static const String dailyLogSuffix = "'s Daily Log";
  static const String logBehaviorAndMood = 'Log Behavior & Mood';
  static const String logFoodOffered = 'Log Food Offered';
  static const String logDroppingsObservation = 'Log Droppings Observation';
  static const String logWeight = 'Log Weight';

  // --- Community ---
  static const String postDetail = 'Chirp';
  static const String createPost = 'Post a New Chirp';
  static const String reportPost = 'Squawk a Chirp';
  static const String reportReply = 'Squawk a Reply';
  
  // --- Dialogs ---
  static const String confirmDeletion = 'Confirm Deletion';
  static const String editYourLabel = 'Edit Your Label';
  static const String confirmCompletion = 'Confirm Completion';
  static const String createNewCareTask = 'Create New Care Task';
}

// ===========================================================================
// SECTION 4: LABELS & HEADERS (For forms, cards, etc.)
// ===========================================================================
class Labels {
  // --- Common Form Fields ---
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Name';
  static const String title = 'Title';
  static const String body = 'Body';
  static const String category = 'Category';
  static const String notesOptional = 'Notes (Optional)';

  // --- Authentication ---
  static const String forgotPassword = 'Forgot Password?';

  // --- Household & User Management ---
  static const String manageHouseholdTooltip = 'Manage Aviary';
  static const String yourEnclosures = 'Your Nests (Cages)';
  static const String secondaryUsers = 'Caregivers';
  static const String setYourHouseholdName = 'Set Your Aviary Name';
  static const String secondaryUserEmail = 'Caregiver\'s Email*';
  static const String theirLabel = 'Their Label*';
  static const String editYourLabelTooltip = 'Edit your label';
  static const String enterNewLabel = 'Enter your new label';
  
  // --- Pet Profile ---
  static const String nameRequired = 'Name*';
  static const String enclosureRequired = 'Nest*';
  static const String createNewEnclosure = 'Create New Nest';
  static const String speciesRequired = 'Species*';
  /// The day the pet was acquired by the owner.
  static const String adoptionDay = 'Gotcha Day (Date you got your bird)';
  /// The day the pet was born/hatched.
  static const String birthDayOptional = 'Hatch Day (Optional)';

  // --- Bulk Move ---
  static const String movePetsFrom = 'Move Birds FROM';
  static const String movePetsTo = 'Move Birds TO';
  static const String selectPetsToMove = 'Select birds to move:';

  // --- Daily Log ---
  static const String diet = 'Diet';
  static const String droppings = 'Droppings';
  static const String behaviorAndMood = 'Behavior & Mood';
  static const String weight = 'Weight';
  static const String consumption = 'Consumption:';
  static const String color = 'Color:';
  static const String consistency = 'Consistency:';
  static const String mood = 'Mood:';
  static const String behaviors = 'Behaviors (select all that apply)';
  static const String overallMood = 'Overall Mood*';
  static const String foodType = 'Food Type';
  static const String description = 'Description (e.g., Fresh chop)';
  static const String consumptionLevel = 'Consumption Level*';
  static const String colorRequired = 'Color*';
  static const String consistencyRequired = 'Consistency*';
  static const String weightRequired = 'Weight*';
  static const String grams = 'Grams';
  static const String ounces = 'Ounces';

  // --- Care Tasks ---
  static const String tasksDueToday = 'Tasks Due Today';
  static const String due = 'Due:';
  static const String taskTitle = 'Task Title*';
  static const String recurrenceNumber = 'Number*';
  static const String appliesTo = 'Applies to: All Birds (for now)';

  // --- Community ---
  static const String postedBy = 'Posted by';
  static const String replies = 'Replies';
  static const String by = 'by';
  static const String byYou = 'by You';
  static const String postTitle = 'Title / Question*';
  static const String postBody = 'Body (Optional)';
  static const String postedByYou = 'Posted by You';
  static const String attachMedia = 'Attach Media (Optional)';
  static const String helpful = 'Helpful';
  static const String reasonForReport = 'Reason for your Squawk?';
  static const String bestAnswer = 'Best Answer';
  static const String markAsBestAnswer = 'Mark as Best Answer';

  // --- Miscellaneous UI ---
  static const String signOut = 'Sign Out';
  static const String whatsNew = 'What\'s New';
  static const String version = 'Version';
  static const String tipFor = 'Tip for';
  static const String upcoming = 'Upcoming:';
  static const String anniversaryChannelName = 'Anniversary Reminders';
  static const String anniversaryChannelDescription = 'Reminders for your birds\' special days';
}

// ===========================================================================
// SECTION 5: DROPDOWN & CHIP OPTIONS
// ===========================================================================
class DropdownOptions {
  /// Species options for the pet profile screen.
  static const List<String> petSpecies = [
    'Cockatiel', 'Budgerigar', 'Parrotlet', 'Lovebird', 'Conure', 'Other',
  ];

  /// Categories for community posts (does not include "All").
  static const List<String> communityCategories = [
    'Health & Wellness', 'Behavior & Training', 'Nutrition & Diet', 'Cage, Toys & Gear', 'General Chat',
  ];

  /// Categories for the community screen tab bar (includes "All").
  static const List<String> communityCategoriesWithAll = [
    'All Chirps', ...communityCategories,
  ];

  /// Units for task recurrence.
  static const List<String> recurrenceUnits = ['days', 'weeks', 'months'];

  /// Levels for diet consumption logging.
  static const List<String> dietConsumptionLevels = ['Ate Well', 'Ate Some', 'Untouched'];
  
  /// Types of food for diet logging.
  static const List<String> dietFoodTypes = [
    'Pellets', 'Green Leafs', 'Vegetables', 'Fruit', 'Sprouts', 'Treat', 'Other',
  ];

  /// Common behaviors for behavior logging.
  static const List<String> commonBehaviors = [
    'Chirping', 'Singing', 'Preening', 'Stretching', 'Foraging', 'Playing', 'Napping'
  ];

  /// Mood options for behavior logging.
  static const List<String> moods = [
    'Happy', 'Calm', 'Playful', 'Anxious', 'Grumpy', 'Quiet'
  ];

  /// Color options for droppings logging.
  static const List<String> droppingsColors = [
    'Normal', 'Green', 'Yellow', 'Black', 'Red',
  ];

  /// Consistency options for droppings logging.
  static const List<String> droppingsConsistencies = [
    'Solid', 'Loose', 'Watery',
  ];

  /// Context options for weight logging.
  static const List<String> weightContexts = [
    'Before Meal', 'After Meal', 'Unspecified',
  ];

  /// Reasons for reporting (squawking) content.
  static const List<String> reportReasons = [
    'Spam or Advertisement',
    'Harassment or Hate Speech',
    'Dangerously Incorrect Advice',
    'Off-Topic or Irrelevant',
    'Other',
  ];
}

// ===========================================================================
// SECTION 6: ASSET PATHS
// ===========================================================================
class AssetPaths {
  static const String logo = 'assets/images/logo.png';
  static const String googleLogo = 'assets/images/google_logo.png';
}