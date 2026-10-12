import 'package:flutter/material.dart';
import '../../../widgets/app_placeholder_scaffold.dart';

class AdsRewardScreen extends StatelessWidget {
  const AdsRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderScaffold(
      title: 'Watch & Earn',
      routeName: '/ads',
      icon: Icons.play_circle_fill_rounded,
      description: 'Rewarded video ads and sponsored ad impressions placeholder.',
    );
  }
}
