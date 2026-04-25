import 'dart:io';
import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campus_news/services/news_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminEditDraftScreen extends StatefulWidget {
  final String draftId;
  final Map<String, dynamic> initialData;

  const AdminEditDraftScreen({
    super.key,
    required this.draftId,
    required this.initialData,
  });

  @override
  State<AdminEditDraftScreen> createState() => _AdminEditDraftScreenState();
}

class _AdminEditDraftScreenState extends State<AdminEditDraftScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final NewsService _newsService = NewsService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _selectedCategory;
  String? _existingImageUrl;
  bool _isSavingDraft = false;
  bool _isPublishing = false;

  static const List<String> _categories = [
    'Academics',
    'Sports',
    'Events',
    'Clubs',
    'Health',
    'Tech',
    'Culture',
    'General',
    'Notices',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData['title']);
    _contentController = TextEditingController(
      text: widget.initialData['content'],
    );
    _selectedCategory = widget.initialData['category'];
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = null;
    }
    _existingImageUrl = widget.initialData['imageUrl'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _handleSubmit({bool isDraft = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      if (isDraft) {
        _isSavingDraft = true;
      } else {
        _isPublishing = true;
      }
    });

    try {
      String? imageUrl = _existingImageUrl;

      if (isDraft) {
        if (_selectedImage != null) {
          imageUrl = _selectedImage!.path;
        }
      } else {
        if (_selectedImage != null) {
          imageUrl = await _newsService.uploadImage(_selectedImage!);
        } else if (imageUrl != null &&
            !imageUrl.startsWith('http') &&
            imageUrl.isNotEmpty) {
          File localFile = File(imageUrl);
          if (await localFile.exists()) {
            imageUrl = await _newsService.uploadImage(localFile);
          } else {
            imageUrl = '';
          }
        }
      }

      final success = await _newsService.updateArticle(
        id: widget.draftId,
        title: _titleController.text,
        category: _selectedCategory!,
        content: _contentController.text,
        imageUrl: imageUrl,
        isDraft: isDraft,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isDraft
                    ? 'Draft updated successfully!'
                    : 'Draft published successfully!',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: isDraft ? AppColors.secondary : Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context); // Go back to drafts list
        }
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Could not update draft'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDraft = false;
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Draft',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Article',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Update your draft and publish it.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.navUnselected,
                ),
              ),
              const SizedBox(height: 28),

              // Image Picker
              if (_selectedImage == null &&
                  (_existingImageUrl == null || _existingImageUrl!.isEmpty))
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(120),
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_rounded,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to add cover image',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PNG, JPG supported',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.navUnselected,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(50),
                          width: 1.0,
                        ),
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : DecorationImage(
                                image: _existingImageUrl!.startsWith('http')
                                    ? CachedNetworkImageProvider(
                                            _existingImageUrl!,
                                          )
                                          as ImageProvider
                                    : FileImage(File(_existingImageUrl!)),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text(
                            'Change Image',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                              _existingImageUrl = '';
                            });
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: Text(
                            'Remove Image',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // Title Field
              _buildLabel('Article Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.inter(color: AppColors.onBackground),
                decoration: _inputDecoration('Enter article title...'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              _buildLabel('Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                style: GoogleFonts.inter(
                  color: AppColors.onBackground,
                  fontSize: 14,
                ),
                decoration: _inputDecoration('Select a category'),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) =>
                    val == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 20),

              // Content Field
              _buildLabel('Article Content'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                style: GoogleFonts.inter(
                  color: AppColors.onBackground,
                  fontSize: 14,
                ),
                maxLines: 8,
                decoration: _inputDecoration('Write your article here...'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Content is required' : null,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  // Save as Draft
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (_isSavingDraft || _isPublishing)
                          ? null
                          : () => _handleSubmit(isDraft: true),
                      icon: _isSavingDraft
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: Text(
                        _isSavingDraft ? 'Saving...' : 'Update Draft',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Publish
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: (_isSavingDraft || _isPublishing)
                          ? null
                          : () => _handleSubmit(),
                      icon: _isPublishing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.publish_rounded, size: 18),
                      label: Text(
                        _isPublishing ? 'Publishing...' : 'Publish Article',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onBackground,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.navUnselected,
      ),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary.withAlpha(100)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
    );
  }
}
