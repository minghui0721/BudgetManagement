import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/app.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/Conversation.dart';
import 'package:wise/models/FinancialAdvisor.dart';
import 'package:wise/models/User.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/repositories/ConversationRepository.dart';
import 'package:wise/repositories/UserRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/ConversationTab.dart';
import 'package:wise/screens/admin/components/FormField.dart';
import 'package:wise/screens/admin/components/ImageSection.dart';
import 'package:wise/repositories/FinancialAdvisorRepository.dart';

class FinancialAdvisorDetailsScreen extends StatefulWidget {
  final FinancialAdvisor? advisor;
  final bool isEditMode;
  final bool isCreateMode;

  const FinancialAdvisorDetailsScreen({
    Key? key,
    this.advisor,
    this.isEditMode = false,
    this.isCreateMode = false,
  }) : super(key: key);

  @override
  _FinancialAdvisorDetailsScreenState createState() =>
      _FinancialAdvisorDetailsScreenState();
}

class _FinancialAdvisorDetailsScreenState
    extends State<FinancialAdvisorDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Conversation> conversations = [];
  bool isLoading = false;
  bool _isPasswordVisible = false;
  String? _emailError;

  File? profileImage;
  File? icImageFront;
  File? icImageBack;
  bool isEnabled = false;

  final conversationRepository = ConversationRepository();

  final _formKey = GlobalKey<FormState>();
  late FinancialAdvisorRepository financialAdvisorRepository;

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
  late TextEditingController icImageFrontController;
  late TextEditingController icImageBackController;
  late TextEditingController rejectReasonController;
  late bool isBan;
  late bool isVerified;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchConversations();

    isEnabled = widget.isEditMode || widget.isCreateMode;
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
    icImageFrontController = TextEditingController();
    icImageBackController = TextEditingController();
    rejectReasonController = TextEditingController();

    if (widget.isCreateMode) {
      profileImageController.text = App.newtWorkImageNotFound;
      icImageFrontController.text = App.newtWorkImageNotFound;
      icImageBackController.text = App.newtWorkImageNotFound;
      isBan = false;
      isVerified = true;
    } else {
      nameController.text = widget.advisor!.user.name;
      emailController.text = widget.advisor!.user.email;
      phoneController.text = widget.advisor!.user.phoneNumber;
      occupationController.text = widget.advisor!.user.occupation;
      ageController.text = widget.advisor!.user.age.toString();
      unitController.text = widget.advisor!.user.address.unit;
      streetController.text = widget.advisor!.user.address.street;
      cityController.text = widget.advisor!.user.address.city;
      postalCodeController.text = widget.advisor!.user.address.postalCode;
      stateController.text = widget.advisor!.user.address.state;
      profileImageController.text = widget.advisor!.user.imagePath;
      icImageFrontController.text = widget.advisor!.icImageFront;
      icImageBackController.text = widget.advisor!.icImageBack;
      rejectReasonController.text = widget.advisor!.rejectReason;
      isBan = widget.advisor!.user.isBan;
      isVerified = widget.advisor!.isVerified;
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
    rejectReasonController.dispose();
    profileImageController.dispose();
    icImageFrontController.dispose();
    icImageBackController.dispose();
    _tabController.dispose();

    super.dispose();
  }

  Future<void> fetchConversations() async {
    final faId = widget.advisor?.id;
    if (faId != null) {
      conversations = await conversationRepository.fetchConversationsById(
          faId: faId, isReturnToUser: false);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showImageOptions(String imageType) {
    ImageHelper.showImageOptions(context, (option) {
      if (option == 'view') {
        _viewImage(imageType);
      } else if (option == 'upload') {
        ImageHelper.pickImage(context, ImageSource.gallery, (selectedImage) {
          setState(() {
            if (imageType == 'profile') {
              profileImage = selectedImage;
            } else if (imageType == 'icFront') {
              icImageFront = selectedImage;
            } else if (imageType == 'icBack') {
              icImageBack = selectedImage;
            }
          });
        });
      }
    });
  }

  void _viewImage(String imageType) {
    String imageUrl;

    if (widget.isCreateMode) {
      imageUrl = App.newtWorkImageNotFound;
    } else if (imageType == 'profile') {
      imageUrl = widget.advisor!.user.imagePath;
    } else if (imageType == 'icFront') {
      imageUrl = widget.advisor!.icImageFront;
    } else {
      imageUrl = widget.advisor!.icImageBack;
    }
    ImageHelper.viewImage(context, imageUrl);
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String profileImageUrl = '';
      String icImageFrontUrl = '';
      String icImageBackUrl = '';
      String userId = widget.isCreateMode ? '' : widget.advisor!.user.id;

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

        icImageFrontUrl = await ImageHelper.uploadImage(
            icImageFront, icImageFrontController, 'users/$userId/icFront');

        icImageBackUrl = await ImageHelper.uploadImage(
            icImageBack, icImageBackController, 'users/$userId/icBack');

        User updatedUser = User(
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
          createdAt: widget.isCreateMode
              ? DateTime.now()
              : widget.advisor!.user.createdAt,
          updatedAt: DateTime.now(),
        );

        FinancialAdvisor updatedAdvisor = FinancialAdvisor(
          id: widget.isCreateMode ? '' : widget.advisor!.id,
          user: updatedUser,
          isVerified: isVerified,
          rejectReason: isVerified ? '' : rejectReasonController.text,
          icImageFront: icImageFrontUrl,
          icImageBack: icImageBackUrl,
        );

        if (widget.isCreateMode || widget.isEditMode) {
          if (widget.isCreateMode) {
            await UserRepository.createUser(updatedUser);
            await financialAdvisorRepository
                .createFinancialAdvisor(updatedAdvisor);
          } else if (widget.isEditMode) {
            await financialAdvisorRepository
                .updateFinancialAdvisor(updatedAdvisor);
          }
          await Provider.of<FinancialAdvisorProvider>(context, listen: false)
              .fetchAllFinancialAdvisors();
        }

        // Show success feedback
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
        const SizedBox(height: 20),
        ImageSection(
          label: 'IC Front:',
          imageFile: icImageFront,
          controller: icImageFrontController,
          onTap: () => _showImageOptions('icFront'),
        ),
        const SizedBox(height: 20),
        ImageSection(
          label: 'IC Back:',
          imageFile: icImageBack,
          controller: icImageBackController,
          onTap: () => _showImageOptions('icBack'),
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
          isEnabled: isEnabled,
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
          isEnabled: isEnabled,
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
          isEnabled: isEnabled,
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
            isEnabled: isEnabled,
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
          )
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
          isEnabled: isEnabled,
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: occupationController,
          labelText: 'Occupation',
          prefixIcon: const Icon(Icons.work),
          keyboardType: TextInputType.text,
          isEnabled: isEnabled,
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
          isEnabled: isEnabled,
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: streetController,
          labelText: 'Street',
          prefixIcon: const Icon(Icons.numbers),
          isEnabled: isEnabled,
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: cityController,
          labelText: 'City',
          prefixIcon: const Icon(Icons.location_city),
          isEnabled: isEnabled,
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
          isEnabled: isEnabled,
        ),
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: stateController,
          labelText: 'State',
          prefixIcon: const Icon(Icons.map),
          isEnabled: isEnabled,
        ),
        const SizedBox(height: 20.0),
        if (widget.isEditMode || !widget.isCreateMode) ...[
          const Text(
            "Validation: ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          CheckboxListTile(
            title: const Text(
              'Is Banned?',
              style: TextStyle(
                color: AppColors.primary,
              ),
            ),
            value: isBan,
            onChanged: widget.isEditMode
                ? (value) {
                    setState(() {
                      isBan = value!;
                    });
                  }
                : null,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            checkColor: AppColors.secondary,
          ),
          CheckboxListTile(
            title: const Text(
              'Is Verified?',
              style: TextStyle(
                color: AppColors.primary,
              ),
            ),
            value: isVerified,
            onChanged: widget.isEditMode
                ? (value) {
                    setState(() {
                      isVerified = value!;
                    });
                  }
                : null,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            checkColor: isEnabled ? AppColors.secondary : AppColors.primary,
          ),
          const SizedBox(height: 20.0),
          if (widget.isEditMode) ...[
            AdminTextFormField(
              controller: rejectReasonController,
              labelText: 'Reject Reason',
              validator: (value) {
                if (!isVerified && (value == null || value.isEmpty)) {
                  return 'Reject Reason is compulsory if not verified';
                }
                return null;
              },
            ),
            const Text(
              "Leave it blank if verified",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ],
        if (isEnabled) ...[
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(
        title: widget.isCreateMode
            ? 'Create Financial Advisor'
            : (widget.isEditMode
                ? 'Edit Financial Advisor'
                : 'View Financial Advisor'),
        showBackButton: true,
        button: widget.isEditMode || widget.isCreateMode
            ? const Icon(Icons.save)
            : null,
        onPressed:
            widget.isEditMode || widget.isCreateMode ? _saveChanges : null,
      ),
      backgroundColor: AppColors.mediumGray,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  unselectedLabelColor: AppColors.gray,
                  tabs: [
                    const Tab(text: 'Basic Info'),
                    Tab(
                        text:
                            'Conversation (${conversations.length})'), // Remove 'const' here
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Content for Tab 1 with padding
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom:
                                16.0), // Padding for the content (left, right, bottom)
                        child: Form(
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
                      // Conversation Tab - Embedding ConversationScreen
                      ConversationTab(
                          conversations: conversations,
                          isFromUser: false,
                          advisor: widget.advisor),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
