import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/app.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/Bank.dart';
import 'package:wise/providers/BankProvider.dart';
import 'package:wise/repositories/BankRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/FormField.dart';
import 'package:wise/screens/admin/components/ImageSection.dart';

class BankDetailsScreen extends StatefulWidget {
  final Bank? bank;
  final bool isEditMode;
  final bool isCreateMode;

  const BankDetailsScreen({
    Key? key,
    this.bank,
    this.isEditMode = false,
    this.isCreateMode = false,
  }) : super(key: key);

  @override
  _BankDetailsScreenState createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  bool isLoading = false;
  File? bankImage;
  bool isEnabled = false;

  final _formKey = GlobalKey<FormState>();
  late BankRepository bankRepository;

  late TextEditingController bankNameController;
  late TextEditingController bankImageController;

  @override
  void initState() {
    super.initState();

    bankRepository = BankRepository();
    isEnabled = widget.isEditMode || widget.isCreateMode;

    bankNameController = TextEditingController();
    bankImageController = TextEditingController();

    if (widget.isCreateMode) {
      bankImageController.text = App.newtWorkImageNotFound;
    } else {
      // Initialize with existing advisor data
      bankNameController.text = widget.bank!.bankName;
      bankImageController.text = widget.bank!.imagePath;
    }
  }

  @override
  void dispose() {
    bankNameController.dispose();
    bankImageController.dispose();

    super.dispose();
  }

  void _showImageOptions(String imageType) {
    ImageHelper.showImageOptions(context, (option) {
      if (option == 'view') {
        _viewImage(imageType);
      } else if (option == 'upload') {
        ImageHelper.pickImage(context, ImageSource.gallery, (selectedImage) {
          setState(() {
            bankImage = selectedImage;
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
      imageUrl = widget.bank!.imagePath;
    }

    ImageHelper.viewImage(context, imageUrl);
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String bankImageUrl = '';

      try {
        String bankId;

        bankId = widget.isCreateMode
            ? FirebaseFirestore.instance.collection('Bank').doc().id
            : widget.bank!.id;

        bankImageUrl = await ImageHelper.uploadImage(
            bankImage, bankImageController, 'banks/$bankId');

        Bank updatedBank = Bank(
          id: bankId,
          bankName: bankNameController.text,
          imagePath: bankImageUrl,
          createdAt:
              widget.isCreateMode ? DateTime.now() : widget.bank!.createdAt,
          updatedAt: DateTime.now(),
        );

        if (widget.isCreateMode || widget.isEditMode) {
          if (widget.isCreateMode) {
            await BankRepository.createBank(updatedBank);
          } else if (widget.isEditMode) {
            await bankRepository.updateBank(updatedBank);
          }
          await Provider.of<BankProvider>(context, listen: false)
              .fetchAllBanks();
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
          label: 'Bank Image:',
          imageFile: bankImage,
          controller: bankImageController,
          onTap: () => _showImageOptions('bank'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFormFieldSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20.0),
      const Text("Bank Info:", style: AppTheme.titleTextStyle),
      const SizedBox(height: 20.0),
      AdminTextFormField(
        controller: bankNameController,
        labelText: 'Bank Name *',
        prefixIcon: const Icon(Icons.money),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter Bank Name';
          }
          return null;
        },
        isEnabled: isEnabled,
      ),
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
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(
        title: widget.isCreateMode
            ? 'Create Bank'
            : (widget.isEditMode ? 'Edit Bank' : 'View Bank'),
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
