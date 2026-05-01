import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campus_news/services/news_service.dart';

class AdminUploadTab extends StatefulWidget {
  const AdminUploadTab({super.key});

  @override
  State<AdminUploadTab> createState() => _AdminUploadTabState();
}

class _AdminUploadTabState extends State<AdminUploadTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final NewsService _newsService = NewsService();
  final ImagePicker _picker = ImagePicker();
  
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  FilePickerResult? _selectedPdf;
  String? _selectedCategory;
  bool _isLoading = false;

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
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress for faster upload
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _selectedPdf = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking PDF: $e')),
        );
      }
    }
  }

  void _handleSubmit({bool isDraft = false}) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      String? pdfUrl;
      if (_selectedImage != null) {
        try {
          imageUrl = await _newsService.uploadPickedImage(_selectedImage!);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.toString(),
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      if (_selectedPdf != null) {
        try {
          pdfUrl = await _newsService.uploadPickedPdf(_selectedPdf!);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.toString(),
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      final success = await _newsService.uploadArticle(
        title: _titleController.text,
        category: _selectedCategory!,
        content: _contentController.text,
        imageUrl: imageUrl,
        pdfUrl: pdfUrl,
        isDraft: isDraft,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isDraft ? 'Article saved as draft!' : 'Article published successfully!',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: isDraft ? AppColors.secondary : Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          _clearForm();
        }
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not publish article: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedImage = null;
      _selectedImageBytes = null;
      _selectedPdf = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Article',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create and publish news for the campus.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.navUnselected,
              ),
            ),
            const SizedBox(height: 28),

            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.transparent, // No fill as requested
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(120), // Blue border
                    width: 2.0,
                  ),
                  image: _selectedImageBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_selectedImageBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),

                child: _selectedImageBytes == null
                    ? Column(
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
                      )
                    : Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.all(12),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withAlpha(200),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primary),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('Article PDF (Optional)'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _pickPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: Text(
                _selectedPdf == null
                    ? 'Select PDF'
                    : _selectedPdf!.files.single.name,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withAlpha(140)),
                minimumSize: const Size(double.infinity, 52),
                alignment: Alignment.centerLeft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if (_selectedPdf != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => setState(() => _selectedPdf = null),
                icon: const Icon(Icons.close, size: 16),
                label: Text(
                  'Remove selected PDF',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
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
              style: GoogleFonts.inter(color: AppColors.onBackground, fontSize: 14),
              decoration: _inputDecoration('Select a category'),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
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
              style: GoogleFonts.inter(color: AppColors.onBackground, fontSize: 14),
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
                    onPressed: _isLoading ? null : () => _handleSubmit(isDraft: true),
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text(
                      'Save Draft',
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
                    onPressed: _isLoading ? null : () => _handleSubmit(),
                    icon: _isLoading
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
                      _isLoading ? 'Publishing...' : 'Publish Article',
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
      filled: false, // Removed color fill as requested
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

