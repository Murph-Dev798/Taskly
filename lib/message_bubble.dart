import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const MessageBubble({super.key, required this.text, required this.isUser});

  static const _userBubbleColor = Color.fromARGB(148, 200, 87, 87);
  static const _bubbleRadius = 22.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: isUser
                  ? BoxDecoration(
                      color: const Color.fromARGB(153, 210, 210, 210),
                      borderRadius: BorderRadius.circular(_bubbleRadius),
                    )
                  : null,
              child: Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
