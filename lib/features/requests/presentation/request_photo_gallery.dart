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

class _RequestPhotoViewerScreen extends StatefulWidget {
  const _RequestPhotoViewerScreen({
    required this.photoUrls,
    required this.initialIndex,
  });

  final List<String> photoUrls;
  final int initialIndex;

  @override
  State<_RequestPhotoViewerScreen> createState() =>
      _RequestPhotoViewerScreenState();
}

class _RequestPhotoViewerScreenState extends State<_RequestPhotoViewerScreen> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _currentIndex = widget.initialIndex;

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.photoUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => InteractiveViewer(
              child: Center(child: Image.network(widget.photoUrls[index])),
            ),
          ),
          if (_currentIndex > 0)
            Positioned(
              left: 8,
              child: _NavArrowButton(
                icon: Icons.chevron_left_rounded,
                onPressed: () => _goTo(_currentIndex - 1),
              ),
            ),
          if (_currentIndex < widget.photoUrls.length - 1)
            Positioned(
              right: 8,
              child: _NavArrowButton(
                icon: Icons.chevron_right_rounded,
                onPressed: () => _goTo(_currentIndex + 1),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavArrowButton extends StatelessWidget {
  const _NavArrowButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 32),
        onPressed: onPressed,
      ),
    );
  }
}
