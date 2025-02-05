import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ADHD_Tracker/providers.dart/symptom_provider.dart';
import 'package:ADHD_Tracker/utils/color.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ADHD_Tracker/ui/home/record/medication.dart';

class SymptomLogging extends StatefulWidget {
  const SymptomLogging({super.key});

  @override
  State<SymptomLogging> createState() => _SymptomLoggingState();
}

class _SymptomLoggingState extends State<SymptomLogging> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? selectedFrequency;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _notesController = TextEditingController();
  late TextEditingController dateController;
  Timer? _debounce;
  Future<void>? _loadingFuture;

  final _frequencyOptions = [
    'Morning',
    'Mid Day',
    'Afternoon',
    'Evening',
    'Night',
    'Mid Night',
  ];
  int _selectedFrequencyIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollStopped);
    dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

    // Initialize the provider with the current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SymptomProvider>(context, listen: false);
      provider.updateDate(dateController.text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final symptomProvider =
          Provider.of<SymptomProvider>(context, listen: false);

      if (!symptomProvider.isInitialized) {
        symptomProvider.fetchSymptoms();
      }
    });
  }

  Future<void> _selectDate(
      BuildContext context, SymptomProvider provider) async {
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

  Future<void> _initializeData() async {
    final symptomProvider =
        Provider.of<SymptomProvider>(context, listen: false);
    await symptomProvider.fetchSymptoms();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollStopped);
    _debounce?.cancel();
    _scrollController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onScrollStopped() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      final offset = _scrollController.offset;
      final itemHeight = 56.0;
      final index = (offset / itemHeight).round();
      setState(() => _selectedFrequencyIndex = index);
    });
  }

  void _selectFrequency(int index) {
    setState(() => _selectedFrequencyIndex = index);
  }

  Future<void> _handleSubmit() async {
    final symptomProvider =
        Provider.of<SymptomProvider>(context, listen: false);
    final selectedSymptoms = symptomProvider.symptomSelection.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedSymptoms.isEmpty || selectedFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select symptoms and severity')),
      );
      return;
    }

    final success = await symptomProvider.logSymptoms(
      symptoms: selectedSymptoms,
      severity: selectedFrequency!,
      timeOfDay: _frequencyOptions[_selectedFrequencyIndex],
      notes: _notesController.text,
    );

    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => MedicationLoggingPage()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(symptomProvider.error ?? 'Failed to submit symptoms')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = size.width < 360 ? 0.8 : size.width / 375.0;
    final padding = size.width * 0.04;
    final isSmallScreen = size.height < 600;

    final grey = const Color(0xFFF5F5F5);
    final darkPurple = Theme.of(context).textTheme.titleLarge?.color;

    Widget _buildTitle(String title) {
      return Text(
        title,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.bold,
            color: darkPurple,
            letterSpacing: -0.5,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Log Symptoms',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold,
              color: darkPurple,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Consumer<SymptomProvider>(
            builder: (context, symptomProvider, child) {
              if (symptomProvider.error != null) {
                return Center(child: Text(symptomProvider.error!));
              }

              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitle('Symptoms'),
                            SizedBox(height: padding / 2),
                            Column(
                              children: symptomProvider.symptomSelection.keys
                                  .map((symptom) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: padding / 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          symptom,
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                              fontSize: 14 * fontScale,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Transform.scale(
                                        scale: fontScale,
                                        child: Checkbox(
                                          value: symptomProvider
                                              .symptomSelection[symptom],
                                          onChanged: (bool? value) {
                                            symptomProvider
                                                .updateSymptomSelection(
                                              symptom,
                                              value ?? false,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: padding * 1.5),
                            _buildTitle('Severity'),
                            SizedBox(height: padding),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _FrequencyButton(
                                    label: 'Not at all',
                                    isSelected:
                                        selectedFrequency == 'Not at all',
                                    onPressed: () => setState(
                                        () => selectedFrequency = 'Not at all'),
                                  ),
                                  SizedBox(width: padding / 2),
                                  _FrequencyButton(
                                    label: 'Mild',
                                    isSelected: selectedFrequency == 'Mild',
                                    onPressed: () => setState(
                                        () => selectedFrequency = 'Mild'),
                                  ),
                                  SizedBox(width: padding / 2),
                                  _FrequencyButton(
                                    label: 'Moderate',
                                    isSelected: selectedFrequency == 'Moderate',
                                    onPressed: () => setState(
                                        () => selectedFrequency = 'Moderate'),
                                  ),
                                  SizedBox(width: padding / 2),
                                  _FrequencyButton(
                                    label: 'Severe',
                                    isSelected: selectedFrequency == 'Severe',
                                    onPressed: () => setState(
                                        () => selectedFrequency = 'Severe'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDateField(
                              context: context,
                              provider: symptomProvider,
                            ),
                            SizedBox(height: padding * 1.5),
                            _buildTitle('Time of day'),
                            SizedBox(height: padding),
                            SizedBox(
                              height: isSmallScreen ? 100 : 120,
                              child: ListView.builder(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _frequencyOptions.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => _selectFrequency(index),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: padding / 2),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: padding,
                                        vertical: isSmallScreen ? 8 : 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedFrequencyIndex == index
                                            ? grey
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(25),
                                        border: _selectedFrequencyIndex == index
                                            ? Border.all(
                                                color: grey, width: 1.5)
                                            : null,
                                      ),
                                      child: Text(
                                        _frequencyOptions[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14 * fontScale,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: padding * 1.5),
                            _buildTitle('Notes'),
                            SizedBox(height: padding),
                            TextField(
                              style: const TextStyle(color: Colors.black),
                              controller: _notesController,
                              maxLines: isSmallScreen ? 3 : 5,
                              decoration: InputDecoration(
                                hintText: 'Add a note',
                                fillColor: Colors.grey[200],
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: padding * 2),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.upeiRed,
                            minimumSize:
                                Size(double.infinity, size.height * 0.07),
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
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required SymptomProvider provider,
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

class _FrequencyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _FrequencyButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = size.width < 360 ? 0.8 : size.width / 375.0;

    return SizedBox(
      width: 85 * fontScale,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue[50] : Colors.white,
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey[400]!,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
