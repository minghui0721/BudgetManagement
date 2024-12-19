import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/models/FinancialAdvisor.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/user/profile/financialAdvice/submitRequest.dart'; // Import the SubmitRequestToAdvisorPage

class FinancialAdvisorSelectionPage extends StatefulWidget {
  @override
  _FinancialAdvisorSelectionPageState createState() =>
      _FinancialAdvisorSelectionPageState();
}

class _FinancialAdvisorSelectionPageState
    extends State<FinancialAdvisorSelectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetching data from providers when the page loads after the initial frame
      final advisorProvider =
          Provider.of<FinancialAdvisorProvider>(context, listen: false);
      advisorProvider.fetchAllFinancialAdvisors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text("Financial Advisor",
            style: TextStyle(color: Color(0xFFF8E4B2))),
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFF8E4B2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFF2C2C2C),
                prefixIcon: Icon(Icons.search, color: Color(0xFFF8E4B2)),
                hintText: 'Search financial advisors',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Consumer<FinancialAdvisorProvider>(
              builder: (context, advisorProvider, child) {
                if (advisorProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (advisorProvider.errorMessage != null) {
                  return Center(
                    child: Text(
                      advisorProvider.errorMessage ?? 'Error loading data',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (advisorProvider.advisors.isEmpty) {
                  return Center(
                    child: Text(
                      'No financial advisors found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return Column(
                  children: advisorProvider.advisors
                      .where((advisor) =>
                          advisor.isVerified && // Only show verified advisors
                          advisor.user.id !=
                              UserData()
                                  .uid) // Exclude advisors with the same userID as current user
                      .map((advisor) {
                    return _buildAdvisorItem(context, advisor);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvisorItem(BuildContext context, FinancialAdvisor advisor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmitRequestToAdvisorPage(advisor: advisor),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF8E4B2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_circle, color: Color(0xFF1E1E1E)),
          ),
          title: Text(
            '${advisor.user.name}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            '${advisor.user.occupation}',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFFF8E4B2)),
        ),
      ),
    );
  }
}
