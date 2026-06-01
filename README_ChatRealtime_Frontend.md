# 📱 Hướng Dẫn Tích Hợp Chat Realtime Trên Frontend (Flutter)

Tài liệu này hướng dẫn chi tiết cấu trúc kiến trúc, luồng hoạt động và cách triển khai tích hợp tính năng trò chuyện thời gian thực (Chat Realtime) trên ứng dụng Flutter sử dụng kiến trúc **MVVM** với **Riverpod State Management** và thư viện **SignalR NetCore**.

---

## 📌 1. Tổng Quan Kiến Trúc Frontend
Hệ thống chat ở phía Client được xây dựng theo mô hình phân lớp rõ ràng (Clean Architecture / MVVM):
1. **Model (Data Layer)**: Định nghĩa các cấu trúc dữ liệu (`ChatMessageDto`, `ChatConversationDto`, `SendMessageDto`).
2. **Service (Data Source Layer)**: Lớp `ChatService` đảm nhận các tương tác HTTP REST API với Server.
3. **ViewModel (Logic Layer)**: Lớp `ChatRoomViewModel` (quản lý bởi Riverpod Notifier) quản lý toàn bộ kết nối SignalR, lắng nghe sự kiện realtime và cập nhật trạng thái UI.
4. **View (UI Layer)**: Widget UI hiển thị dữ liệu tin nhắn, trạng thái kết nối, trạng thái đang gõ phím dựa trên dữ liệu từ ViewModel.

```
View (Widget UI) ──> Lắng nghe ──> ChatRoomState (Immutability)
      │                                 ▲
      ▼                                 │
ChatRoomViewModel ───────── Cập nhật ───┘
 (SignalR Connection)
      │
      ├─► REST API (ChatService - Tải tin nhắn lịch sử & Đọc tin)
      └─► WebSockets (SignalR Hub - Gửi/Nhận tin realtime, Typing...)
```

---

## 📁 2. Chi Tiết Các Lớp Triển Khai

### 2.1. Lớp Service: `ChatService`
Nằm tại: `lib/features/chat/services/chat_service.dart`
Quản lý tất cả các kết nối HTTP truyền thống, đóng vai trò:
* Tải danh sách cuộc trò chuyện và lịch sử tin nhắn khi vừa mở màn hình.
* Đánh dấu tin nhắn đã đọc.
* **Cơ chế dự phòng (Fallback)**: Cung cấp phương thức `sendMessageRest` để gửi tin nhắn qua giao thức HTTP POST trong trường hợp kết nối WebSocket/SignalR bị gián đoạn.

### 2.2. Lớp Trạng Thái: `ChatRoomState`
Nằm tại: `lib/features/chat/viewmodels/chat_room_viewmodel.dart`
Một lớp bất biến (Immutable State) biểu diễn dữ liệu của phòng chat tại một thời điểm:
* `messages`: Danh sách tin nhắn (`List<ChatMessageDto>`).
* `isLoading`: Trạng thái đang tải lịch sử tin nhắn.
* `isConnected`: Trạng thái kết nối thời gian thực với SignalR Hub.
* `isPeerTyping`: Trạng thái đối phương có đang soạn tin nhắn hay không (Typing Indicator).
* `error`: Thông báo lỗi nếu có.

### 2.3. Lớp Điều Khiển: `ChatRoomViewModel`
Nằm tại: `lib/features/chat/viewmodels/chat_room_viewmodel.dart`
Quản lý chính toàn bộ vòng đời của một cuộc trò chuyện thời gian thực.

---

## 🔄 3. Luồng Hoạt Động của ViewModel (Vòng Đời Phòng Chat)

### Luồng 1: Khởi Tạo (`_initializeChat`)
Khi màn hình chat chi tiết mở ra, Riverpod kích hoạt khởi tạo `ChatRoomViewModel` thông qua tham số `conversationId` (`NotifierProvider.family`):
1. **Bước 1**: Đẩy trạng thái `isLoading = true`.
2. **Bước 2**: Gọi API `ChatService.getMessages` để tải lịch sử tin nhắn và hiển thị lên màn hình.
3. **Bước 3**: Gọi API `ChatService.markAsRead` để xóa đếm tin nhắn chưa đọc của cuộc hội thoại này trên server và cập nhật UI danh sách ngoài.
4. **Bước 4**: Đọc Token JWT từ `SharedPreferences` (khóa `'accessToken'`).
5. **Bước 5**: Khởi tạo cấu hình `HubConnectionBuilder` với `Constants.hubUrl` và cài đặt hàm cấp Token tự động.
6. **Bước 6**: Đăng ký lắng nghe 3 sự kiện SignalR chính: `"ReceiveMessage"`, `"UserTyping"`, `"MessagesMarkedAsRead"`.
7. **Bước 7**: Bắt đầu kết nối (`start()`) và kích hoạt trạng thái `isConnected = true`.
8. **Bước 8**: Gửi yêu cầu `JoinConversation` lên Server để tham gia nhóm phòng chat.

### Luồng 2: Nhận Tin Nhắn Realtime (`_onReceiveMessage`)
Khi đối phương gửi tin nhắn, Server sẽ đẩy sự kiện `"ReceiveMessage"` về:
* **Nếu tin nhắn thuộc cuộc trò chuyện hiện tại**:
  1. Thêm tin nhắn mới vào đầu danh sách: `state.messages: [message, ...state.messages]`.
  2. Tự động gọi API `markAsRead` để báo cho server đã xem.
  3. Cập nhật nội dung tin nhắn mới nhất ra màn hình danh sách cuộc trò chuyện chính (`chatListProvider`) mà không tăng đếm số tin nhắn chưa đọc.
