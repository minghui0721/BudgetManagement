import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/models/FinancialAdvisor.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/repositories/FinancialAdvisorRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/ConfirmationDialog.dart';
import 'package:wise/screens/admin/components/ItemList.dart';
import 'package:wise/screens/admin/components/SearchBar.dart';
import 'package:wise/screens/admin/components/SearchButton.dart';
import 'package:wise/screens/admin/components/TableTabBar.dart';
import 'package:wise/screens/admin/financial-advisor/details.dart';

class FinancialAdvisorsScreen extends StatefulWidget {
  @override
  _FinancialAdvisorsScreenState createState() =>
      _FinancialAdvisorsScreenState();
}

class _FinancialAdvisorsScreenState extends State<FinancialAdvisorsScreen>
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

  Widget buildFinancialAdvisorList(List<FinancialAdvisor> items) {
    return ItemList<FinancialAdvisor>(
      items: items,
      getTitle: (advisor) => advisor.user.name,
      getImagePath: (advisor) => advisor.user.imagePath,
      getDetails: (advisor) => [
        Text('FA ID: ${advisor.id}'),
        Text('User ID: ${advisor.user.id}'),
        Text(advisor.user.email),
        Text(advisor.user.phoneNumber),
        Text('Age: ${advisor.user.age}'),
        Text(
          advisor.isVerified ? 'Verified' : 'Not Verified',
          style: TextStyle(
            color: advisor.isVerified ? AppColors.darkGreen : AppColors.darkRed,
          ),
        ),
      ],
      onEdit: _edit,
      onDelete: (advisor) => _confirmDelete(context, advisor),
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
    final financialAdvisorProvider =
        Provider.of<FinancialAdvisorProvider>(context);

    final advisors = financialAdvisorProvider.advisors
        .where((advisor) =>
            advisor.user.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    int totalAdvisors = financialAdvisorProvider.total;
    int verifiedCount = financialAdvisorProvider.verified;
    int unverifiedCount = financialAdvisorProvider.unverified;

    return Scaffold(
      backgroundColor: AppColors.mediumGray,
      appBar: AdminAppBar(
        title: 'Financial Advisors',
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
              hintText: 'Search Financial Advisors by Name',
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
              child: advisors.isEmpty
                  ? const Text(
                      "No Financial Advisors found.",
                      style: AppTheme.titleTextStyle,
                    )
                  : isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : TableTabBar(
                          tabTitles: [
                            'All ($totalAdvisors)',
                            'Verified ($verifiedCount)',
                            'Unverified ($unverifiedCount)',
                          ],
                          tabViews: [
                            buildFinancialAdvisorList(advisors),
                            buildFinancialAdvisorList(advisors.where((advisor) => advisor.isVerified).toList()),
                            buildFinancialAdvisorList(advisors.where((advisor) => !advisor.isVerified).toList()),
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

  void _confirmDelete(BuildContext context, FinancialAdvisor advisor) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Confirm Delete",
          content: "Are you sure you want to delete this Financial Advisor?",
          confirmButtonText: "Yes",
          cancelButtonText: "No",
          onConfirm: () {
            _delete(advisor);
          },
        );
      },
    );
  }

  void _delete(
    FinancialAdvisor advisor,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      FinancialAdvisorRepository financialAdvisorRepository =
          FinancialAdvisorRepository();
      await financialAdvisorRepository.deleteFinancialAdvisor(advisor.id);
      await Provider.of<FinancialAdvisorProvider>(context, listen: false)
          .fetchAllFinancialAdvisors();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted advisor!')),
        );
      }
    }
  }

  void _navigateToDetails(FinancialAdvisor? advisor,
      {bool isEditMode = false, bool isCreateMode = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinancialAdvisorDetailsScreen(
          advisor: advisor,
          isEditMode: isEditMode,
          isCreateMode: isCreateMode,
        ),
      ),
    );
  }

  void _edit(FinancialAdvisor advisor) {
    _navigateToDetails(advisor, isEditMode: true);
  }

  void _view(FinancialAdvisor advisor) {
    _navigateToDetails(advisor);
  }
}
