import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fishapp/models/fish_result.dart';
import 'package:fishapp/models/user_model.dart';
import 'package:fishapp/services/sqlite_service.dart';
import 'package:fishapp/services/pdf_service.dart';
import 'package:fishapp/pages/home_page.dart';
import 'package:fishapp/pages/market_page.dart';
import 'package:fishapp/pages/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SQLiteService _sqliteService = SQLiteService();
  List<FishResult> _fishResults = [];
  UserModel? _currentUser;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _sqliteService.getUser();
    final results = await _sqliteService.getFishResults();
    setState(() {
      _currentUser = user;
      _fishResults = results;
    });
  }

  Future<void> _uploadToMarket(FishResult result) async {
    if (_currentUser == null) return;

    if (result.uploadedToMarket) {
      _showSnackBar('Already uploaded to market', Colors.orange);
      return;
    }

    try {
      final marketListing = {
        'fish_result_id': result.id,
        'user_name': _currentUser!.name,
        'user_contact': _currentUser!.contact,
        'user_address': _currentUser!.address,
        'species': result.species,
        'count': result.count,
        'individual_weight': result.individualWeight,
        'total_weight': result.totalWeight,
        'health_status': result.healthStatus,
        'image_path': result.imagePath,
        'listed_at': DateTime.now().toIso8601String(),
      };

      await _sqliteService.insertMarketListing(marketListing);
      result.uploadedToMarket = true;
      await _sqliteService.updateFishResult(result);

      setState(() {});
      _showSnackBar('Successfully uploaded to market', Colors.green);
    } catch (e) {
      _showSnackBar('Upload failed: $e', Colors.red);
    }
  }

  Future<void> _exportToPDF() async {
    if (_fishResults.isEmpty) {
      _showSnackBar('No data to export', Colors.orange);
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // Show immediate feedback
      _showSnackBar('Generating PDF...', Colors.blue);
      
      await PDFService.generateAndSharePDF(_fishResults);
      
      // Success message will be shown by the PDF service
    } catch (e) {
      _showSnackBar('Export failed: $e', Colors.red);
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
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
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              onPressed: _exportToPDF,
              tooltip: 'Export to PDF',
            ),
        ],
      ),
      body: _fishResults.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 64, color: Colors.white38),
                  SizedBox(height: 16),
                  Text(
                    'No analysis results yet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(const Color(0xFF1E1E2E)),
                  columns: const [
                    DataColumn(label: Text('Image', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Species', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Count', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Confidence', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Weight', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Health', style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text('Action', style: TextStyle(color: Colors.white))),
                  ],
                  rows: _fishResults.map((result) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(File(result.imagePath)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(result.species, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(result.count.toString(), style: const TextStyle(color: Colors.white))),
                        DataCell(Text('${result.confidence.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white))),
                        DataCell(Text('${result.totalWeight.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white))),
                        DataCell(
                          Text(
                            result.healthStatus,
                            style: TextStyle(
                              color: result.healthStatus.toLowerCase().contains('fresh') ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: result.uploadedToMarket ? null : () => _uploadToMarket(result),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: result.uploadedToMarket ? Colors.grey : Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Text(
                              result.uploadedToMarket ? 'Uploaded' : 'Upload',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1E1E2E),
      selectedItemColor: const Color(0xFF2196F3),
      unselectedItemColor: Colors.white70,
      currentIndex: 0,
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
        } else if (index == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
            (route) => false,
          );
        }
      },
    );
  }
}