import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/models/user_model.dart';
import 'package:learningmanagement/service/clouddinary_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final cloudinaryService = CloudinaryService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _selectedImage;
  bool _isUploadingImage = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });

      await _uploadAvatar(_selectedImage!);
    }
  }

  Future<void> _uploadAvatar(File file) async {
    setState(() => _isUploadingImage = true);

    final url = await cloudinaryService.uploadImage(file);

    if (url != null) {
      final dbRef = FirebaseDatabase.instance.ref('users/${widget.user.uid}');
      await dbRef.update({'avatarUrl': url});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật ảnh đại diện thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload ảnh thất bại")),
      );
    }

    setState(() => _isUploadingImage = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dbRef = FirebaseDatabase.instance.ref('users/${widget.user.uid}');
    await dbRef.update({
      'displayName': _nameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneController.text,
    });

    if (mounted) {
      Navigator.pop(context, true);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ---- Avatar ----
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (widget.user.avatarUrl != null
                            ? NetworkImage(widget.user.avatarUrl!)
                            : null) as ImageProvider?,
                    child: widget.user.avatarUrl == null && _selectedImage == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  if (_isUploadingImage)
                    const CircularProgressIndicator(),
                ],
              ),

              TextButton.icon(
                onPressed: _isUploadingImage ? null : _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Đổi ảnh đại diện"),
              ),

              const SizedBox(height: 24.0),

              // ---- Name ----
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
              ),

              const SizedBox(height: 16.0),

              // ---- Email ----
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập email' : null,
              ),

              const SizedBox(height: 16.0),

              // ---- Phone ----
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),

              const SizedBox(height: 32.0),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
