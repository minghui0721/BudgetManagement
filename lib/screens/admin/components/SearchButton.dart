import 'package:flutter/material.dart';
import 'package:wise/config/colors.dart';

class SearchButton extends StatelessWidget {
  final String heroTag;
  final bool showSearch;
  final FocusNode searchFocusNode;
  final TextEditingController searchController;
  final ValueChanged<bool> onSearchToggle;

  const SearchButton({
    Key? key,
    required this.heroTag,
    required this.showSearch,
    required this.searchFocusNode,
    required this.searchController,
    required this.onSearchToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: () {
        onSearchToggle(!showSearch);
        if (!showSearch) {
          searchFocusNode.requestFocus();
        } else {
          searchFocusNode.unfocus();
          searchController.clear();
        }
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.search, color: Colors.white),
    );
  }
}
