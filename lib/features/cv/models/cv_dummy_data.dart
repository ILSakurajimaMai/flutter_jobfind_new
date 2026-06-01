import 'package:app_jobfind/features/cv/models/cv_dto.dart';

final CvDto defaultDummyCv = CvDto(
  fullName: 'Trần Mạnh Dũng',
  targetPosition: 'Content Leader',
  phoneNumber: '0123 456 789',
  email: 'tech.growth@topcv.vn',
  address: 'Thanh Xuân, Hà Nội',
  bio: 'Content Leader với 6 năm kinh nghiệm xây dựng và triển khai chiến lược nội dung đa nền tảng cho các thương hiệu trong lĩnh vực FMCG, công nghệ, giáo dục và bán lẻ. Tôi có thế mạnh quản lý đội ngũ Content từ 5-10 người, từng góp phần tăng 40% Organic Traffic và nâng tỷ lệ chuyển đổi từ nội dung gấp 2-3 lần. Từ nền tảng Content vững chắc, tôi hướng đến vai trò Marketing Leader trong 1-2 năm tới, xây dựng chiến lược Marketing toàn diện, góp phần tăng trưởng độ nhận diện thương hiệu và hiệu quả kinh doanh trong dài hạn.',
  dateOfBirth: '1997-12-10T00:00:00.000Z',
  linkedInUrl: 'facebook.com/TopCV.vn', 
  skills: [
    CvSkillDto(skillName: 'Kỹ năng giao tiếp', proficiencyLevel: 4),
    CvSkillDto(skillName: 'Kỹ năng làm việc nhóm', proficiencyLevel: 4),
    CvSkillDto(skillName: 'Kỹ năng giải quyết vấn đề', proficiencyLevel: 4),
    CvSkillDto(skillName: 'Kỹ năng Quản lý thời gian', proficiencyLevel: 4),
    CvSkillDto(skillName: 'Kỹ năng tin học', proficiencyLevel: 4),
    CvSkillDto(skillName: 'Kỹ năng ngoại ngữ', proficiencyLevel: 3),
  ],
  experiences: [
    CvExperienceDto(
      companyName: 'Công ty Công nghệ NTD Tech',
      position: 'Content Leader',
      startDate: '2023-01-01T00:00:00.000Z',
      isCurrentlyWorking: true,
      description: '- Xây dựng chiến lược nội dung cho website, social media và các kênh digital, giúp tăng 40% organic traffic và nâng tỷ lệ chuyển đổi từ Landing Page gấp 2.5 lần sau 6 tháng.\n- Quản lý đội nhóm 10 thành viên, phối hợp chặt chẽ với team Media, Design và Product để triển khai các chiến dịch Marketing tích hợp.\n- Dẫn dắt các dự án nội dung trọng điểm như: Ra mắt sản phẩm mới, chiến dịch thương hiệu mùa cao điểm, xây dựng hệ thống nội dung CRM/Email Marketing.\n- Phân tích dữ liệu từ GA4, Meta Insights và Looker Studio để đánh giá hiệu quả nội dung, đề xuất phương án tối ưu theo từng giai đoạn.',
    ),
    CvExperienceDto(
      companyName: 'Agency NDS - Marketing & Advertising',
      position: 'Content Executive -> Content Team Lead',
      startDate: '2019-01-01T00:00:00.000Z',
      endDate: '2023-01-01T00:00:00.000Z',
      isCurrentlyWorking: false,
      description: '- Triển khai và quản lý hơn 100 chiến dịch nội dung (Website & Social) cho các thương hiệu trong lĩnh vực FMCG, F&B, bán lẻ, tài chính, công nghệ.\n- Làm việc trực tiếp với khách hàng để đề xuất chiến lược nội dung, thực thi plan và điều phối thiết kế, media theo đúng KPIs.\n- Quản lý team Content (4-5 người), đào tạo nhân sự mới và xây dựng quy trình quản lý Content.\n- Một số dự án tiêu biểu: Ra mắt sản phẩm mới cho nhãn hàng F&B quốc tế, chiến dịch viral Tết cho thương hiệu FMCG nội địa, chuỗi video branding cho startup công nghệ.',
    )
  ],
  educations: [
    CvEducationDto(
      institutionName: 'Đại học Kinh tế TOPCV',
      degree: 'Cử nhân Public Relation & Advertising',
      startDate: '2015-01-01T00:00:00.000Z',
      endDate: '2019-01-01T00:00:00.000Z',
      description: 'Đạt giải Nhì cuộc thi "Chiến lược truyền thông sáng tạo" do khoa PR tổ chức',
    )
  ],
  certificates: [
    CvCertificateDto(
      name: 'Top 5 Chiến dịch Content hiệu quả nhất năm',
      issueDate: '2022-01-01T00:00:00.000Z',
    ),
    CvCertificateDto(
      name: 'Google Digital Garage: Fundamentals of Digital Marketing',
      issueDate: '2022-01-01T00:00:00.000Z',
    ),
  ],
);
