import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/community/widgets/chirp_list.dart';
import 'package:cockatiel_companion/features/community/screens/create_chirp_screen.dart';

// A list to define our categories. Keeping it here makes it easy to manage.
const List<String> _categories = [
  'All Chirps',
  'Health & Wellness',
  'Behavior & Training',
  'Nutrition & Diet',
  'Cage, Toys & Gear',
  'General Chat',
];

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

// We need TickerProviderStateMixin to handle the TabController animation.
class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

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
        title: const Text('Community Aviary'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((String category) {
            return Tab(text: category);
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // Use our new, reusable ChirpList widget for each tab.
        children: _categories.map((String category) {
          return ChirpList(category: category);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Get the currently selected category from the TabController.
          final String currentCategory = _categories[_tabController.index];

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateChirpScreen(
                // Pass the current category, but not if it's "All Chirps".
                initialCategory: currentCategory == 'All Chirps' ? null : currentCategory,
              ),
            ),
          );
        },
        label: const Text('Post a Chirp'),
        icon: const Icon(Icons.add_comment_outlined),
      ),
    );
  }
}