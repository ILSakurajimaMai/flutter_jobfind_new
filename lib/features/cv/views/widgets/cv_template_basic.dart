import 'package:flutter/material.dart';
import 'package:app_jobfind/features/cv/models/cv_dto.dart';

/// Template CƠ BẢN – Nội dung chính bên trái, sidebar xanh nhạt bên phải
class CvTemplateBasic extends StatelessWidget {
  final CvDto? cvData;
  const CvTemplateBasic({super.key, this.cvData});

  String _fmt(String? iso) {
    if (iso == null || iso.length < 7) return '';
    final parts = iso.substring(0, 10).split('-');
    if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
    return iso.substring(0, 10);
  }

  String _fmtMonth(String? iso) {
    if (iso == null || iso.length < 7) return '';
    return iso.substring(0, 7);
  }

  @override
  Widget build(BuildContext context) {
    final d = cvData;
    const accent = Color(0xFF1E88E5);
    const sideColor = Color(0xFFE3F2FD);

    final name = d?.fullName?.isNotEmpty == true
        ? d!.fullName!.toUpperCase()
        : 'HỌ VÀ TÊN';
    final pos = d?.targetPosition?.isNotEmpty == true
        ? d!.targetPosition!.toUpperCase()
        : 'VỊ TRÍ ỨNG TUYỂN';
    final phone = d?.phoneNumber?.isNotEmpty == true
        ? d!.phoneNumber!
        : '0123 456 789';
    final email = d?.email?.isNotEmpty == true
        ? d!.email!
        : 'email@example.com';
    final addr = d?.address?.isNotEmpty == true ? d!.address! : 'Địa chỉ';
    final bio = d?.bio?.isNotEmpty == true ? d!.bio! : '';
    final gender = d?.gender != null
        ? (d!.gender == 0
              ? 'Nam'
              : d.gender == 1
              ? 'Nữ'
              : 'Khác')
        : '';
    final dob = _fmt(d?.dateOfBirth);
    final linkedIn = d?.linkedInUrl?.isNotEmpty == true ? d!.linkedInUrl! : '';
    final gitHub = d?.gitHubUrl?.isNotEmpty == true ? d!.gitHubUrl! : '';
    final uni = d?.university?.isNotEmpty == true ? d!.university! : '';
    final major = d?.major?.isNotEmpty == true ? d!.major! : '';
    final gpa = d?.gpa != null ? d!.gpa.toString() : '';
    final stuId = d?.studentId?.isNotEmpty == true ? d!.studentId! : '';
    final yearStudy = d?.yearOfStudy?.toString() ?? '';
    final skills = d?.skills ?? [];
    final exps = d?.experiences ?? [];
    final edus = d?.educations ?? [];
    final certs = d?.certificates ?? [];

    return Container(
      width: 500,
      height: 707,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── LEFT MAIN CONTENT ──
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.shade100,
                          border: Border.all(color: accent, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 42,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: accent,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              pos,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bio
                  if (bio.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bio,
                            style: const TextStyle(
                              fontSize: 9,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Kinh nghiệm
                  if (exps.isNotEmpty) ...[
                    _secTitle('Kinh nghiệm làm việc', accent),
                    ...exps
                        .take(2)
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _exp(
                              e.position,
                              e.companyName,
                              e.isCurrentlyWorking
                                  ? '${_fmtMonth(e.startDate)} - Nay'
                                  : '${_fmtMonth(e.startDate)} - ${_fmtMonth(e.endDate)}',
                              e.description ?? '',
                              accent,
                            ),
                          ),
                        ),
                  ] else ...[
                    _secTitle('Kinh nghiệm làm việc', accent),
                    _exp(
                      'Chức vụ',
                      'Tên công ty',
                      '2022 - Nay',
                      'Mô tả công việc.',
                      accent,
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Học vấn (list)
                  if (edus.isNotEmpty) ...[
                    _secTitle('Học vấn', accent),
                    ...edus
                        .take(2)
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _edu(
                              e.degree,
                              e.institutionName,
                              e.fieldOfStudy,
                              '${_fmtMonth(e.startDate)} - ${e.endDate != null ? _fmtMonth(e.endDate) : "Nay"}',
                              e.gpa?.toString(),
                              accent,
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),

          // ── RIGHT SIDEBAR (xanh nhạt) ──
          Container(
            width: 160,
            color: sideColor,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Liên hệ
                _sLabel('Liên hệ', accent),
                _sItem(Icons.phone, phone, accent),
                _sItem(Icons.email, email, accent),
                _sItem(Icons.location_on, addr, accent),
                if (dob.isNotEmpty) _sItem(Icons.cake, dob, accent),
                if (gender.isNotEmpty)
                  _sItem(Icons.person_outline, gender, accent),
                if (linkedIn.isNotEmpty) _sItem(Icons.link, linkedIn, accent),
                if (gitHub.isNotEmpty) _sItem(Icons.code, gitHub, accent),

                // Học vấn SV
                if (uni.isNotEmpty || major.isNotEmpty || stuId.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sLabel('Thông tin SV', accent),
                  if (stuId.isNotEmpty)
                    _sItem(Icons.badge, 'MSSV: $stuId', accent),
                  if (uni.isNotEmpty) _sItem(Icons.school, uni, accent),
                  if (major.isNotEmpty) _sItem(Icons.book, major, accent),
                  if (gpa.isNotEmpty) _sItem(Icons.grade, 'GPA: $gpa', accent),
                  if (yearStudy.isNotEmpty)
                    _sItem(Icons.calendar_today, 'Năm $yearStudy', accent),
                ],

                // Kỹ năng
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sLabel('Kỹ năng', accent),
                  ...skills
                      .take(5)
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 3,
                                  right: 4,
                                ),
                                child: Icon(
                                  Icons.circle,
                                  size: 4,
                                  color: accent,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  s.skillName,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],

                // Chứng chỉ
                if (certs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sLabel('Chứng chỉ', accent),
                  ...certs
                      .take(3)
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (c.issuingOrganization?.isNotEmpty == true)
                                Text(
                                  c.issuingOrganization!,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (c.issueDate?.isNotEmpty == true)
                                Text(
                                  _fmt(c.issueDate),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.black45,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sLabel(String t, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(Icons.circle, size: 6, color: c),
        const SizedBox(width: 4),
        Text(
          t.toUpperCase(),
          style: TextStyle(
            color: c,
            fontWeight: FontWeight.bold,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );

  Widget _sItem(IconData icon, String text, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 7),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _secTitle(String t, Color c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        t,
        style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 11),
      ),
      const SizedBox(height: 2),
      Container(height: 2, width: 24, color: c),
      const SizedBox(height: 8),
    ],
  );

  Widget _exp(String pos, String company, String time, String desc, Color c) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 9,
              color: c,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            pos,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
          Text(
            company,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black45,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (desc.isNotEmpty)
            Text(
              desc,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      );

  Widget _edu(
    String degree,
    String inst,
    String? field,
    String time,
    String? gpa,
    Color c,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        time,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: c),
      ),
      Text(
        degree,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      ),
      Text(
        inst,
        style: const TextStyle(fontSize: 10, color: Colors.black45),
        overflow: TextOverflow.ellipsis,
      ),
      if (field?.isNotEmpty == true)
        Text(
          field!,
          style: const TextStyle(fontSize: 9, color: Colors.black38),
        ),
      if (gpa?.isNotEmpty == true)
        Text('GPA: $gpa', style: TextStyle(fontSize: 9, color: c)),
    ],
  );
}
