import 'package:flutter/material.dart';
import 'package:filmdeneme/theme/app_theme.dart';
import 'package:filmdeneme/widgets/info_section.dart';

class TVShowInfo extends StatelessWidget {
  final Map<String, dynamic> data;

  const TVShowInfo({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final numberOfSeasons = data['number_of_seasons'] ?? 0;
    final numberOfEpisodes = data['number_of_episodes'] ?? 0;
    final lastAirDate = data['last_air_date'] ?? 'Unknown';
    final networks = data['networks'] as List<dynamic>? ?? [];
    final inProduction = data['in_production'] ?? false;
    final type = data['type'] ?? 'Unknown';

    return Column(
      children: [
        // Seasons and Episodes
        InfoSection(
          icon: Icons.playlist_play,
          title: 'Seasons & Episodes',
          content: '$numberOfSeasons Seasons, $numberOfEpisodes Episodes',
        ),

        // Last Air Date
        InfoSection(
          icon: Icons.calendar_today,
          title: 'Last Air Date',
          content: lastAirDate,
        ),

        // Type and Status
        InfoSection(
          icon: Icons.info_outline,
          title: 'Type',
          content: '$type ${inProduction ? "(In Production)" : "(Completed)"}',
        ),

        // Networks
        if (networks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Networks',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: networks.length,
                    itemBuilder: (context, index) {
                      final network = networks[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (network['logo_path'] != null) ...[
                              Image.network(
                                'https://image.tmdb.org/t/p/w200${network['logo_path']}',
                                height: 30,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              network['name'],
                              style: const TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        // Next Episode Info
        if (data['next_episode_to_air'] != null)
          InfoSection(
            icon: Icons.upcoming,
            title: 'Next Episode',
            content: 'Episode ${data['next_episode_to_air']['episode_number']} on ${data['next_episode_to_air']['air_date']}',
          ),
      ],
    );
  }
}
