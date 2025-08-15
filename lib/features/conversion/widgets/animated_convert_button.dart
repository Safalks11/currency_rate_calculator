import 'package:flutter/material.dart';

class AnimatedConvertButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final bool success;
  const AnimatedConvertButton({super.key, required this.onPressed, required this.loading, required this.success});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
          child: loading
              ? const SizedBox(key: ValueKey('loading'), height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
              : success
                  ? const Row(
                      key: ValueKey('success'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.check_circle, size: 20), SizedBox(width: 8), Text('Converted')],
                    )
                  : const Text(key: ValueKey('idle'), 'Convert'),
        ),
      ),
    );
  }
}
