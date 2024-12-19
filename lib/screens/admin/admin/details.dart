import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wise/config/app.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/Admin.dart';
import 'package:wise/models/User.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/repositories/AdminRepository.dart';
import 'package:wise/repositories/UserRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/FormField.dart';
import 'package:wise/screens/admin/components/ImageSection.dart';

class AdminDetailsScreen extends StatefulWidget {
  final bool isCreateMode;

  const AdminDetailsScreen({Key? key, required this.isCreateMode})
      : super(key: key);

  @override
  _AdminDetailsScreenState createState() => _AdminDetailsScreenState();
}

class _AdminDetailsScreenState extends State<AdminDetailsScreen> {
  bool isLoading = false;
  bool _isPasswordVisible = false;
  String? _emailError;

  File? profileImage;

  final _formKey = GlobalKey<FormState>();
  late AdminRepository adminRepository;
  final userRepository = UserRepository();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController occupationController;
  late TextEditingController ageController;
  late TextEditingController unitController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController postalCodeController;
  late TextEditingController stateController;
  late TextEditingController profileImageController;
  late bool isBan;

  @override
  void initState() {
    super.initState();
    adminRepository = AdminRepository();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    occupationController = TextEditingController();
    ageController = TextEditingController();
    unitController = TextEditingController();
    streetController = TextEditingController();
    cityController = TextEditingController();
    postalCodeController = TextEditingController();
    stateController = TextEditingController();
    profileImageController = TextEditingController();

    if (widget.isCreateMode) {
      profileImageController.text = App.newtWorkImageNotFound;
      isBan = false;
    } else {
      nameController.text = UserData().fullName;
      emailController.text = UserData().email;
      phoneController.text = UserData().phoneNumber;
      occupationController.text = UserData().occupation;
      ageController.text = UserData().age.toString();
      unitController.text = UserData().unit;
      streetController.text = UserData().street;
      cityController.text = UserData().city;
      postalCodeController.text = UserData().postalCode;
      stateController.text = UserData().state;
      profileImageController.text = UserData().imagePath;
      isBan = UserData().isBan;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    occupationController.dispose();
    ageController.dispose();
    unitController.dispose();
    streetController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    stateController.dispose();
    profileImageController.dispose();
    super.dispose();
  }

  void _showImageOptions(String imageType) {
    ImageHelper.showImageOptions(context, (option) {
      if (option == 'view') {
        _viewImage(imageType);
      } else if (option == 'upload') {
        ImageHelper.pickImage(context, ImageSource.gallery, (selectedImage) {
          setState(() {
            profileImage = selectedImage;
          });
        });
      }
    });
  }

  void _viewImage(String imageType) {
    String imageUrl;

    imageUrl = App.newtWorkImageNotFound;

    ImageHelper.viewImage(context, imageUrl);
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String profileImageUrl = '';
      String userId = widget.isCreateMode ? '' : UserData().uid;

      if (widget.isCreateMode) {
        firebase_auth.UserCredential userCredential = await firebase_auth
            .FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        userId = userCredential.user!.uid;
      }

      try {
        profileImageUrl = await ImageHelper.uploadImage(
            profileImage, profileImageController, 'users/$userId/profile');

        User user = User(
          id: userId,
          name: nameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
          occupation: occupationController.text,
          imagePath: profileImageUrl,
          age: int.parse(ageController.text),
          isBan: isBan,
          address: Address(
            unit: unitController.text,
            street: streetController.text,
            city: cityController.text,
            postalCode: postalCodeController.text,
            state: stateController.text,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        Admin admin = Admin(
          id: '',
          user: user,
        );
        if (widget.isCreateMode) {
          await UserRepository.createUser(user);
          await adminRepository.create(admin);
        } else {
          await userRepository.updateUser(user);
        }

        UserData().retrieveLoginUser(userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully saved changes!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong!')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        ImageSection(
          label: 'Profile Image:',
          imageFile: profileImage,
          controller: profileImageController,
          onTap: () => _showImageOptions('profile'),
        ),
      ],
    );
  }

  Widget _buildFormFieldSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0),
        const Text("Basic Info:", style: AppTheme.titleTextStyle),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: nameController,
          labelText: 'Name *',
          prefixIcon: const Icon(Icons.person),
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Name';
            }
            return null;
          },
          isEnabled: true,
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: emailController,
          labelText: 'Email *',
          prefixIcon: const Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Email';
            }
            final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );
            if (!emailRegex.hasMatch(value)) {
              return 'Please enter a valid Email format';
            }
            if (_emailError != null) {
              return _emailError;
            }
            return null;
          },
          onChanged: (value) async {
            if (value.isNotEmpty && value.contains('@')) {
              bool exists = await UserRepository().emailExists(value);
              setState(() {
                _emailError = exists ? 'Email already exists' : null;
              });
            }
          },
          isEnabled: widget.isCreateMode,
        ),
        if (_emailError != null) ...[
          Text(
            _emailError!,
            style: const TextStyle(color: Colors.red),
          ),
        ],
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: phoneController,
          labelText: 'Phone Number *',
          prefixIcon: const Icon(Icons.phone),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Phone Number';
            }
            if (!value.startsWith('+')) {
              return 'Phone Number must start with +';
            }
            return null;
          },
          isEnabled: true,
        ),
        const Text(
          "e.g. +60107447262",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        if (widget.isCreateMode) ...[
          const SizedBox(height: 20.0),
          AdminTextFormField(
            controller: passwordController,
            labelText: 'Password *',
            prefixIcon: const Icon(Icons.password),
            keyboardType: TextInputType.text,
            isEnabled: true,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: ageController,
          labelText: 'Age *',
          prefixIcon: const Icon(Icons.calendar_today),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter age';
            }

            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }

            return null;
          },
          isEnabled: true,
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: occupationController,
          labelText: 'Occupation',
          prefixIcon: const Icon(Icons.work),
          keyboardType: TextInputType.text,
          isEnabled: true,
        ),
        const SizedBox(height: 20.0),
        const Text(
          "Address Info:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: unitController,
          labelText: 'Unit',
          prefixIcon: const Icon(Icons.home),
          isEnabled: true,
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: streetController,
          labelText: 'Street',
          prefixIcon: const Icon(Icons.numbers),
          isEnabled: true,
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: cityController,
          labelText: 'City',
          prefixIcon: const Icon(Icons.location_city),
          isEnabled: true,
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: postalCodeController,
          labelText: 'Postal Code',
          prefixIcon: const Icon(Icons.code),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (int.tryParse(value) == null) {
                return 'Please enter a valid postal code';
              }
            }
            return null;
          },
          isEnabled: true,
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: stateController,
          labelText: 'State',
          prefixIcon: const Icon(Icons.map),
          isEnabled: true,
        ),
        const SizedBox(height: 20.0),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightGray,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(
        title: widget.isCreateMode ? 'Create Admin' : 'Edit Admin',
        showBackButton: true,
        button: const Icon(Icons.save),
        onPressed: _saveChanges,
      ),
      backgroundColor: AppColors.mediumGray,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 5.0),
                    _buildImageSection(),
                    _buildFormFieldSection(),
                  ],
                ),
              ),
      ),
    );
  }
}
