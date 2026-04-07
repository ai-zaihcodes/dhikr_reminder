import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/quote_entity.dart';

/// Widget for displaying a Dhikr quote
class QuoteCard extends StatelessWidget {
  final QuoteEntity quote;
  final bool showTranslation;
  final VoidCallback? onDismiss;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const QuoteCard({
    super.key,
    required this.quote,
    this.showTranslation = true,
    this.onDismiss,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.all(16.w),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.9),
              theme.colorScheme.primary,
            ],
          ),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category badge
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    quote.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!quote.isGlobal)
                  Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'CUSTOM',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[100],
                      ),
                    ),
                  ),
                const Spacer(),
                if (onFavorite != null)
                  IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 24.h),
            // Arabic text
            Text(
              quote.text,
              style: TextStyle(
                fontSize: 24.sp,
                height: 1.8,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            // Translation
            if (showTranslation && quote.translation != null) ...[
              SizedBox(height: 20.h),
              Divider(
                color: Colors.white.withOpacity(0.3),
                thickness: 1,
              ),
              SizedBox(height: 16.h),
              Text(
                quote.translation!,
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            // Source
            if (quote.source != null) ...[
              SizedBox(height: 16.h),
              Text(
                '— ${quote.source}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 24.h),
            // Dismiss button
            if (onDismiss != null)
              ElevatedButton.icon(
                onPressed: onDismiss,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
