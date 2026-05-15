import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cloudinary_service.dart';
import '../services/user_services.dart';

class SelectProfileImageScreen extends StatefulWidget {
  const SelectProfileImageScreen({super.key});

  @override
  State<SelectProfileImageScreen> createState() =>
      _SelectProfileImageScreenState();
}

class _SelectProfileImageScreenState extends State<SelectProfileImageScreen> {
  final userService = UserService();
  final cloudinaryService = CloudinaryService();
  final imagePicker = ImagePicker();

  bool isLoading = false;

  String selectedProfile = "https://i.pravatar.cc/300?img=1";
  String selectedBanner =
      "https://images.unsplash.com/photo-1516280440614-37939bbacd81?q=80&w=1200&auto=format&fit=crop";

  Future<void> pickAndUploadProfileImage() async {
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1000,
    );

    if (pickedImage == null) return;

    setState(() => isLoading = true);

    final uploadedUrl = await cloudinaryService.uploadImage(
      File(pickedImage.path),
    );

    if (uploadedUrl != null) {
      setState(() {
        selectedProfile = uploadedUrl;
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> pickAndUploadBannerImage() async {
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (pickedImage == null) return;

    setState(() => isLoading = true);

    final uploadedUrl = await cloudinaryService.uploadImage(
      File(pickedImage.path),
    );

    if (uploadedUrl != null) {
      setState(() {
        selectedBanner = uploadedUrl;
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> saveImages() async {
    try {
      setState(() => isLoading = true);

      await userService.updateProfileImages(
        profileImage: selectedProfile,
        bannerImage: selectedBanner,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudieron guardar las imágenes."),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Seleccionar imágenes"),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Imagen de perfil",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: CircleAvatar(
                radius: 62,
                backgroundImage: NetworkImage(selectedProfile),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : pickAndUploadProfileImage,
                icon: const Icon(Icons.upload),
                label: const Text("Subir imagen de perfil"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 34),

            const Text(
              "Banner",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: NetworkImage(selectedBanner),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : pickAndUploadBannerImage,
                icon: const Icon(Icons.upload),
                label: const Text("Subir banner"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Guardar imágenes",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}