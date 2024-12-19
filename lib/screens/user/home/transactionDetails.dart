// transaction_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wise/models/Transactions.dart';
import 'package:wise/providers/TransactionsProvider.dart';
import 'package:wise/screens/user/home/editTransaction.dart';

void showTransactionDetails(
    BuildContext context, TransactionModel transaction) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Color(0xFF2E2E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              transaction.type.toLowerCase() == 'income'
                  ? Icons.trending_up
                  : Icons.trending_down,
              color: transaction.type.toLowerCase() == 'income'
                  ? Colors.green
                  : Colors.red,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                transaction.category,
                style: TextStyle(
                    color: Color(0xFFF8E4B2),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: Colors.grey[700]),
            SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: DateFormat('MMM dd, yyyy')
                  .format(transaction.transactionDate),
            ),
            SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.monetization_on,
              label: 'Amount',
              value: 'RM ${transaction.amount.toStringAsFixed(2)}',
            ),
            SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.category,
              label: 'Type',
              value: transaction.type,
            ),
            SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.description,
              label: 'Description',
              value: transaction.description.length > 50
                  ? '${transaction.description.substring(0, 50)}...' // Limit to 50 characters
                  : transaction.description.isNotEmpty
                      ? transaction.description
                      : 'No description available',
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context); // Close the details dialog
                    showEditTransactionDialog(
                        context, transaction); // Open the edit dialog
                  },
                  label: Text("Edit", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Delete"),
                          content: Text(
                              "Are you sure you want to delete this transaction?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                Navigator.of(context)
                                    .pop(); // Close the confirmation dialog
                                Navigator.of(context)
                                    .pop(); // Close the transaction details dialog

                                // Perform delete operation
                                await Provider.of<TransactionProvider>(context,
                                        listen: false)
                                    .deleteTransaction(transaction.id);

                                // Show snackbar after deletion
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Transaction deleted successfully"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              child: Text("Delete",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Delete", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// Helper widget to build each detail row with an icon, label, and value.
Widget _buildDetailRow(
    {required IconData icon, required String label, required String value}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.grey[400], size: 20),
      SizedBox(width: 10),
      Text(
        '$label: ',
        style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(color: Colors.grey[300]),
        ),
      ),
    ],
  );
}
