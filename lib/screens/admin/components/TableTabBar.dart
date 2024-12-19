import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';

class TableTabBar extends StatelessWidget {
  final List<String> tabTitles;
  final List<Widget> tabViews;
  final TabController tabController;

  const TableTabBar({
    Key? key,
    required this.tabTitles,
    required this.tabViews,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.secondary,
          child: PreferredSize(
            preferredSize: Size.fromHeight(50.0), // Set preferred height for TabBar
            child: TabBar(
              controller: tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray,
              indicatorColor: AppColors.primary,
              indicatorWeight: 4.0,
              isScrollable: tabTitles.length != 3, // Tabs will be scrollable if not exactly 3
              tabs: tabTitles
                  .map((title) => Tab(
                        text: title,
                      ))
                  .toList(),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: tabViews,
          ),
        ),
      ],
    );
  }
}
