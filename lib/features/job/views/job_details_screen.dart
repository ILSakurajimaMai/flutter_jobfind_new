import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/job/models/job_post_dto.dart';
import 'package:app_jobfind/features/job/viewmodels/saved_jobs_provider.dart';
import 'package:app_jobfind/features/job/viewmodels/company_provider.dart';
import 'package:app_jobfind/features/application/viewmodels/application_provider.dart';
import 'package:app_jobfind/features/auth/viewmodels/auth_provider.dart';
import 'package:app_jobfind/features/job/views/widgets/apply_job_bottom_sheet.dart';
import 'package:app_jobfind/features/chat/views/chat_room_screen.dart';
import 'package:app_jobfind/features/chat/viewmodels/chat_list_viewmodel.dart';

class JobDetailsScreen extends ConsumerWidget {
  final JobPostDto job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isEmployer = authState.user?.roles.contains('EMPLOYER') ?? false;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(child: _buildTopSection(context)),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          labelColor: Color(0xFF0D9D58), // Green
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Color(0xFF0D9D58),
                          indicatorWeight: 3,
                          tabs: [
                            Tab(text: "Thông tin"),
                            Tab(text: "Công ty"),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [_buildInfoTab(), _buildCompanyTab(ref)],
                ),
              ),
            ),
            if (!isEmployer) _buildBottomBar(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          height: 260,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00B4DB),
                Color(0xFF0083B0),
              ], // Giả lập gradient xanh
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Fake App Bar with Circular Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black54,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Card with Logo Overlap
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.only(
                      top: 55,
                      bottom: 24,
                      left: 16,
                      right: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Color(0xFF0D9D58),
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.companyName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildCardMetric(
                                icon: Icons.monetization_on,
                                title: 'Mức lương',
                                value: job.salaryMax != null
                                    ? '\$${(job.salaryMax! / 1000).toStringAsFixed(0)}K'
                                    : 'Thoả thuận',
                              ),
                            ),
                            _buildDivider(),
                            Expanded(
                              child: _buildCardMetric(
                                icon: Icons.location_on,
                                title: 'Địa điểm',
                                value: job.location ?? 'Remote',
                              ),
                            ),
                            _buildDivider(),
                            Expanded(
                              child: _buildCardMetric(
                                icon: Icons.star,
                                title: 'Kinh nghiệm',
                                value: 'Không yêu cầu', // Theo UI mẫu
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              job.companyLogoUrl != null &&
                                  job.companyLogoUrl!.isNotEmpty
                              ? Image.network(
                                  job.companyLogoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildFallbackLogo(),
                                )
                              : _buildFallbackLogo(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackLogo() {
    return Center(
      child: Text(
        job.companyName.isNotEmpty
            ? job.companyName.substring(0, 1).toUpperCase()
            : 'C',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Color(0xFF14003E),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildCardMetric({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0D9D58), size: 28),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0D9D58),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (job.category != null) _buildTag(job.category!),
              if (job.requiredSkills.isNotEmpty)
                ...job.requiredSkills.map((s) => _buildTag(s)),
              if (job.workType != null) _buildTag(job.workType!),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Mô tả công việc',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildBulletedList(job.description),
          const SizedBox(height: 24),
          const Text(
            'Yêu cầu ứng viên',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (job.requirements != null && job.requirements!.isNotEmpty)
            _buildBulletedList(job.requirements!)
          else
            const Text(
              "Không có yêu cầu mô tả thêm.",
              style: TextStyle(color: Colors.black87),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBulletedList(String text) {
    // Fix literal '\n' characters that might be returned from the API
    final decodedText = text.replaceAll(RegExp(r'\\n'), '\n');
    var lines = decodedText
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    // Nếu text chỉ là một chuỗi dài không xuống dòng, tách bằng dấu chấm hoặc coi như 1 gạch đầu dòng
    if (lines.length == 1) {
      if (lines[0].contains('. ')) {
        lines = lines[0]
            .split('. ')
            .where((e) => e.trim().isNotEmpty)
            .map((e) => e.endsWith('.') ? e : '$e.')
            .toList();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Loại bỏ gạch ngang thủ công ở đầu dòng nếu có để dùng bullet
        var cleanLine = line.trim();
        if (cleanLine.startsWith('-') || cleanLine.startsWith('•')) {
          cleanLine = cleanLine.substring(1).trim();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6.0, right: 12.0),
                child: Icon(Icons.circle, size: 6, color: Colors.black87),
              ),
              Expanded(
                child: Text(
                  cleanLine,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompanyTab(WidgetRef ref) {
    if (job.companyId <= 0) {
      return const Center(
        child: Text("Không có thông tin chi tiết về công ty."),
      );
    }

    final companyAsync = ref.watch(companyDetailProvider(job.companyId));

    return companyAsync.when(
      data: (company) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giới thiệu công ty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                company.description ?? 'Công ty chưa cập nhật mô tả.',
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildCompanyInfoRow(
                Icons.business,
                'Ngành nghề',
                company.industry ?? 'Đang cập nhật',
              ),
              const SizedBox(height: 12),
              _buildCompanyInfoRow(
                Icons.group,
                'Quy mô',
                company.employeeCount != null
                    ? '${company.employeeCount} nhân viên'
                    : 'Đang cập nhật',
              ),
              const SizedBox(height: 12),
              _buildCompanyInfoRow(
                Icons.location_on,
                'Địa chỉ',
                company.address ?? 'Đang cập nhật',
              ),
              const SizedBox(height: 12),
              _buildCompanyInfoRow(
                Icons.language,
                'Website',
                company.website ?? 'Đang cập nhật',
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0D9D58)),
      ),
      error: (e, st) => Center(child: Text('Lỗi tải thông tin công ty: $e')),
    );
  }

  Widget _buildCompanyInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Trả về label tiếng Việt tương ứng với statusName từ backend
  String _getStatusLabel(String statusName) {
    switch (statusName) {
      case 'Pending':
        return 'Chờ xét duyệt';
      case 'Reviewing':
        return 'Đang xem xét';
      case 'Shortlisted':
        return 'Đã lọc hồ sơ';
      case 'Interviewing':
        return 'Đang phỏng vấn';
      case 'Offered':
        return 'Đã được offer';
      case 'Accepted':
        return 'Đã chấp nhận';
      case 'Rejected':
        return 'Bị từ chối';
      case 'Withdrawn':
        return 'Đã rút đơn';
      case 'Expired':
        return 'Hết hạn';
      default:
        return statusName;
    }
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    final savedJobs = ref.watch(savedJobsProvider);
    final isSaved = savedJobs.any((j) => j.id == job.id);

    // Watch danh sách đã ứng tuyển
    final applicationsAsync = ref.watch(applicationProvider);

    // Lấy tất cả đơn ứng tuyển cho job này và sắp xếp theo ID giảm dần (mới nhất lên đầu)
    final jobApplications =
        applicationsAsync.value
            ?.where((app) => app.jobPostId == job.id)
            .toList() ??
        [];
    jobApplications.sort((a, b) => b.id.compareTo(a.id));

    // Các trạng thái active
    final activeStatusIds = {1, 2, 3, 4, 5, 6, 7}; // Pending → Rejected

    // Ưu tiên tìm application đang active. Nếu không có, lấy application mới nhất.
    final activeApplication = jobApplications
        .where((app) => activeStatusIds.contains(app.statusId))
        .firstOrNull;
    final application = activeApplication ?? jobApplications.firstOrNull;

    // Chỉ coi là "đã ứng tuyển" (khoá nút) khi trạng thái đang active
    // Withdrawn (8) và Expired (9) thì cho phép ứng tuyển lại
    final isApplied =
        application != null && activeStatusIds.contains(application.statusId);
    final hasWithdrawnOrExpired =
        application != null && !activeStatusIds.contains(application.statusId);

    // Label hiển thị trên nút
    String buttonLabel;
    if (isApplied) {
      buttonLabel = 'Đã ứng tuyển (${_getStatusLabel(application.statusName)})';
    } else if (hasWithdrawnOrExpired) {
      buttonLabel = 'Ứng tuyển lại';
    } else {
      buttonLabel = 'Ứng tuyển ngay';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Chat Button (Show only when Accepted/Đã chấp nhận)
            if (application != null && application.statusId == 6) ...[
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF14003E)),
                    ),
                  );

                  try {
                    final chatService = ref.read(chatServiceProvider);
                    final conversation = await chatService.getOrCreateConversation(
                      job.employerId ?? 0,
                      job.id,
                    );

                    if (context.mounted) Navigator.pop(context);

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            conversationId: conversation.id,
                            recipientId: job.employerId ?? 0,
                            recipientName: job.companyName,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Không thể kết nối trò chuyện: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF0D9D58),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF0D9D58),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            // Bookmark Box Button
            GestureDetector(
              onTap: () {
                ref.read(savedJobsProvider.notifier).toggleSave(job);
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF0D9D58),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: const Color(0xFF0D9D58),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Apply Button
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isApplied
                      ? null // Vô hiệu hoá nút khi đang trong trạng thái active
                      : () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ApplyJobBottomSheet(
                              jobId: job.id,
                              jobTitle: job.title,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApplied
                        ? Colors.grey.shade400
                        : const Color(0xFF0D9D58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Text(
                    buttonLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isApplied ? Colors.grey.shade600 : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: Column(children: [_tabBar]),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
