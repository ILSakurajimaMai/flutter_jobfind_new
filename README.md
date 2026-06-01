# Tài Liệu Kỹ Thuật Frontend - Dự Án JobFind (Flutter)

Chào mừng đến với tài liệu giải thích chi tiết hoạt động của hệ thống Frontend (Ứng dụng di động) trong dự án **JobFind**. Tài liệu này được cấu trúc lại nhằm phản ánh trung thực kiến trúc phần mềm mới nhất theo chuẩn **MVVM (Model - View - ViewModel)** kết hợp với Feature-based module.

---

## 1. Cơ chế hoạt động của Frontend theo Kiến trúc MVVM

Frontend của JobFind đang được tổ chức theo kiến trúc **Feature-First MVVM**. Mỗi tính năng (Feature như `auth`, `user`, `employer`) đề cao tính đóng gói độc lập. Thay vì ném tất yếu giao diện vào một nơi hay tất cả Model vào một nơi, hệ thống chia nhỏ source code thành từng khối chức năng hoàn chỉnh. Theo thiết kế MVVM:

*   **Model (`models/`)**: Đóng vai trò là Tầng dữ liệu (Data Layer - bao gồm Data Transfer Objects). Xử lý việc định nghĩa cấu trúc dữ liệu JSON giao tiếp với API hoặc Database cục bộ, cùng các phương thức chuyển hóa trung gian `fromJson` và `toJson`.
*   **View (`views/`)**: Đóng vai trò là Tầng giao diện. Trọng tâm của `View` là việc kết xuất các Widget lên màn hình Flutter dựa trên dữ liệu (State) hiện tại. View chỉ chịu trách nhiệm thông báo bắt sự kiện (nhấn nút, vuốt, nhập chữ) lên ViewModel, và KHÔNG GỌI API hay chứa logic luồng quy trình phức tạp.
*   **ViewModel (`viewmodels/`)**: Đóng vai trò là Tầng quản lý trạng thái (State Management thông qua Riverpod). Đây là trái tim của logic nghiệp vụ frontend. Nó lắng nghe và nhận mệnh lệnh từ `View`, sau đó nhờ `Services` xử lý, nhận dữ liệu về, lưu vào Trạng thái (State), rồi tự động "bơm" Trạng thái mới này đẩy ngược lại cho `View` khiến `View` vẽ lại (Rebuild) thành công.
*   **Services (`services/`)**: Tuy không xếp chính thức vào tên MVVM, nhưng Services là phần mở rộng quan trọng trong ViewModel. Services tập trung duy nhất cho việc Call Network APIs thông qua file cốt lõi `ApiClient`.

**Luồng dữ liệu mẫu (Data Flow):**
> **View** `login_screen`: Người dùng nhập Email, Pass và ấn Đăng Nhập ➔ `View` gọi hàm `login()` bên trong tầng **ViewModel** `auth_provider` ➔ `ViewModel` yêu cầu **Services** `auth_service` gọi logic mạng ➔ Lớp `AuthService` bọc Data vào Request và gửi `POST /api/auth/login` bằng cấu hình `ApiClient` ➔ CSDL Backend xác thực và trả về JSON ➔ Phân tích JSON thành **Model** `AuthResponseDto` ➔ `ViewModel` đón lấy Model này và cập nhật lại `AuthState` (từ Đang Loading thành Thành Công) ➔ Khớp trạng thái State, **View** ngay lập tức redirect màn hình mới tự động.

---

## 2. Các thư viện (Packages) đã sử dụng

Các package trọng tâm đóng vai trò trụ cột giúp hiện thực hóa MVVM và vận hành Frontend:

1. **`flutter_riverpod` (`^3.3.1`)**: Thư viện State Management tối tân thay thế cơ chế State cũ kỹ. Riverpod đóng vai trò ViewModel với quy cách ràng buộc an toàn, cung cấp `Notifier` quản lý state và `Provider` cung ứng data giữa các Widget và lớp.
2. **`dio` (`^5.9.2`)**: Thư viện mạng (HTTP client). Xử lý Request/Response linh hoạt thông qua interceptors tự động ghép JWT Bearer Token vào Header, cấu hình base URLs, quản lý exception hiệu quả.
3. **`shared_preferences` (`^2.5.5`)**: Phục vụ lưu trữ Storage cục bộ (Local). Ghi nhớ mã `Token` và cấu hình hệ thống trên điện thoại thay vì bắt người dùng phải đăng nhập mỗi khi mở lại App.
4. **`intl` (`^0.20.2`)**: Cung cấp giải pháp DateTime formatter quốc tế hóa, hỗ trợ bóc tách DateTime Object để binding lên Input Date Picker trong hồ sơ người dùng.
5. **`cupertino_icons`**: Phục vụ bộ biểu tượng icon mặc định cho cấu trúc IOS.

---

## 3. Chức năng chi tiết của Từng File & Class & Function

Dự án được cấu trúc Feature-Based đọng gọn trong thư mục `lib/`. Dưới đây là chức năng chi tiết cho hệ sinh thái source code:

### 3.1. Lõi Hệ Thống & Khởi Tạo (`lib/` & `lib/core/`)

* **`main.dart`**: Entrypoint hệ thống.
  - **`main()`**: Khởi chạy ứng dụng Flutter với vỏ bọc `ProviderScope` (Kích hoạt Riverpod).
  - **`MyApp`** (Class): Khởi tạo tổng quan cấu trúc Material, gán điều hướng trang mặc định vào `SplashScreen`.
