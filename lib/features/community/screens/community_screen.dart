// lib/features/community/screens/community_screen.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/community/widgets/chirp_list.dart';
import 'package:cockatiel_companion/features/community/screens/create_chirp_screen.dart';
import 'package:cockatiel_companion/core/constants.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  
  // --- NEW: State variable to hold the selected sort option ---
  String _selectedSortOption = DropdownOptions.chirpSortOptions[0]; // Default to 'Latest Activity'

  final List<String> _categories = DropdownOptions.communityCategoriesWithAll;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenTitles.community),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((String category) {
            return Tab(text: category);
          }).toList(),
        ),
      ),
      // --- REVISED: The body is now a Column containing the controls and the TabBarView ---
      body: Column(
        children: [
          // --- REVISED: Sorting Controls UI using a Dropdown ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align to the right
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
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((String category) {
                return ChirpList(
                  category: category,
                  sortBy: _selectedSortOption,
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final String currentCategory = _categories[_tabController.index];
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
      ),
    );
  }
}