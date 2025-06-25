import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

class ViewProfileScreen extends StatelessWidget {
  const ViewProfileScreen({super.key});

  Future<Map<String, dynamic>> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('username') ?? "User";
    double height = prefs.getDouble('height') ?? 0.0;
    double weight = prefs.getDouble('weight') ?? 0.0;
    int age = prefs.getInt('age') ?? 0;
    String email = prefs.getString('usermail') ?? "";
    String dob = prefs.getString('dob') ?? "";
    String phone = prefs.getString('phone') ?? "";
    String address = prefs.getString('address') ?? "";
    String avatarPath = "assets/images/profile/avatar.jpg";
    Uint8List? avatarBytes;
    final base64Str = prefs.getString('avatar_base64');
    final savedAvatar = prefs.getString('avatar');
    if (base64Str != null && base64Str.isNotEmpty) {
      avatarBytes = base64Decode(base64Str);
      avatarPath = "";
    } else if (savedAvatar != null && savedAvatar.isNotEmpty) {
      avatarPath = savedAvatar;
      avatarBytes = null;
    }
    return {
      'userName': userName,
      'height': height,
      'weight': weight,
      'age': age,
      'email': email,
      'dob': dob,
      'phone': phone,
      'address': address,
      'avatarPath': avatarPath,
      'avatarBytes': avatarBytes,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Details"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadProfile(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildAvatar(data['avatarBytes'], data['avatarPath']),
                  const SizedBox(height: 20),
                  Text(
                    data['userName'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(thickness: 1, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  _buildInfoCard(data),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(Uint8List? avatarBytes, String avatarPath) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: avatarBytes != null
              ? Image.memory(avatarBytes, fit: BoxFit.cover)
              : (avatarPath.startsWith('/')
                  ? Image.file(File(avatarPath), fit: BoxFit.cover)
                  : Image.asset(avatarPath)),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        child: Column(
          children: [
            _buildInfoRow(Icons.email, "Email", data['email'].isNotEmpty ? data['email'] : "Not set"),
            _buildInfoRow(Icons.cake, "Date of Birth", data['dob'].isNotEmpty ? data['dob'] : "Not set"),
            _buildInfoRow(Icons.phone, "Phone", data['phone'].isNotEmpty ? data['phone'] : "Not set"),
            _buildInfoRow(Icons.home, "Address", data['address'].isNotEmpty ? data['address'] : "Not set"),
            _buildInfoRow(Icons.height, "Height", data['height'] > 0 ? "${data['height']} cm" : "Not set"),
            _buildInfoRow(Icons.monitor_weight, "Weight", data['weight'] > 0 ? "${data['weight']} kg" : "Not set"),
            _buildInfoRow(Icons.person, "Age", data['age'] > 0 ? "${data['age']} years" : "Not set"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(width: 14),
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
