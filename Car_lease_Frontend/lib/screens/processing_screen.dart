import 'package:flutter/material.dart';

class ProcessingDialog extends StatefulWidget {
  final int currentStep;

  const ProcessingDialog({
    super.key,
    required this.currentStep,
  });

  @override
  State<ProcessingDialog> createState() => _ProcessingDialogState();
}

class _ProcessingDialogState extends State<ProcessingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  final List<String> steps = [
    "Detecting hidden fees and clauses",
    "Evaluating monthly payments",
    "Assessing risks and penalties",
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.65),
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 380,
              height: 520,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  /// 🌌 BACKGROUND IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      "assets/images/galaxy_bg.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                  /// 🌑 OVERLAY
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),

                  /// CONTENT
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Processing Your Car Lease...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// 🔵 CIRCULAR PROGRESS
                        SizedBox(
                          height: 160,
                          width: 160,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: (widget.currentStep + 1) / 4,
                                strokeWidth: 8,
                                backgroundColor: Colors.white12,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF38BDF8),
                                ),
                              ),
                              const Icon(
                                Icons.description_outlined,
                                size: 54,
                                color: Color(0xFF38BDF8),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "Analyzing your lease document...",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// STEPS
                        Column(
                          children: List.generate(
                            steps.length,
                            (index) => _stepTile(
                              title: steps[index],
                              index: index,
                            ),
                          ),
                        ),
                      ],
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

  Widget _stepTile({
    required String title,
    required int index,
  }) {
    final bool isCompleted = widget.currentStep > index;
    final bool isActive = widget.currentStep == index;

    Widget icon;

    if (isCompleted) {
      icon = const Icon(Icons.check_circle,
          color: Color(0xFF38BDF8), size: 22);
    } else if (isActive) {
      icon = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFF38BDF8),
        )
      );
    } else {
      icon = const Icon(Icons.circle_outlined,
          color: Colors.white24, size: 20);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isCompleted || isActive
                    ? Colors.white
                    : Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
