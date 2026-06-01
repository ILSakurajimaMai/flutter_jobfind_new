// lib/features/application/models/application_dto.dart

class ApplicationDto {
  final int id;
  final int jobPostId;
  final String jobTitle;
  final String companyName;
  final String? companyLogoUrl;
  final int? employerId;
  final String employerName;
  final int profileId;
  final String applicantName;
  final int statusId;
  final String statusName;
  final String? coverLetter;
  final String? resumeUrl;
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  ApplicationDto({
    required this.id,
    required this.jobPostId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogoUrl,
    this.employerId,
    required this.employerName,
    required this.profileId,
    required this.applicantName,
    required this.statusId,
    required this.statusName,
    this.coverLetter,
    this.resumeUrl,
    required this.appliedAt,
    this.reviewedAt,
    this.reviewNotes,
  });

  factory ApplicationDto.fromJson(Map<String, dynamic> json) {
    return ApplicationDto(
      id: json['id'] ?? 0,
      jobPostId: json['jobPostId'] ?? 0,
      jobTitle: json['jobTitle'] ?? '',
      companyName: json['companyName'] ?? '',
      companyLogoUrl: json['companyLogoUrl'],
      employerId: json['employerId'],
      employerName: json['employerName'] ?? '',
      profileId: json['profileId'] ?? 0,
      applicantName: json['applicantName'] ?? '',
      statusId: json['statusId'] ?? 1,
      statusName: json['statusName'] ?? '',
      coverLetter: json['coverLetter'],
      resumeUrl: json['resumeUrl'],
      appliedAt: json['appliedAt'] != null ? DateTime.parse(json['appliedAt']) : DateTime.now(),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      reviewNotes: json['reviewNotes'],
    );
  }
}
