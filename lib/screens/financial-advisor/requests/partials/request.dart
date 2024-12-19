import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/models/User.dart';
import 'package:wise/providers/userGlobalVariables.dart';

class RequestDetailPage extends StatelessWidget {
  final String requestId; // Request ID to fetch the specific request details

  const RequestDetailPage({super.key, required this.requestId});

  void showConfirmationDialog(
      BuildContext context, String action, String advisorId, String requestId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Confirm $action',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to $action this request?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close the dialog

                bool isUpdated = false;
                if (action == 'accept') {
                  isUpdated = await Provider.of<FinancialAdvisorProvider>(
                    context,
                    listen: false,
                  ).updateRequestStatus(context, advisorId, requestId, 'Approved');
                } else {
                  isUpdated = await Provider.of<FinancialAdvisorProvider>(
                    context,
                    listen: false,
                  ).updateRequestStatus(context, advisorId, requestId, 'Rejected');
                }

                if (isUpdated && context.mounted) {
                  Future.microtask(() {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Request ${action == 'accept' ? 'approved' : 'rejected'} successfully!',
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                    );

                    // Navigate back to the previous screen
                    Navigator.pop(context);
                  });
                }
              },
              child: Text(
                action == 'accept' ? 'Accept' : 'Decline',
                style: TextStyle(
                  color: action == 'accept' ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final financialAdvisorProvider =
        Provider.of<FinancialAdvisorProvider>(context, listen: false);

    return FutureBuilder<String?>(
      future: financialAdvisorProvider.getAdvisorIdByUserId(UserData().uid),
      builder: (context, advisorIdSnapshot) {
        if (advisorIdSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (advisorIdSnapshot.hasError) {
          return Center(child: Text('Error: ${advisorIdSnapshot.error}'));
        } else if (!advisorIdSnapshot.hasData || advisorIdSnapshot.data == null) {
          return const Center(child: Text('Advisor ID not found.'));
        }

        final advisorId = advisorIdSnapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFF1e1e1e),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1e1e1e),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            centerTitle: true,
            title: const Text(
              'New Subscription Request',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          body: FutureBuilder<User?>(
            future: financialAdvisorProvider.fetchRequestDetails(requestId, UserData().uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No request details found.'));
              }

              final user = snapshot.data!;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40.0,
                                  backgroundImage: user.imagePath != null
                                      ? NetworkImage(user.imagePath!)
                                      : null,
                                  backgroundColor: Colors.amber,
                                  child: user.imagePath == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 40.0,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFF8E4B2),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Age: ${user.age}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Occupation: ${user.occupation}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Phone: ${user.phoneNumber}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Email: ${user.email}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      const Text(
                        'Additional Comment:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Container(
                        height: 250.0, // Larger height for full-width box
                        padding: const EdgeInsets.all(12.0),
                        width: double.infinity, // Full-width
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                        child: Text(
                          user.additionalComment ?? 'No additional comment provided.',
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => showConfirmationDialog(
                                    context, 'accept', advisorId, requestId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text(
                                  'Accept',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => showConfirmationDialog(
                                    context, 'decline', advisorId, requestId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text(
                                  'Decline',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
