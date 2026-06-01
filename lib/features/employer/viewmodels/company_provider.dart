// lib/features/employer/viewmodels/company_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/employer/models/company_dto.dart';
import 'package:app_jobfind/features/employer/services/company_service.dart';
import 'package:app_jobfind/features/auth/viewmodels/auth_provider.dart';

final companyServiceProvider = Provider((ref) => CompanyService());

class CompanyState {
  final bool isLoading;
  final String? error;
  final CompanyDto? company;
  final bool isPendingApproval;

  CompanyState({
    this.isLoading = false,
    this.error,
    this.company,
    this.isPendingApproval = false,
  });

  CompanyState copyWith({
    bool? isLoading,
    String? error,
    CompanyDto? company,
    bool? isPendingApproval,
  }) {
    return CompanyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      company: company ?? this.company,
      isPendingApproval: isPendingApproval ?? this.isPendingApproval,
    );
  }
}

final companyProvider = NotifierProvider<CompanyNotifier, CompanyState>(() {
  return CompanyNotifier();
});

class CompanyNotifier extends Notifier<CompanyState> {
  @override
  CompanyState build() {
    ref.watch(authProvider); // Reset when auth changes
    return CompanyState();
  }

  Future<void> fetchMyCompany() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(companyServiceProvider);
      final company = await service.getMyCompany();
      state = state.copyWith(isLoading: false, company: company, isPendingApproval: false);
    } catch (e) {
      // If company not found, check if there's a pending request
      try {
        final service = ref.read(companyServiceProvider);
        final pendingRequest = await service.getMyPendingRequest();
        if (pendingRequest != null) {
          state = state.copyWith(
            isLoading: false,
            company: pendingRequest,
            isPendingApproval: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: e.toString().replaceAll('Exception: ', ''),
            isPendingApproval: false,
          );
        }
      } catch (e2) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString().replaceAll('Exception: ', ''),
          isPendingApproval: false,
        );
      }
    }
  }

  Future<bool> saveCompany(CompanyDto dto) async {
    // Không cho phép lưu khi đang chờ duyệt
    if (state.isPendingApproval) {
      state = state.copyWith(error: 'Hồ sơ đang chờ Admin phê duyệt');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(companyServiceProvider);
      CompanyDto savedCompany;

      // Chỉ update nếu đây là công ty đã được duyệt (isVerified = true)
      // Không dùng ID của pending request để gọi PUT
      final isApprovedCompany = state.company?.id != null && state.company?.isVerified == true;

      if (isApprovedCompany) {
        // Update công ty đã được duyệt
        savedCompany = await service.updateCompany(state.company!.id!, dto);
      } else {
        // Tạo yêu cầu đăng ký mới
        savedCompany = await service.createCompany(dto);
        // Sau khi gửi yêu cầu, đánh dấu là đang chờ duyệt
        state = state.copyWith(
          isLoading: false,
          company: savedCompany,
          isPendingApproval: true,
        );
        return true;
      }

      state = state.copyWith(isLoading: false, company: savedCompany);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}
