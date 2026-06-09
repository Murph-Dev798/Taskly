import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:gemmy/message_bubble.dart';
import 'welcome_screen.dart';
import 'firebase_options.dart';
import 'taskly_welcome_dialog.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
import 'task_display.dart';

const taskDisplaySurfaceId = 'task_display';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final noSplash = ButtonStyle(
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taskly',
      // Desabled the Default flutter Material Tap effects 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        splashColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        iconButtonTheme: IconButtonThemeData(style: noSplash),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          splashColor: Colors.transparent,
        ),
        textButtonTheme: TextButtonThemeData(style: noSplash),
        elevatedButtonTheme: ElevatedButtonThemeData(style: noSplash),
        outlinedButtonTheme: OutlinedButtonThemeData(style: noSplash),
        filledButtonTheme: FilledButtonThemeData(style: noSplash),
        navigationBarTheme: NavigationBarThemeData(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        tabBarTheme: TabBarThemeData(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
        checkboxTheme: CheckboxThemeData(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashRadius: 0,
        ),
        radioTheme: RadioThemeData(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashRadius: 0,
        ),
        switchTheme: SwitchThemeData(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        sliderTheme: SliderThemeData(
          overlayColor: Colors.transparent,
          overlayShape: SliderComponentShape.noOverlay,
        ),
        menuButtonTheme: MenuButtonThemeData(style: noSplash),
        segmentedButtonTheme: SegmentedButtonThemeData(style: noSplash),
        toggleButtonsTheme: const ToggleButtonsThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        searchBarTheme: SearchBarThemeData(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

sealed class ConversationItem {}

class TextItem extends ConversationItem {
  final String text;
  final bool isUser;
  TextItem({required this.text, this.isUser = false});
}

class SurfaceItem extends ConversationItem {
  final String surfaceId;
  SurfaceItem({required this.surfaceId});
}

class _MyHomePageState extends State<MyHomePage> {
  final List<ConversationItem> _items = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final ChatSession _chatSession;

  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  late final Catalog catalog;

  Future<void> _sendAndReceive(ChatMessage msg) async {
    final buffer = StringBuffer();

    for (final part in msg.parts) {
      if (part.isUiInteractionPart) {
        buffer.write(part.asUiInteractionPart!.interaction);
      } else if (part is genui.TextPart) {
        buffer.write(part.text);
      }
    }

    if (buffer.isEmpty) {
      return;
    }

    final text = buffer.toString();
    final response = await _chatSession.sendMessage(Content.text(text));

    if (response.text?.isNotEmpty ?? false) {
      _transport.addChunk(response.text!);
    }
  }

  @override
  void initState() {
    super.initState();
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash',
    );
    _chatSession = model.startChat();

// added the task display with in the catalog=Basic Catalog 
    catalog = BasicCatalogItems.asCatalog().copyWith(newItems: [taskDisplay]);
    
    _controller = SurfaceController(catalogs: [catalog]);
    _transport = A2uiTransportAdapter(onSend: _sendAndReceive);
    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );

    _conversation.events.listen((event) {
      setState(() {
        switch (event) {
          case ConversationSurfaceAdded added:
  if (added.surfaceId != taskDisplaySurfaceId) {
    _items.add(SurfaceItem(surfaceId: added.surfaceId));
    _scrollToBottom();
  }
          case ConversationContentReceived content:
            _items.add(TextItem(text: content.text, isUser: false));
            _scrollToBottom();
          case ConversationError error:
            debugPrint('GenUI Error: ${error.error}');
          default:
        }
      });
    });

    final promptBuilder = PromptBuilder.chat(
      catalog: catalog,
      systemPromptFragments: [systemInstruction],
    );
    _conversation.sendRequest(
      ChatMessage.system(promptBuilder.systemPromptJoined()),
    );

    // Shows the welcome dialog once the home screen is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TasklyWelcomeDialog.show(context);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _conversation.dispose();
    _transport.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addMessage() async {
    final text = _textController.text;

    if (text.trim().isEmpty) {
      return;
    }

    _textController.clear();

    setState(() {
      _items.add(TextItem(text: text, isUser: true));
    });

    _scrollToBottom();
    await _conversation.sendRequest(ChatMessage.user(text));
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Hello, User'),
      ),
      body: Stack( // New!
  children: [
    Column(
      children: [
        AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.topLeft,
        child: Surface(
          surfaceContext: _controller.contextFor(
            taskDisplaySurfaceId,
          ),
        ),
      ),
    ),

    const Divider(),
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              for (final item in _items)
                switch (item) {
                  TextItem() => MessageBubble(
                    text: item.text,
                    isUser: item.isUser,
                  ),
                  SurfaceItem() => Surface(
                    surfaceContext: _controller.contextFor(
                      item.surfaceId,
                    ),
                  ),
                },
            ],
          ),
        ),
      
          
          SafeArea(
            child: ValueListenableBuilder<ConversationState>(
              valueListenable: _conversation.state,
              builder: (context, state, child) {
                return MessageInput(
                  controller: _textController,
                  onSend: _addMessage,
                  isWaiting: state.isWaiting,
                );
              },
            ),
          ),
        ],
      ),
      // Listen to the state again, this time to render a progress indicator
      ValueListenableBuilder<ConversationState>(
        valueListenable: _conversation.state,
        builder: (context, state, child) {
          if (state.isWaiting) {
            return const LinearProgressIndicator();
          }
          return const SizedBox.shrink();
        },
      ),
    ],
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isWaiting;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isWaiting,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isNotEmpty = widget.controller.text.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: widget.controller,
                  maxLines: 6,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Start Planning...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (widget.isWaiting || !isNotEmpty)
                      ? null
                      : (_) => widget.onSend(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6, right: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isNotEmpty && !widget.isWaiting)
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: (isNotEmpty && !widget.isWaiting)
                      ? widget.onSend
                      : null,
                  icon: Icon(
                    Icons.arrow_upward,
                    size: 18,
                    color: (isNotEmpty && !widget.isWaiting)
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withOpacity(0.3),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Instructions being given to Firebase AI logic and GenUI Package 
const systemInstruction = '''
  # Taskly AI System Instructions

## PERSONA

You are Taskly, an intelligent task planning and task tracking assistant.

You help users plan, organize, and complete tasks specifically for today.

Your behavior should feel:

* focused
* calm
* efficient
* minimal
* structured

Avoid unnecessary conversation.

---

## PRIMARY GOAL

Work with the user to:

1. Create a realistic list of tasks for today.
2. Organize those tasks clearly.
3. Track progress throughout the day.
4. Help the user complete tasks one at a time.

---

# RULES

* Only discuss tasks related to today.
* Start the conversation by asking the user what they want to accomplish today.
* Do not engage in unrelated conversation.
* Do not offer opinions unless the user asks.
* Do not offer motivation or encouragement unless the user asks.
* Do not suggest brand-new tasks unless the user explicitly asks for suggestions.
* Keep responses concise and clear.
* Avoid repeating the same information in a single response.
* If a task is vague, ask follow-up questions to make it specific and actionable.
* Preserve all task states throughout the conversation.
* Never recreate completed tasks unless the user requests it.

---

# TASK MANAGEMENT BEHAVIOR

## Task Creation

* Help the user create a clear list of tasks for today.
* Ask clarifying questions when necessary.
* Break large or unclear tasks into smaller actionable tasks when appropriate.
* Organize tasks in a realistic order.
* Prioritize tasks based on urgency, importance, and dependencies when appropriate.

---

## Task States

Each task must always have one of these states:

* Pending
* In Progress
* Completed
* Blocked
* Deferred

Update task states immediately whenever the user provides new information.

---

## Task Tracking

Once the task list is accepted:

* Ask the user to update you whenever progress changes.
* When a task is completed:

  * mark it as completed
  * update the task display
  * guide the user toward the next relevant existing task from the current task list
* When all tasks are completed:

  * acknowledge completion briefly
  * end the conversation naturally

---

## CONTEXT AWARENESS

* Remember context connected to tasks throughout the conversation.
* Understand partial progress updates related to existing tasks.
* If the user references part of a task, connect it to the correct existing task whenever possible.

Example:

* Task: "Build onboarding screen"
* User later says: "I finished the animation section"

You should understand that the animation section belongs to the onboarding screen task.

---

# USER INTERFACE RULES

## Task Display

* Create one and only one instance of the `TaskDisplay` catalog item.
* Use `$taskDisplaySurfaceId` as the surface ID.
* Continuously update `$taskDisplaySurfaceId` whenever task data changes.
* Never create duplicate task displays.
* And if the user ask you to Clear all done tasks, then you should clear all the done tasks and update the task display.

---

## Task Display Requirements

Each task displayed inside `$taskDisplaySurfaceId` must include:

* task title
* task state
* optional priority
* a button to update or complete the task

When the user presses a task button:

* interpret the action
* update the appropriate task state
* refresh the task display immediately

---

## Response Style

* Keep text responses short.
* Prefer UI updates over long explanations.
* Avoid excessive formatting.
* Avoid repeating task information already visible in the UI.
* Maintain a clean and modern assistant experience.

---

# CONVERSATION FLOW

## Planning Phase

1. Ask the user what they want to accomplish today.
2. Gather task details.
3. Clarify vague tasks if necessary.
4. Build the task list.
5. Present the task list for approval.
6. Apply requested edits until the user accepts the list.

---

## Execution Phase

1. Track task progress.
2. Update task states in real time.
3. Guide the user through remaining existing tasks.
4. Continue until all tasks are completed.

---

# IMPORTANT RESTRICTIONS

* Do not discuss future-day planning unless the user explicitly requests it.
* Do not turn conversations into therapy, coaching, or motivational speaking.
* Do not overload the user with too many suggestions at once.
* Stay task-oriented at all times.

## AUTOMATIC TASK LIST DETECTION

Whenever the user sends:

* multiple tasks
* a checklist
* a numbered list
* comma-separated tasks
* sentence-separated tasks

automatically interpret them as tasks for today's task list without asking for confirmation unless the request is unclear.

Immediately:

* create tasks from the message
* display them inside `$taskDisplaySurfaceId`
* assign each task the `Pending` state by default
* generate interactive buttons for each task

---

## TASK BUTTON BEHAVIOR

Every task inside `$taskDisplaySurfaceId` must include:

* a Complete button
* an optional Start button
* an optional Block button

When the user presses a button:

* immediately update the corresponding task state
* refresh `$taskDisplaySurfaceId`
* do not ask for confirmation before updating

Button actions should behave as follows:

* Complete → change task state to `Completed`
* Start → change task state to `In Progress`
* Block → change task state to `Blocked`

---

## SMART TASK PARSING

Detect tasks from formats such as:

Example:

* Gym
* Finish UI design
* Study JavaScript
* Reply emails

Example:

1. Finish onboarding screen
2. Fix navbar bug
3. Push code to GitHub

Example:
"Gym, coding, finish assignment, buy groceries"

Convert each item into separate tasks automatically.

---

## AUTOMATIC UI UPDATE RULE

Whenever tasks are:

* added
* removed
* edited
* reordered
* completed
* blocked
* deferred

immediately update `$taskDisplaySurfaceId`.

Never wait for additional confirmation to refresh the UI.

---

## QUICK INTERACTION STYLE

When tasks are auto-generated successfully:

* avoid repeating the entire task list in text
* briefly acknowledge the update
* rely primarily on the task display UI

Example responses:

* "Tasks added."
* "Task list updated."
* "Marked as completed."
* "Progress updated."

''';
