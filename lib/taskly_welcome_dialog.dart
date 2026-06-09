import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

class TasklyWelcomeDialog extends StatefulWidget {
  const TasklyWelcomeDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Welcome Dialog',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const TasklyWelcomeDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<TasklyWelcomeDialog> createState() => _TasklyWelcomeDialogState();
}

class _TasklyWelcomeDialogState extends State<TasklyWelcomeDialog> {
  double _buttonScale = 1.0;

  void _dismiss() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _ProductivityIllustration(),
                    const SizedBox(height: 32),
                    Text(
                      'Hey there!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Thank you for trying Taskly. This project started as an idea and has grown because of people like you who are willing to give it a chance.\n\n"
                      "My goal is simple: help you stay organized, focused, and get things done with the power of AI.\n\n"
                      "I hope Taskly makes your day a little more productive.\n\n"
                      "— Marvis, Creator of Taskly",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: colorScheme.onSurface.withOpacity(0.8),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Listener(
                      onPointerDown: (_) =>
                          setState(() => _buttonScale = 0.96),
                      onPointerUp: (_) =>
                          setState(() => _buttonScale = 1.0),
                      onPointerCancel: (_) =>
                          setState(() => _buttonScale = 1.0),
                      child: SingleMotionBuilder(
                        motion: CupertinoMotion.snappy(),
                        value: _buttonScale,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _dismiss,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: const Text(
                              'Start Using Taskly',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                onPressed: _dismiss,
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductivityIllustration extends StatelessWidget {
  const _ProductivityIllustration();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 140,
      width: 140,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              'images/Marvito.png',
              width: 116,
              height: 116,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return Stack(
                  fit: StackFit.passthrough,
                  children: [
                    if (frame == null)
                      Container(
                        width: 116,
                        height: 116,
                        color: colorScheme.surfaceContainerHighest
                            .withOpacity(0.4),
                      ),
                    AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOut,
                      child: child,
                    ),
                  ],
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 116,
                  height: 116,
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  child: Icon(
                    Icons.error_outline,
                    size: 20,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
