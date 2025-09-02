// lib/features/community/screens/community_screen.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/community/widgets/chirp_list.dart';
import 'package:cockatiel_companion/features/community/screens/create_chirp_screen.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/community/screens/flock_feed_screen.dart';
import 'package:cockatiel_companion/features/profile/widgets/settings_action_button.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  late final TabController _hubTabController;
  late final TabController _qaTabController;

  final List<String> _hubTabs = [ScreenTitles.qaForum, ScreenTitles.socialFeed];
  final List<String> _qaCategories = DropdownOptions.communityCategoriesWithAll;
  
  String _selectedSortOption = DropdownOptions.chirpSortOptions[0];

  @override
  void initState() {
    super.initState();
    _hubTabController = TabController(length: _hubTabs.length, vsync: this);
    // Add a listener to know when the main tab changes
    _hubTabController.addListener(() {
      setState(() {}); // Trigger a rebuild to show/hide FAB
    });
    _qaTabController = TabController(length: _qaCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _hubTabController.removeListener(() {});
    _hubTabController.dispose();
    _qaTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenTitles.community),
        actions: const [
          SettingsActionButton(),
        ],
        bottom: TabBar(
          controller: _hubTabController,
          tabs: _hubTabs.map((String tabName) {
            return Tab(text: tabName);
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _hubTabController,
        children: [
          // --- TAB 1: Q&A FORUM ---
          _buildQaForum(),
          
          // --- TAB 2: FLOCK FEED ---
          const FlockFeedScreen(),
        ],
      ),
      // --- NEW: Conditional FloatingActionButton ---
      floatingActionButton: _hubTabController.index == 0 
        ? _buildQaFab(context) 
        : _buildFlockFeedFab(context),
    );
  }

  // --- NEW: Helper method to build the Q&A FAB ---
  Widget _buildQaFab(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'qa_fab',
      onPressed: () {
        final String currentCategory = _qaCategories[_qaTabController.index];
        final String allPostsCategory = DropdownOptions.communityCategoriesWithAll[0];

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateChirpScreen(
              initialCategory: currentCategory == allPostsCategory ? null : currentCategory,
            ),
          ),
        );
      },
      label: Text('${ButtonLabels.post} a ${AppStrings.post}'),
      icon: const Icon(Icons.add_comment_outlined),
    );
  }

  // --- NEW: Helper method to build the Flock Feed FAB ---
  Widget _buildFlockFeedFab(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'flock_feed_fab',
      onPressed: () {
        // TODO: Navigate to a new 'Create Feed Post' screen
      },
      child: const Icon(Icons.add_a_photo_outlined),
    );
  }

  // --- NEW: Helper method to build the Q&A Forum UI ---
  Widget _buildQaForum() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(Labels.sortBy, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedSortOption,
                items: DropdownOptions.chirpSortOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSortOption = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        // This is a much cleaner way to display the category tabs
        TabBar(
          controller: _qaTabController,
          isScrollable: true,
          tabs: _qaCategories.map((String category) {
            return Tab(text: category);
          }).toList(),
        ),
        const Divider(height: 1),
        Expanded(
          child: TabBarView(
            controller: _qaTabController,
            children: _qaCategories.map((String category) {
              return ChirpList(
                category: category,
                sortBy: _selectedSortOption,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}