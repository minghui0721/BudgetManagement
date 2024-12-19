import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wise/models/Transactions.dart';
import 'package:wise/providers/TransactionsProvider.dart';
import 'package:wise/screens/user/home/transactionDetails.dart';

class AllTransactionsPage extends StatefulWidget {
  @override
  _AllTransactionsPageState createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  DateTime selectedDate = DateTime.now();

  // Function to open a month-year picker using showModalBottomSheet
  Future<void> _selectMonthYear(BuildContext context) async {
    DateTime tempSelectedDate = selectedDate;
    final pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 400, // Increased height for more space
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Text(
                    "Select Month and Year",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: YearPicker(
                      selectedDate: tempSelectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      onChanged: (newDate) {
                        setModalState(() {
                          tempSelectedDate = DateTime(newDate.year,
                              tempSelectedDate.month); // Update only the year
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButton<int>(
                      value: tempSelectedDate.month,
                      items: List.generate(12, (index) {
                        final month = DateTime(0, index + 1);
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(DateFormat('MMMM').format(month)),
                        );
                      }),
                      onChanged: (newMonth) {
                        setModalState(() {
                          tempSelectedDate = DateTime(tempSelectedDate.year,
                              newMonth!); // Update only the month
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, tempSelectedDate);
                    },
                    child: Text("Confirm"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = DateTime(pickedDate.year, pickedDate.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    // Filter and group transactions by date within the selected month and year
    Map<String, List<TransactionModel>> groupedTransactions = {};
    for (var transaction in transactionProvider.transactions) {
      // Check if the transaction date matches the selected month and year
      if (transaction.transactionDate.year == selectedDate.year &&
          transaction.transactionDate.month == selectedDate.month) {
        String dateKey =
            DateFormat('dd MMMM yyyy').format(transaction.transactionDate);
        if (groupedTransactions[dateKey] == null) {
          groupedTransactions[dateKey] = [];
        }
        groupedTransactions[dateKey]!.add(transaction);
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight + 15), // 15 pixels extra for spacing
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: AppBar(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: TextStyle(
                  color: Color(0xFFF8E4B2), fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () => _selectMonthYear(context),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: groupedTransactions.keys.map((date) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  date,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: groupedTransactions[date]!.map((transaction) {
                  return GestureDetector(
                    onTap: () => showTransactionDetails(
                        context, transaction), // Show transaction details
                    child: _buildTransactionItem(transaction),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    bool isIncome = transaction.type.toLowerCase() == 'income';
    Color indicatorColor = isIncome ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A), // Darker color for transaction cards
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              transaction.category[0].toUpperCase(),
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  DateFormat('MMM dd, yyyy')
                      .format(transaction.transactionDate),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RM ${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: 8,
                height: 30,
                color: indicatorColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
