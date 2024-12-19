import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/models/Notification.dart' as wise_notifications;
import 'package:wise/providers/NotificationProvider.dart';
import 'package:wise/repositories/NotificationRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/ConfirmationDialog.dart';
import 'package:wise/screens/admin/components/ItemList.dart';
import 'package:wise/screens/admin/components/SearchBar.dart';
import 'package:wise/screens/admin/components/SearchButton.dart';
import 'package:wise/screens/admin/components/TableCard.dart';
import 'package:wise/screens/admin/notification/details.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
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
    final notificationProvider = Provider.of<NotificationProvider>(context);

    final notifications = notificationProvider.notifications
        .where((notification) => notification.title
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.mediumGray,
      appBar: AdminAppBar(
        title: 'Notifications',
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
              hintText: 'Search notification by Name',
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
              child: notifications.isEmpty
                  ? const Text(
                      "No Available Notification",
                      style: AppTheme.titleTextStyle,
                    )
                  : isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ItemList<wise_notifications.Notification>(
                          items: notifications,
                          getTitle: (notification) => notification.title,
                          getImagePath: (notification) =>
                              notification.imagePath,
                          getDetails: (notification) => [
                            Text('Created At: ${notification.createdAt}'),
                            Text('Updated At: ${notification.updatedAt}'),
                          ],
                          onEdit: _edit,
                          onDelete: (notification) =>
                              _confirmDelete(context, notification),
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

  void _confirmDelete(
      BuildContext context, wise_notifications.Notification notification) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Confirm Delete",
          content: "Are you sure you want to delete this notification?",
          confirmButtonText: "Yes",
          cancelButtonText: "No",
          onConfirm: () {
            _delete(notification);
          },
        );
      },
    );
  }

  void _delete(
    wise_notifications.Notification notification,
  ) async {
    setState(() {
      isLoading = true;
    });

    try {
      NotificationRepository notificationRepository = NotificationRepository();
      await notificationRepository.delete(notification.id);
      await Provider.of<NotificationProvider>(context, listen: false)
          .fetchAllNotifications();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted notification!')),
        );
      }
    }
  }

  void _navigateToDetails(wise_notifications.Notification? notification,
      {bool isEditMode = false, bool isCreateMode = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailsScreen(
          notification: notification,
          isEditMode: isEditMode,
          isCreateMode: isCreateMode,
        ),
      ),
    );
  }

  void _edit(wise_notifications.Notification notification) {
    _navigateToDetails(notification, isEditMode: true);
  }

  void _view(wise_notifications.Notification notification) {
    _navigateToDetails(notification);
  }
}
