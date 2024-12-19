import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wise/models/SpendingCategory.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/repositories/SpendingCategoryRepository.dart';
import 'package:image_picker/image_picker.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final SpendingCategoryRepository _repository = SpendingCategoryRepository();
  final ImagePicker _picker = ImagePicker();

  List<SpendingCategory> incomeCategories = [];
  List<SpendingCategory> expenseCategories = [];
  String? imageUrl; // Variable to store the image URL
  String? selectedType; // Variable to hold the selected type (income/expense)
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  fetchCategories() async {
    // Fetch categories from the main SpendingCategory collection
    List<SpendingCategory> fetchedCategories =
        await _repository.getCategories();

    // Fetch categories from the user's sub-collection
    List<SpendingCategory> userCategories =
        await _repository.getUserCategories(UserData().uid);

    // Combine both lists
    List<SpendingCategory> allCategories = [
      ...fetchedCategories,
      ...userCategories
    ];

    // Separate income and expense categories
    setState(() {
      incomeCategories =
          allCategories.where((category) => category.type == 'income').toList();
      expenseCategories = allCategories
          .where((category) => category.type == 'expense')
          .toList();
    });
  }

  Future<String> uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
    Reference ref =
        FirebaseStorage.instance.ref().child('categories/$fileName');
    await ref.putFile(image);
    return await ref.getDownloadURL(); // Return the download URL
  }

  void _showAddCategoryDialog(BuildContext context) {
    imageUrl = null; // Reset image URL
    nameController.clear(); // Clear the text field
    selectedType = null; // Clear the selected type
    bool isLoading = false; // Loading state

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFF2A2A2A),
              title: Center(
                child: Text(
                  "Add New Category",
                  style: TextStyle(color: Color(0xFFF8E4B2), fontSize: 20),
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Step 1: Category Name Input
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          labelStyle: TextStyle(color: Color(0xFFF8E4B2)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF8E4B2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF8E4B2)),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),

                      // Step 2: Dropdown for Type Selection
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        hint: Text("Select Type",
                            style: TextStyle(color: Colors.grey)),
                        dropdownColor: Color(0xFF2A2A2A),
                        items:
                            <String>['income', 'expense'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedType =
                                value; // Update selected type immediately
                          });
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF8E4B2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF8E4B2)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Step 3: Button to Select Image
                      GestureDetector(
                        onTap: () async {
                          final pickedFile = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              imageUrl = pickedFile
                                  .path; // Update image URL immediately
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF8E4B2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          alignment: Alignment.center,
                          child: Text(
                            'Select Image',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),

                      // Display the selected image
                      if (imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(imageUrl!),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Color(0xFFF8E4B2)),
                  ),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true; // Set loading to true
                          });
                          String categoryName = nameController.text;
                          if (categoryName.isNotEmpty &&
                              imageUrl != null &&
                              selectedType != null) {
                            String uploadedImageUrl =
                                await uploadImage(File(imageUrl!));

                            SpendingCategory newCategory = SpendingCategory(
                              id: FirebaseFirestore.instance
                                  .collection('SpendingCategory')
                                  .doc()
                                  .id,
                              name: categoryName,
                              imagePath: uploadedImageUrl,
                              type: selectedType!,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );

                            await _repository.addUserCategory(
                                UserData().uid, newCategory);
                            setState(() {
                              imageUrl =
                                  null; // Clear the image URL after adding
                              nameController
                                  .clear(); // Clear the text field after adding
                              selectedType = null; // Clear the selected type
                              isLoading = false; // Reset loading
                            });

                            // Show confirmation Snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Category added successfully!',
                                    style: TextStyle(color: Colors.white)),
                                backgroundColor:
                                    Colors.blueAccent, // Set Snackbar color
                                duration: Duration(seconds: 2),
                              ),
                            );

                            fetchCategories(); // Refresh categories to reflect the new addition
                            Navigator.of(context).pop(); // Close dialog
                          } else {
                            setState(() {
                              isLoading =
                                  false; // Reset loading if inputs are invalid
                            });
                          }
                        },
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          "Add",
                          style: TextStyle(color: Color(0xFFF8E4B2)),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 15.0), // Add margin space above the AppBar
            AppBar(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
              title: Text(
                'Categories',
                style: TextStyle(
                  color: Color(0xFFF8E4B2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: const Color.fromARGB(255, 255, 255, 255)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.add_circle, color: const Color(0xFFF8E4B2)),
                  onPressed: () {
                    _showAddCategoryDialog(context); // Link to dialog
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0), // Space below the AppBar

            // Income Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Income Categories',
                style: TextStyle(
                  color: Color(0xFFF8E4B2),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: GridView.builder(
                    primary: false,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 20.0,
                    ),
                    itemCount: incomeCategories.length,
                    itemBuilder: (context, index) {
                      final category = incomeCategories[index];
                      return GestureDetector(
                        onTap: () {
                          print('Tapped on ${category.name}');
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Image.network(
                                category.imagePath,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Flexible(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0), // Space between sections

            // Expense Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Expense Categories',
                style: TextStyle(
                  color: Color(0xFFF8E4B2),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 20.0,
                    ),
                    itemCount: expenseCategories.length,
                    itemBuilder: (context, index) {
                      final category = expenseCategories[index];
                      return GestureDetector(
                        onTap: () {
                          print('Tapped on ${category.name}');
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Image.network(
                                category.imagePath,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Flexible(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
