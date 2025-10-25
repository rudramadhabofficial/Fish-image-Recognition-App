import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fishapp/models/fish_result.dart';
import 'package:fishapp/models/user_model.dart';
import 'package:fishapp/services/gemini_service.dart';
import 'package:fishapp/services/sqlite_service.dart';
import 'package:fishapp/pages/dashboard_page.dart';
import 'package:fishapp/pages/market_page.dart';
import 'package:fishapp/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SQLiteService _sqliteService = SQLiteService();
  final GeminiService _geminiService = GeminiService();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _selectedImage;
  bool _isAnalyzing = false;
  int _currentStep = 0;
  bool? _useOnlineMode;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _sqliteService.getUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null || _useOnlineMode == null) return;

    setState(() {
      _isAnalyzing = true;
      _currentStep = 0;
    });

    try {
      // Simulate step-by-step analysis
      for (int i = 1; i <= 4; i++) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _currentStep = i;
        });
      }

      final response = await _geminiService.analyzeFishImage(_selectedImage!);
      final resultData = _geminiService.parseResponse(response);

      final fishResult = FishResult(
        imagePath: _selectedImage!.path,
        species: resultData['species'],
        count: resultData['count'],
        confidence: resultData['confidence'],
        individualWeight: resultData['individualWeight'],
        totalWeight: resultData['totalWeight'],
        healthStatus: resultData['healthStatus'],
        analyzedAt: DateTime.now(),
      );

      await _sqliteService.insertFishResult(fishResult);

      // Show results
      _showAnalysisResult(fishResult);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
        _currentStep = 0;
      });
    }
  }

  void _showAnalysisResult(FishResult result) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E),
                Color(0xFF283593),
                Color(0xFF303F9F),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF64FFDA), Color(0xFF009688)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Analysis Complete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildGemResultRow('Species', result.species, Icons.emoji_nature),
                      _buildGemResultRow('Count', result.count.toString(), Icons.format_list_numbered),
                      _buildGemResultRow('Confidence', '${result.confidence.toStringAsFixed(1)}%', Icons.verified),
                      _buildGemResultRow('Individual Weight', '${result.individualWeight.toStringAsFixed(1)}g', Icons.fitness_center),
                      _buildGemResultRow('Total Weight', '${result.totalWeight.toStringAsFixed(1)}g', Icons.scale),
                      _buildGemResultRow('Health Status', result.healthStatus, Icons.health_and_safety),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF64FFDA), Color(0xFF009688)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'EXCELLENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGemResultRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF64FFDA), Color(0xFF009688)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF1A237E),
              Color(0xFF283593),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildGemHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Main Card
                      _buildMainCard(),
                      const SizedBox(height: 24),

                      // Mode Selection
                      if (_selectedImage != null && !_isAnalyzing) ...[
                        _buildModeSelection(),
                        const SizedBox(height: 24),
                      ],

                      // Analysis Steps
                      if (_isAnalyzing) ...[
                        _buildAnalysisProgress(),
                        const SizedBox(height: 24),
                      ],

                      // Analyze Button
                      if (_selectedImage != null && _useOnlineMode != null && !_isAnalyzing)
                        _buildAnalyzeButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildGemBottomNavigationBar(),
    );
  }

  Widget _buildGemHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF64FFDA),
            Color(0xFF009688),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'ATMAN AI',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.analytics, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1E2E),
            Color(0xFF2D2D44),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology, color: Color(0xFF64FFDA), size: 24),
                SizedBox(width: 8),
                Text(
                  'AI FISH ANALYSIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2A2A3E),
                    Color(0xFF3A3A4E),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF64FFDA),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF64FFDA).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF64FFDA),
                                Color(0xFF009688),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF64FFDA).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.photo_camera, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'CAPTURE OR SELECT IMAGE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageButton(
                              'Camera',
                              Icons.camera_alt,
                              _takePhoto,
                            ),
                            _buildImageButton(
                              'Gallery',
                              Icons.photo_library,
                              _pickImage,
                            ),
                          ],
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_camera, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageButton(String label, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF64FFDA),
            Color(0xFF009688),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64FFDA).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1E2E),
            Color(0xFF2D2D44),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'SELECT ANALYSIS MODE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGemModeButton('OFFLINE MODE', false, Icons.offline_bolt),
              _buildGemModeButton('ONLINE AI MODE', true, Icons.cloud),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGemModeButton(String label, bool isOnline, IconData icon) {
    final isSelected = _useOnlineMode == isOnline;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF64FFDA),
                    Color(0xFF009688),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey[800]!,
                    Colors.grey[900]!,
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF64FFDA).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => setState(() => _useOnlineMode = isOnline),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisProgress() {
    final steps = _useOnlineMode == true
        ? [
            'AI Species Detection',
            'AI Classification',
            'Health Estimation',
            'Weight Analysis',
          ]
        : [
            'Species Detection',
            'Classification',
            'Health Analysis',
            'Weight Calculation',
          ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1E2E),
            Color(0xFF2D2D44),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF64FFDA), size: 24),
              const SizedBox(width: 8),
              Text(
                _useOnlineMode == true ? 'AI ANALYSIS IN PROGRESS' : 'ANALYSIS IN PROGRESS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = _currentStep > index;
            final isCurrent = _currentStep == index + 1;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF64FFDA),
                                Color(0xFF009688),
                              ],
                            )
                          : isCurrent
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF2196F3),
                                    Color(0xFF1976D2),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey[700]!,
                                    Colors.grey[800]!,
                                  ],
                                ),
                      shape: BoxShape.circle,
                      boxShadow: isCompleted || isCurrent
                          ? [
                              BoxShadow(
                                color: (isCompleted ? const Color(0xFF64FFDA) : const Color(0xFF2196F3))
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        color: isCompleted ? const Color(0xFF64FFDA) : Colors.white70,
                        fontSize: 14,
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF64FFDA),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF64FFDA).withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF64FFDA),
            Color(0xFF009688),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64FFDA).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _analyzeImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 24),
            const SizedBox(width: 12),
            Text(
              _useOnlineMode == true ? 'START AI ANALYSIS' : 'START ANALYSIS',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGemBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A237E),
            Color(0xFF283593),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF64FFDA),
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_rounded),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          }
        },
      ),
    );
  }
}