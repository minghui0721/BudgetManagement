import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/models/TermAndCondition.dart';
import 'package:wise/providers/TermAndConditionProvider.dart';
import 'package:wise/repositories/TermAndConditionRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/ConfirmationDialog.dart';
import 'package:wise/screens/admin/components/ItemList.dart';
import 'package:wise/screens/admin/components/SearchBar.dart';
import 'package:wise/screens/admin/components/SearchButton.dart';
import 'package:wise/screens/admin/components/TableCard.dart';
import 'package:wise/screens/admin/term-condition/details.dart';

class TacsScreen extends StatefulWidget {
  @override
  _TacsScreenState createState() => _TacsScreenState();
}

class _TacsScreenState extends State<TacsScreen> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  String searchQuery = '';
  bool showSearch = false;
  bool isLoading = false;

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();

    super.dispose();
  }

  void toggleSearch(bool value) {
    setState(() {
      showSearch = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final termAndConditionProvider =
        Provider.of<TermAndConditionProvider>(context);
    final tacs = termAndConditionProvider.termsAndConditions
        .where((tac) =>
            tac.content.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.mediumGray,
      appBar: AdminAppBar(
        title: 'Term And Conditions',
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
              hintText: 'Search Terms and Conditions by Content',
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
              child: tacs.isEmpty
                  ? const Text(
                      "No Available TAC",
                      style: AppTheme.titleTextStyle,
                    )
                  : isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ItemList<TermAndCondition>(
                          items: tacs,
                          getTitle: (tac) => tac.content,
                          getDetails: (tac) => [
                            Text('Created At: ${tac.createdAt}'),
                            Text('Updated At: ${tac.updatedAt}'),
                          ],
                          onEdit: _edit,
                          onDelete: (tac) => _confirmDelete(context, tac),
                          onView: _view,
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

  void _confirmDelete(BuildContext context, TermAndCondition tac) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Confirm Delete",
          content: "Are you sure you want to delete this tac?",
          confirmButtonText: "Yes",
          cancelButtonText: "No",
          onConfirm: () {
            _delete(tac);
          },
        );
      },
    );
  }

  void _delete(
    TermAndCondition tac,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      TermAndConditionRepository termAndConditionRepository =
          TermAndConditionRepository();
      await termAndConditionRepository.delete(tac.id);
      await Provider.of<TermAndConditionProvider>(context, listen: false)
          .fetchAllTermsAndConditions();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted tac!')),
        );
      }
    }
  }

  void _navigateToDetails(TermAndCondition? tac,
      {bool isEditMode = false, bool isCreateMode = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TACDetailsScreen(
          tac: tac,
          isEditMode: isEditMode,
          isCreateMode: isCreateMode,
        ),
      ),
    );
  }

  void _edit(TermAndCondition tac) {
    _navigateToDetails(tac, isEditMode: true);
  }

  void _view(TermAndCondition tac) {
    _navigateToDetails(tac);
  }
}