import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(
            0xFF1E1E1E), // Set background color to #1E1E1E, // Dark background color
        elevation: 0, // Remove shadow for a flat appearance
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios, // Back arrow icon style
            color: Colors.white70, // Color of the back arrow
          ),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text(
          'Notification',
          style: TextStyle(
            color: Color(0xFFF8E4B2), // Light color for the title text
            fontSize: 18, // Font size for the title
            fontWeight: FontWeight.w600, // Optional: adjust weight for emphasis
          ),
        ),
        centerTitle: true, // Center align the title
      ),
      backgroundColor: Color(0xFF1E1E1E), // Set background color to #1E1E1E
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Notification')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No notifications available"));
          }

          final notifications = snapshot.data!.docs;

          return Scrollbar(
            thumbVisibility: true, // Optionally always show the scrollbar
            thickness: 6.0, // Set thickness for a more prominent scrollbar
            radius: Radius.circular(10), // Rounded corners for the scrollbar
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var notification = notifications[index];
                var title = notification['title'] ?? 'No Title';
                var content = notification['content'] ?? 'No Content';
                var imagePath = notification['imagePath'];
                var createdAt = notification['createdAt'] != null
                    ? (notification['createdAt'] as Timestamp).toDate()
                    : null;

                return InkWell(
                  onTap: () {
                    // Show dialog when the card is tapped
                    _showNotificationDialog(context, title, content, imagePath);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Color(
                        0xFF2E2E2E), // Custom dark grey color for the card background
                    elevation: 4,

                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          if (imagePath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imagePath,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.notifications,
                                  color: Colors.blue, size: 30),
                            ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Colors.white, // Light color for title
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors
                                        .white70, // Light gray for content
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 10),
                                if (createdAt != null)
                                  Text(
                                    _formatDate(createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _showNotificationDialog(
      BuildContext context, String title, String content, String? imagePath) {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Allows the user to tap outside the dialog to dismiss it
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(), // Close dialog
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Close',
                      style: TextStyle(
                          color: Colors.white)), // Set text color to white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
