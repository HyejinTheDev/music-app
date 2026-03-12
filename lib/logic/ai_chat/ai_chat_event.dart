import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

/// Gửi tin nhắn đến AI
class SendMessage extends AiChatEvent {
  final String message;
  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

/// Xóa toàn bộ lịch sử chat
class ClearChat extends AiChatEvent {
  const ClearChat();
}
