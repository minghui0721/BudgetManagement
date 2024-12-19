import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportPage extends StatelessWidget {
  final String userId;
  final String faId;

  const ReportPage({super.key, required this.userId, required this.faId});

  Future<Map<String, dynamic>> fetchTransactions(String userId) async {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    Map<String, Map<String, dynamic>> categoryDetails = {}; // Store amount and type

    try {
      QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance
          .collection('Transactions')
          .where('userId', isEqualTo: FirebaseFirestore.instance.collection('Users').doc(userId))
          .get();

      for (var doc in transactionsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String category = data['category'] ?? 'Uncategorized';
        double amount = (data['amount'] ?? 0).toDouble();
        String type = data['type'] ?? 'unknown';

        if (type == 'income') {
          totalIncome += amount;
        } else if (type == 'expense') {
          totalExpense += amount;
        }

        if (categoryDetails.containsKey(category)) {
          categoryDetails[category]?['amount'] += amount;
        } else {
          categoryDetails[category] = {
            'amount': amount,
            'type': type,
          };
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'categoryDetails': categoryDetails,
      };
    } catch (e) {
      print('Error fetching transactions: $e');
      return {
        'totalIncome': 0.0,
        'totalExpense': 0.0,
        'categoryDetails': {},
      };
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Report Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No transactions found.'));
          } else {
            Map<String, dynamic> data = snapshot.data!;
            double totalIncome = data['totalIncome'];
            double totalExpense = data['totalExpense'];
            Map<String, Map<String, dynamic>> categoryDetails = data['categoryDetails'];

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard('Total Income', 'RM $totalIncome', Icons.arrow_upward, Colors.greenAccent),
                    const SizedBox(height: 20.0),
                    _buildInfoCard('Total Expense', 'RM $totalExpense', Icons.arrow_downward, Colors.redAccent),
                    const SizedBox(height: 30.0),
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ...categoryDetails.entries.map((entry) => _buildExpenseItem(
                          entry.key,
                          'RM ${entry.value['amount']}',
                          entry.value['type'] == 'income' ? 'Income' : 'Expense',
                          Icons.category,
                        )),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(String title, String amount, String type, IconData icon) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.black38,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6.0,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.amber.shade200,
              child: Icon(icon, color: Colors.black),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Center(
          child: Text(
            type,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: type == 'Income' ? Colors.greenAccent : Colors.redAccent,
            ),
            textAlign: TextAlign.center, // Center the text within the space
          ),
        ),
      ],
    ),
  );
}
}
