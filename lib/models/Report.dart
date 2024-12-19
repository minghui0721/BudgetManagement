
class Report {
  String id;
  num entertainment;
  num expenses;
  num food;
  num healthCare;
  num housing;
  num income;
  num membership;
  num personalCare;
  num saving;
  num shopping;
  num transportation;
  String userId;

  Report({
    required this.id,
    required this.entertainment,
    required this.expenses,
    required this.food,
    required this.healthCare,
    required this.housing,
    required this.income,
    required this.membership,
    required this.personalCare,
    required this.saving,
    required this.shopping,
    required this.transportation,
    required this.userId,
  });

  // Factory constructor to create a Report object from Firestore data
  factory Report.fromFirestore(Map<String, dynamic> data, String id) {
    return Report(
      id: id,
      entertainment: (data['Entertainment'] ?? 0).toDouble(),
      expenses: (data['Expenses'] ?? 0).toDouble(),
      food: (data['Food'] ?? 0).toDouble(),
      healthCare: (data['Health Care'] ?? 0).toDouble(),
      housing: (data['Housing'] ?? 0).toDouble(),
      income: (data['Income'] ?? 0).toDouble(),
      membership: (data['Membership'] ?? 0).toDouble(),
      personalCare: (data['Personal Care'] ?? 0).toDouble(),
      saving: (data['Saving'] ?? 0).toDouble(),
      shopping: (data['Shopping'] ?? 0).toDouble(),
      transportation: (data['Transportation'] ?? 0).toDouble(),
      userId: data['userID'] ?? '',
    );
  }

  // Function to convert the object into a map (if needed for saving data)
  Map<String, dynamic> toMap() {
    return {
      'Entertainment': entertainment,
      'Expenses': expenses,
      'Food': food,
      'Health Care': healthCare,
      'Housing': housing,
      'Income': income,
      'Membership': membership,
      'Personal Care': personalCare,
      'Saving': saving,
      'Shopping': shopping,
      'Transportation': transportation,
      'userID': userId,
    };
  }
}
