import 'package:flutter/material.dart';
import 'package:fishapp/models/user_model.dart';
import 'package:fishapp/services/sqlite_service.dart';
import 'package:fishapp/pages/login_page.dart';
import 'package:fishapp/pages/home_page.dart';
import 'package:fishapp/pages/market_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SQLiteService _sqliteService = SQLiteService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  UserModel? _currentUser;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _sqliteService.getUser();
    setState(() {
      _currentUser = user;
      if (user != null) {
        _nameController.text = user.name;
        _contactController.text = user.contact;
        _addressController.text = user.address;
      }
    });
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    if (_nameController.text.isEmpty || 
        _contactController.text.isEmpty || 
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final updatedUser = UserModel(
      id: _currentUser!.id,
      name: _nameController.text,
      contact: _contactController.text,
      address: _addressController.text,
      role: _currentUser!.role,
      lastLogin: _currentUser!.lastLogin,
    );

    await _sqliteService.updateUser(updatedUser);
    setState(() {
      _currentUser = updatedUser;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> _logout() async {
    await _sqliteService.deleteUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers to original values
        _nameController.text = _currentUser?.name ?? '';
        _contactController.text = _currentUser?.contact ?? '';
        _addressController.text = _currentUser?.address ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
            onPressed: _toggleEdit,
            tooltip: _isEditing ? 'Cancel' : 'Edit',
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _updateProfile,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _currentUser!.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _currentUser!.role,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Profile Information
            const Text(
              'Profile Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  _buildInfoField(
                    'Name',
                    _nameController,
                    Icons.person,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoField(
                    'Contact',
                    _contactController,
                    Icons.phone,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoField(
                    'Address',
                    _addressController,
                    Icons.location_on,
                    maxLines: 2,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                    'Role',
                    _currentUser!.role,
                    Icons.work,
                  ),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                    'Last Login',
                    _formatDate(_currentUser!.lastLogin),
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 40),

                  // Logout Button
                  if (!_isEditing)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    bool enabled = false,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2196F3)),
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1E1E2E),
      selectedItemColor: const Color(0xFF2196F3),
      unselectedItemColor: Colors.white70,
      currentIndex: 2, // Profile is index 2
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Market',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else if (index == 1) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MarketPage()),
            (route) => false,
          );
        }
        // If index is 2 (Profile), we're already here, so do nothing
      },
    );
  }
}