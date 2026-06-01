import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/user/models/profile_dto.dart';
import 'package:app_jobfind/features/user/services/profile_service.dart';
import 'package:app_jobfind/features/auth/viewmodels/auth_provider.dart';

/// Provider cung cấp đối tượng ProfileService để có thể gọi ở bất kì đâu
final profileServiceProvider = Provider((ref) => ProfileService());

/// Trạng thái của màn hình Profile lưu trữ trạng thái load, thông báo lỗi và dữ liệu hồ sơ
class ProfileState {
  final bool
  isLoading; // Đánh dấu API đang chạy hay không để hiện vòng xoay quay quay
  final String? error; // Lưu trữ lỗi nếu gọi API thất bại
  final ProfileDto? profile; // Lưu trữ đối tượng ProfileDto tải từ Backend

  ProfileState({this.isLoading = false, this.error, this.profile});

  /// Hàm copyWith giúp tạo mới state bằng cách sao chép thuộc tính cũ và đè dữ liệu mới lên
  ProfileState copyWith({bool? isLoading, String? error, ProfileDto? profile}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // overwrite error nếu thay đổi rõ ràng
      profile: profile ?? this.profile,
    );
  }
}

/// ProfileProvider chịu trách nhiệm nạp dữ liệu và đẩy xuống các Widget UI đang lắng nghe
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    ref.watch(
      authProvider,
    ); // Tự động reset state khi authProvider thay đổi (Logout/Login)
    return ProfileState(); // Khởi tạo state gốc mặc định
  }

  /// Hàm lấy hồ sơ gọi từ API
  Future<void> fetchProfile() async {
    // Sửa trạng thái thành "Đang Load"
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(profileServiceProvider);
      // Chờ dịch vụ lấy dữ liệu về
      final profile = await service.getMyProfile();
      // Hoàn tất, tắt vòng xoay loading và lưu lại ProfileDto
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      // Nếu thất bại thì báo lỗi dạng chữ
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Hàm cập nhật hồ sơ lên API
  Future<bool> updateProfile(ProfileDto dto) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(profileServiceProvider);
      final updatedProfile = await service.updateProfile(dto);
      // Gán đè dữ liệu cũ bằng dữ liệu mới nhất
      state = state.copyWith(isLoading: false, profile: updatedProfile);
      return true; // Báo UI biết là thành công
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false; // Báo UI biết là thất bại
    }
  }
}
