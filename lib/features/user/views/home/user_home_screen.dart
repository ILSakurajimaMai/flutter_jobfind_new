import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/user/views/profile/main_profile_screen.dart';
import 'package:app_jobfind/features/job/viewmodels/job_provider.dart';
import 'package:app_jobfind/features/job/views/job_details_screen.dart';
import 'package:app_jobfind/features/job/views/widgets/job_card.dart';
import 'package:app_jobfind/features/job/viewmodels/saved_jobs_provider.dart';
import 'package:app_jobfind/features/cv/views/my_cv_screen.dart';
import 'package:app_jobfind/features/chat/views/chat_list_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Màn hình Trang chủ Người Dùng (User Home Screen)
/// Đây là màn hình chứa thanh điều hướng `BottomNavigationBar`. Nó điều hướng
/// thành phần hiển thị `body` giữa thẻ Home, thẻ Cộng Đồng, và thẻ Profile (`MainProfileScreen`).
class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Xây dựng thanh điều hướng dưới cùng (BottomNavigationBar).
  /// Sử dụng [IndexedStack] để bọc phần nội dung (body). Điều này giúp giữ nguyên trạng thái
  /// của các tab khi ấn chuyển đổi qua lại mà không phải load lại từ đầu.
  @override
  Widget build(BuildContext context) {
    // Determine user status just in case we need it
    // final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB), // Light greyish background
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(context),
          const Center(child: Text('Network')),
          const ChatListScreen(),
          const MainProfileScreen(), // Index 3 is Profile
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyCvScreen()),
          );
        },
        backgroundColor: const Color(0xFF14003E), // Deep Navy
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 0),
            _buildNavItem(Icons.group_work_outlined, 1),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(Icons.chat_bubble_outline, 2),
            _buildNavItem(Icons.person_outline, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final jobsState = ref.watch(jobsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, ref)),
        SliverToBoxAdapter(child: _buildFilterBar()),
        if (jobsState.isLoading)
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF14003E)),
            ),
          )
        else if (jobsState.error != null)
          SliverFillRemaining(
            child: Center(child: Text("Error: ${jobsState.error}")),
          )
        else if (jobsState.jobs.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                "No job posts available.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == jobsState.jobs.length) {
                  return const SizedBox(height: 80); // spacing for bottom nav
                }
                final job = jobsState.jobs[index];
                final timeAgo = timeago.format(job.createdAt, locale: 'en');
                final savedJobs = ref.watch(savedJobsProvider);
                final isSaved = savedJobs.any((j) => j.id == job.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailsScreen(job: job),
                        ),
                      );
                    },
                    child: JobCard(
                      logoUrl: job.companyLogoUrl ?? '',
                      title: job.title,
                      company: job.companyName,
                      location: job.location ?? 'Remote',
                      tags: job.requiredSkills.isNotEmpty
                          ? job.requiredSkills.take(3).toList()
                          : ['Full-time'],
                      timeAgo: timeAgo,
                      salary: job.salaryMax != null
                          ? '\$${(job.salaryMax! / 1000).toStringAsFixed(0)}K'
                          : 'Negotiable',
                      isSaved: isSaved,
                      onToggleSave: () {
                        ref.read(savedJobsProvider.notifier).toggleSave(job);
                      },
                    ),
                  ),
                );
              }, childCount: jobsState.jobs.length + 1),
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = _currentIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isActive ? const Color(0xFF14003E) : Colors.grey.shade400,
        size: 28,
      ),
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 30,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A155C), Color(0xFF14003E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'JobFind',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          // Search Field
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) {
                ref.read(jobsProvider.notifier).searchJobs(value);
              },
              decoration: InputDecoration(
                hintText: 'Design',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(jobsProvider.notifier).searchJobs('');
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16, left: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF14003E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: Colors.white),
            ),
            const SizedBox(width: 12),
            _buildFilterChip('Part-time'),
            const SizedBox(width: 8),
            _buildFilterChip('Designer'),
            const SizedBox(width: 8),
            _buildFilterChip('Công nghệ thông tin'),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        ref.read(jobsProvider.notifier).searchJobs(label);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
