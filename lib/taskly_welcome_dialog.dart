import 'package:flutter/material.dart';

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
                    // Illustration
                    const _ProductivityIllustration(),
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      "Hey there!",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Body Text
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
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          " Start Using Taskly",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            
            // Close Button
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
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
          // Background circles for depth
          Positioned(
            right: 10,
            top: 20,
            child: _Circle(size: 20, color: colorScheme.primary.withOpacity(0.2)),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: _Circle(size: 15, color: colorScheme.secondary.withOpacity(0.2)),
          ),
          
          // Central Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 60,
              color: colorScheme.primary,
            ),
          ),
          
          // Floating Task Checks
          Positioned(
            top: 30,
            left: 15,
            child: _FloatingElement(
              delay: 0,
              child: Icon(Icons.check_circle, color: Colors.green.shade400, size: 24),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 15,
            child: _FloatingElement(
              delay: 500,
              child: Icon(Icons.bolt_rounded, color: Colors.amber.shade400, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _FloatingElement extends StatefulWidget {
  final Widget child;
  final int delay;
  const _FloatingElement({required this.child, required this.delay});

  @override
  State<_FloatingElement> createState() => _FloatingElementState();
}

class _FloatingElementState extends State<_FloatingElement> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: widget.child,
        );
      },
    );
  }
}
