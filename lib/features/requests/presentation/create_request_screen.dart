import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/didim_neighborhoods.dart';
import '../../../core/constants/service_categories.dart';
import '../../../core/theme/glass_colors.dart';
import '../../../core/theme/glass_spacing.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import 'request_providers.dart';

const _maxPhotos = 5;

String _contentTypeFor(XFile file) {
  final name = file.name.toLowerCase();
  if (name.endsWith('.png')) return 'image/png';
  if (name.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  String? _neighborhood;
  DateTime? _preferredDate;
  final List<XFile> _photos = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final remaining = _maxPhotos - _photos.length;
    if (remaining <= 0) return;
    try {
      final picked = await ImagePicker().pickMultiImage(
        imageQuality: 80,
        maxWidth: 1600,
        limit: remaining,
      );
      if (picked.isEmpty) return;
      setState(() => _photos.addAll(picked.take(remaining)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fotoğraf seçilemedi: $e')));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final customerId = ref.read(supabaseClientProvider).auth.currentUser!.id;
      final uploader = ref.read(r2UploadRepositoryProvider);
      final photoUrls = await Future.wait(_photos.map((file) async {
        final bytes = await file.readAsBytes();
        return uploader.uploadPhoto(
          bytes: bytes,
          contentType: _contentTypeFor(file),
        );
      }));
      await ref.read(serviceRequestRepositoryProvider).createRequest(
            id: const Uuid().v4(),
            customerId: customerId,
            category: _category!,
            title: _titleController.text.trim(),
            neighborhood: _neighborhood!,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            preferredDate: _preferredDate,
            photoUrls: photoUrls,
          );
      ref.invalidate(myRequestsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GlassScaffold(
      appBar: const GlassAppBar(title: Text('Hizmet Talebi Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Hizmet Kategorisi'),
                items: serviceCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) => value == null ? 'Kategori seçin' : null,
              ),
              const SizedBox(height: 12),
              GlassTextField(
                controller: _titleController,
                labelText: 'Başlık',
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Başlık gerekli' : null,
              ),
              const SizedBox(height: 12),
              GlassTextField(
                controller: _descriptionController,
                maxLines: 3,
                labelText: 'Açıklama (opsiyonel)',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _neighborhood,
                decoration: const InputDecoration(labelText: 'Mahalle (Didim)'),
                items: didimNeighborhoods
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (value) => setState(() => _neighborhood = value),
                validator: (value) => value == null ? 'Mahalle seçin' : null,
              ),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                onTap: _pickDate,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _preferredDate == null
                        ? 'Tercih edilen tarih (opsiyonel)'
                        : 'Tercih edilen tarih: ${_preferredDate!.day}.${_preferredDate!.month}.${_preferredDate!.year}',
                    style: TextStyle(color: GlassColors.textPrimary(brightness)),
                  ),
                  trailing: Icon(Icons.calendar_today, color: GlassColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Fotoğraflar (opsiyonel, en fazla $_maxPhotos)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 88,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var i = 0; i < _photos.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _PhotoThumbnail(
                          file: _photos[i],
                          onRemove: () => setState(() => _photos.removeAt(i)),
                        ),
                      ),
                    if (_photos.length < _maxPhotos)
                      GestureDetector(
                        onTap: _pickPhotos,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: GlassColors.glassFill(brightness),
                            borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
                            border: Border.all(color: GlassColors.glassBorder(brightness)),
                          ),
                          child: Icon(Icons.add_a_photo_outlined,
                              color: GlassColors.primary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassButton(
                label: 'Talebi Oluştur',
                loading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.file, required this.onRemove});

  final XFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
            child: FutureBuilder<Uint8List>(
              future: file.readAsBytes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    width: 88,
                    height: 88,
                    color: GlassColors.glassFill(Theme.of(context).brightness),
                  );
                }
                return Image.memory(
                  snapshot.data!,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
