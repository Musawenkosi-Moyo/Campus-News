import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_news/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:campus_news/screens/admin_tabs/AdminEditDraftScreen.dart';
import 'package:campus_news/services/news_service.dart';

class AdminDraftTab extends StatefulWidget {
  const AdminDraftTab({super.key});

  @override
  State<AdminDraftTab> createState() => _AdminDraftTabState();
}

class _AdminDraftTabState extends State<AdminDraftTab> {
  bool _isSelectionMode = false;
  final Set<String> _selectedDrafts = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedDrafts.contains(id)) {
        _selectedDrafts.remove(id);
        if (_selectedDrafts.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedDrafts.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Drafts',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${_selectedDrafts.length} selected draft(s)?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey.shade700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final NewsService newsService = NewsService();
      bool allSuccess = true;
      for (String id in _selectedDrafts) {
        final success = await newsService.deleteArticle(id);
        if (!success) {
          allSuccess = false;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              allSuccess
                  ? 'Drafts deleted successfully'
                  : 'Some drafts failed to delete',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: allSuccess ? Colors.green : AppColors.error,
          ),
        );
      }

      setState(() {
        _isSelectionMode = false;
        _selectedDrafts.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          if (_isSelectionMode)
            Container(
              color: AppColors.primaryVariant.withAlpha(20),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.onBackground),
                    onPressed: () {
                      setState(() {
                        _isSelectionMode = false;
                        _selectedDrafts.clear();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDrafts.length} selected',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _selectedDrafts.isEmpty ? null : _deleteSelected,
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('articles')
            .where('isDraft', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryVariant),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading drafts',
                style: GoogleFonts.inter(color: AppColors.error),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_note_outlined,
                    size: 64,
                    color: AppColors.primaryVariant.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No drafts available',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your saved drafts will appear here.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.navUnselected,
                    ),
                  ),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['timestamp'] as Timestamp?;
            final bTime = bData['timestamp'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.onBackground.withAlpha(20),
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled Draft';

              final content =
                  data['content']
                      ?.toString()
                      .replaceAll(RegExp(r'<[^>]*>'), '')
                      .trim() ??
                  'No content available';
              final imageUrl = data['imageUrl'];
              final timestamp = data['timestamp'] as Timestamp?;

              String dateText = 'Saved just now';
              if (timestamp != null) {
                final now = DateTime.now();
                final diff = now.difference(timestamp.toDate());
                if (diff.inDays > 1) {
                  dateText = DateFormat(
                    'MMM dd, yyyy',
                  ).format(timestamp.toDate());
                } else if (diff.inDays == 1) {
                  dateText = 'Yesterday';
                } else if (diff.inHours >= 1) {
                  dateText = '${diff.inHours} hours ago';
                } else if (diff.inMinutes >= 1) {
                  dateText = '${diff.inMinutes} mins ago';
                }
              }

              final isSelected = _selectedDrafts.contains(docs[index].id);

              return InkWell(
                onLongPress: () {
                  if (!_isSelectionMode) {
                    setState(() {
                      _isSelectionMode = true;
                      _selectedDrafts.add(docs[index].id);
                    });
                  }
                },
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(docs[index].id);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminEditDraftScreen(
                          draftId: docs[index].id,
                          initialData: data,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  color: isSelected ? AppColors.primaryVariant.withAlpha(20) : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primaryVariant,
                            onChanged: (bool? value) {
                              _toggleSelection(docs[index].id);
                            },
                          ),
                        ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl != null && imageUrl.toString().isNotEmpty
                            ? (imageUrl.toString().startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 90,
                                      height: 90,
                                      color: AppColors.primaryVariant.withAlpha(30),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: 90,
                                      height: 90,
                                      color: AppColors.primaryVariant.withAlpha(30),
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: AppColors.primaryVariant.withAlpha(100),
                                      ),
                                    ),
                                  )
                                : Image.file(
                                    File(imageUrl),
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 90,
                                      height: 90,
                                      color: AppColors.primaryVariant.withAlpha(30),
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: AppColors.primaryVariant.withAlpha(100),
                                      ),
                                    ),
                                  ))
                            : Container(
                                width: 90,
                                height: 90,
                                color: AppColors.primaryVariant.withAlpha(30),
                                child: Icon(
                                  Icons.edit_document,
                                  color: AppColors.primaryVariant.withAlpha(100),
                                  size: 32,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onBackground,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!_isSelectionMode)
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AdminEditDraftScreen(
                                                draftId: docs[index].id,
                                                initialData: data,
                                              ),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            'Delete Draft',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                            'Are you sure you want to delete this draft?',
                                            style: GoogleFonts.inter(),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text(
                                                'Cancel',
                                                style: GoogleFonts.inter(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: Text(
                                                'Delete',
                                                style: GoogleFonts.inter(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final NewsService newsService =
                                            NewsService();
                                        final success = await newsService
                                            .deleteArticle(docs[index].id);
                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Draft deleted successfully',
                                                style: GoogleFonts.inter(),
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to delete draft',
                                                style: GoogleFonts.inter(),
                                              ),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: AppColors.primaryVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Edit Draft',
                                            style: GoogleFonts.inter(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Delete Draft',
                                            style: GoogleFonts.inter(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  child: Icon(
                                    Icons.more_vert,
                                    size: 20,
                                    color: colorScheme.onBackground.withAlpha(100),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            Text(
                              content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: colorScheme.onBackground.withAlpha(160),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Text(
                                  'Draft',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryVariant,
                                  ),
                                ),
                                Text(
                                  '  •  $dateText',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: colorScheme.onBackground.withAlpha(120),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
    ],
    ),
    );
  }
}
