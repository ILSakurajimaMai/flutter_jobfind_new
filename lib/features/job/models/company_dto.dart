class CompanyDto {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? website;
  final String? logoUrl;
  final String? taxCode;
  final String? industry;
  final int? employeeCount;
  final DateTime? foundedYear;
  final bool isVerified;
  final DateTime createdAt;

  CompanyDto({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.website,
    this.logoUrl,
    this.taxCode,
    this.industry,
    this.employeeCount,
    this.foundedYear,
    required this.isVerified,
    required this.createdAt,
  });

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    return CompanyDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'],
      website: json['website'],
      logoUrl: json['logoUrl'],
      taxCode: json['taxCode'],
      industry: json['industry'],
      employeeCount: json['employeeCount'],
      foundedYear: json['foundedYear'] != null
          ? DateTime.tryParse(json['foundedYear'])
          : null,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
