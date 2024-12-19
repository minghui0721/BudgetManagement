import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/app.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/Conversation.dart';
import 'package:wise/models/User.dart';
import 'package:wise/providers/UserProvider.dart';
import 'package:wise/repositories/ConversationRepository.dart';
import 'package:wise/repositories/CountryRepository.dart';
import 'package:wise/repositories/UserRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/ConversationTab.dart';
import 'package:wise/screens/admin/components/FormField.dart';
import 'package:wise/screens/admin/components/ImageSection.dart';

class UserDetailsScreen extends StatefulWidget {
  final User? user;
  final bool isEditMode;
  final bool isCreateMode;

  const UserDetailsScreen({
    Key? key,
    this.user,
    this.isEditMode = false,
    this.isCreateMode = false,
  }) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Conversation> conversations = [];
  bool isLoading = false;
  bool _isPasswordVisible = false;
  String? _emailError;

  File? profileImage;
  bool isEnabled = false;

  final conversationRepository = ConversationRepository();
  final _formKey = GlobalKey<FormState>();
  late UserRepository userRepository;

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

  final CountryRepository countryRepository = CountryRepository();
  List<String> states = [];
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchConversations();
    userRepository = UserRepository();

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

    if (widget.isCreateMode) {
      profileImageController.text = App.newtWorkImageNotFound;
      isBan = false;
    } else {
      nameController.text = widget.user!.name;
      emailController.text = widget.user!.email;
      phoneController.text = widget.user!.phoneNumber;
      occupationController.text = widget.user!.occupation;
      ageController.text = widget.user!.age.toString();
      unitController.text = widget.user!.address.unit;
      streetController.text = widget.user!.address.street;
      cityController.text = widget.user!.address.city;
      postalCodeController.text = widget.user!.address.postalCode;
      stateController.text = widget.user!.address.state;
      profileImageController.text = widget.user!.imagePath;
      isBan = widget.user!.isBan;
    }

    _loadStates();
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
    _tabController.dispose();

    super.dispose();
  }

  Future<void> _loadStates() async {
    states = await countryRepository.getStates();
    setState(() {}); // Update the UI with the fetched states
  }

  Future<void> _loadCities(String state) async {
    cities = await countryRepository.fetchCities('Malaysia', state);
  }

  Future<void> fetchConversations() async {
    final userId = widget.user?.id;
    if (userId != null) {
      // Fetch conversations by user ID or FA ID
      conversations = await conversationRepository.fetchConversationsById(
          userId: userId, isReturnToUser: true);
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
    } else {
      imageUrl = widget.user!.imagePath;
    }

    ImageHelper.viewImage(context, imageUrl);
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String profileImageUrl = '';
      String userId = widget.isCreateMode ? '' : widget.user!.id;

      try {
        if (widget.isCreateMode) {
          firebase_auth.UserCredential userCredential = await firebase_auth
              .FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          userId = userCredential.user!.uid;
        }

        profileImageUrl = await ImageHelper.uploadImage(
            profileImage, profileImageController, 'users/$userId/profile');

        // Construct User object
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
          createdAt:
              widget.isCreateMode ? DateTime.now() : widget.user!.createdAt,
          updatedAt: DateTime.now(),
        );

        if (widget.isCreateMode || widget.isEditMode) {
          if (widget.isCreateMode) {
            await UserRepository.createUser(updatedUser);
          } else if (widget.isEditMode) {
            await userRepository.updateUser(updatedUser);
          }
          await Provider.of<UserProvider>(context, listen: false)
              .fetchAllUsers();
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
        // State dropdown with search functionality
        DropdownSearch<String>(
          selectedItem: stateController.text,
          items: (filter, infiniteScrollProps) => states,
          onChanged: (String? state) {
            setState(() {
              stateController.text = state ?? '';
              cityController.clear();
              _loadCities(state!);
            });
          },
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              labelText: 'State',
              labelStyle: const TextStyle(
                color: Colors.white, // Adjust color based on isEnabled
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              filled: true, // Match the filled background of TextFormField
              fillColor: AppColors.lightGray, // Use the same fill color
              prefixIcon: const Icon(
                Icons.map,
                color:
                    AppColors.primary, // Adjust icon color based on isEnabled
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 20.0,
              ), // Match the content padding
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: isEnabled ? AppColors.gray : AppColors.mediumGray,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(
                  color: AppColors.darkRed,
                  width: 2.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(color: AppColors.red, width: 2.0),
              ),
            ),
          ),
          popupProps: PopupProps.dialog(
            showSearchBox: true,
            fit: FlexFit.loose,
            title: Container(
              decoration: BoxDecoration(color: AppColors.primary),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Select Your State',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary),
              ),
            ),
            dialogProps: DialogProps(
              clipBehavior: Clip.antiAlias,
              shape: OutlineInputBorder(
                borderSide: BorderSide(width: 0),
                borderRadius: BorderRadius.circular(25),

              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        DropdownSearch<String>(
          selectedItem: cityController.text,
          items: (filter, infiniteScrollProps) => cities,
          onChanged: (String? city) {
            setState(() {
              cityController.text = city ?? '';
            });
          },
          decoratorProps: const DropDownDecoratorProps(
            decoration: InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.map),
              border: OutlineInputBorder(), // Add a border if needed
            ),
          ),
          popupProps: const PopupProps.dialog(
            showSearchBox: true,
            fit: FlexFit.loose,
          ),
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
            ? 'Create User'
            : (widget.isEditMode ? 'Edit User' : 'View User'),
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
                // TabBar placed directly below AppBar with no padding
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
                          isFromUser: true,
                          user: widget.user),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
