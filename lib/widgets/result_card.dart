import 'package:flutter/material.dart';
import '../utils/url_launcher_util.dart';
import '../utils/app_styles.dart';
import '../utils/app_colors.dart';

class ResultCard extends StatelessWidget {
  final dynamic result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final title = result['title'];
    final snippet = result['snippet'];
    final url = result['url'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      ),
      child: InkWell(
        // Use InkWell for ripple effect on tap
        onTap: url != null ? () => UrlLauncherUtil.launchURL(url) : null,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'No title available',
                style: AppStyles.cardTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                snippet ?? 'No snippet available.',
                style: AppStyles.bodyText.copyWith(color: AppColors.lightText),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (url != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Source: ${Uri.parse(url).host}', // Show only the host for cleaner look
                  style: AppStyles.linkText,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
