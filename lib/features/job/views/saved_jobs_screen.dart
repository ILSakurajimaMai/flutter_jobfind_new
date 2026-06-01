import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/job/viewmodels/saved_jobs_provider.dart';
import 'package:app_jobfind/features/job/views/widgets/job_card.dart';
import 'package:app_jobfind/features/job/views/job_details_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class SavedJobsScreen extends ConsumerWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedJobs = ref.watch(savedJobsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text(
          'Công việc đang theo dõi',
          style: TextStyle(color: Color(0xFF14003E), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        centerTitle: true,
      ),
      body: savedJobs.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa có công việc nào đang theo dõi.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: savedJobs.length,
              itemBuilder: (context, index) {
                final job = savedJobs[index];
                final timeAgo = timeago.format(job.createdAt, locale: 'en');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
                      );
                    },
                    child: JobCard(
                      logoUrl: job.companyLogoUrl ?? '',
                      title: job.title,
                      company: job.companyName,
                      location: job.location ?? 'Remote',
                      tags: job.requiredSkills.isNotEmpty ? job.requiredSkills.take(3).toList() : ['Full-time'],
                      timeAgo: timeAgo,
                      salary: job.salaryMax != null ? '\$${(job.salaryMax! / 1000).toStringAsFixed(0)}K' : 'Negotiable',
                      isSaved: true,
                      onToggleSave: () {
                        ref.read(savedJobsProvider.notifier).toggleSave(job);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
