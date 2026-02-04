import 'package:flutter/material.dart';
import '../widgets/upload_step_indicator.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  int currentStep = 0;

  final aiMessages = [
    "Checking for hidden fees…",
    "Reviewing early termination clauses…",
    "Detecting unfair conditions…",
    "Summarizing insights clearly…",
  ];

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    for (int i = 0; i < aiMessages.length; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => currentStep = i);
    }

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              Text(
                "Analyzing your lease",
                style: theme.textTheme.titleLarge,
              ),

              const SizedBox(height: 10),

              Text(
                aiMessages[currentStep],
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

              UploadStepIndicator(currentStep: currentStep),

              const Spacer(),

              Center(
                child: Text(
                  "This usually takes a few seconds",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
