import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_message_model.dart';
import '../../logic/ai_chat/ai_chat_bloc.dart';
import '../../logic/ai_chat/ai_chat_event.dart';
import '../../logic/ai_chat/ai_chat_state.dart';

/// Màn hình Chat AI — giao diện bubble chat premium
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<AiChatBloc>().add(SendMessage(text));
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF16213E),
              child: Text('🎵', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Music AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Trợ lý âm nhạc thông minh',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white54),
            tooltip: 'Xóa cuộc trò chuyện',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text(
                    'Xóa cuộc trò chuyện?',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Toàn bộ tin nhắn sẽ bị xóa.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<AiChatBloc>().add(const ClearChat());
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text('Xóa'),
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
          // Danh sách tin nhắn
          Expanded(
            child: BlocConsumer<AiChatBloc, AiChatState>(
              listener: (context, state) => _scrollToBottom(),
              builder: (context, state) {
                if (state.messages.isEmpty) {
                  return _buildWelcomeScreen();
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length && state.isLoading) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(state.messages[index]);
                  },
                );
              },
            ),
          ),

          // Thanh nhập tin nhắn
          _buildInputBar(),
        ],
      ),
    );
  }

  /// Màn hình chào mừng khi chưa có tin nhắn
  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon AI
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.tealAccent.withValues(alpha: 0.3),
                    Colors.purpleAccent.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: const Center(
                child: Text('🎵', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Xin chào! Tôi là Music AI 🎶',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy hỏi tôi bất cứ điều gì về âm nhạc!',
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Gợi ý nhanh
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('🎤 Gợi ý bài hát V-Pop hay'),
                _buildSuggestionChip('🎸 Top nghệ sĩ Rock'),
                _buildSuggestionChip('🎧 Nhạc thư giãn'),
                _buildSuggestionChip('📝 Giải thích lời bài hát'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      onPressed: () {
        _controller.text = text.replaceAll(RegExp(r'[^\w\sÀ-ỹ]'), '').trim();
        _sendMessage();
      },
    );
  }

  /// Bubble tin nhắn
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFF16213E),
              child: Text('🎵', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.tealAccent.withValues(alpha: 0.2)
                    : const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.tealAccent.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: SelectableText(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.tealAccent[100] : Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// Typing indicator (3 chấm nhảy)
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF16213E),
            child: Text('🎵', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  /// Thanh nhập tin nhắn
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Hỏi về âm nhạc...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            BlocBuilder<AiChatBloc, AiChatState>(
              builder: (context, state) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: state.isLoading
                        ? null
                        : const LinearGradient(
                            colors: [Colors.tealAccent, Colors.teal],
                          ),
                    color: state.isLoading ? Colors.grey[800] : null,
                  ),
                  child: IconButton(
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.black),
                    onPressed: state.isLoading ? null : _sendMessage,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget 3 chấm nhảy — typing indicator
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger animations
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(0, _animations[i].value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
