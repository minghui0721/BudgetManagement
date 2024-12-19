import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/app.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/helper/DateTimeHelper.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/models/Advertisement.dart';
import 'package:wise/providers/AdvertismentProvider.dart';
import 'package:wise/repositories/AdvertisementRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/FormField.dart';
import 'package:wise/screens/admin/components/ImageSection.dart';

class AdvertisementDetailsScreen extends StatefulWidget {
  final Advertisement? advertisement;
  final bool isEditMode;
  final bool isCreateMode;

  const AdvertisementDetailsScreen({
    Key? key,
    this.advertisement,
    this.isEditMode = false,
    this.isCreateMode = false,
  }) : super(key: key);

  @override
  _AdvertisementDetailsScreenState createState() =>
      _AdvertisementDetailsScreenState();
}

class _AdvertisementDetailsScreenState
    extends State<AdvertisementDetailsScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool isEnabled = false;

  late TextEditingController titleController;
  late TextEditingController merchantNameController;
  late DateTime startAt;
  late DateTime endAt;
  late AdvertisementRepository advertisementRepository;

  List<File?> imageFiles = [null, null, null]; // Holds up to 3 images
  List<TextEditingController> imageControllers = [];

  @override
  void initState() {
    super.initState();

    advertisementRepository = AdvertisementRepository();
    titleController = TextEditingController();
    merchantNameController = TextEditingController();
    isEnabled = widget.isEditMode || widget.isCreateMode;

    if (widget.isCreateMode) {
      startAt = DateTime.now();
      endAt = DateTime.now().add(Duration(days: 1)); // Set end date to tomorrow
      // Initialize imageControllers with default image placeholder
      imageControllers = List.generate(
          3, (_) => TextEditingController(text: App.newtWorkImageNotFound));
    } else {
      titleController.text = widget.advertisement!.adsTitle;
      merchantNameController.text = widget.advertisement!.merchantName;
      startAt = widget.advertisement!.startAt;
      endAt = widget.advertisement!.endAt;

      // Initialize with existing images or default placeholders
      imageControllers = List.generate(
        3,
        (i) => TextEditingController(
          text: i < widget.advertisement!.images.length
              ? widget.advertisement!.images[i]
              : App.newtWorkImageNotFound,
        ),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    merchantNameController.dispose();
    imageControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

void _showDatePicker(BuildContext context, bool isStartDate) async {
  DateTime? pickedDate = await DateTimeHelper.pickDate(
    context,
    isStartDate ? startAt : endAt,
  );

  if (pickedDate != null) {
    setState(() {
      if (isStartDate) {
        startAt = pickedDate;
      } else {
        // Validate the end date
        if (pickedDate.isBefore(DateTime.now())) {
          // Show an error message if the selected date is today or in the past
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End date cannot be today or in the past.'),
            ),
          );
        } else {
          endAt = pickedDate;
        }
      }
    });
  }
}



  void _showImageOptions(int index) {
    ImageHelper.showImageOptions(context, (option) {
      if (option == 'view') {
        _viewImage(index);
      } else if (option == 'upload') {
        ImageHelper.pickImage(context, ImageSource.gallery, (selectedImage) {
          setState(() {
            imageFiles[index] = selectedImage;
          });
        });
      }
    });
  }

  void _viewImage(int index) {
    String imageUrl;

    if (widget.isCreateMode ||
        imageControllers[index].text == App.newtWorkImageNotFound) {
      imageUrl = App.newtWorkImageNotFound;
    } else {
      imageUrl = imageControllers[index].text;
    }

    ImageHelper.viewImage(context, imageUrl);
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        String id;

        id = widget.isCreateMode
            ? FirebaseFirestore.instance.collection('Advertisement').doc().id
            : widget.advertisement!.id;

        List<String> uploadedImageUrls = [];
        for (int i = 0; i < 3; i++) {
          if (imageFiles[i] != null) {
            uploadedImageUrls.add(await ImageHelper.uploadImage(
                imageFiles[i], imageControllers[i], 'advertisements/$id'));
          } else {
            uploadedImageUrls.add(imageControllers[i].text);
          }
        }

        // Create or update Advertisement
        Advertisement newAd = Advertisement(
          id: id,
          merchantName: merchantNameController.text,
          adsTitle: titleController.text,
          images: uploadedImageUrls,
          startAt: startAt,
          endAt: endAt,
          createdAt: widget.isCreateMode
              ? DateTime.now()
              : widget.advertisement!.createdAt,
          updatedAt: DateTime.now(),
        );

        if (widget.isCreateMode || widget.isEditMode) {
          if (widget.isCreateMode) {
            await AdvertisementRepository.create(newAd);
          } else {
            await advertisementRepository.update(newAd);
          }
          await Provider.of<AdvertisementProvider>(context, listen: false)
              .fetchAllAdvertisments();
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
        for (int i = 0; i < 3; i++) ...[
          ImageSection(
            label: 'Image ${i + 1}:',
            imageFile: imageFiles[i],
            controller: imageControllers[i],
            onTap: () => _showImageOptions(i),
          ),
          if (i < 2) const SizedBox(height: 20), // Add space between sections
        ],
      ],
    );
  }

  Widget _buildFormFieldSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20.0),
      const Text("Bank Info:", style: AppTheme.titleTextStyle),
      const SizedBox(height: 20.0),
      AdminTextFormField(
        controller: merchantNameController,
        labelText: 'Merchant Name *',
        prefixIcon: const Icon(Icons.store),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter Merchant Name';
          }
          return null;
        },
        isEnabled: isEnabled,
      ),
      const SizedBox(height: 20.0),
      AdminTextFormField(
        controller: titleController,
        labelText: 'Advertisement Title *',
        prefixIcon: const Icon(Icons.title),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter Advertisement Title';
          }
          return null;
        },
        isEnabled: isEnabled,
      ),
      const SizedBox(height: 20.0),
      const Text("Start Date:", style: AppTheme.titleTextStyle),
      isEnabled
          ? TextButton(
              onPressed: () =>
                  _showDatePicker(context, true), // true for start date
              child: Text(DateTimeHelper.formatDate(startAt)),
            )
          : Text(DateTimeHelper.formatDate(startAt),
              style: AppTheme.dateTimeStyle), // Display the date as plain text
      const SizedBox(height: 20.0),
      const Text("End Date:", style: AppTheme.titleTextStyle),
      isEnabled
          ? TextButton(
              onPressed: () =>
                  _showDatePicker(context, false), // false for end date
              child: Text(DateTimeHelper.formatDate(endAt)),
            )
          : Text(DateTimeHelper.formatDate(endAt),
              style: AppTheme.dateTimeStyle), // Display the date as plain text
      const SizedBox(height: 20.0),

      if (isEnabled) ...[
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
            ? 'Create Advertisement'
            : (widget.isEditMode ? 'Edit Advertisement' : 'View Advertisement'),
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
