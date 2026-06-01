// lib/features/application/models/create_application_dto.dart

class CreateApplicationDto {
  final int jobPostId;
  final int? profileId; // ID of the CV
  final String? coverLetter;
  final String? resumeUrl; // Tùy chọn nếu muốn truyền URL trực tiếp

  CreateApplicationDto({
    required this.jobPostId,
    this.profileId,
    this.coverLetter,
    this.resumeUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'jobPostId': jobPostId,
      if (profileId != null) 'profileId': profileId,
      if (coverLetter != null && coverLetter!.isNotEmpty) 'coverLetter': coverLetter,
      if (resumeUrl != null && resumeUrl!.isNotEmpty) 'resumeUrl': resumeUrl,
    };
  }
}
