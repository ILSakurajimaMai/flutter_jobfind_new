class CvDto {
  final int? id;
  final int? userId;
  final String? title;
  final String? targetPosition;
  final bool isDefault;
  final String? fullName;
  final String? email;
  final String? dateOfBirth;
  final int? gender;
  final String? address;
  final String? phoneNumber;
  final String? studentId;
  final String? university;
  final String? major;
  final double? gpa;
  final int? yearOfStudy;
  final String? expectedGraduationDate;
  final String? resumeUrl;
  final String? bio;
  final String? linkedInUrl;
  final String? gitHubUrl;
  final List<CvSkillDto>? skills;
  final List<CvExperienceDto>? experiences;
  final List<CvEducationDto>? educations;
  final List<CvCertificateDto>? certificates;

  CvDto({
    this.id,
    this.userId,
    this.title,
    this.targetPosition,
    this.isDefault = false,
    this.fullName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.phoneNumber,
    this.studentId,
    this.university,
    this.major,
    this.gpa,
    this.yearOfStudy,
    this.expectedGraduationDate,
    this.resumeUrl,
    this.bio,
    this.linkedInUrl,
    this.gitHubUrl,
    this.skills,
    this.experiences,
    this.educations,
    this.certificates,
  });

  factory CvDto.fromJson(Map<String, dynamic> json) {
    return CvDto(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      targetPosition: json['targetPosition'],
      isDefault: json['isDefault'] ?? false,
      fullName: json['fullName'],
      email: json['email'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      studentId: json['studentId'],
      university: json['university'],
      major: json['major'],
      gpa: json['gpa']?.toDouble(),
      yearOfStudy: json['yearOfStudy'],
      expectedGraduationDate: json['expectedGraduationDate'],
      resumeUrl: json['resumeUrl'],
      bio: json['bio'],
      linkedInUrl: json['linkedInUrl'],
      gitHubUrl: json['gitHubUrl'],
      skills: json['skills'] != null
          ? (json['skills'] as List).map((i) => CvSkillDto.fromJson(i)).toList()
          : null,
      experiences: json['experiences'] != null
          ? (json['experiences'] as List)
                .map((i) => CvExperienceDto.fromJson(i))
                .toList()
          : null,
      educations: json['educations'] != null
          ? (json['educations'] as List)
                .map((i) => CvEducationDto.fromJson(i))
                .toList()
          : null,
      certificates: json['certificates'] != null
          ? (json['certificates'] as List)
                .map((i) => CvCertificateDto.fromJson(i))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (title != null) 'title': title,
      if (targetPosition != null) 'targetPosition': targetPosition,
      'isDefault': isDefault,
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (studentId != null) 'studentId': studentId,
      if (university != null) 'university': university,
      if (major != null) 'major': major,
      if (gpa != null) 'gpa': gpa,
      if (yearOfStudy != null) 'yearOfStudy': yearOfStudy,
      if (expectedGraduationDate != null)
        'expectedGraduationDate': expectedGraduationDate,
      if (resumeUrl != null) 'resumeUrl': resumeUrl,
      if (bio != null) 'bio': bio,
      if (linkedInUrl != null) 'linkedInUrl': linkedInUrl,
      if (gitHubUrl != null) 'gitHubUrl': gitHubUrl,
      if (skills != null) 'skills': skills!.map((i) => i.toJson()).toList(),
      if (experiences != null)
        'experiences': experiences!.map((i) => i.toJson()).toList(),
      if (educations != null)
        'educations': educations!.map((i) => i.toJson()).toList(),
      if (certificates != null)
        'certificates': certificates!.map((i) => i.toJson()).toList(),
    };
  }
}

class CvSkillDto {
  final int? id;
  final String skillName;
  final int? proficiencyLevel;
  final int? yearsOfExperience;

  CvSkillDto({
    this.id,
    required this.skillName,
    this.proficiencyLevel,
    this.yearsOfExperience,
  });

  factory CvSkillDto.fromJson(Map<String, dynamic> json) {
    return CvSkillDto(
      id: json['id'],
      skillName: json['skillName'] ?? '',
      proficiencyLevel: json['proficiencyLevel'],
      yearsOfExperience: json['yearsOfExperience'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'skillName': skillName,
      if (proficiencyLevel != null) 'proficiencyLevel': proficiencyLevel,
      if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
    };
  }
}

class CvExperienceDto {
  final int? id;
  final String companyName;
  final String position;
  final String? description;
  final String startDate;
  final String? endDate;
  final bool isCurrentlyWorking;

  CvExperienceDto({
    this.id,
    required this.companyName,
    required this.position,
    this.description,
    required this.startDate,
    this.endDate,
    this.isCurrentlyWorking = false,
  });

  factory CvExperienceDto.fromJson(Map<String, dynamic> json) {
    return CvExperienceDto(
      id: json['id'],
      companyName: json['companyName'] ?? '',
      position: json['position'] ?? '',
      description: json['description'],
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'],
      isCurrentlyWorking: json['isCurrentlyWorking'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'companyName': companyName,
      'position': position,
      if (description != null) 'description': description,
      'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      'isCurrentlyWorking': isCurrentlyWorking,
    };
  }
}

class CvEducationDto {
  final int? id;
  final String institutionName;
  final String degree;
  final String? fieldOfStudy;
  final String startDate;
  final String? endDate;
  final double? gpa;
  final String? description;

  CvEducationDto({
    this.id,
    required this.institutionName,
    required this.degree,
    this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.gpa,
    this.description,
  });

  factory CvEducationDto.fromJson(Map<String, dynamic> json) {
    return CvEducationDto(
      id: json['id'],
      institutionName: json['institutionName'] ?? '',
      degree: json['degree'] ?? '',
      fieldOfStudy: json['fieldOfStudy'],
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'],
      gpa: json['gpa']?.toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'institutionName': institutionName,
      'degree': degree,
      if (fieldOfStudy != null) 'fieldOfStudy': fieldOfStudy,
      'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (gpa != null) 'gpa': gpa,
      if (description != null) 'description': description,
    };
  }
}

class CvCertificateDto {
  final int? id;
  final String name;
  final String? issuingOrganization;
  final String? issueDate;
  final String? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? certificateFileUrl;

  CvCertificateDto({
    this.id,
    required this.name,
    this.issuingOrganization,
    this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.certificateFileUrl,
  });

  factory CvCertificateDto.fromJson(Map<String, dynamic> json) {
    return CvCertificateDto(
      id: json['id'],
      name: json['name'] ?? '',
      issuingOrganization: json['issuingOrganization'],
      issueDate: json['issueDate'],
      expiryDate: json['expiryDate'],
      credentialId: json['credentialId'],
      credentialUrl: json['credentialUrl'],
      certificateFileUrl: json['certificateFileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (issuingOrganization != null)
        'issuingOrganization': issuingOrganization,
      if (issueDate != null) 'issueDate': issueDate,
      if (expiryDate != null) 'expiryDate': expiryDate,
      if (credentialId != null) 'credentialId': credentialId,
      if (credentialUrl != null) 'credentialUrl': credentialUrl,
      if (certificateFileUrl != null) 'certificateFileUrl': certificateFileUrl,
    };
  }
}
