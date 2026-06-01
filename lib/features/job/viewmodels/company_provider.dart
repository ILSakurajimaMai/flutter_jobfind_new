import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/job/models/company_dto.dart';
import 'package:app_jobfind/features/job/viewmodels/job_provider.dart';

final companyDetailProvider = FutureProvider.family<CompanyDto, int>((
  ref,
  companyId,
) async {
  final service = ref.read(jobServiceProvider);
  return await service.getCompanyById(companyId);
});
