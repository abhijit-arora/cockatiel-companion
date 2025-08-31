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
  
  // The list of categories is now sourced from our central constants file.
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
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((String category) {
          return ChirpList(category: category);
        }).toList(),
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
        // The label now uses our generic "post" term.
        label: Text('${ButtonLabels.post} a ${AppStrings.post}'),
        icon: const Icon(Icons.add_comment_outlined),
      ),
    );
  }
}