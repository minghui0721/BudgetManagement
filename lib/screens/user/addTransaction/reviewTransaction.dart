import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wise/models/SpendingCategory.dart';
import 'package:wise/providers/SpendingCategoryProvider.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/user/rootPage.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class ReviewTransactionPage extends StatefulWidget {
  final String amount;
  final String description;
  final DateTime transactionDateTime;

  ReviewTransactionPage({
    required this.amount,
    required this.description,
    required this.transactionDateTime,
  });

  @override
  _ReviewTransactionPageState createState() => _ReviewTransactionPageState();
}

class _ReviewTransactionPageState extends State<ReviewTransactionPage> {
  SpendingCategory? _selectedCategory;
  List<SpendingCategory> _combinedCategories = [];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _transactionType = 'expense'; // Default to 'expense'
  late DateTime _transactionDateTime;

  @override
  void initState() {
    super.initState();
    _transactionDateTime =
        DateTime.now(); // Initialize with the current date and time
    _amountController.text = widget.amount;
    _descriptionController.text = widget.description;

    // Fetch and combine categories when the page initializes
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final userId = UserData().uid;
    List<SpendingCategory> userCategories = [];

    try {
      // Fetch user-specific categories from Firestore
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Category')
          .get();

      userCategories = categorySnapshot.docs.map((doc) {
        return SpendingCategory(
          id: doc.id,
          name: doc['name'] ?? 'Unnamed Category',
          type: doc['type'] ?? 'Unknown Type',
          imagePath: doc['imagePath'] ?? '',
          createdAt: (doc['createdAt'] as Timestamp).toDate(),
          updatedAt: (doc['updatedAt'] as Timestamp).toDate(),
        );
      }).toList();

      // Fetch global categories from provider and combine with user-specific categories
      final globalCategories =
          Provider.of<SpendingCategoryProvider>(context, listen: false)
              .categories;
      setState(() {
        _combinedCategories = [...globalCategories, ...userCategories];
      });
    } catch (e) {
      print("Error fetching user categories: $e");
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _transactionDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_transactionDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _transactionDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF2E2E2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildEditableDateTimeCard(context),
                      SizedBox(height: 20.0),
                      _buildTransactionTypeCard(),
                      SizedBox(height: 20.0),
                      _buildInfoCard(
                          Icons.category, "Category", _buildCategoryDropdown()),
                      SizedBox(height: 20.0),
                      _buildEditableTextField(
                          Icons.attach_money, "Amount", _amountController),
                      SizedBox(height: 20.0),
                      _buildEditableTextField(Icons.description, "Description",
                          _descriptionController),
                      SizedBox(height: 30.0),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeCard() {
    return _buildInfoCard(
      Icons.compare_arrows,
      "Transaction Type",
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _transactionType = 'income';
                });
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _transactionType == 'income'
                      ? Colors.green
                      : Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    "Income",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _transactionType = 'expense';
                });
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _transactionType == 'expense'
                      ? Colors.red
                      : Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    "Expense",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Review Transaction",
        style: TextStyle(
          color: Color(0xFFF8E4B2),
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildEditableDateTimeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDateTime(context),
      child: _buildInfoCard(
        Icons.calendar_today,
        "Transaction Date & Time",
        DateFormat('yyyy-MM-dd hh:mm a').format(_transactionDateTime),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, dynamic content) {
    return SizedBox(
      height: 100.0, // Set desired height here
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            children: [
              Icon(icon, color: Color(0xFFF8E4B2), size: 28.0),
              SizedBox(width: 12.0),
              Expanded(
                child: content is Widget
                    ? content
                    : Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center vertically
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Color(0xFFF8E4B2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            content,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
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
  }

  Widget _buildEditableTextField(
      IconData icon, String title, TextEditingController controller) {
    return SizedBox(
      height: 120.0, // Set a consistent height for the card
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            children: [
              Icon(icon, color: Color(0xFFF8E4B2), size: 28.0),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center vertically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Color(0xFFF8E4B2),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    TextField(
                      controller: controller,
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter $title',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      keyboardType: title == "Amount"
                          ? TextInputType.number
                          : TextInputType.text,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<SpendingCategory>(
        dropdownColor: Color(0xFF2C2C2C),
        value: _selectedCategory,
        hint: Text(
          "Select Category",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        icon: Icon(Icons.arrow_drop_down, color: Color(0xFFF8E4B2)),
        isExpanded: true,
        onChanged: (SpendingCategory? newValue) {
          setState(() {
            _selectedCategory = newValue;
          });
        },
        items: _combinedCategories.map((category) {
          return DropdownMenuItem<SpendingCategory>(
            value: category,
            child: Text(
              category.name,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildGradientButton("Save", Colors.green, () {
          if (_selectedCategory == null || _amountController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please fill in all required fields."),
              ),
            );
            return;
          }

          // Show confirmation dialog before saving
          _showSaveConfirmationDialog(context);
        }),
        _buildGradientButton("Cancel", Colors.red, () {
          _showCancelConfirmationDialog(context);
        }),
      ],
    );
  }

  Widget _buildGradientButton(
      String text, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSaveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E), // Dark background
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.save_alt,
                  color: Colors.blueAccent,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Save Transaction',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Are you sure you want to save this transaction?',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await _saveTransactionToFirestore(); // Save transaction to Firestore

                          // Delay navigation slightly
                          await Future.delayed(Duration(milliseconds: 500));

                          // Navigate to RootPage with success message
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => RootPage(
                                currentIndex: 0,
                                showSnackBarMessage:
                                    "Transaction saved successfully!",
                              ),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        } catch (e) {
                          print("Error saving transaction: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Failed to save transaction. Please try again."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E), // Dark background
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Cancel Transaction',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Are you sure you want to cancel? Any unsaved data will be lost.',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context)
                            .pop(); // Go back to the previous screen
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveTransactionToFirestore() async {
    print("Attempting to save transaction...");
    final userId = "/${UserData().uid}"; // Ensure this is correctly set
    final currentDateTime = DateTime.now();

    try {
      await FirebaseFirestore.instance.collection("Transactions").add({
        "amount": double.tryParse(_amountController.text) ?? 0.0,
        "category": _selectedCategory?.name ??
            "Unknown Category", // Use name if not null, otherwise default to "Unknown Category"
        "createdAt": currentDateTime,
        "transactionDate":
            _transactionDateTime, // Make sure this variable is set correctly
        "description": _descriptionController.text,
        "type": _transactionType, // or "expense" based on user input
        "userId": FirebaseFirestore.instance.collection('Users').doc(userId),
      });

      print("Transaction saved successfully.");
    } catch (e) {
      print("Error saving transaction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to save transaction. Please try again.")),
      );
    }
  }
}
