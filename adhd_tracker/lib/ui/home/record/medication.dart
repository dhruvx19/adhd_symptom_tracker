import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindle/ui/home/home.dart';

class MedicationLoggingPage extends StatefulWidget {
  const MedicationLoggingPage({Key? key}) : super(key: key);

  @override
  State<MedicationLoggingPage> createState() => _MedicationLoggingPageState();
}

class _MedicationLoggingPageState extends State<MedicationLoggingPage> {
  String medication = 'Adderall XR 20mg';
  String dosage = '20mg';
  String timeOfDay = '10:00 am';
  String effects = 'Focused, calm';
  String reminder = 'Set Reminder';

  void _editField({
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController(text: initialValue);
        return AlertDialog(
          title: Text(title, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter $title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSetReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SetReminderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = size.width / 375.0;
    final softPurple = const Color(0xFF8D5BFF);
    final grey = const Color(0xFFF5F5F5);
    final darkPurple = const Color(0xFF2D2642);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          'Add a New Entry',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold,
              color: darkPurple,
              letterSpacing: -0.5,
            ),
          ),
        ),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ListTileWidget(
              icon: Icons.medical_services,
              title: 'Medication',
              subtitle: medication,
              onTap: () => _editField(
                title: 'Medication',
                initialValue: medication,
                onSave: (value) => setState(() => medication = value),
              ),
            ),
            _ListTileWidget(
              icon: Icons.label,
              title: 'Dosage',
              subtitle: dosage,
              onTap: () => _editField(
                title: 'Dosage',
                initialValue: dosage,
                onSave: (value) => setState(() => dosage = value),
              ),
            ),
            _ListTileWidget(
              icon: Icons.access_time,
              title: 'Time of Day',
              subtitle: timeOfDay,
              onTap: () => _editField(
                title: 'Time of Day',
                initialValue: timeOfDay,
                onSave: (value) => setState(() => timeOfDay = value),
              ),
            ),
            _ListTileWidget(
              icon: Icons.emoji_emotions,
              title: 'Effects',
              subtitle: effects,
              onTap: () => _editField(
                title: 'Effects',
                initialValue: effects,
                onSave: (value) => setState(() => effects = value),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.notification_important, color: Colors.black),
              ),
              title: Text(
                'Reminder',
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              subtitle: Text(
                reminder,
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.black),
              onTap: _navigateToSetReminder,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  HomePage(),
                                ),
                              );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: softPurple,
                minimumSize: Size(double.infinity, size.height * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Record Side Effects',
                style: TextStyle(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  HomePage(),
                                ),
                              );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                minimumSize: Size(double.infinity, size.height * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ListTileWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(
        title,
        style: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
      trailing: const Icon(Icons.edit, color: Colors.black),
      onTap: onTap,
    );
  }
}

class SetReminderPage extends StatelessWidget {
  const SetReminderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Reminder'),
      ),
      body: const Center(
        child: Text('Reminder Settings Page'),
      ),
    );
  }
}
