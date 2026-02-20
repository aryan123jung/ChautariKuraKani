import 'dart:io';

import 'package:chautari_kurakani/features/addPost/data/post_remote_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key, this.popOnSuccess = false});
  final bool popOnSuccess;

  @override
  ConsumerState<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedMedia;
  String? _selectedMediaType; // image | video
  bool _isPosting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1500,
    );
    if (pickedFile == null) return;

    setState(() {
      _selectedMedia = File(pickedFile.path);
      _selectedMediaType = "image";
    });
  }

  Future<void> _pickVideo(ImageSource source) async {
    final XFile? pickedFile = await _imagePicker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 2),
    );
    if (pickedFile == null) return;

    setState(() {
      _selectedMedia = File(pickedFile.path);
      _selectedMediaType = "video";
    });
  }

  Future<void> _handlePost() async {
    if (!_formKey.currentState!.validate()) return;

    final caption = _captionController.text.trim();
    final hasCaption = caption.isNotEmpty;
    final hasMedia = _selectedMedia != null;

    if (!hasCaption && !hasMedia) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add a caption, an image, or both.")),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      await ref
          .read(postRemoteServiceProvider)
          .createPost(caption: caption, mediaFile: _selectedMedia);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPosting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create post: $e")));
      return;
    }

    if (!mounted) return;

    setState(() {
      _isPosting = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Post created successfully.")));
    if (widget.popOnSuccess) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _captionController.clear();
      _selectedMedia = null;
      _selectedMediaType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        backgroundColor: const Color(0XFF76C05D),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Share something new",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0XFF76C05D)),
                  ),
                  child: _selectedMedia == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.perm_media_outlined, size: 44),
                            SizedBox(height: 8),
                            Text("No media selected"),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: _selectedMediaType == "video"
                              ? Container(
                                  color: Colors.black87,
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white,
                                          size: 56,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Video selected",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Image.file(_selectedMedia!, fit: BoxFit.cover),
                        ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text("Image"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickVideo(ImageSource.gallery),
                        icon: const Icon(Icons.video_library_outlined),
                        label: const Text("Video"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text("Camera"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _captionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Caption",
                    hintText: "Write something...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (_) => null,
                ),
                const SizedBox(height: 14),
                // DropdownButtonFormField<String>(
                //   value: _visibility,
                //   decoration: InputDecoration(
                //     labelText: "Visibility",
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                //   items: const [
                //     DropdownMenuItem(value: "Public", child: Text("Public")),
                //     DropdownMenuItem(value: "Friends", child: Text("Friends")),
                //     DropdownMenuItem(value: "Private", child: Text("Private")),
                //   ],
                //   onChanged: (value) {
                //     if (value == null) return;
                //     setState(() {
                //       _visibility = value;
                //     });
                //   },
                // ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isPosting ? null : _handlePost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0XFF76C05D),
                          foregroundColor: Colors.white,
                        ),
                        child: _isPosting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Post"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
