import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindle/providers.dart/profile_provider.dart';
import 'package:mindle/ui/auth/login.dart';
import 'package:provider/provider.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({Key? key}) : super(key: key);

  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final Color softPurple = const Color(0xFF8D5BFF);
  final Color darkPurple = const Color(0xFF2D2642);

  // Predefined lists as instance variables
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
  File? _profileImage;
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

  void _submitProfile() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);

    // Convert image to base64 and log it
    final base64Image = _convertImageToBase64();
    if (base64Image != null) {
      debugPrint('Profile Image Base64: $base64Image');
    }

    // Ensure at least one strategy is selected
    if (_selectedStrategies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a support strategy')),
      );
      return;
    }

    final success = await provider.submitProfile(
      base64Image: base64Image,
      medications: _currentMedications,
      symptoms: _selectedSymptoms,
      strategy: _selectedStrategies.first, // Taking the first selected strategy
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to submit profile'),
        ),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  String? _convertImageToBase64() {
  if (_profileImage == null) return null;
  try {
    final bytes = _profileImage!.readAsBytesSync();
    final base64String = base64Encode(bytes);
    // Log the first and last few characters to verify the string
    print('Base64 length: ${base64String.length}');
    print('Base64 start: ${base64String.substring(0, 50)}...');
    print('Base64 end: ...${base64String.substring(base64String.length - 50)}');
    return base64String;
  } catch (e) {
    print('Error converting image to base64: $e');
    return null;
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
    final fontScale = size.width / 375.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Text(
            'Let\'s Tailor Your Experience: Complete Your Profile',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12 * fontScale,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            'Step ${_currentStep + 1}/4',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16 * fontScale,
            ),
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
            padding: const EdgeInsets.all(16.0),
            child: _buildNavigationButton(),
          ),
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
            color: _currentStep == index ? Colors.blue : Colors.grey.shade300,
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

  Widget _buildNavigationButton() {
    final size = MediaQuery.of(context).size;
    final fontScale = size.width / 375.0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _currentStep == 3 ? _submitProfile : _goToNextStep,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: softPurple,
        ),
        child: Text(
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
          _profileImage != null
              ? CircleAvatar(
                  radius: 100,
                  backgroundImage: FileImage(_profileImage!),
                )
              : const CircleAvatar(
                  radius: 100,
                  child: Icon(Icons.person, size: 100),
                ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickProfileImage,
            child: const Text('Pick Profile Photo'),
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
          groupValue: _selectedStrategies.isEmpty ? null : _selectedStrategies.first,
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