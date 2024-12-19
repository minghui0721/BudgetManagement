import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/models/Goals.dart';
import 'package:wise/providers/GoalsProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class SetGoalForm extends StatefulWidget {
  final String userId;
  final Goal? goal; // Optional goal data for editing
  final bool isEditing; // Flag to indicate editing mode

  const SetGoalForm({
    Key? key,
    required this.userId,
    this.goal,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _SetGoalFormState createState() => _SetGoalFormState();
}

class _SetGoalFormState extends State<SetGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd'); // Date format

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if editing an existing goaledit
    if (widget.isEditing && widget.goal != null) {
      _nameController.text = widget.goal!.name;
      _targetAmountController.text = widget.goal!.targetAmount.toString();
      _startDate = widget.goal!.startDate;
      _endDate = widget.goal!.endDate;
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Restrict selection to today and future dates
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitGoal() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a start date')),
        );
        return;
      }
      if (_endDate == null || _endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('End date cannot be before start date')),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      final userRef =
          FirebaseFirestore.instance.collection('Users').doc(widget.userId);
      final updatedGoal = Goal(
        id: widget.goal?.id ?? '', // Use existing ID if editing
        name: _nameController.text,
        targetAmount: double.tryParse(_targetAmountController.text) ?? 0,
        currentAmount:
            widget.goal?.currentAmount ?? 0, // Keep current amount if editing
        startDate: _startDate!,
        endDate: _endDate!,
        userRef: userRef,
      );

      try {
        if (widget.isEditing) {
          // Update existing goal
          await Provider.of<GoalProvider>(context, listen: false)
              .updateGoal(widget.userId, updatedGoal);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Goal updated successfully!'),
              backgroundColor: Colors.blueAccent, // Blue accent color
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Refresh the goals list by calling fetchGoals again
          Provider.of<GoalProvider>(context, listen: false)
              .fetchGoals(widget.userId);
        } else {
          // Add new goal
          await Provider.of<GoalProvider>(context, listen: false)
              .addGoal(widget.userId, updatedGoal);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Goal added successfully!'),
              backgroundColor: Colors.blueAccent, // Blue accent color
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Refresh goals list explicitly after adding a new goal
          Provider.of<GoalProvider>(context, listen: false)
              .fetchGoals(widget.userId);
        }

        Navigator.pop(context); // Close the bottom sheet after submission
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save goal: $e')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Goal Name Field
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: Color(0xFFF8E4B2)),
            decoration: InputDecoration(
              labelText: "Goal Name",
              labelStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFF8E4B2)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter a goal name'
                : null,
          ),
          SizedBox(height: 16),

          // Target Amount Field
          TextFormField(
            controller: _targetAmountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Color(0xFFF8E4B2)),
            decoration: InputDecoration(
              labelText: "Target Amount",
              labelStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFF8E4B2)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a target amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid number greater than 0';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Start Date Picker
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _startDate == null
                  ? "Select Start Date"
                  : "Start Date: ${_dateFormatter.format(_startDate!)}", // Format date
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: Icon(Icons.calendar_today, color: Color(0xFFF8E4B2)),
            onTap: () => _pickDate(context, true),
          ),
          Divider(color: Colors.grey[700]),

          // End Date Picker
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _endDate == null
                  ? "Select End Date"
                  : "End Date: ${_dateFormatter.format(_endDate!)}", // Format date
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: Icon(Icons.calendar_today, color: Color(0xFFF8E4B2)),
            onTap: () => _pickDate(context, false),
          ),
          Divider(color: Colors.grey[700]),
          SizedBox(height: 20),

          // Submit Button
          _isSubmitting
              ? CircularProgressIndicator(color: Color(0xFFF8E4B2))
              : ElevatedButton(
                  onPressed: _submitGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF8E4B2),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.isEditing ? "Update Goal" : "Set Goal",
                    style: TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }
}
