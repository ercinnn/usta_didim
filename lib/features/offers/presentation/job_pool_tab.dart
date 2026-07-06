import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ticket_card.dart';
import '../../requests/presentation/request_providers.dart';
import 'job_opportunity_detail_screen.dart';

class JobPoolTab extends ConsumerWidget {
  const JobPoolTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobPoolProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(jobPoolProvider),
      child: jobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Kategorinizde açık iş fırsatı yok.')),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return TicketCard(
                eyebrow: job.category,
                accentColor: AppColors.navy,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => JobOpportunityDetailScreen(requestId: job.id),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(job.neighborhood),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Hata: $error')),
      ),
    );
  }
}
