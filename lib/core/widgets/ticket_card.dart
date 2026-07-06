import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

const double _headerHeight = 40;
const double _cornerRadius = 14;
const double _notchRadius = 7;

class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();

  @override
  Path getClip(Size size) {
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(_cornerRadius),
        ),
      );
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: const Offset(0, _headerHeight), radius: _notchRadius),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, _headerHeight),
          radius: _notchRadius,
        ),
      );
    return Path.combine(PathOperation.difference, base, notches);
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) => false;
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    const dashWidth = 5.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => oldDelegate.color != color;
}

/// The signature "iş fişi" (work ticket) card used for job/offer/request
/// listings: a fixed-height eyebrow header (category + optional verified
/// stamp) separated from the body by a dashed line with punched notches at
/// the card's edges, echoing a repairman's paper work order.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.eyebrow,
    required this.child,
    this.trailing,
    this.accentColor = AppColors.navy,
    this.onTap,
  });

  final String eyebrow;
  final Widget child;
  final Widget? trailing;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipPath(
        clipper: const _TicketClipper(),
        child: Material(
          color: AppColors.paper,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outline),
                borderRadius: BorderRadius.circular(_cornerRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: _headerHeight,
                    child: Row(
                      children: [
                        Container(width: 5, height: _headerHeight, color: accentColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            eyebrow.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.mono(color: accentColor),
                          ),
                        ),
                        if (trailing != null) ...[
                          trailing!,
                          const SizedBox(width: 14),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _notchRadius + 4),
                    child: CustomPaint(
                      painter: const _DashedLinePainter(color: AppColors.outline),
                      size: const Size(double.infinity, 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
