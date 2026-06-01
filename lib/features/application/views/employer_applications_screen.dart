// lib/features/application/views/employer_applications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/application/viewmodels/employer_applications_provider.dart';
import 'package:app_jobfind/features/application/models/application_dto.dart';
import 'package:app_jobfind/features/jobpost/viewmodels/my_job_posts_provider.dart';
import 'employer_application_detail_screen.dart';

class EmployerApplicationsScreen extends ConsumerStatefulWidget {
  final int? initialJobPostId;
  const EmployerApplicationsScreen({super.key, this.initialJobPostId});

  @override
  ConsumerState<EmployerApplicationsScreen> createState() => _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState extends ConsumerState<EmployerApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedJobPostId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedJobPostId = widget.initialJobPostId;
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update tab specific view/filter
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employerApplicationsProvider.notifier).fetchApplications(jobPostId: _selectedJobPostId);
      ref.read(myJobPostsProvider.notifier).fetchMyJobs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getStatusLabel(String statusName) {
    switch (statusName) {
      case 'Pending':      return 'Chờ xét duyệt';
      case 'Reviewing':    return 'Đang xem xét';
      case 'Shortlisted':  return 'Đã lọc hồ sơ';
      case 'Interviewing': return 'Đang phỏng vấn';
      case 'Offered':      return 'Đã được offer';
      case 'Accepted':     return 'Đã chấp nhận';
      case 'Rejected':     return 'Bị từ chối';
      case 'Withdrawn':    return 'Đã rút đơn';
      case 'Expired':      return 'Hết hạn';
      default:             return statusName;
    }
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1: return Colors.orange; // Pending
      case 2: return Colors.blue; // Reviewing
      case 3:
      case 4: return Colors.purple; // Shortlisted / Interviewing
      case 5:
      case 6: return Colors.green; // Offered / Accepted
      case 7: return Colors.red; // Rejected
      default: return Colors.grey; // Withdrawn / Expired
    }
  }

  List<ApplicationDto> _filterByTab(List<ApplicationDto> apps) {
    // 0: Tất cả, 1: Chờ duyệt (1), 2: Đang xem xét (2), 3: Đã duyệt (6), 4: Từ chối (7)
    switch (_tabController.index) {
      case 1:
        return apps.where((a) => a.statusId == 1).toList();
      case 2:
        return apps.where((a) => a.statusId == 2).toList();
      case 3:
        return apps.where((a) => a.statusId == 6).toList();
      case 4:
        return apps.where((a) => a.statusId == 7).toList();
      default:
        return apps;
    }
  }

  List<ApplicationDto> _filterBySearch(List<ApplicationDto> apps) {
    if (_searchQuery.trim().isEmpty) return apps;
    return apps.where((a) {
      final name = a.applicantName.toLowerCase();
      final jobTitle = a.jobTitle.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || jobTitle.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(employerApplicationsProvider);
    final jobsState = ref.watch(myJobPostsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14003E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ứng viên tuyển dụng',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Thống kê & Bộ lọc phần đầu
          _buildFilterHeader(jobsState),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm ứng viên hoặc công việc...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // TabBar trạng thái
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF14003E),
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: const Color(0xFFFDAE5C),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              isScrollable: true,
              tabs: const [
                Tab(text: 'Tất cả'),
                Tab(text: 'Chờ duyệt'),
                Tab(text: 'Đang xem xét'),
                Tab(text: 'Đã nhận'),
                Tab(text: 'Từ chối'),
              ],
            ),
          ),

          // Danh sách
          Expanded(
            child: appsAsync.when(
              data: (apps) {
                final filteredBySearch = _filterBySearch(apps);
                final finalApps = _filterByTab(filteredBySearch);

                if (finalApps.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(employerApplicationsProvider.notifier).fetchApplications(jobPostId: _selectedJobPostId),
                  color: const Color(0xFF14003E),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: finalApps.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = finalApps[index];
                      return _buildCandidateCard(app);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF14003E))),
              error: (e, st) => _buildErrorState(e.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(MyJobPostsState jobsState) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF14003E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lọc theo tin tuyển dụng:',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: _selectedJobPostId,
                dropdownColor: const Color(0xFF23124D),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                hint: const Text('Tất cả tin tuyển dụng', style: TextStyle(color: Colors.white70)),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Tất cả tin tuyển dụng'),
                  ),
                  ...jobsState.jobs.map((job) {
                    return DropdownMenuItem<int?>(
                      value: job.id,
                      child: Text(job.title, overflow: TextOverflow.ellipsis),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedJobPostId = val;
                  });
                  ref.read(employerApplicationsProvider.notifier).fetchApplications(jobPostId: val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(ApplicationDto app) {
    final statusColor = _getStatusColor(app.statusId);
    final statusLabel = _getStatusLabel(app.statusName);
    final initials = app.applicantName.isNotEmpty
        ? app.applicantName.trim().split(' ').last.substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar tròn giả lập
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF14003E).withValues(alpha: 0.08),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14003E),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.applicantName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14003E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ứng tuyển: ${app.jobTitle}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Cover Letter Snippet
          if (app.coverLetter != null && app.coverLetter!.trim().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Thư ứng tuyển: "${app.coverLetter}"',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Trạng thái badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Thao tác
              Row(
                children: [
                  Text(
                    'Ngày nộp: ${app.appliedAt.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmployerApplicationDetailScreen(application: app),
                        ),
                      ).then((_) {
                        // Reload data to reflect state updates
                        ref.read(employerApplicationsProvider.notifier).fetchApplications(jobPostId: _selectedJobPostId);
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Xem hồ sơ',
                      style: TextStyle(color: Color(0xFFFDAE5C), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF14003E).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline, size: 40, color: Color(0xFF14003E)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy ứng viên nào',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF14003E)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hãy thử điều chỉnh bộ lọc hoặc từ khóa tìm kiếm',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.red),
          const SizedBox(height: 12),
          Text('Lỗi: $error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(employerApplicationsProvider.notifier).fetchApplications(jobPostId: _selectedJobPostId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14003E)),
            child: const Text('Tải lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
