import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/widgets/glass_service_card.dart';
import '../../requests/presentation/request_providers.dart';
import 'job_opportunity_detail_screen.dart';

class JobPoolTab extends ConsumerWidget {
  const JobPoolTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobPoolProvider);
    final brightness = Theme.of(context).brightness;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(jobPoolProvider),
      child: jobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Kategorinizde açık iş fırsatı yok.',
                      style: TextStyle(color: GlassColors.textSecondary(brightness)),
                    ),
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return GlassServiceCard(
                eyebrow: job.category,
                accentColor: GlassColors.primary,
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
                          Text(
                            job.neighborhood,
                            style: TextStyle(color: GlassColors.textSecondary(brightness)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: GlassColors.primary),
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
