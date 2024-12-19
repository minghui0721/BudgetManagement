import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wise/models/Goals.dart';
import 'package:wise/providers/GoalsProvider.dart';
import 'package:wise/screens/user/profile/financialAdvice/submitGoals.dart';

class GoalsSettingPage extends StatefulWidget {
  final String userId;

  const GoalsSettingPage({Key? key, required this.userId}) : super(key: key);

  @override
  _GoalsSettingPageState createState() => _GoalsSettingPageState();
}

class _GoalsSettingPageState extends State<GoalsSettingPage> {
  @override
  void initState() {
    super.initState();

    // Use listen: false to avoid rebuilding the widget during initState
    Future.microtask(() {
      Provider.of<GoalProvider>(context, listen: false)
          .fetchGoals(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          if (goalProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFF8E4B2)),
            );
          } else if (goalProvider.goals.isEmpty) {
            return Center(
              child: Text(
                "No goals found.",
                style: TextStyle(color: Color(0xFFF8E4B2), fontSize: 16),
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: goalProvider.goals.length,
              itemBuilder: (context, index) {
                final goal = goalProvider.goals[index];
                return GoalCard(
                  goal: goal,
                  userId: widget.userId,
                  onEdit: () {},
                  onDelete: () async {
                    bool confirmDelete =
                        await showDeleteConfirmationDialog(context);
                    if (confirmDelete) {
                      try {
                        await goalProvider.deleteGoal(goal.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Goal deleted successfully!'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        // Refresh the goals list by calling fetchGoals again
                        Provider.of<GoalProvider>(context, listen: false)
                            .fetchGoals(widget.userId);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Failed to delete goal: ${goalProvider.errorMessage}'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFF8E4B2),
        child: Icon(Icons.add, color: Color(0xFF1E1E1E)),
        onPressed: () {
          // Show the bottom sheet to add a new goal
          _showGoalBottomSheet(context);
        },
      ),
    );
  }

  void _showGoalBottomSheet(BuildContext context) {
    print("Testing ${widget.userId}");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 15,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Title and Close Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Set a New Goal",
                    style: TextStyle(
                      color: Color(0xFFF8E4B2),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Divider(color: Colors.grey[600], thickness: 1),

              // SetGoalForm Widget
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SetGoalForm(userId: widget.userId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xFF1E1E1E),
              title: Text(
                "Delete Goal",
                style: TextStyle(
                    color: Color(0xFFF8E4B2), fontWeight: FontWeight.bold),
              ),
              content: Text(
                "Are you sure you want to delete this goal?",
                style: TextStyle(color: Color(0xFFF8E4B2)),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .pop(false), // Return false if canceled
                  child: Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .pop(true), // Return true if confirmed
                  child: Text("Delete",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if null
  }
}

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String userId; // Add userId parameter

  const GoalCard({
    Key? key,
    required this.goal,
    required this.onEdit,
    required this.onDelete,
    required this.userId, // Add userId to constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      color: Color(0xFF2E2E2E), // Dark background for the card
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Title with Edit and Delete Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF8E4B2), // Secondary color for title
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_money, color: Colors.greenAccent),
                  onPressed: () =>
                      _showAddMoneyBottomSheet(context, goal, userId),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFFF8E4B2)),
                  onPressed: () =>
                      _showEditGoalBottomSheet(context, goal, userId),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: onDelete,
                ),
              ],
            ),
            SizedBox(height: 8),

            // Display Start and End Dates
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Start Date: ${dateFormat.format(goal.startDate)}",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    "End Date: ${dateFormat.format(goal.endDate)}",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Target and Saved Amounts
            Row(
              children: [
                _buildGoalDetail(
                    "Target",
                    "\$${goal.targetAmount.toStringAsFixed(2)}",
                    Colors.grey[400]!),
                SizedBox(width: 20),
                _buildGoalDetail(
                    "Saved",
                    "\$${goal.currentAmount.toStringAsFixed(2)}",
                    Color(0xFFF8E4B2)),
              ],
            ),
            SizedBox(height: 16),

            // Custom Progress Indicator
            Text("Progress", style: TextStyle(color: Colors.grey[500])),
            SizedBox(height: 6),
            AnimatedProgressIndicator(value: progress),

            // Completion Percentage Text
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${(progress * 100).toStringAsFixed(1)}% Completed",
                style: TextStyle(
                  color: progress >= 1.0 ? Colors.green : Color(0xFFF8E4B2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Target and Saved Amounts
  Widget _buildGoalDetail(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        SizedBox(height: 4),
        Text(amount,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

void _showAddMoneyBottomSheet(BuildContext context, Goal goal, String userId) {
  final TextEditingController _amountController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add Money to Goal",
              style: TextStyle(
                color: Color(0xFFF8E4B2),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              style: TextStyle(
                  color: Color(0xFFF8E4B2)), // Text color for user input
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount to Add",
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
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final double? amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  _addMoneyToGoal(context, goal, amount);
                  // Refresh the goals list by calling fetchGoals again
                  Provider.of<GoalProvider>(context, listen: false)
                      .fetchGoals(goal.userRef.id);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid amount")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF8E4B2),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Add Money",
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _addMoneyToGoal(BuildContext context, Goal goal, double amount) async {
  try {
    await Provider.of<GoalProvider>(context, listen: false)
        .addMoneyToGoal(goal.id, amount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Money added successfully!"),
        backgroundColor: Colors.blueAccent,
      ),
    );

    // Refresh the goals list by calling fetchGoals again
    Provider.of<GoalProvider>(context, listen: false)
        .fetchGoals(goal.userRef.id);
  } catch (e) {
    // Check the exception message to provide a specific error
    final errorMessage =
        e.toString().contains("exceeds the target saving amount")
            ? "Amount exceeds the target saving goal."
            : "An error occurred. Please try again.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

// Bottom sheet for editing a goal
void _showEditGoalBottomSheet(BuildContext context, Goal goal, String userId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SetGoalForm(
          userId: userId, // Use `userId` directly here
          goal: goal, // Pass the existing goal for editing
          isEditing: true, // Set editing mode to true
        ),
      ),
    ),
  );
}

// Custom Animated Progress Indicator
class AnimatedProgressIndicator extends StatelessWidget {
  final double value;

  const AnimatedProgressIndicator({Key? key, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
        backgroundColor: Colors.grey[700],
        color: value >= 1.0 ? Colors.green : Color(0xFFF8E4B2),
      ),
    );
  }
}
