import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/app.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/SpendingCategory.dart';
import 'package:wise/providers/SpendingCategoryProvider.dart';
import 'package:wise/repositories/SpendingCategoryRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/FormField.dart';
import 'package:wise/screens/admin/components/ImageSection.dart';

class SpendingCategoryDetailsScreen extends StatefulWidget {
  final SpendingCategory? category;
  final bool isEditMode;
  final bool isCreateMode;

  const SpendingCategoryDetailsScreen({
    Key? key,
    this.category,
    this.isEditMode = false,
    this.isCreateMode = false,
  }) : super(key: key);

  @override
  _SpendingCategoryDetailsScreenState createState() =>
      _SpendingCategoryDetailsScreenState();
}

class _SpendingCategoryDetailsScreenState
    extends State<SpendingCategoryDetailsScreen> {
  bool isLoading = false;
  File? categoryImage;
  bool isEnabled = false;

  final _formKey = GlobalKey<FormState>();
  late SpendingCategoryRepository spendingCategoryRepository;

  late TextEditingController categoryNameController;
  late TextEditingController categoryImageController;
  late TextEditingController categoryTypeController;

  String? selectedType; // For selecting type (income/expense)

  @override
  void initState() {
    super.initState();

    spendingCategoryRepository = SpendingCategoryRepository();
    isEnabled = widget.isEditMode || widget.isCreateMode;

    categoryNameController = TextEditingController();
    categoryImageController = TextEditingController();
    categoryTypeController = TextEditingController();
    
    if (widget.isCreateMode) {
      categoryImageController.text = App.newtWorkImageNotFound;
      selectedType = 'expense'; // Default type
    } else {
      // Initialize with existing category data
      categoryNameController.text = widget.category!.name;
      categoryImageController.text = widget.category!.imagePath;
      categoryTypeController.text = widget.category!.type;
      selectedType = widget.category!.type;
    }
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    categoryImageController.dispose();
    categoryTypeController.dispose();
    super.dispose();
  }

  void _showImageOptions(String imageType) {
    ImageHelper.showImageOptions(context, (option) {
      if (option == 'view') {
        _viewImage(imageType);
      } else if (option == 'upload') {
        ImageHelper.pickImage(context, ImageSource.gallery, (selectedImage) {
          setState(() {
            categoryImage = selectedImage;
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
      imageUrl = widget.category!.imagePath;
    }

    ImageHelper.viewImage(context, imageUrl);
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String categoryImageUrl = '';

      try {
        String categoryId;

        categoryId = widget.isCreateMode
            ? FirebaseFirestore.instance.collection('SpendingCategory').doc().id
            : widget.category!.id;

        categoryImageUrl = await ImageHelper.uploadImage(
            categoryImage, categoryImageController, 'categories/$categoryId');

        SpendingCategory updatedCategory = SpendingCategory(
          id: categoryId,
          name: categoryNameController.text,
          imagePath: categoryImageUrl,
          type: selectedType!,
          createdAt:
              widget.isCreateMode ? DateTime.now() : widget.category!.createdAt,
          updatedAt: DateTime.now(),
        );

        if (widget.isCreateMode || widget.isEditMode) {
          if (widget.isCreateMode) {
            await SpendingCategoryRepository.create(updatedCategory);
          } else if (widget.isEditMode) {
            await spendingCategoryRepository.update(updatedCategory);
          }
          await Provider.of<SpendingCategoryProvider>(context, listen: false)
              .fetchAllCategories();
        }

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
          label: 'Category Image:',
          imageFile: categoryImage,
          controller: categoryImageController,
          onTap: () => _showImageOptions('category'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFormFieldSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20.0),
      const Text("Category Info:", style: AppTheme.titleTextStyle),
      const SizedBox(height: 20.0),
      AdminTextFormField(
        controller: categoryNameController,
        labelText: 'Category Name *',
        prefixIcon: const Icon(Icons.category),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter Category Name';
          }
          return null;
        },
        isEnabled: isEnabled,
      ),
      if (!isEnabled) ...[
        const SizedBox(height: 20.0),
        AdminTextFormField(
          controller: categoryTypeController,
          labelText: 'Type*',
          prefixIcon: const Icon(Icons.type_specimen),
          isEnabled: isEnabled,
        ),
      ],
      if (isEnabled) ...[
        const SizedBox(height: 20.0),
        const Text("Type:", style: AppTheme.titleTextStyle),
        DropdownButtonFormField<String>(
          value: selectedType,
          decoration: const InputDecoration(
            filled: true,
            fillColor: AppColors.mediumGray,
          ),
          dropdownColor:
              AppColors.mediumGray, // Optional: Set dropdown background color
          style: const TextStyle(
            color: Colors.white, // Text color
          ),
          items: const [
            DropdownMenuItem(value: 'income', child: Text('Income')),
            DropdownMenuItem(value: 'expense', child: Text('Expense')),
          ],
          onChanged: isEnabled
              ? (value) {
                  setState(() {
                    selectedType = value;
                  });
                }
              : null,
          validator: (value) {
            if (value == null) {
              return 'Please select a type';
            }
            return null;
          },
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
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(
        title: widget.isCreateMode
            ? 'Create Category'
            : (widget.isEditMode ? 'Edit Category' : 'View Category'),
        showBackButton: true,
        button: widget.isEditMode || widget.isCreateMode
            ? const Icon(Icons.save)
            : null,
        onPressed:
            widget.isEditMode || widget.isCreateMode ? _saveChanges : null,
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