* **Nếu tin nhắn thuộc cuộc trò chuyện khác**:
  1. Kích hoạt cập nhật tin nhắn mới nhất và tự động tăng số lượng tin nhắn chưa đọc (`incrementUnread: true`) trên màn hình danh sách chính bên ngoài để người dùng biết có tin nhắn mới từ người khác.

### Luồng 3: Gửi Tin Nhắn và Cơ Chế Dự Phòng (`sendMessage`)
Khi người dùng bấm nút gửi:
1. Tạo đối tượng `SendMessageDto` chứa nội dung, ID cuộc trò chuyện và người nhận.
2. **Trường hợp Bình Thường (Đã Kết Nối)**: Gọi `HubConnection.invoke("SendMessage")` để gửi tin nhắn ngay lập tức qua WebSocket.
3. **Trường hợp Lỗi Kết Nối (Mất mạng/Hub ngắt kết nối)**:
   * ViewModel tự động chuyển sang gửi bằng HTTP POST thông qua `ChatService.sendMessageRest`.
   * Nhận kết quả phản hồi từ API, chèn trực tiếp tin nhắn vào danh sách cục bộ để đảm bảo trải nghiệm người dùng không bị gián đoạn.

### Luồng 4: Giải Phóng Kết Nối (`onDispose`)
Khi người dùng bấm nút back quay lại:
1. Riverpod tự động kích hoạt sự kiện giải phóng `onDispose`.
2. ViewModel gửi yêu cầu `LeaveConversation` lên server để rời nhóm phòng chat.
3. ViewModel đóng kết nối `HubConnection` thông qua phương thức `stop()`.
4. Đánh dấu cờ `_isDisposed = true` để ngăn chặn việc cập nhật trạng thái UI vào các tiến trình bất đồng bộ đang chạy dở.

---

## 💻 4. Hướng Dẫn Sử Dụng ViewModel Trong Giao Diện (View Layer)

Để lắng nghe và tương tác với phòng chat, Widget cần sử dụng `ConsumerWidget` hoặc `ConsumerStatefulWidget` từ Riverpod.

### 4.1. Lắng nghe Trạng thái Phòng Chat và Hiển thị
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/chat/viewmodels/chat_room_viewmodel.dart';

class ChatRoomScreen extends ConsumerWidget {
  final int conversationId;
  final int recipientId; // ID của đối tác chat

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.recipientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe trạng thái của phòng chat cụ thể qua Family Provider
    final chatState = ref.watch(chatRoomProvider(conversationId));
    final chatNotifier = ref.read(chatRoomProvider(conversationId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Trò chuyện"),
            // Hiển thị trạng thái đang gõ phím của đối phương
            if (chatState.isPeerTyping)
              const Text(
                "đối phương đang soạn tin...",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.green),
              ),
          ],
        ),
        actions: [
          // Hiển thị trạng thái kết nối thời gian thực
          Icon(
            chatState.isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: chatState.isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // 1. Danh sách tin nhắn
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true, // Tin nhắn mới ở dưới cùng
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatState.messages[index];
                      final isMe = msg.senderId != recipientId; // Xác định người gửi
                      return ChatBubble(message: msg, isMe: isMe);
                    },
                  ),
          ),
          
          // 2. Ô nhập liệu và các sự kiện soạn thảo
          ChatInputArea(
            onSend: (text) => chatNotifier.sendMessage(text, recipientId),
            onTypingChanged: (isTyping) => chatNotifier.sendTypingStatus(isTyping),
          ),
        ],
      ),
    );
  }
}
```

### 4.2. Xử lý Trạng thái Typing ở ô nhập liệu
Để tối ưu hiệu năng và tránh spam kết nối, chỉ gửi sự kiện `UpdateTyping` khi có sự thay đổi thực sự của bàn phím và sử dụng cơ chế trì hoãn (Debounce):

```dart
import 'dart:async';
import 'package:flutter/material.dart';

class ChatInputArea extends StatefulWidget {
  final Function(String) onSend;
  final Function(bool) onTypingChanged;

  const ChatInputArea({super.key, required this.onSend, required this.onTypingChanged});

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final _controller = TextEditingController();
  Timer? _typingTimer;
  bool _isTyping = false;

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      widget.onTypingChanged(true); // Báo đang soạn tin
    }

    // Cơ chế Debounce dừng gõ sau 2 giây không bấm phím
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        widget.onTypingChanged(false); // Báo dừng soạn tin
      }
    });
  }

  void _send() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
      if (_isTyping) {
        _isTyping = false;
        widget.onTypingChanged(false); // Gửi tin nhắn xong báo dừng gõ
      }
      _typingTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              decoration: const InputDecoration(placeholder: "Nhập tin nhắn..."),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _send),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }
}
```

---

## ⚠️ 5. Các Lưu Ý Quan Trọng khi Phát Triển
1. **Cấu hình Địa chỉ Hub**: Đảm bảo địa chỉ URL `Constants.hubUrl` trùng khớp với endpoint trên server (kể cả khi sử dụng local IP, Cloudflare Tunnel hoặc domain Production).
2. **Khóa Lưu Trữ SharedPreferences**: Khi đăng nhập thành công, token JWT bắt buộc phải được lưu với key `'accessToken'` dưới dạng String để ViewModel đọc được và truyền cho Hub.
3. **Phân trang danh sách tin nhắn**: Khi vuốt lên trên cùng màn hình (vì ListView reverse), hãy thiết lập sự kiện tải thêm tin nhắn lịch sử (gọi phương thức REST API `getMessages` tăng `pageNumber` lên).