* **`core/constants.dart`**: Lưu trữ biến môi trường hằng số chung.
  - **`Constants`** (Class): Thuộc tính static hằng số `baseUrl` đóng vai trò URL trỏ tới cấu trúc Localhost backend (`http://10.0.2.2:5000` đối với máy ảo Android).
* **`core/api_client.dart`**: Xử lý Networking.
  - **`ApiClient`** (Class/Singleton): Cấu hình chung cho HTTP với thư viện `dio`. Tự động can thiệp mọi Request (Interceptor) để load mã `SharedPreferences` và nạp `Bearer Token` vào Header bảo mật. Đảm nhiệm nhận diện và quăng lỗi Response chuẩn cho ứng dụng.

### 3.2. Tính Năng Xác Thực (Feature: `lib/features/auth/`)

*   **Models**:
    - **`login_dto.dart` (`LoginDto`)**: Đối tượng tham số cho form Login gồm email, password.
    - **`register_dto.dart` (`RegisterDto`)**: Đối tượng tham số cho form Register.
    - **`auth_response_dto.dart` (`AuthResponseDto`)**: Đối tượng bóc tách JSON Trả về khi thành công chứa các key như `email`, `role`, `token`, `fullName`. Hàm `fromJson()` để mapping auto.
*   **Services**:
    - **`auth_service.dart` (`AuthService`)**: Tầng Network gọi `POST /api/auth/login` và `POST /api/auth/register`, hứng response rồi ném về đối tượng Models.
*   **ViewModels**:
    - **`auth_state.dart` (`AuthState`)**: Class lưu biến trạng thái bất biến, giữ cờ `isLoading`, error msg, và giá trị biến người dùng hiện tại `AuthResponseDto`. Cung cấp phương thức bất biến `copyWith()`.
    - **`auth_provider.dart` (`AuthProvider` - Notifier)**: Đóng vai trò là ViewModel tổng chỉ đạo cho quá trình đăng nhập/đăng ký.  Có các func:
        - `login()`, `register()`, `logout()`: Các func Action giao tiếp với Views & gọi Services, báo cáo thay đổi cho Views.
        - `loadToken()`: Giải mã SharedPreferences nạp trực tiếp JWT để điều hướng bypass Login lúc mở ứng dụng.
*   **Views**:
    - **`splash_screen.dart`**: Giao diện Loading khởi động, kích hoạt hàm ngầm `loadToken()` trong lúc load UX. Phân loại đường dẫn route dựa trên role `Student`/`Admin`.
    - **`login_screen.dart`**: Giao diện UI màn hình đăng nhập. Khi Submit, gọi Trigger lên ViewModel thay vì gọi trực tiếp API. Lắng nghe trạng thái State (role tương ứng) để redirect vào Home hợp lý.
    - **`register_screen.dart`**: Giao diện Đăng ký tài khoản người tìm việc (Role mặc định).

### 3.3. Tính Năng Người Dùng (Feature: `lib/features/user/`)

*   **Models**:
    - **`profile_dto.dart` (`ProfileDto`)**: Model Hồ sơ cá nhân người tìm việc. Mapping các properties phức tạp như DOB, Quận/Huyện, CV. Các func `fromJson()` và `toJson()` đóng vai trò Serialize gửi và nhận HTTP.
*   **Services**:
    - **`profile_service.dart` (`ProfileService`)**: Tương tác API bằng hàm `getMyProfile()` tải GET Info, và `updateProfile()` để nhận đẩy bằng lệnh POST với Payload JSON.
*   **ViewModels**:
    - **`profile_provider.dart`**: Gồm State `ProfileState` (chứa ProfileDto, bool Loading). ViewModel `ProfileNotifier` expose hàm `fetchProfile()` dành cho việc kéo dữ liệu dưới nền; và hàm `updateProfile()` để gửi yêu cầu đẩy từ Client giao diện lên Backend.
*   **Views**:
    - **`home/user_home_screen.dart` (`UserHomeScreen`)**: Giao diện Dashboard gồm 1 `BottomNavigationBar` ở Tabbar đáy. Dùng `IndexedStack` để giữ lại state cho tất cả 4 trang phụ bên trong.
    - **`profile/main_profile_screen.dart`**: Giao diện Profile User tĩnh, trang quản lý thẻ cá nhân và Menu điều hướng (Tạo Avatar từ ký tự đầu).
    - **`profile/edit_profile_screen.dart`**: Form động cập nhật hồ sơ với FormValidation & liên kết Provider. Truyền DatePicker bằng `intl`. Nơi có Func `_selectDate()`, `_save()` đồng bộ dữ liệu vào ViewModel khi submit.
    - **`profile/settings_screen.dart`**: Màn hình cài đặt hiện lên độc lập. Giải quyết logout với `_showLogoutDialog()`.

### 3.4. Tính Năng Nhà Tuyển Dụng (Feature: `lib/features/employer/`)

Hiện tính năng này được thiết kế như một phần mở rộng tương lai cho các Role Admin/Employer với khung cấu trúc sơ khởi tương tự MVVM.

*   **Views**:
    - **`home/employer_home_screen.dart` (`EmployerHomeScreen`)**: Màn hình Dashboard riêng biệt cho người sở hữu Role doanh nghiệp. Thiết kế View tích hợp nút **Thoát (Sign out)** cấu hình liên kết chuẩn với AuthViewModel để xóa phiên.

---

*Tài liệu này được đồng bộ và nâng cấp chuẩn kiến trúc mới của tổ hợp dự án mã nguồn JobFind.*
