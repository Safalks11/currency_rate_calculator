import 'package:flutter/material.dart';

class AnimatedConvertButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final bool success;

  const AnimatedConvertButton({
    super.key,
    required this.onPressed,
    required this.loading,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 50,
      curve: Curves.easeInOut,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: success
              ? Colors.green
              : loading
              ? colorScheme.primary.withValues(alpha: 0.6)
              : colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: success ? 0 : 2,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: anim, child: child),
          ),
          child: loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : success
              ? const Row(
                  key: ValueKey('success'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 22, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Converted', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )
              : const Text(
                  key: ValueKey('idle'),
                  'Convert',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}
