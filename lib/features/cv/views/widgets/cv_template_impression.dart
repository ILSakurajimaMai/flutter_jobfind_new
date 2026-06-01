import 'package:flutter/material.dart';
import 'package:app_jobfind/features/cv/models/cv_dto.dart';

/// Template ẤN TƯỢNG – Sidebar nâu đậm bên trái, nội dung bên phải
class CvTemplateImpression extends StatelessWidget {
  final CvDto? cvData;
  const CvTemplateImpression({super.key, this.cvData});

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
    final gpa = d?.gpa?.toString() ?? '';
    final skills = d?.skills ?? [];
    final exps = d?.experiences ?? [];
    final edus = d?.educations ?? [];
    final certs = d?.certificates ?? [];

    const accent = Color(0xFF4A342E);

    return Container(
      width: 500,
      height: 707,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── LEFT SIDEBAR ──
          Container(
            width: 175,
            color: accent,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + Name
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.grey.shade400,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 3),
                Center(
                  child: Text(
                    pos,
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                _divider(),

                // Liên hệ
                _sideLabel('Liên hệ'),
                _sItem(Icons.phone, phone),
                _sItem(Icons.email, email),
                _sItem(Icons.location_on, addr),
                if (dob.isNotEmpty) _sItem(Icons.cake, dob),
                if (gender.isNotEmpty) _sItem(Icons.person_outline, gender),
                if (linkedIn.isNotEmpty) _sItem(Icons.link, linkedIn),
                if (gitHub.isNotEmpty) _sItem(Icons.code, gitHub),

                // Học vấn SV
                if (uni.isNotEmpty || major.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _divider(),
                  _sideLabel('Trường học'),
                  if (uni.isNotEmpty) _sItem(Icons.school, uni),
                  if (major.isNotEmpty) _sItem(Icons.book, major),
                  if (gpa.isNotEmpty) _sItem(Icons.grade, 'GPA: $gpa'),
                ],

                // Kỹ năng
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _divider(),
                  _sideLabel('Kỹ năng'),
                  ...skills
                      .take(5)
                      .map(
                        (s) => _skill(
                          s.skillName,
                          (s.proficiencyLevel ?? 3) / 5.0,
                        ),
                      ),
                ],
              ],
            ),
          ),

          // ── RIGHT CONTENT ──
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bio
                    if (bio.isNotEmpty) ...[
                      Text(
                        bio,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
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
                              ),
                            ),
                          ),
                    ],

                    // Học vấn
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
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _cert(
                                c.name,
                                c.issuingOrganization,
                                _fmt(c.issueDate),
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    height: 1,
    color: Colors.white24,
    margin: const EdgeInsets.only(bottom: 8),
  );

  Widget _sideLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      t.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 8,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );

  Widget _sItem(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      children: [
        Icon(icon, color: Colors.white60, size: 10),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 9),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _skill(String name, double val) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 9)),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: val,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation(Colors.white),
          minHeight: 3,
        ),
      ],
    ),
  );

  Widget _secTitle(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      t.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 9,
      ),
    ),
  );

  Widget _exp(String pos, String company, String time, String desc) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              pos,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 9, color: Colors.black54),
          ),
        ],
      ),
      Text(
        company,
        style: const TextStyle(
          fontSize: 10,
          fontStyle: FontStyle.italic,
          color: Colors.black54,
        ),
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
            style: const TextStyle(fontSize: 9, color: Colors.black54),
          ),
        ],
      ),
      Text(inst, style: const TextStyle(fontSize: 10, color: Colors.black54)),
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

  Widget _cert(String name, String? org, String date) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.verified, size: 10, color: Color(0xFF4A342E)),
      const SizedBox(width: 4),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
            if (org?.isNotEmpty == true)
              Text(
                '$org${date.isNotEmpty ? " · $date" : ""}',
                style: const TextStyle(fontSize: 9, color: Colors.black45),
              ),
          ],
        ),
      ),
    ],
  );
}
