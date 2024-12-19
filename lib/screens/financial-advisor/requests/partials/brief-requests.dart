import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/models/User.dart';
import 'package:wise/screens/financial-advisor/requests/partials/request.dart'; // Import the request detail page

class BriefRequestsPage extends StatefulWidget {
  final String faId; // Pass the financial advisor ID

  const BriefRequestsPage({super.key, required this.faId});

  @override
  _BriefRequestsPageState createState() => _BriefRequestsPageState();
}

class _BriefRequestsPageState extends State<BriefRequestsPage> {
  late Future<List<Map<String, dynamic>>> _pendingRequestsFuture;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  void _fetchPendingRequests() {
    // Create an instance of the FinancialAdvisorProvider and fetch the pending requests
    _pendingRequestsFuture = Provider.of<FinancialAdvisorProvider>(
      context,
      listen: false,
    ).fetchPendingRequests(widget.faId);
  }

  Future<void> _refreshRequests() async {
    setState(() {
      _fetchPendingRequests();
    });
    await _pendingRequestsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1e1e1e), // Matching background color
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        onRefresh: _refreshRequests,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _pendingRequestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No pending requests found.'));
            } else {
              final pendingRequestsWithIds = snapshot.data!;
              return ListView.builder(
                itemCount: pendingRequestsWithIds.length,
                itemBuilder: (context, index) {
                  final requestData = pendingRequestsWithIds[index];
                  final User user = requestData['user'];
                  final String requestId = requestData['requestId'];

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (requestId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestDetailPage(
                                  requestId: requestId, // Pass the non-null request ID here
                                ),
                              ),
                            ).then((_) => _refreshRequests()); // Refresh after navigation
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Request ID is missing for this request.')),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white24, // Match request item color
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24.0,
                                backgroundImage: user.imagePath.isNotEmpty
                                    ? NetworkImage(user.imagePath)
                                    : null,
                                backgroundColor: user.imagePath.isEmpty ? Colors.amber.shade200 : Colors.transparent,
                                child: user.imagePath.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.black,
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
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF8E4B2),
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      '${user.name} sent a subscription request!',
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0), // Add spacing between items
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
