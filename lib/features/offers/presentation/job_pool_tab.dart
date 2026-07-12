import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/theme/glass_spacing.dart';
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
                  padding: const EdgeInsets.all(GlassSpacing.xl),
                  child: Column(
                    children: [
                      const SizedBox(height: GlassSpacing.xxl),
                      Icon(
                        Icons.work_off_outlined,
                        size: 64,
                        color: GlassColors.textSecondary(brightness),
                      ),
                      const SizedBox(height: GlassSpacing.md),
                      Text(
                        'Kategorinizde açık iş fırsatı yok.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: GlassSpacing.xs),
                      Text(
                        'Kategorine uygun yeni ilanlar açıldığında burada görünecek.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: GlassSpacing.sm),
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
                            style: Theme.of(context).textTheme.bodyMedium,
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
        error: (error, _) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(GlassSpacing.xl),
              child: Column(
                children: [
                  const SizedBox(height: GlassSpacing.xxl),
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: GlassColors.error,
                  ),
                  const SizedBox(height: GlassSpacing.md),
                  Text(
                    'İş fırsatları yüklenirken bir hata oluştu.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: GlassSpacing.xs),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: GlassSpacing.md),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(jobPoolProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
