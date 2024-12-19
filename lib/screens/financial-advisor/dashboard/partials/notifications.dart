import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/NotificationProvider.dart';
import 'package:intl/intl.dart'; // Don't forget to import this for date formatting

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.fetchAllNotifications(); // Fetch notifications when widget is first initialized
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1e1e1e), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e), // Dark app bar background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        centerTitle: true,
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.amber, // Amber title color
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: notificationProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                var notification = notificationProvider.notifications[index];
                return GestureDetector(
                  onTap: () {
                    _showNotificationDetails(context, notification);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 0)
                        const Text(
                          'Today',
                          style: TextStyle(
                            color: Colors.white, // White text for section header
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 10.0),
                      _buildNotificationCard(
                        icon: Icons.notifications,
                        title: notification.title,
                        description: notification.content,
                        imageUrl: notification.imagePath ?? '',
                        time: DateFormat('yyyy-MM-dd HH:mm').format(notification.createdAt),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // Helper method to build notification card
  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required String imageUrl,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade800, // Dark gray background for card
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon or Image for notification
          imageUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                  radius: 20.0,
                )
              : CircleAvatar(
                  backgroundColor: Colors.grey.shade700, // Icon background
                  radius: 20.0,
                  child: Icon(icon, color: Colors.white),
                ),
          const SizedBox(width: 16.0),
          // Notification details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  maxLines: 1, // Truncate long descriptions
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white70, // Slightly lighter white text for description
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          // Time of notification
          Text(
            time,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.white70, // Lighter white for the time
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to show notification details in a dialog
  void _showNotificationDetails(BuildContext context, notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: Text(
            notification.title,
            style: const TextStyle(
              color: Colors.amber, // Amber title color
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.imagePath != null && notification.imagePath.isNotEmpty)
                  Image.network(
                    notification.imagePath,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 10.0),
                Text(
                  notification.content,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  'Received at: ${DateFormat('yyyy-MM-dd HH:mm').format(notification.createdAt)}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        );
      },
    );
  }
}
