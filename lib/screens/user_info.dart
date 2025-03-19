import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  UserModel? userModel;
  String? _profileImagePath;
  String? _idCardImagePath;
  String? _driverLicenseImagePath;
  bool isLoading = false;

  final Color primaryColor = Colors.blue; // Đồng bộ với các màn hình khác

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (snapshot.exists) {
        setState(() {
          _profileImagePath = snapshot.data()?['profileImage'];
          _idCardImagePath = snapshot.data()?['idCardImagePath'];
          _driverLicenseImagePath = snapshot.data()?['driverLicenseImagePath'];
        });
      }

      final user = await getUserByUid(userId);
      if (user != null) {
        setState(() {
          userModel = user;
          isLoading = false;
        });
      }
    }
    setState(() => isLoading = false);
  }

  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<void> _pickAndSaveImage(String type) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      String path = pickedFile.path;
      String field = type == 'profile'
          ? 'profileImage'
          : type == 'idCard'
          ? 'idCardImagePath'
          : 'driverLicenseImagePath';

      await FirebaseFirestore.instance.collection('users').doc(userId).update({field: path});

      setState(() {
        if (type == 'profile') _profileImagePath = path;
        else if (type == 'idCard') _idCardImagePath = path;
        else _driverLicenseImagePath = path;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật $type thành công!')),
      );
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy người dùng!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Tin Người Dùng', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: isLoading || userModel == null
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Thông Tin Cá Nhân'),
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Bằng Lái Xe'),
              const SizedBox(height: 12),
              _buildImageCard(
                imagePath: _driverLicenseImagePath,
                placeholder: 'assets/img.png',
                onTap: () => _pickAndSaveImage('driverLicense'),
                label: 'Cập nhật bằng lái xe',
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Chứng Minh Nhân Dân'),
              const SizedBox(height: 12),
              _buildImageCard(
                imagePath: _idCardImagePath,
                placeholder: 'assets/img.png',
                onTap: () => _pickAndSaveImage('idCard'),
                label: 'Cập nhật CMND/CCCD',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _profileImagePath != null
                  ? FileImage(File(_profileImagePath!))
                  : const AssetImage('assets/gps.png') as ImageProvider,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () => _pickAndSaveImage('profile'),
              child: CircleAvatar(
                backgroundColor: primaryColor,
                radius: 20,
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoTile(Icons.person, 'Họ và tên', userModel!.fullName),
            _buildInfoTile(Icons.email, 'Email', userModel!.email),
            _buildInfoTile(Icons.phone, 'Số điện thoại', userModel!.phoneNumber),
            _buildInfoTile(Icons.badge, 'CMND/CCCD', userModel!.idCardNumber),
            _buildInfoTile(Icons.drive_eta, 'Bằng lái xe', userModel!.driverLicense),
            _buildInfoTile(Icons.location_on, 'Địa chỉ', userModel!.address),
            _buildInfoTile(Icons.cake, 'Ngày sinh', userModel!.dateOfBirth),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            '$title:',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Chưa cập nhật',
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard({
    required String? imagePath,
    required String placeholder,
    required VoidCallback onTap,
    required String label,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: imagePath != null ? BoxFit.cover : BoxFit.contain,
                  image: imagePath != null
                      ? FileImage(File(imagePath))
                      : AssetImage(placeholder) as ImageProvider,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.upload, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

