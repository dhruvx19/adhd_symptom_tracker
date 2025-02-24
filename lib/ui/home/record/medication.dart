import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhd_tracker/providers.dart/medication_provider.dart';
import 'package:adhd_tracker/utils/color.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    medicationController = TextEditingController();
    dosageController = TextEditingController();
    timeController = TextEditingController();
    effectsController = TextEditingController();
    dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now())
    );

    // Initialize the provider with the current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MedicationProvider>(context, listen: false);
      provider.updateDate(dateController.text);
    });
  }

  @override
  void dispose() {
    medicationController.dispose();
    dosageController.dispose();
    timeController.dispose();
    effectsController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, MedicationProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        dateController.text = formattedDate;
      });
      provider.updateDate(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = size.width / 375.0;
    final darkPurple = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor:Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                _buildDateField(
                  context: context,
                  provider: provider,
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
                              effectsController.text.isEmpty ||
                              dateController.text.isEmpty) {
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
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          style: TextStyle(color: Colors.black),
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

  Widget _buildDateField({
    required BuildContext context,
    required MedicationProvider provider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: dateController,
          readOnly: true,
          onTap: () => _selectDate(context, provider),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today),
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