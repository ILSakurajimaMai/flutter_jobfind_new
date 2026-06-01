// lib/features/job/models/job_post_dto.dart
class JobPostDto {
  final int id;
  final int? employerId;
  final String employerName;
  final String? employerAvatarUrl;
  final int companyId;
  final String companyName;
  final String? companyLogoUrl;
  final String title;
  final String description;
  final String? requirements;
  final String? benefits;
  final double? salaryMin;
  final double? salaryMax;
  final String? salaryPeriod;
  final String? location;
  final String? workType;
  final String? category;
  final int? numberOfPositions;
  final DateTime? applicationDeadline;
  final int status; // JobPostStatus enum equivalent
  final int viewCount;
  final int applicationCount;
  final bool isFeatured;
  final bool isUrgent;
  final DateTime createdAt;
  final List<String> requiredSkills;

  JobPostDto({
    required this.id,
    this.employerId,
    required this.employerName,
    this.employerAvatarUrl,
    required this.companyId,
    required this.companyName,
    this.companyLogoUrl,
    required this.title,
    required this.description,
    this.requirements,
    this.benefits,
    this.salaryMin,
    this.salaryMax,
    this.salaryPeriod,
    this.location,
    this.workType,
    this.category,
    this.numberOfPositions,
    this.applicationDeadline,
    required this.status,
    required this.viewCount,
    required this.applicationCount,
    required this.isFeatured,
    required this.isUrgent,
    required this.createdAt,
    required this.requiredSkills,
  });

  factory JobPostDto.fromJson(Map<String, dynamic> json) {
    return JobPostDto(
      id: json['id'] ?? 0,
      employerId: json['employerId'],
      employerName: json['employerName'] ?? '',
      employerAvatarUrl: json['employerAvatarUrl'],
      companyId: json['companyId'] ?? 0,
      companyName: json['companyName'] ?? '',
      companyLogoUrl: json['companyLogoUrl'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'],
      benefits: json['benefits'],
      salaryMin: (json['salaryMin'] as num?)?.toDouble(),
      salaryMax: (json['salaryMax'] as num?)?.toDouble(),
      salaryPeriod: json['salaryPeriod'],
      location: json['location'],
      workType: json['workType'],
      category: json['category'],
      numberOfPositions: json['numberOfPositions'],
      applicationDeadline: json['applicationDeadline'] != null ? DateTime.tryParse(json['applicationDeadline']) : null,
      status: json['status'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      applicationCount: json['applicationCount'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      isUrgent: json['isUrgent'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
