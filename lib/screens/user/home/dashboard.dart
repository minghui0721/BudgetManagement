import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wise/models/Transactions.dart';
import 'package:wise/providers/TransactionsProvider.dart';
import 'package:wise/screens/admin/advertisement/AdvertisementSlider.dart';
import 'package:wise/screens/user/home/notification.dart';
import 'package:wise/screens/user/home/seeMoreTransaction.dart';
import 'package:wise/screens/user/home/transactionDetails.dart';

class BudgetTrackerPage extends StatefulWidget {
  @override
  _BudgetTrackerPageState createState() => _BudgetTrackerPageState();
}

class _BudgetTrackerPageState extends State<BudgetTrackerPage> {
  bool showAdvertisement = true;

  @override
  void initState() {
    super.initState();

    // Fetch transactions when the page initializes
    Future.microtask(() {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    // Define a method to refresh transactions
    void refreshTransactions() {
      transactionProvider
          .fetchTransactions(); // Refreshes the transactions and updates totals
    }

    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar Section
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, bottom: 20.0, top: 45.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo/noWord.png',
                      width: 50,
                      height: 40,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'WISE',
                      style: TextStyle(
                        color: Color(0xFFF8E4B2),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 28,
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            ' ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Net Balance Section
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, bottom: 16.0, top: 10.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF8E4B2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net Balance:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'RM ${transactionProvider.netBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    color: transactionProvider.netBalance >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          // Income and Expenses Summary Section
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIncomeExpenseCard(
                      'Income',
                      'RM ${transactionProvider.totalIncome.toStringAsFixed(2)}',
                      Colors.green,
                      Icons.trending_up,
                    ),
                    _buildIncomeExpenseCard(
                      'Expenses',
                      'RM ${transactionProvider.totalExpense.toStringAsFixed(2)}',
                      Colors.red,
                      Icons.trending_down,
                    ),
                  ],
                );
              },
            ),
          ),
          // Transaction Section
          Container(
            color: Color.fromARGB(255, 40, 40, 40), // Grey background color
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllTransactionsPage()),
                        );
                      },
                      child: Text(
                        'See More',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                // Transaction List with Fixed Height
                SizedBox(
                  height: 293, // Adjust height as needed
                  child: Consumer<TransactionProvider>(
                    builder: (context, transactionProvider, child) {
                      final transactions =
                          transactionProvider.latest10Transactions;

                      if (transactions.isEmpty) {
                        return Center(
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'No transactions available',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        );
                      }
                      ScrollController _scrollController = ScrollController();

                      return Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return GestureDetector(
                              onTap: () =>
                                  showTransactionDetails(context, transaction),
                              child: _buildTransactionItem(transaction),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseCard(
      String title, String amount, Color color, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 20,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8E4B2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    // Determine color based on the transaction type
    bool isIncome = transaction.type.toLowerCase() == 'income';
    Color transactionColor = isIncome ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF8E4B2),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Card(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transactionColor,
              child: Icon(
                isIncome ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
              ),
            ),
            title: Text(
              transaction.category,
              style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('yyyy-MM-dd HH:mm')
                  .format(transaction.transactionDate), // Format DateTime
              style: TextStyle(color: const Color.fromARGB(255, 80, 80, 80)),
            ),
            trailing: Text(
              'RM ${transaction.amount.toStringAsFixed(2)}', // Format amount to 2 decimal places
              style: TextStyle(
                color: transactionColor, // Use the determined color here
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
