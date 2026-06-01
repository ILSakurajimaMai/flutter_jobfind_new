// import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/cv/models/cv_dto.dart';
import 'package:app_jobfind/features/cv/services/cv_service.dart';
import 'package:app_jobfind/features/auth/viewmodels/auth_provider.dart';

final cvServiceProvider = Provider((ref) => CvService());

final cvProvider = AsyncNotifierProvider<CvNotifier, List<CvDto>>(() {
  return CvNotifier();
});

class CvNotifier extends AsyncNotifier<List<CvDto>> {
  @override
  Future<List<CvDto>> build() async {
    ref.watch(
      authProvider,
    ); // Tự động reset state khi authProvider thay đổi (Logout/Login)

    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      return []; // Không gọi API nếu chưa đăng nhập
    }

    final service = ref.read(cvServiceProvider);
    return await service.getMyCvs();
  }

  Future<void> fetchMyCvs() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(cvServiceProvider);
      final cvs = await service.getMyCvs();
      state = AsyncValue.data(cvs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> uploadAndCreateCv(Uint8List bytes, String fileName) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(cvServiceProvider);
      // Upload file to get URL
      final fileUrl = await service.uploadCvFile(bytes, fileName);

      // Create CV Record with the URL
      final newCv = CvDto(title: fileName, resumeUrl: fileUrl);
      await service.createCv(newCv);

      await fetchMyCvs(); // Refresh list to get all data including generated ID
      return true;
    } catch (e, st) {
      debugPrint("Upload Error: $e\n$st");
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> deleteCvAndFile(int cvId, String? fileUrl) async {
    try {
      final service = ref.read(cvServiceProvider);
      // Delete the file from the server if it exists
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          await service.deleteFile(fileUrl);
        } catch (e) {
          // Log error but continue to delete the DB record
          debugPrint("Warning: Failed to delete physical file: $e");
        }
      }

      // Delete the database record
      await service.deleteCv(cvId);

      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((cv) => cv.id != cvId).toList(),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTemplateCv({
    required String title,
    required String styleType,
  }) async {
    try {
      final service = ref.read(cvServiceProvider);
      final newCv = CvDto(title: title, targetPosition: styleType);
      final createdCv = await service.createCv(newCv);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, createdCv]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Tạo CV từ CvDto đầy đủ (dùng bởi CvEditScreen)
  Future<void> createCvFromDto(CvDto dto) async {
    try {
      final service = ref.read(cvServiceProvider);
      final createdCv = await service.createCv(dto);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, createdCv]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCv(int cvId, CvDto dto) async {
    try {
      final service = ref.read(cvServiceProvider);
      final updatedCv = await service.updateCv(cvId, dto);

      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.map((cv) => cv.id == cvId ? updatedCv : cv).toList(),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeCv(int cvId) async {
    try {
      final service = ref.read(cvServiceProvider);
      await service.deleteCv(cvId);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((cv) => cv.id != cvId).toList(),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setDefaultCv(int cvId) async {
    try {
      final service = ref.read(cvServiceProvider);
      await service.setDefaultCv(cvId);
      await fetchMyCvs(); // refresh
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
