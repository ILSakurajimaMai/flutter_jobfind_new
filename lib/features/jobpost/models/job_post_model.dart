// lib/features/jobpost/models/job_post_model.dart
// Read model – nhận dữ liệu từ API

class JobPostModel {
  final int id;
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
  final int status; // 0=Draft, 1=Active, 2=Closed, 3=Expired
  final int viewCount;
  final int applicationCount;
  final bool isFeatured;
  final bool isUrgent;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> requiredSkills;

  JobPostModel({
    required this.id,
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
    this.updatedAt,
    required this.requiredSkills,
  });

  factory JobPostModel.fromJson(Map<String, dynamic> json) {
    return JobPostModel(
      id: json['id'] ?? 0,
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
      applicationDeadline: json['applicationDeadline'] != null
          ? DateTime.tryParse(json['applicationDeadline'])
          : null,
      status: json['status'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      applicationCount: json['applicationCount'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      isUrgent: json['isUrgent'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Nháp';
      case 1:
        return 'Đang tuyển';
      case 2:
        return 'Đã đóng';
      case 3:
        return 'Hết hạn';
      default:
        return 'Không xác định';
    }
  }

  String get salaryDisplay {
    if (salaryMin == null && salaryMax == null) return 'Thỏa thuận';
    final unit = _salaryUnit(salaryPeriod);
    if (salaryMin != null && salaryMax != null) {
      return '${_fmt(salaryMin!)} – ${_fmt(salaryMax!)} $unit';
    }
    if (salaryMax != null) return 'Đến ${_fmt(salaryMax!)} $unit';
    return 'Từ ${_fmt(salaryMin!)} $unit';
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}tr';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  String _salaryUnit(String? period) {
    switch (period) {
      case 'Hourly':
        return '/giờ';
      case 'Daily':
        return '/ngày';
      case 'Weekly':
        return '/tuần';
      default:
        return '/tháng';
    }
  }
}
