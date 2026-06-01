// lib/features/jobpost/views/my_job_posts_screen.dart
// Màn hình: Danh sách tin tuyển dụng của Employer

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/jobpost/viewmodels/my_job_posts_provider.dart';
import 'package:app_jobfind/features/jobpost/models/job_post_model.dart';
import 'package:app_jobfind/features/jobpost/views/widgets/job_post_employer_card.dart';
import 'package:app_jobfind/features/jobpost/views/create_job_post_screen.dart';

class MyJobPostsScreen extends ConsumerStatefulWidget {
  const MyJobPostsScreen({super.key});

  @override
  ConsumerState<MyJobPostsScreen> createState() => _MyJobPostsScreenState();
}

class _MyJobPostsScreenState extends ConsumerState<MyJobPostsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myJobPostsProvider.notifier).fetchMyJobs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(int id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa tin "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final success =
          await ref.read(myJobPostsProvider.notifier).deleteJob(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? '✅ Đã xóa tin tuyển dụng' : '❌ Xóa thất bại'),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
      }
    }
  }

  Future<void> _toggleStatus(JobPostModel job) async {
    final newStatus = job.status == 1 ? 2 : 1;
    final label = newStatus == 1 ? 'đăng lại' : 'đóng';
    final success =
        await ref.read(myJobPostsProvider.notifier).changeStatus(job.id, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? '✅ Đã $label tin tuyển dụng' : '❌ Thất bại'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  void _openEdit(JobPostModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateJobPostScreen(jobToEdit: job),
      ),
    ).then((_) => ref.read(myJobPostsProvider.notifier).fetchMyJobs());
  }

  void _openCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateJobPostScreen()),
    ).then((_) => ref.read(myJobPostsProvider.notifier).fetchMyJobs());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myJobPostsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14003E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tin tuyển dụng của tôi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26),
            tooltip: 'Tạo tin mới',
            onPressed: _openCreate,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFFFDAE5C),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          tabs: [
            Tab(text: 'Tất cả (${state.jobs.length})'),
            Tab(text: 'Đang tuyển (${state.activeJobs.length})'),
            Tab(text: 'Nháp (${state.draftJobs.length})'),
            Tab(text: 'Đã đóng (${state.closedJobs.length})'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF14003E)))
          : state.error != null
              ? _buildError(state.error!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(state.jobs),
                    _buildList(state.activeJobs),
                    _buildList(state.draftJobs),
                    _buildList(state.closedJobs),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        backgroundColor: const Color(0xFF14003E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tạo tin mới', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildList(List<JobPostModel> jobs) {
    if (jobs.isEmpty) return _buildEmptyState();
    return RefreshIndicator(
      onRefresh: () => ref.read(myJobPostsProvider.notifier).fetchMyJobs(),
      color: const Color(0xFF14003E),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return JobPostEmployerCard(
            job: job,
            onEdit: () => _openEdit(job),
            onDelete: () => _confirmDelete(job.id, job.title),
            onToggleStatus: () => _toggleStatus(job),
            onTap: () => _openEdit(job),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF14003E).withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.post_add_outlined,
                size: 50, color: Color(0xFF14003E)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có tin tuyển dụng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF14003E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn nút + để đăng tin tuyển dụng đầu tiên',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openCreate,
            icon: const Icon(Icons.add),
            label: const Text('Tạo tin tuyển dụng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14003E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                ref.read(myJobPostsProvider.notifier).fetchMyJobs(),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14003E)),
            child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
