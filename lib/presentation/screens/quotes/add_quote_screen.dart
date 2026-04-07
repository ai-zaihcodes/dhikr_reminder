import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../blocs/quote/quote_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class AddQuoteScreen extends StatefulWidget {
  const AddQuoteScreen({super.key});

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _translationController = TextEditingController();
  final _sourceController = TextEditingController();
  String _selectedCategory = 'general';

  final List<String> _categories = [
    'morning',
    'evening',
    'general',
    'forgiveness',
    'gratitude',
    'protection',
    'custom',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _translationController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<QuoteBloc>().add(QuoteCreated(
            text: _textController.text.trim(),
            translation: _translationController.text.trim().isEmpty
                ? null
                : _translationController.text.trim(),
            category: _selectedCategory,
            source: _sourceController.text.trim().isEmpty
                ? null
                : _sourceController.text.trim(),
          ));

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quote added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Quote'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category[0].toUpperCase() + category.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 16.h),
                // Text field
                AppTextField(
                  controller: _textController,
                  label: 'Dhikr Text',
                  hint: 'Enter the Arabic text',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the dhikr text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                // Translation field
                AppTextField(
                  controller: _translationController,
                  label: 'Translation (Optional)',
                  hint: 'Enter the translation',
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),
                // Source field
                AppTextField(
                  controller: _sourceController,
                  label: 'Source (Optional)',
                  hint: 'e.g., Sahih Bukhari',
                ),
                SizedBox(height: 32.h),
                // Save button
                AppButton(
                  text: 'Save Quote',
                  onPressed: _onSavePressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
