// lib/features/employer/models/company_dto.dart

class CompanyDto {
  final int? id;
  final String name;
  final String? description;
  final String? address;
  final String? website;
  final String? taxCode;
  final String? industry;
  final int? employeeCount;
  final String? foundedYear;
  final String? logoUrl;
  final bool? isVerified;

  CompanyDto({
    this.id,
    required this.name,
    this.description,
    this.address,
    this.website,
    this.taxCode,
    this.industry,
    this.employeeCount,
    this.foundedYear,
    this.logoUrl,
    this.isVerified,
  });

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    return CompanyDto(
      id: json['id'],
      name: json['name'] ?? json['companyName'] ?? '',
      description: json['description'],
      address: json['address'],
      website: json['website'],
      taxCode: json['taxCode'],
      industry: json['industry'],
      employeeCount: json['employeeCount'],
      foundedYear: json['foundedYear'],
      logoUrl: json['logoUrl'],
      isVerified: json['isVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'website': website,
      'taxCode': taxCode,
      'industry': industry,
      'employeeCount': employeeCount,
      'foundedYear': foundedYear,
    };
  }
}
