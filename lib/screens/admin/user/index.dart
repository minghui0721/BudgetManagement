import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/models/User.dart';
import 'package:wise/providers/UserProvider.dart';
import 'package:wise/repositories/UserRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/ConfirmationDialog.dart';
import 'package:wise/screens/admin/components/ItemList.dart';
import 'package:wise/screens/admin/components/SearchBar.dart';
import 'package:wise/screens/admin/components/SearchButton.dart';
import 'package:wise/screens/admin/components/TableCard.dart';
import 'package:wise/screens/admin/components/TableTabBar.dart';
import 'package:wise/screens/admin/user/details.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
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

  Widget buildUserList(List<User> items) {
    return ItemList<User>(
      items: items,
      getTitle: (user) => user.name,
      getImagePath: (user) => user.imagePath,
      getDetails: (user) => [
        Text('Created At: ${user.createdAt}'),
        Text('Updated At: ${user.updatedAt}'),
      ],
      onEdit: _edit,
      onDelete: (user) => _confirmDelete(context, user),
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
    final userProvider = Provider.of<UserProvider>(context);

    final users = userProvider.users
        .where((user) =>
            user.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    int total = userProvider.total;
    int valid = userProvider.valid;
    int invalid = userProvider.invalid;

    return Scaffold(
      backgroundColor: AppColors.mediumGray,
      appBar: AdminAppBar(
        title: 'Users',
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
              hintText: 'Search Users by Name',
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
              child: users.isEmpty
                  ? const Text(
                      "No Users found.",
                      style: AppTheme.titleTextStyle,
                    )
                  : isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : TableTabBar(
                          tabTitles: [
                            'All ($total)',
                            'Valid ($valid)',
                            'Invalid ($invalid)',
                          ],
                          tabViews: [
                            buildUserList(users),
                            buildUserList(
                                users.where((user) => !user.isBan).toList()),
                            buildUserList(
                                users.where((user) => user.isBan).toList()),
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

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Confirm Delete",
          content: "Are you sure you want to delete this user?",
          confirmButtonText: "Yes",
          cancelButtonText: "No",
          onConfirm: () {
            _delete(user);
          },
        );
      },
    );
  }

  void _delete(
    User user,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      UserRepository userRepository = UserRepository();
      await userRepository.deleteUser(user.id);
      await Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted user!')),
        );
      }
    }
  }

  void _navigateToDetails(User? user,
      {bool isEditMode = false, bool isCreateMode = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(
          user: user,
          isEditMode: isEditMode,
          isCreateMode: isCreateMode,
        ),
      ),
    );
  }

  void _edit(User user) {
    _navigateToDetails(user, isEditMode: true);
  }

  void _view(User user) {
    _navigateToDetails(user);
  }
}