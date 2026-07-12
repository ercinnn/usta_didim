import 'package:flutter/material.dart';

import '../../../core/theme/glass_spacing.dart';

class RequestPhotoGallery extends StatelessWidget {
  const RequestPhotoGallery({required this.photoUrls, super.key});

  final List<String> photoUrls;

  void _openFullScreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _RequestPhotoViewerScreen(
          photoUrls: photoUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoUrls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _openFullScreen(context, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
            child: Image.network(
              photoUrls[index],
              width: 88,
              height: 88,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestPhotoViewerScreen extends StatelessWidget {
  const _RequestPhotoViewerScreen({
    required this.photoUrls,
    required this.initialIndex,
  });

  final List<String> photoUrls;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photoUrls.length,
        itemBuilder: (context, index) => InteractiveViewer(
          child: Center(child: Image.network(photoUrls[index])),
        ),
      ),
    );
  }
}
