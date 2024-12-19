import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/app.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/helper/ImageHelper.dart';
import 'package:wise/providers/NotificationProvider.dart';
import 'package:wise/repositories/NotificationRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/FormField.dart';
import 'package:wise/screens/admin/components/ImageSection.dart';
import 'package:wise/models/Notification.dart' as wise_notifications;

class NotificationDetailsScreen extends StatefulWidget {
  final wise_notifications.Notification? notification;
  final bool isEditMode;
  final bool isCreateMode;

  const NotificationDetailsScreen({
    Key? key,
    this.notification,
    this.isEditMode = false,
    this.isCreateMode = false,
  }) : super(key: key);

  @override
  _NotificationDetailsScreenState createState() =>
      _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  bool isLoading = false;
  File? image;
  bool isEnabled = false;

  final _formKey = GlobalKey<FormState>();
  late NotificationRepository notificationRepository;

  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController imagePathController;

  @override
  void initState() {
    super.initState();

    notificationRepository = NotificationRepository();
    isEnabled = widget.isEditMode || widget.isCreateMode;

    titleController = TextEditingController();
    contentController = TextEditingController();
    imagePathController = TextEditingController();

    if (widget.isCreateMode) {
      imagePathController.text = App.newtWorkImageNotFound;
    } else {
      // Initialize with existing advisor data
      titleController.text = widget.notification!.title;
      contentController.text = widget.notification!.content;
      imagePathController.text = widget.notification!.imagePath;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    imagePathController.dispose();

    super.dispose();
  }

  void _showImageOptions(String imageType) {
    ImageHelper.showImageOptions(context, (option) {
      if (option == 'view') {
        _viewImage(imageType);
      } else if (option == 'upload') {
        ImageHelper.pickImage(context, ImageSource.gallery, (selectedImage) {
          setState(() {
            image = selectedImage;
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
      imageUrl = widget.notification!.imagePath;
    }

    ImageHelper.viewImage(context, imageUrl);
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String imageUrl = '';

      try {
        String notificationId;

        notificationId = widget.isCreateMode
            ? FirebaseFirestore.instance.collection('Notification').doc().id
            : widget.notification!.id;

        imageUrl = await ImageHelper.uploadImage(
            image, imagePathController, 'notifications/$notificationId');

        wise_notifications.Notification updatedNotification =
            wise_notifications.Notification(
          id: notificationId,
          title: titleController.text,
          content: contentController.text,
          imagePath: imageUrl,
          createdAt: widget.isCreateMode
              ? DateTime.now()
              : widget.notification!.createdAt,
          updatedAt: DateTime.now(),
        );

        if (widget.isCreateMode || widget.isEditMode) {
          if (widget.isCreateMode) {
            await NotificationRepository.create(updatedNotification);
          } else if (widget.isEditMode) {
            await notificationRepository.update(updatedNotification);
          }
          await Provider.of<NotificationProvider>(context, listen: false)
              .fetchAllNotifications();
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
          label: 'Notification Image:',
          imageFile: image,
          controller: imagePathController,
          onTap: () => _showImageOptions('notification'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFormFieldSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20.0),
      const Text("Notification Info:", style: AppTheme.titleTextStyle),
      const SizedBox(height: 20.0),
      AdminTextFormField(
        controller: titleController,
        labelText: 'Title *',
        prefixIcon: const Icon(Icons.announcement),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter title';
          }
          return null;
        },
        isEnabled: isEnabled,
      ),
      const SizedBox(height: 20.0),
      AdminTextFormField(
        controller: contentController,
        labelText: 'Content *',
        prefixIcon: const Icon(Icons.description),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter content';
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
            ? 'Create Notification'
            : (widget.isEditMode ? 'Edit Notification' : 'View Notification'),
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
