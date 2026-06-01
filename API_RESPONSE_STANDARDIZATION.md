# Chuẩn hóa Logic xử lý API Response ở tầng Service

Tài liệu này mô tả chi tiết cách thức Frontend hoạt động sau khi cấu trúc phản hồi API (`ApiResponse`, `PaginatedListDto`) và lớp gọi API (`ApiClient`) đã được chuẩn hóa.

## 1. Cách thức hoạt động của các file Service sau khi chuẩn hóa

Trước đây, mỗi file Service phải tự chịu trách nhiệm gọi thư viện HTTP (Dio), tự viết vòng lặp `try...catch`, tự bắt các mã trạng thái (`statusCode == 200`), và tự bóc tách các trường JSON một cách thủ công. Điều này khiến code bị lặp lại rất nhiều.

Sau khi chuẩn hóa, luồng hoạt động diễn ra tuần tự qua các bước:

- **Bước 1: Tách biệt logic HTTP qua `ApiClient`**: Các file logic dữ liệu như `ProfileService`, `JobService` sẽ không còn kế thừa trực tiếp cấu hình hay thao tác trực tiếp với class `Dio`. Thay vào đó, chúng phụ thuộc vào lớp trung gian `ApiClient`.
- **Bước 2: Centralized Response Processing (Xử lý tập trung)**: Khi Service gọi hàm `_apiClient.get()` hoặc `_apiClient.post()`, bản thân `ApiClient` tại hàm `_handleResponse` sẽ đón nhận kết quả. Tại đây, hệ thống "kỳ vọng" Backend luôn trả về một khuôn mẫu JSON cố định (tương đương với `ApiResponse` ở backend):
  ```json
  {
    "success": true,
    "message": "Lấy thông tin thành công",
    "data": { "id": 1, "name": "Nguyên Văn A" }
  }
  ```
- **Bước 3: Tự động trích xuất Data (Bóc vỏ payload)**:
  - Nếu `success == true`: `ApiClient` sẽ tự động trích xuất chỉ duy nhất trường `data` (payload thực sự) và xoay ngược trả nguyên vẹn về cho bộ phân Service. Tầng Service hoàn toàn không cần phải tốn công trỏ qua lớp màng `success` hay `message` nữa.
  - Nếu `success == false`: `ApiClient` lập tức kiểm tra thông điệp lỗi (message) được backend cung cấp và ném ra một đối tượng `ApiException`.
- **Bước 4: Chuyển đổi siêu gọn tại Service**: Service lúc này nhận "dữ liệu sạch" (là Object đã được bọc vào bên trong thuộc tính Data). Nhiệm vụ mấu chốt và duy nhất của Service là Map dữ liệu Dictionary/Map JSON đó vào Object Dart tương ứng, ví dụ như `ProfileDto` hay `PaginatedListDto`.

```dart
// Code minh họa tại ProfileService siêu ngắn gọn:
Future<ProfileDto> getMyProfile() async {
  // Biến 'data' lúc này đã được loại bỏ lớp vỏ bọc 'ApiResponse' nhờ ApiClient.
  final data = await _apiClient.get('/profiles/me'); 
  return ProfileDto.fromJson(data);
}
```

## 2. Tác dụng của việc chuẩn hóa

- **Thống nhất cấu trúc dữ liệu**: Toàn bộ ứng dụng từ Frontend đến Backend đồng bộ nói chung một "ngôn ngữ": Khi cần kết quả thông thường ta có lớp vỏ bọc `success/message/data`, khi cần kết quả dạng phân trang ta luôn có `PaginatedListDto<T>` (kèm pageSize, totalCount). Tránh tình trạng mỗi API trả về một cấu trúc lung tung khác nhau.
- **Che giấu chi tiết triển khai Network**: Tầng Services (dành riêng lưu trữ business logic gọi API) không bị "loãng" hoặc "gánh" logic thiết lập Token vào header, logic chặn Refresh token đi kèm, hay bắt từng http code (200, 201, 500...). Mọi thứ được giấu bên trong khối Interceptor của `ApiClient`.
- **Tập trung hóa xử lý Ngoại Lệ (Exception)**: Tất cả những trục trặc từ đứt mạng internet, Timeout cho tới lỗi `Validation` do backend trả về đều bị chặn tại ổ `_handleError` (trong ApiClient) và quy đổi sang class `ApiException`. Các thông điệp ném ra đảm bảo đã được tối ưu ngôn ngữ hướng về người dùng ("Mất kết nối server", "Tài khoản không tồn tại"...).

## 3. Lợi ích khi được chuẩn hóa

1. **Dễ đọc, dễ bảo trì (Maintainability):** Mã nguồn ở mỗi lớp Services giảm độ dài trung bình từ 20-30 dòng cho 1 func chỉ còn vỏn vẹn 3-4 dòng. Lập trình viên mới nhìn vào file lập tức thấy ngay trọng tâm: gọi Endpoint (URL) nào và đúc (Parse) ra Model gì.
2. **Khả năng tái tạo cao (Reusability):** Cấu hình truyền Headers hay cơ chế kiểm tra token bây giờ chỉ cần viết **đúng một lần** ở constructor của lớp `ApiClient`. Bất kì Service nào tạo mới trong tương lai như ApplicationService, NotificationService... đều lập tức được dùng chung và miễn phí logic này.
3. **Mở rộng dễ dàng (Scalability):** Ví dụ mai sau dự án yêu cầu "Refresh lại Token" khi mã HTTP 401 ném về, bạn chỉ việc gõ thêm logic Refresh tại đúng 1 chỗ là lớp chặn (interceptor) của `ApiClient`. Hàng chục hay hàng trăm file Services không hề phải điều chỉnh dù chỉ một kí tự.
4. **An toàn, giảm thiểu Crash App:** Bỏ tình trạng lạm dụng `dynamic` và kiểu tra soát thủ công (`if data['status'] == 'ok'`). Việc chuẩn hóa ép toàn hệ thống ném trả lỗi về dạng thân thiện `ApiException`. Nhờ vậy, tầng giao diện (UI / ViewModel) có thể bắt chắt lỗi này và chủ động hiển ra `SnackBar` hoặc `Dialog` báo lỗi nhẹ nhàng, chấm dứt hoàn toàn trình trạng Crash sụp màn đỏ chói cho End-Users.
