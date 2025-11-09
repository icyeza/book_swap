import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../models/book.dart';
import '../widgets/primary_button.dart';
import '../widgets/form_label.dart';
import '../widgets/form_text_field.dart';
import '../widgets/condition_chip_selector.dart';

class PostBookPage extends StatefulWidget {
  final Book? bookToEdit;

  const PostBookPage({super.key, this.bookToEdit});

  @override
  State<PostBookPage> createState() => _PostBookPageState();
}

class _PostBookPageState extends State<PostBookPage> {
  static const Color _bg = Color(0xFF0B1026);
  static const Color _accent = Color(0xFFF1C64A);
  static const Color _cardBg = Color(0xFF1A1F3A);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  String selectedCondition = 'Like New';
  final List<String> conditions = ['New', 'Like New', 'Good', 'Used'];

  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool get _isEditMode => widget.bookToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateFieldsForEdit();
    }
  }

  void _populateFieldsForEdit() {
    final book = widget.bookToEdit!;
    _titleController.text = book.title;
    _authorController.text = book.author;
    _categoryController.text = book.category;
    _descriptionController.text = book.description ?? '';
    selectedCondition = book.condition;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: const Text(
          'Select Image Source',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: _accent),
              title: const Text(
                'Camera',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: _accent),
              title: const Text(
                'Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (authProvider.currentUser == null ||
            authProvider.userModel == null) {
          throw Exception('User not authenticated');
        }

        bool success;

        if (_isEditMode) {
          // Update existing book
          success = await bookProvider.updateBook(
            bookId: widget.bookToEdit!.id,
            title: _titleController.text.trim(),
            author: _authorController.text.trim(),
            category: _categoryController.text.trim(),
            condition: selectedCondition,
            description: _descriptionController.text.trim(),
            imageFile: _selectedImage,
          );
        } else {
          // Create new book
          success = await bookProvider.createBook(
            title: _titleController.text.trim(),
            author: _authorController.text.trim(),
            ownerId: authProvider.currentUserId!,
            ownerName: authProvider.userModel!.displayName,
            ownerEmail: authProvider.userModel!.email,
            category: _categoryController.text.trim(),
            condition: selectedCondition,
            description: _descriptionController.text.trim(),
            imageFile: _selectedImage,
          );
        }

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditMode
                      ? 'Book updated successfully!'
                      : 'Book posted successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditMode
                      ? 'Failed to update book. Please try again.'
                      : 'Failed to post book. Please try again.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Book' : 'Post a Book',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Upload Section
                const FormLabel(
                  text: 'Book Cover (Optional)',
                  isRequired: false,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _isLoading ? null : _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: _selectedImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add book cover',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Book Title
                const FormLabel(text: 'Book Title'),
                const SizedBox(height: 8),
                FormTextField(
                  controller: _titleController,
                  hintText: 'Enter book title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a book title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Author
                const FormLabel(text: 'Author'),
                const SizedBox(height: 8),
                FormTextField(
                  controller: _authorController,
                  hintText: 'Enter author name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the author name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category
                const FormLabel(text: 'Category'),
                const SizedBox(height: 8),
                FormTextField(
                  controller: _categoryController,
                  hintText: 'e.g., Data Structures, Algorithms',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description (Optional)
                const FormLabel(
                  text: 'Description (Optional)',
                  isRequired: false,
                ),
                const SizedBox(height: 8),
                FormTextField(
                  controller: _descriptionController,
                  hintText: 'Describe the book condition, notes, etc.',
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Condition
                const FormLabel(text: 'Condition'),
                const SizedBox(height: 12),
                IgnorePointer(
                  ignoring: _isLoading,
                  child: Opacity(
                    opacity: _isLoading ? 0.5 : 1.0,
                    child: ConditionChipSelector(
                      conditions: conditions,
                      selectedCondition: selectedCondition,
                      onConditionSelected: (condition) {
                        setState(() {
                          selectedCondition = condition;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Post Button
                _isLoading
                    ? Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      )
                    : PrimaryButton(
                        text: _isEditMode ? 'Update' : 'Post',
                        onPressed: _handlePost,
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

