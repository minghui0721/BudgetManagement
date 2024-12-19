import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/models/SpendingCategory.dart';
import 'package:wise/providers/SpendingCategoryProvider.dart';
import 'package:wise/repositories/SpendingCategoryRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/ConfirmationDialog.dart';
import 'package:wise/screens/admin/components/ItemList.dart';
import 'package:wise/screens/admin/components/SearchBar.dart';
import 'package:wise/screens/admin/components/SearchButton.dart';
import 'package:wise/screens/admin/components/TableTabBar.dart';
import 'package:wise/screens/admin/spending-category/details.dart';

class SpendingCategoriesScreen extends StatefulWidget {
  @override
  _SpendingCategoriesScreenState createState() =>
      _SpendingCategoriesScreenState();
}

class _SpendingCategoriesScreenState extends State<SpendingCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';
  bool showSearch = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Widget buildCategoryList(List<SpendingCategory> items) {
    return ItemList<SpendingCategory>(
      items: items,
      getTitle: (category) => category.name,
      getImagePath: (category) => category.imagePath,
      getDetails: (category) => [
        Text('Created At: ${category.createdAt}'),
        Text('Updated At: ${category.updatedAt}'),
      ],
      onEdit: _edit,
      onDelete: (category) => _confirmDelete(context, category),
      onView: _view,
    );
  }

  void toggleSearch(bool value) {
    setState(() {
      showSearch = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spendingCategoryProvider =
        Provider.of<SpendingCategoryProvider>(context);
    final categories = spendingCategoryProvider.categories
        .where((category) =>
            category.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    int total = spendingCategoryProvider.total;
    int expense = spendingCategoryProvider.expense;
    int income = spendingCategoryProvider.income;

    return Scaffold(
      backgroundColor: AppColors.mediumGray,
      appBar: AdminAppBar(
        title: 'Categories',
        showBackButton: true,
        button: const Icon(Icons.add),
        onPressed: () => _navigateToDetails(null, isCreateMode: true),
      ),
      body: Column(
        children: [
          if (showSearch)
            WiseSearchBar(
              controller: searchController,
              focusNode: searchFocusNode,
              hintText: 'Search Categories by Name',
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
              onPressed: () {
                setState(() {
                  searchController.clear();
                  searchQuery = '';
                  showSearch = false;
                });
              },
            ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.mediumGray,
              ),
              child: categories.isEmpty
                  ? const Center(child: Text('No Category Found.'))
                  : TableTabBar(
                      tabTitles: [
                        'All ($total)',
                        'Income ($income)',
                        'Expense ($expense)',
                      ],
                      tabViews: [
                        buildCategoryList(categories),
                        buildCategoryList(
                          categories
                              .where((category) => category.type == "income")
                              .toList(),
                        ),
                        buildCategoryList(
                          categories
                              .where((category) => category.type == "expense")
                              .toList(),
                        ),
                      ],
                      tabController: _tabController,
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: SearchButton(
        heroTag: 'search',
        showSearch: showSearch,
        searchFocusNode: searchFocusNode,
        searchController: searchController,
        onSearchToggle: toggleSearch,
      ),
    );
  }

  void _confirmDelete(BuildContext context, SpendingCategory category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Confirm Delete",
          content: "Are you sure you want to delete this category?",
          confirmButtonText: "Yes",
          cancelButtonText: "No",
          onConfirm: () {
            _delete(category);
          },
        );
      },
    );
  }

  void _delete(
    SpendingCategory category,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      SpendingCategoryRepository spendingCategoryRepository =
          SpendingCategoryRepository();
      await spendingCategoryRepository.delete(category.id);
      await Provider.of<SpendingCategoryProvider>(context, listen: false)
          .fetchAllCategories();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted category!')),
        );
      }
    }
  }

  void _navigateToDetails(SpendingCategory? category,
      {bool isEditMode = false, bool isCreateMode = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpendingCategoryDetailsScreen(
          category: category,
          isEditMode: isEditMode,
          isCreateMode: isCreateMode,
        ),
      ),
    );
  }

  void _edit(SpendingCategory category) {
    _navigateToDetails(category, isEditMode: true);
  }

  void _view(SpendingCategory category) {
    _navigateToDetails(category);
  }
}
