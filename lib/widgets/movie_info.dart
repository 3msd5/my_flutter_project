import 'package:flutter/material.dart';
import 'package:filmdeneme/theme/app_theme.dart';
import 'package:filmdeneme/widgets/info_section.dart';

class MovieInfo extends StatelessWidget {
  final Map<String, dynamic> data;

  const MovieInfo({
    Key? key,
    required this.data,
  }) : super(key: key);

  String _formatCurrency(int? amount) {
    if (amount == null || amount == 0) return 'Not Available';
    
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    
    return '\$$amount';
  }

  @override
  Widget build(BuildContext context) {
    final budget = data['budget'] as int? ?? 0;
    final revenue = data['revenue'] as int? ?? 0;
    final originalTitle = data['original_title'] as String?;
    final voteCount = data['vote_count'] as int? ?? 0;
    final popularity = data['popularity'] as double? ?? 0.0;
    final adult = data['adult'] as bool? ?? false;
    final video = data['video'] as bool? ?? false;

    return Column(
      children: [
        // Budget and Revenue
        if (budget > 0 || revenue > 0) ...[
          InfoSection(
            icon: Icons.attach_money,
            title: 'Budget',
            content: _formatCurrency(budget),
          ),
          InfoSection(
            icon: Icons.money,
            title: 'Revenue',
            content: _formatCurrency(revenue),
          ),
        ],

        // Original Title (if different from title)
        if (originalTitle != null && originalTitle != data['title'])
          InfoSection(
            icon: Icons.title,
            title: 'Original Title',
            content: originalTitle,
          ),

        // Vote Count and Popularity
        InfoSection(
          icon: Icons.people,
          title: 'Vote Count',
          content: '$voteCount votes',
        ),

        InfoSection(
          icon: Icons.trending_up,
          title: 'Popularity',
          content: popularity.toStringAsFixed(1),
        ),

        // Additional Info
        if (adult || video)
          InfoSection(
            icon: Icons.info_outline,
            title: 'Additional Info',
            content: [
              if (adult) 'Adult Content',
              if (video) 'Video Available',
            ].join(', '),
          ),

        // Collection Info
        if (data['belongs_to_collection'] != null)
          InfoSection(
            icon: Icons.collections_bookmark,
            title: 'Collection',
            content: data['belongs_to_collection']['name'],
          ),

        // Homepage
        if (data['homepage'] != null && data['homepage'].toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Homepage',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['homepage'],
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
