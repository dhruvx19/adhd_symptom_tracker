// medication_logging_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindle/providers.dart/medication_provider.dart';
import 'package:mindle/utils/color.dart';
import 'package:provider/provider.dart';

class MedicationLoggingPage extends StatefulWidget {
  const MedicationLoggingPage({Key? key}) : super(key: key);

  @override
  State<MedicationLoggingPage> createState() => _MedicationLoggingPageState();
}

class _MedicationLoggingPageState extends State<MedicationLoggingPage> {
  late TextEditingController medicationController;
  late TextEditingController dosageController;
  late TextEditingController timeController;
  late TextEditingController effectsController;

  @override
  void initState() {
    super.initState();
    medicationController = TextEditingController();
    dosageController = TextEditingController();
    timeController = TextEditingController();
    effectsController = TextEditingController();
  }

  @override
  void dispose() {
    medicationController.dispose();
    dosageController.dispose();
    timeController.dispose();
    effectsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = size.width / 375.0;

    final darkPurple = const Color(0xFF2D2642);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Medication',
          style: GoogleFonts.lato(
            fontSize: 20 * fontScale,
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
      ),
      body: Consumer<MedicationProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  title: 'Medication Name',
                  icon: Icons.medication,
                  controller: medicationController,
                  onChanged: provider.updateMedicationName,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  title: 'Dosage',
                  icon: Icons.scale,
                  controller: dosageController,
                  onChanged: provider.updateDosage,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  title: 'Time of Day',
                  icon: Icons.access_time,
                  controller: timeController,
                  onChanged: provider.updateTimeOfDay,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  title: 'Effects (comma-separated)',
                  icon: Icons.psychology,
                  controller: effectsController,
                  onChanged: provider.updateEffects,
                ),
                const SizedBox(height: 54),
                if (provider.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      provider.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (medicationController.text.isEmpty ||
                              dosageController.text.isEmpty ||
                              timeController.text.isEmpty ||
                              effectsController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          await provider.submitMedication(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.upeiRed,
                    minimumSize: Size(double.infinity, size.height * 0.07),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Submit Medication',
                          style: TextStyle(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }
}
