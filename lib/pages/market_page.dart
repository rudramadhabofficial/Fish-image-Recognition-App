import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fishapp/services/sqlite_service.dart';
import 'package:fishapp/pages/home_page.dart';
import 'package:fishapp/pages/profile_page.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final SQLiteService _sqliteService = SQLiteService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _marketListings = [];
  List<Map<String, dynamic>> _filteredListings = [];

  @override
  void initState() {
    super.initState();
    _loadMarketListings();
    _addDemoData();
  }

  Future<void> _loadMarketListings() async {
    final listings = await _sqliteService.getMarketListings();
    setState(() {
      _marketListings = listings;
      _filteredListings = listings;
    });
  }

  void _addDemoData() async {
    final existingListings = await _sqliteService.getMarketListings();
    if (existingListings.isEmpty) {
      // Add some demo data
      final demoListings = [
        {
          'user_name': 'Rajesh Kumar',
          'user_contact': '+91 9876543210',
          'user_address': 'Mumbai Fishing Harbor',
          'species': 'Pomfret',
          'count': 5,
          'individual_weight': 250.0,
          'total_weight': 1250.0,
          'health_status': 'Fresh',
          'image_path': 'demo_pomfret',
          'listed_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'user_name': 'Suresh Patil',
          'user_contact': '+91 8765432109',
          'user_address': 'Goa Beach',
          'species': 'Mackerel',
          'count': 8,
          'individual_weight': 180.0,
          'total_weight': 1440.0,
          'health_status': 'Fresh',
          'image_path': 'demo_mackerel',
          'listed_at': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        },
        {
          'user_name': 'Anita Sharma',
          'user_contact': '+91 7654321098',
          'user_address': 'Chennai Port',
          'species': 'Salmon',
          'count': 3,
          'individual_weight': 1200.0,
          'total_weight': 3600.0,
          'health_status': 'Fresh',
          'image_path': 'demo_salmon',
          'listed_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
      ];

      for (final listing in demoListings) {
        await _sqliteService.insertMarketListing(listing);
      }
      _loadMarketListings();
    }
  }

  void _searchListings(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredListings = _marketListings;
      });
      return;
    }

    final filtered = _marketListings.where((listing) {
      return listing['species'].toString().toLowerCase().contains(query.toLowerCase()) ||
          listing['user_name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          listing['user_address'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredListings = filtered;
    });
  }

  Widget _buildDemoImage(String species) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          species.substring(0, 1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Marketplace',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchListings,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by fish name, fisherman, or address...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: _filteredListings.isEmpty
                ? const Center(
                    child: Text(
                      'No listings found',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredListings.length,
                    itemBuilder: (context, index) {
                      final listing = _filteredListings[index];
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              listing['image_path'].toString().startsWith('demo_')
                                  ? _buildDemoImage(listing['species'])
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: FileImage(File(listing['image_path'])),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      listing['species'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow('Fisherman:', listing['user_name']),
                                    _buildInfoRow('Contact:', listing['user_contact']),
                                    _buildInfoRow('Address:', listing['user_address']),
                                    _buildInfoRow('Count:', listing['count'].toString()),
                                    _buildInfoRow('Total Weight:', '${listing['total_weight']}g'),
                                    _buildInfoRow(
                                      'Health:',
                                      listing['health_status'],
                                      valueColor: listing['health_status'] == 'Fresh' ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Listed: ${_formatDate(DateTime.parse(listing['listed_at']))}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1E1E2E),
      selectedItemColor: const Color(0xFF2196F3),
      unselectedItemColor: Colors.white70,
      currentIndex: 1, // Market is index 1
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
        } else if (index == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
            (route) => false,
          );
        }
        // If index is 1 (Market), we're already here, so do nothing
      },
    );
  }
}