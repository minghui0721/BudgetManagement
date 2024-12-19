import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/models/Bank.dart';
import 'package:wise/providers/BankProvider.dart';
import 'package:wise/repositories/BankRepository.dart';
import 'package:wise/screens/admin/bank/details.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/ConfirmationDialog.dart';
import 'package:wise/screens/admin/components/ItemList.dart';
import 'package:wise/screens/admin/components/SearchBar.dart';
import 'package:wise/screens/admin/components/SearchButton.dart';

class BanksScreen extends StatefulWidget {
  @override
  _BanksScreenState createState() => _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen> {
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
    final bankProvider = Provider.of<BankProvider>(context);
    final banks = bankProvider.banks
        .where((bank) =>
            bank.bankName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.mediumGray,
      appBar: AdminAppBar(
        title: 'Banks',
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
              hintText: 'Search Bank by Name',
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
              child: banks.isEmpty
                  ? const Text(
                      "No Available Bank",
                      style: AppTheme.titleTextStyle,
                    )
                  : isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ItemList<Bank>(
                          items: banks,
                          getTitle: (bank) => bank.bankName,
                          getImagePath: (bank) => bank.imagePath,
                          getDetails: (bank) => [
                            Text('Created At: ${bank.createdAt}'),
                            Text('Updated At: ${bank.updatedAt}'),
                          ],
                          onEdit: _edit,
                          onDelete: (bank) => _confirmDelete(context, bank),
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

  void _confirmDelete(BuildContext context, Bank bank) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Confirm Delete",
          content: "Are you sure you want to delete this bank?",
          confirmButtonText: "Yes",
          cancelButtonText: "No",
          onConfirm: () {
            _delete(bank);
          },
        );
      },
    );
  }

  void _delete(
    Bank bank,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      BankRepository bankRepository = BankRepository();
      await bankRepository.deleteBank(bank.id);
      await Provider.of<BankProvider>(context, listen: false).fetchAllBanks();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted bank!')),
        );
      }
    }
  }

  void _navigateToDetails(Bank? bank,
      {bool isEditMode = false, bool isCreateMode = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankDetailsScreen(
          bank: bank,
          isEditMode: isEditMode,
          isCreateMode: isCreateMode,
        ),
      ),
    );
  }

  void _edit(Bank bank) {
    _navigateToDetails(bank, isEditMode: true);
  }

  void _view(Bank bank) {
    _navigateToDetails(bank);
  }
}
