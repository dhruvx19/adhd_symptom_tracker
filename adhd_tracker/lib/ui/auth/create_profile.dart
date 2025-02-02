import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindle/providers.dart/profile_provider.dart';
import 'package:mindle/providers.dart/profile_services.dart';
import 'package:mindle/ui/auth/login.dart';
import 'package:mindle/utils/color.dart';
import 'package:provider/provider.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({Key? key}) : super(key: key);

  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  
  final Color darkPurple = const Color(0xFF2D2642);

  // Predefined lists remain the same
  final List<String> _predefinedSymptoms = [
    'Careless mistakes',
    'Difficulty focusing',
    'Trouble listening',
    'Difficulty following instructions',
    'Difficulty organizing',
    'Avoiding tough mental activities',
    'Losing items',
    'Distracted by surroundings',
    'Forgetful during daily activities',
    'Fidgeting',
    'Leaving seat',
    'Moving excessively',
    'Trouble doing something quietly',
    'Always on the go',
    'Talking excessively',
    'Blurting out answers',
    'Trouble waiting turn',
    'Interrupting'
  ];

  final List<String> _predefinedStrategies = [
    'Psychology',
    'Occupational therapist',
    'Coaching',
    'Financial coaching',
    'Social Work'
  ];

  // State variables
  int _currentStep = 0;
  bool _isLoading = false;
  File? _profileImage;
  String? _base64Image;
  final List<String> _currentMedications = [];
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedStrategies = [];

  // Controllers
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _customSymptomController =
      TextEditingController();

  @override
  void dispose() {
    _medicationController.dispose();
    _customSymptomController.dispose();
    super.dispose();
  }

  Future<void> _handleStepSubmission() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    bool success = false;

    try {
      switch (_currentStep) {
        case 0: // Profile Photo
          if (_profileImage != null) {
            if (_base64Image == null) {
              _base64Image = await _convertImageToBase64();
            }
            if (_base64Image != null) {
              success = await provider.uploadProfilePicture(_base64Image!);
            }
          } else {
            success = true; // Skip if no image selected
          }
          break;

        case 1: // Medications
          if (_currentMedications.isNotEmpty) {
            success = await provider.addMedications(_currentMedications);
          } else {
            success = true;
          }
          break;

        case 2: // Symptoms
          if (_selectedSymptoms.isNotEmpty) {
            success = await provider.addSymptoms(_selectedSymptoms);
          } else {
            success = true;
          }
          break;

        case 3: // Strategy
          if (_selectedStrategies.isEmpty) {
            _showError('Please select a support strategy');
            success = false;
          } else {
            success = await provider
                .addStrategy(_selectedStrategies.first.toString());

            if (success) {
            // Mark profile creation as complete
            final storage = FlutterSecureStorage();
            await storage.delete(key: 'profile_creation_pending');
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            return;
          }
        }
          break;
      }

      if (success) {
        setState(() => _currentStep++);
      } else {
        _showError(provider.error ?? 'Failed to save data');
      }
    } catch (e) {
      _showError('An unexpected error occurred');
      print('Error in step submission: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  

  Future<void> _pickProfileImage() async {
    try {
      final picker = ImagePicker();

      // Show platform-specific picker dialog
      if (Platform.isIOS) {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  _handlePickedImage(image);
                },
                child: const Text('Take Photo'),
              ),
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  _handlePickedImage(image);
                },
                child: const Text('Choose from Library'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        );
      } else {
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );
        _handlePickedImage(pickedFile);
      }
    } catch (e) {
      print('Error picking image: $e');
      _showError('Failed to pick image');
    }
  }

  void _handlePickedImage(XFile? pickedFile) {
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _base64Image = null;
      });
      _convertImageToBase64();
    }
  }

  Future<String?> _convertImageToBase64() async {
    if (_profileImage == null) return null;

    try {
      List<int> imageBytes = await _profileImage!.readAsBytes();
      String base64String = base64Encode(imageBytes);
      return base64String;
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Widget _buildProfileImage() {
    if (_profileImage != null) {
      return CircleAvatar(
        radius: 100,
        backgroundImage: FileImage(_profileImage!),
        onBackgroundImageError: (e, stackTrace) {
          print('Error loading image: $e');
          setState(() {
            _profileImage = null;
            _base64Image = null;
          });
        },
      );
    } else {
      return const CircleAvatar(
        radius: 100,
        child: Icon(Icons.person, size: 100),
      );
    }
  }

  void _addMedication() {
    final medication = _medicationController.text.trim();
    if (medication.isEmpty) return;

    setState(() {
      _currentMedications.add(medication);
      _medicationController.clear();
    });
  }

  void _removeMedication(int index) {
    setState(() => _currentMedications.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    // Calculate responsive values
    final double paddingScale = size.width / 375.0;
    final double fontScale = size.width < 600 ? size.width / 375.0 : 1.5;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20 * fontScale,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          _buildStepIndicators(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              _getStepTitle(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: _buildStepContent(),
          ),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: _buildNavigationButton(fontScale),
          ),
          SizedBox(height: 24,)
        ],
      ),
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentStep == index ? AppTheme.upeiGreen: Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  String _getStepTitle() {
    const titles = [
      'Profile Photo',
      'Current Medications',
      'ADHD Symptoms',
      'Support Strategies'
    ];
    return titles[_currentStep];
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildProfilePhotoStep();
      case 1:
        return _buildCurrentMedicationsStep();
      case 2:
        return _buildADHDSymptomsStep();
      case 3:
        return _buildStrategiesStep();
      default:
        return Container();
    }
  }

  Widget _buildNavigationButton(double fontScale) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleStepSubmission,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppTheme.upeiRed,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                _currentStep == 3 ? 'Submit' : 'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * fontScale,
                ),
              ),
      ),
    );
  }

  void _goToNextStep() {
    setState(() {
      _currentStep = (_currentStep + 1) % 4;
    });
  }

  Widget _buildProfilePhotoStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfileImage(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickProfileImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.upeiRed,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Pick Profile Photo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMedicationsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _medicationController,
            onSubmitted: (_) => _addMedication(),
            decoration: InputDecoration(
              labelText: 'Enter Current Medication',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addMedication,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _currentMedications.isEmpty
                ? const Center(child: Text('No medications added'))
                : ListView.builder(
                    itemCount: _currentMedications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_currentMedications[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _removeMedication(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildADHDSymptomsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _customSymptomController,
            decoration: InputDecoration(
              labelText: 'Add Custom Symptom',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final customSymptom = _customSymptomController.text.trim();
                  if (customSymptom.isNotEmpty) {
                    setState(() {
                      _selectedSymptoms.add(customSymptom);
                      _customSymptomController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ..._predefinedSymptoms.map((symptom) => CheckboxListTile(
                      title: Text(symptom),
                      value: _selectedSymptoms.contains(symptom),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedSymptoms.add(symptom);
                          } else {
                            _selectedSymptoms.remove(symptom);
                          }
                        });
                      },
                    )),
                ..._selectedSymptoms
                    .where((symptom) => !_predefinedSymptoms.contains(symptom))
                    .map((customSymptom) => ListTile(
                          title: Text(customSymptom),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _selectedSymptoms.remove(customSymptom);
                              });
                            },
                          ),
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategiesStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _predefinedStrategies.length,
        itemBuilder: (context, index) {
          final strategy = _predefinedStrategies[index];
          return RadioListTile<String>(
            title: Text(strategy),
            value: strategy,
            groupValue:
                _selectedStrategies.isEmpty ? null : _selectedStrategies.first,
            onChanged: (String? value) {
              setState(() {
                _selectedStrategies.clear();
                if (value != null) {
                  _selectedStrategies.add(value);
                }
              });
            },
          );
        },
      ),
    );
  }
}
