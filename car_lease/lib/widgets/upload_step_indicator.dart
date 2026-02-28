import 'package:flutter/material.dart';

class UploadStepIndicator extends StatelessWidget {
  final int currentStep;

  const UploadStepIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      "Uploading document",
      "Reading lease content",
      "Analyzing clauses with AI",
      "Detecting risks & penalties",
    ];

    // Clamp step to valid range
    final int safeStep =
        currentStep.clamp(0, steps.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final active = index <= safeStep;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: active ? Colors.green : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: active
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 16,
                  color: active
                      ? Colors.lightGreenAccent
                      : Colors.grey,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
