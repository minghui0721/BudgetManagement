import 'package:flutter/material.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController =
      TextEditingController(text: UserData().fullName);
  final TextEditingController emailController =
      TextEditingController(text: UserData().email);
  final TextEditingController cityController =
      TextEditingController(text: UserData().city);
  final TextEditingController postalCodeController =
      TextEditingController(text: UserData().postalCode);
  final TextEditingController stateController =
      TextEditingController(text: UserData().state);
  final TextEditingController streetController =
      TextEditingController(text: UserData().street);
  final TextEditingController unitController =
      TextEditingController(text: UserData().unit);
  final TextEditingController ageController = TextEditingController(
    text: UserData().age.toString() == '0' ? '' : UserData().age.toString(),
  );
  final TextEditingController occupationController =
      TextEditingController(text: UserData().occupation);
  final TextEditingController phoneNumberController =
      TextEditingController(text: UserData().phoneNumber);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      resizeToAvoidBottomInset: true,
      body: Scrollbar(
        // Wrap the SingleChildScrollView with Scrollbar
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15.0), // Space above the AppBar
              AppBar(
                backgroundColor: const Color(0xFF1E1E1E),
                elevation: 0,
                title: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Color(0xFFF8E4B2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Color.fromARGB(255, 255, 255, 255)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              // Container to hold everything below the AppBar with padding
              Container(
                padding: const EdgeInsets.all(
                    20.0), // Padding for the entire content below AppBar
                child: Column(
                  children: [
                    // Profile Image and Edit Picture Button
                    Column(
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage: UserData().imagePath.isNotEmpty
                                ? NetworkImage(UserData().imagePath)
                                : NetworkImage(UserData().defaultImagePath),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        TextButton(
                          onPressed: () {
                            // Handle change profile picture
                          },
                          child: const Text(
                            "Edit picture",
                            style: TextStyle(
                              color: Color(0xFF4D81E7),
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF4D81E7)),
                    const SizedBox(height: 20.0),

                    // Personal Information Section
                    _buildSectionTitle('Personal Information'),
                    _buildTextField(nameController, 'Name'),
                    _buildTextField(emailController, 'Email address'),

                    const SizedBox(height: 20.0), // Space between sections

                    // Address Section
                    _buildSectionTitle('Address'),
                    _buildAddressFields(), // Updated address layout

                    const SizedBox(height: 20.0), // Space between sections

                    // Additional Information Section
                    _buildSectionTitle('Additional Information'),
                    _buildTextField(ageController, 'Age'),
                    _buildTextField(occupationController, 'Occupation'),
                    _buildTextField(phoneNumberController, 'Phone Number'),

                    const SizedBox(
                        height: 30.0), // Space before Change Password Button

                    // Change Password Label
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          color: Color(0xFFF8E4B2), // Label color
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 8.0), // Space between the label and the button

                    // Change Password Button
                    GestureDetector(
                      onTap: () {
                        // Handle change password
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                color: Color(0xFF4D81E7),
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30.0), // Space before Save Changes Button

                    // Save Changes Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D81E7),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Changes"),
                              content: const Text(
                                  "Are you sure you want to save the changes?"),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                                TextButton(
                                  child: const Text("Confirm"),
                                  onPressed: () async {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                    // Handle save changes
                                    String uid = UserData()
                                        .uid; // Assuming uid is stored in UserData
                                    String fullName = nameController.text;
                                    String email = emailController.text;
                                    String city = cityController.text;
                                    String postalCode =
                                        postalCodeController.text;
                                    String state = stateController.text;
                                    String street = streetController.text;
                                    String unit = unitController.text;
                                    // Convert age to int; default to 0 if empty
                                    int age = ageController.text.isEmpty
                                        ? 0
                                        : int.parse(ageController.text);
                                    String occupation =
                                        occupationController.text;
                                    String phoneNumber =
                                        phoneNumberController.text;

                                    // Update Firestore Users collection
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(uid)
                                          .update({
                                        'fullName': fullName,
                                        'email': email,
                                        'address': {
                                          'city': city,
                                          'postalCode': postalCode,
                                          'state': state,
                                          'street': street,
                                          'unit': unit,
                                        },
                                        'age': age,
                                        'occupation': occupation,
                                        'phoneNumber': phoneNumber,
                                      });

                                      // Refresh the user data after updating
                                      UserData().retrieveLoginUser(uid);

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Success"),
                                            content: const Text(
                                                "Your profile has been updated successfully."),
                                            actions: [
                                              TextButton(
                                                child: const Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                  // Navigate back to ProfilePage and remove previous routes
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } catch (e) {
                                      // Handle any errors that occur during the update
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Failed to update profile: $e")),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        "SAVE CHANGES",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFF8E4B2),
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Space between text fields
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4D81E7)),
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildAddressFields() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildTextField(unitController, 'Unit'),
            ),
            const SizedBox(width: 10.0), // Space between fields
            Expanded(
              child: _buildTextField(postalCodeController, 'Postal Code'),
            ),
          ],
        ),
        const SizedBox(height: 10.0), // Space between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildTextField(cityController, 'City'),
            ),
            const SizedBox(width: 10.0), // Space between fields
            Expanded(
              child: _buildTextField(stateController, 'State'),
            ),
          ],
        ),
        const SizedBox(height: 10.0), // Space between rows
        Row(
          children: [
            Expanded(
              child: _buildTextField(streetController, 'Street'),
            ),
          ],
        ),
      ],
    );
  }
}
