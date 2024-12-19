import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wise/models/Transactions.dart';
import 'package:wise/providers/TransactionsProvider.dart';

void showEditTransactionDialog(
    BuildContext context, TransactionModel transaction) {
  final TextEditingController categoryController =
      TextEditingController(text: transaction.category);
  final TextEditingController amountController =
      TextEditingController(text: transaction.amount.toString());
  final TextEditingController descriptionController =
      TextEditingController(text: transaction.description);

  // Use StatefulBuilder to ensure the dialog has its own state management
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          // Updated variable name for clarity
          ValueNotifier<String> transactionType =
              ValueNotifier<String>(transaction.type);

          return AlertDialog(
            backgroundColor: Color(0xFF2E2E2E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              "Edit Transaction",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Editable Category Field
                TextField(
                  controller: categoryController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 10),

                // Editable Amount Field
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 10),

                // Editable Description Field
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 10),

                // Transaction Type Dropdown with setModalState to manage state
                ValueListenableBuilder<String>(
                  valueListenable: transactionType,
                  builder: (context, value, child) {
                    return DropdownButton<String>(
                      value: value,
                      dropdownColor: Color(0xFF2E2E2E),
                      iconEnabledColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          transactionType.value = newValue;
                          print("Transaction type changed to: $newValue");
                        }
                      },
                      items: <String>['income', 'expense']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value[0].toUpperCase() + value.substring(1),
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close the dialog
                child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final shouldSave = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Confirm Save"),
                      content: Text("Are you sure you want to save changes?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text("No"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text("Yes"),
                        ),
                      ],
                    ),
                  );

                  if (shouldSave == true) {
                    final newData = {
                      'category': categoryController.text,
                      'amount': double.tryParse(amountController.text) ??
                          transaction.amount,
                      'description': descriptionController.text,
                      'type':
                          transactionType.value, // Use updated transaction type
                    };

                    // Call update function
                    await Provider.of<TransactionProvider>(context,
                            listen: false)
                        .updateTransaction(transaction.id, newData);

                    Navigator.pop(context); // Close the edit dialog

                    // Show a snackbar on successful update
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Transaction updated successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Text("Save",
                    style:
                        TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
              ),
            ],
          );
        },
      );
    },
  );
}
