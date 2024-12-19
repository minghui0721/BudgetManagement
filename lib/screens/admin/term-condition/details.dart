import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/models/TermAndCondition.dart';
import 'package:wise/providers/TermAndConditionProvider.dart';
import 'package:wise/repositories/TermAndConditionRepository.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/FormField.dart';

class TACDetailsScreen extends StatefulWidget {
  final TermAndCondition? tac;
  final bool isEditMode;
  final bool isCreateMode;

  const TACDetailsScreen({
    Key? key,
    this.tac,
    this.isEditMode = false,
    this.isCreateMode = false,
  }) : super(key: key);

  @override
  _TACDetailsScreenState createState() => _TACDetailsScreenState();
}

class _TACDetailsScreenState extends State<TACDetailsScreen> {
  bool isLoading = false;
  bool isEnabled = false;

  final _formKey = GlobalKey<FormState>();
  late TermAndConditionRepository termAndConditionRepository;

  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();

    termAndConditionRepository = TermAndConditionRepository();
    isEnabled = widget.isEditMode || widget.isCreateMode;

    contentController = TextEditingController();

    if (!widget.isCreateMode) {
      contentController.text = widget.tac!.content;
    } 
  }

  @override
  void dispose() {
    contentController.dispose();

    super.dispose();
  }



  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });


      try {
        String tacId;

        tacId = widget.isCreateMode
            ? FirebaseFirestore.instance.collection('TermAndCondition').doc().id
            : widget.tac!.id;

        TermAndCondition updatedTAC = TermAndCondition(
          id: tacId,
          content: contentController.text,
          createdAt:
              widget.isCreateMode ? DateTime.now() : widget.tac!.createdAt,
          updatedAt: DateTime.now(),
        );

        if (widget.isCreateMode || widget.isEditMode) {
          if (widget.isCreateMode) {
            await TermAndConditionRepository.create(updatedTAC);
          } else if (widget.isEditMode) {
            await termAndConditionRepository.update(updatedTAC);
          }
          await Provider.of<TermAndConditionProvider>(context, listen: false)
              .fetchAllTermsAndConditions();
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


  Widget _buildFormFieldSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20.0),
      const Text("TAC Info:", style: AppTheme.titleTextStyle),
      const SizedBox(height: 20.0),
      AdminTextFormField(
        controller: contentController,
        labelText: 'Content *',
        prefixIcon: const Icon(Icons.text_format),
        keyboardType: TextInputType.text,
          minLines: 5, // Set the minimum number of lines to display
  maxLines: 10, // Set the maximum number of lines (or null for unlimited)
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
            ? 'Create Term And Condition'
            : (widget.isEditMode ? 'Edit Term And Condition' : 'View Term And Condition'),
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
                    _buildFormFieldSection(),
                  ],
                ),
              ),
      ),
    );
  }
}
