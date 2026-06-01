// lib/features/jobpost/models/job_shift_request.dart
// Sub-model cho ca làm việc trong form tạo tin

class JobShiftRequest {
  int dayOfWeek; // 0=Sunday, 1=Monday, ..., 6=Saturday
  String startTime; // "HH:mm"
  String endTime;   // "HH:mm"
  String? notes;

  JobShiftRequest({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'startTime': '$startTime:00',
        'endTime': '$endTime:00',
        if (notes != null) 'notes': notes,
      };

  static const dayLabels = [
    'Chủ nhật',
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
  ];

  String get dayLabel => dayLabels[dayOfWeek];
}
