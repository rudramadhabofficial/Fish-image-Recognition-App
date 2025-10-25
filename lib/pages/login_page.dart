import 'package:flutter/material.dart';
import 'package:fishapp/models/user_model.dart';
import 'package:fishapp/services/sqlite_service.dart';
import 'package:fishapp/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SQLiteService _sqliteService = SQLiteService();
  String? _selectedRole;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isNewUser = true;

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
  }

  Future<void> _checkExistingUser() async {
    final user = await _sqliteService.getUser();
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() {
        _isNewUser = true;
      });
    }
  }

  Future<void> _saveUser() async {
    if (_selectedRole == null ||
        _nameController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final user = UserModel(
      name: _nameController.text,
      contact: _contactController.text,
      address: _addressController.text,
      role: _selectedRole!,
      lastLogin: DateTime.now(),
    );

    await _sqliteService.insertUser(user);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      resizeToAvoidBottomInset: true, // Important: adjusts when keyboard appears
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Atman',
                    style: TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Smart Fish Identification. Instant Insights. Offline',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  if (_isNewUser) ...[
                    const Text(
                      'Select Your Role:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRoleButton('Fisherman', '1. Fisherman'),
                        _buildRoleButton('Buyer', '2. Buyer'),
                      ],
                    ),
                    const SizedBox(height: 40),

                    if (_selectedRole != null) ...[
                      _buildTextField('Name', _nameController),
                      const SizedBox(height: 16),
                      _buildTextField('Contact', _contactController),
                      const SizedBox(height: 16),
                      _buildTextField('Address', _addressController, maxLines: 2),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: _saveUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: const Text('Get Started'),
                      ),
                    ],
                  ] else ...[
                    const Spacer(),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    const Text(
                      'Checking user data...',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String role, String label) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedRole == role
              ? const Color(0xFF2196F3)
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2196F3)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
