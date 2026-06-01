import 'package:flutter/material.dart';
import 'package:app_jobfind/features/cv/models/cv_dto.dart';

/// Template HIỆN ĐẠI – Sidebar hồng nude bên trái, nội dung bên phải
class CvTemplateModern extends StatelessWidget {
  final CvDto? cvData;
  const CvTemplateModern({super.key, this.cvData});

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
    const accent = Color(0xFF8B3A3A);

    final name = d?.fullName?.isNotEmpty == true ? d!.fullName! : 'Họ và Tên';
    final pos = d?.targetPosition?.isNotEmpty == true
        ? d!.targetPosition!
        : 'Vị trí ứng tuyển';
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
          // ── LEFT SIDEBAR (hồng nude) ──
          Container(
            width: 170,
            color: const Color(0xFFFAF0EE),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade400,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Thông tin cá nhân
                _sLabel('Thông tin cá nhân', accent),
                if (dob.isNotEmpty) _sItem(Icons.cake, dob, accent),
                if (gender.isNotEmpty) _sItem(Icons.person, gender, accent),
                _sItem(Icons.phone, phone, accent),
                _sItem(Icons.email, email, accent),
                _sItem(Icons.location_on, addr, accent),
                if (linkedIn.isNotEmpty) _sItem(Icons.link, linkedIn, accent),
                if (gitHub.isNotEmpty) _sItem(Icons.code, gitHub, accent),

                // Học vấn SV
                if (uni.isNotEmpty || major.isNotEmpty || stuId.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sLabel('Học vấn', accent),
                  if (uni.isNotEmpty) _sItem(Icons.school, uni, accent),
                  if (major.isNotEmpty) _sItem(Icons.book, major, accent),
                  if (gpa.isNotEmpty) _sItem(Icons.grade, 'GPA: $gpa', accent),
                  if (stuId.isNotEmpty)
                    _sItem(Icons.badge, 'MSSV: $stuId', accent),
                ],

                // Kỹ năng
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sLabel('Kỹ năng', accent),
                  ...skills
                      .take(6)
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            '• ${s.skillName}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),

          // ── RIGHT MAIN CONTENT ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      color: accent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pos.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(height: 2, color: accent.withValues(alpha: 0.3)),
                  const SizedBox(height: 10),

                  // Bio
                  if (bio.isNotEmpty) ...[
                    Text(
                      bio,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
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

                  // Chứng chỉ
                  if (certs.isNotEmpty) ...[
                    _secTitle('Chứng chỉ', accent),
                    ...certs
                        .take(3)
                        .map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: _cert(
                              c.name,
                              c.issuingOrganization,
                              _fmt(c.issueDate),
                              accent,
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sLabel(String t, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 11),
    ),
  );

  Widget _sItem(IconData icon, String text, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: c, size: 11),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black87, fontSize: 9),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _secTitle(String t, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.toUpperCase(),
          style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 11),
        ),
        Container(
          height: 1,
          width: 40,
          color: c.withValues(alpha: 0.4),
          margin: const EdgeInsets.only(top: 2, bottom: 4),
        ),
      ],
    ),
  );

  Widget _exp(String pos, String company, String time, String desc, Color c) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pos,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 9, color: Colors.black45),
              ),
            ],
          ),
          Text(
            company,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: c.withValues(alpha: 0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (desc.isNotEmpty)
            Text(
              desc,
              style: const TextStyle(fontSize: 10, height: 1.4),
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              degree,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 9, color: Colors.black45),
          ),
        ],
      ),
      Text(
        inst,
        style: TextStyle(fontSize: 10, color: c.withValues(alpha: 0.7)),
        overflow: TextOverflow.ellipsis,
      ),
      if (field?.isNotEmpty == true)
        Text(
          field!,
          style: const TextStyle(fontSize: 9, color: Colors.black45),
        ),
      if (gpa?.isNotEmpty == true)
        Text(
          'GPA: $gpa',
          style: const TextStyle(fontSize: 9, color: Colors.black45),
        ),
    ],
  );

  Widget _cert(String name, String? org, String date, Color c) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.verified_outlined, size: 10, color: c),
      const SizedBox(width: 4),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
            if (org?.isNotEmpty == true || date.isNotEmpty)
              Text(
                '${org ?? ""}${date.isNotEmpty ? " · $date" : ""}',
                style: const TextStyle(fontSize: 9, color: Colors.black45),
              ),
          ],
        ),
      ),
    ],
  );
}
