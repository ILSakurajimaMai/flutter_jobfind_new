// lib/features/jobpost/models/create_job_post_request.dart
// Write model – dữ liệu gửi lên API khi tạo hoặc cập nhật tin tuyển dụng

import 'job_shift_request.dart';

class CreateJobPostRequest {
  String title;
  String description;
  String? requirements;
  String? benefits;
  double? salaryMin;
  double? salaryMax;
  String? salaryPeriod; // Hourly | Daily | Weekly | Monthly
  String? location;
  String? workType;     // Full-time | Part-time | Freelance | Internship
  String? category;
  int? numberOfPositions;
  DateTime? applicationDeadline;
  bool isUrgent;
  List<String> requiredSkills;
  List<JobShiftRequest> shifts;

  CreateJobPostRequest({
    this.title = '',
    this.description = '',
    this.requirements,
    this.benefits,
    this.salaryMin,
    this.salaryMax,
    this.salaryPeriod = 'Monthly',
    this.location,
    this.workType = 'Part-time',
    this.category,
    this.numberOfPositions,
    this.applicationDeadline,
    this.isUrgent = false,
    List<String>? requiredSkills,
    List<JobShiftRequest>? shifts,
  })  : requiredSkills = requiredSkills ?? [],
        shifts = shifts ?? [];

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        if (requirements != null && requirements!.isNotEmpty) 'requirements': requirements,
        if (benefits != null && benefits!.isNotEmpty) 'benefits': benefits,
        if (salaryMin != null) 'salaryMin': salaryMin,
        if (salaryMax != null) 'salaryMax': salaryMax,
        if (salaryPeriod != null) 'salaryPeriod': salaryPeriod,
        if (location != null && location!.isNotEmpty) 'location': location,
        if (workType != null) 'workType': workType,
        if (category != null && category!.isNotEmpty) 'category': category,
        if (numberOfPositions != null) 'numberOfPositions': numberOfPositions,
        if (applicationDeadline != null)
          'applicationDeadline': applicationDeadline!.toIso8601String(),
        'requiredSkills': requiredSkills,
        'shifts': shifts.map((s) => s.toJson()).toList(),
      };
}
