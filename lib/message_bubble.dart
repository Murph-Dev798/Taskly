import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const MessageBubble({super.key, required this.text, required this.isUser});

  static const _userGradientColors = [
    Color(0xFF2A2A2A),
    Color(0xFF0A0A0A),
  ];

  static const _assistantGradientColors = [
    Color(0xFF4A4A4A),
    Color(0xFF1E1E1E),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final gradientColors =
        isUser ? _userGradientColors : _assistantGradientColors;

    final textColor = isUser ? Colors.white : Colors.white70;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: ClipPath(
                  clipper: ChatBubbleClipper(isUser: isUser),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      isUser ? 16.0 : 22.0, // Extra padding for the beak
                      12.0,
                      isUser ? 22.0 : 16.0, // Extra padding for the beak
                      12.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 249, 249)
                              .withAlpha(40),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class ChatBubbleClipper extends CustomClipper<Path> {
  final bool isUser;
  final double radius;

  ChatBubbleClipper({required this.isUser, this.radius = 20.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    const beakWidth = 8.0;

    if (isUser) {
      // User bubble (Beak at bottom right)
      path.moveTo(radius, 0);
      path.lineTo(width - radius, 0);
      path.arcToPoint(Offset(width, radius), radius: Radius.circular(radius));
      path.lineTo(width, height - radius);
      
      // The Beak (bottom right)
      path.lineTo(width, height);
      path.lineTo(width - beakWidth, height - beakWidth / 2);
      
      path.lineTo(radius, height);
      path.arcToPoint(Offset(0, height - radius), radius: Radius.circular(radius));
      path.lineTo(0, radius);
      path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));
    } else {
      // Assistant bubble (Beak at bottom left)
      path.moveTo(radius, 0);
      path.lineTo(width - radius, 0);
      path.arcToPoint(Offset(width, radius), radius: Radius.circular(radius));
      path.lineTo(width, height - radius);
      path.arcToPoint(Offset(width - radius, height), radius: Radius.circular(radius));
      
      // The Beak (bottom left)
      path.lineTo(beakWidth, height - beakWidth / 2);
      path.lineTo(0, height);
      
      path.lineTo(0, radius);
      path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
