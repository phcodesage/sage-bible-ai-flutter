import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/utils/bible_reference_parser.dart';
import 'package:sagebible/features/ai/models/chat_message.dart';
import 'package:sagebible/features/ai/providers/ai_provider.dart';
import 'package:sagebible/features/auth/providers/auth_provider.dart';
import 'package:sagebible/features/bible/screens/bible_reader_screen.dart';

/// AI Assistant Screen
/// 
/// Chat with AI about biblical questions.
/// Requires authentication.
class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();
    
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final userId = ref.read(authProvider).user?.id;
    if (userId != null) {
      ref.read(aiProvider.notifier).sendMessage(userId, message);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final aiState = ref.watch(aiProvider);
    final user = authState.user;
    final messages = aiState.messages;

    // Scroll to bottom when messages change
    ref.listen(aiProvider, (previous, next) {
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        // Wait for list to build
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(aiProvider.notifier).clearChat();
            },
            tooltip: 'Clear Chat',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('AI Assistant'),
                  content: const Text(
                    'Ask questions about Bible verses, get explanations, and receive spiritual guidance powered by AI.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome message
          if (messages.isEmpty)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.psychology_rounded,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Hello, ${user?.name ?? "Friend"}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ask me anything about the Bible',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildSuggestionChip('What is love according to the Bible?'),
                          _buildSuggestionChip('Explain John 3:16'),
                          _buildSuggestionChip('How to pray effectively?'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                itemCount: messages.length + (aiState.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _buildMessageBubble(messages[index]);
                },
              ),
            ),

          // Error message
          if (aiState.error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      aiState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      // Clear error (would need a method in notifier, or just ignore)
                    },
                  ),
                ],
              ),
            ),

          // Input field
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !aiState.isLoading,
                    minLines: 1,
                    maxLines: 3,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: aiState.isLoading ? null : _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
    );
  }


  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: message.isUser
            ? Text(
                message.text,
                style: const TextStyle(color: Colors.white),
              )
            : _buildClickableText(message.text),
      ),
    );
  }

  Widget _buildClickableText(String text) {
    final matches = BibleReferenceParser.parse(text);
    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      );
    }

    final spans = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      // Add text before match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ));
      }

      // Add clickable match
      spans.add(TextSpan(
        text: match.text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BibleReaderScreen(
                  bookName: match.book,
                  chapterNumber: match.chapter,
                  highlightVerse: match.verse,
                ),
              ),
            );
          },
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
