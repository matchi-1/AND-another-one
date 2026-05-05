import 'dart:async';

import 'package:and_another_one/core/audio/sfx_controller.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';
import '../../util/leaderboard_service.dart';

enum LeaderboardMode {
  gatekeeping,
  oneOrNone,
}

enum LeaderboardDifficulty {
  basic,
  logic,
  manic,
}

final LeaderboardService _leaderboardService = LeaderboardService();


class LeaderboardsPage extends StatefulWidget {
  const LeaderboardsPage({super.key});

  @override
  State<LeaderboardsPage> createState() => _LeaderboardsPageState();
}

class _LeaderboardsPageState extends State<LeaderboardsPage> {

  LeaderboardMode selectedMode = LeaderboardMode.gatekeeping;
  LeaderboardDifficulty selectedDifficulty = LeaderboardDifficulty.basic;

  String get _modeId {
    switch (selectedMode) {
      case LeaderboardMode.gatekeeping:
        return 'gatekeeping';
      case LeaderboardMode.oneOrNone:
        return 'one_or_none';
    }
  }

  String get _difficultyId {
    switch (selectedDifficulty) {
      case LeaderboardDifficulty.basic:
        return 'basic';
      case LeaderboardDifficulty.logic:
        return 'logic';
      case LeaderboardDifficulty.manic:
        return 'manic';
    }
  }


  final Map<LeaderboardMode,
      Map<LeaderboardDifficulty, List<LeaderboardEntry>>> leaderboardData = {
    LeaderboardMode.gatekeeping: {
      LeaderboardDifficulty.basic: const [
        LeaderboardEntry(username: 'AlphaWolf', score: 12850),
        LeaderboardEntry(username: 'PixelMint', score: 12140),
        LeaderboardEntry(username: 'NekoByte', score: 11760),
        LeaderboardEntry(username: 'LogicLad', score: 10950),
        LeaderboardEntry(username: 'GigaGate', score: 10110),
        LeaderboardEntry(username: 'CodaPop', score: 9840),
        LeaderboardEntry(username: 'ZenBug', score: 9560),
        LeaderboardEntry(username: 'ArcNova', score: 9150),
      ],
      LeaderboardDifficulty.logic: const [
        LeaderboardEntry(username: 'PixelMint', score: 22400),
        LeaderboardEntry(username: 'AlphaWolf', score: 21920),
        LeaderboardEntry(username: 'GigaGate', score: 21480),
        LeaderboardEntry(username: 'ZenBug', score: 20320),
        LeaderboardEntry(username: 'NekoByte', score: 19800),
        LeaderboardEntry(username: 'ArcNova', score: 19450),
      ],
      LeaderboardDifficulty.manic: const [
        LeaderboardEntry(username: 'AlphaWolf', score: 38990),
        LeaderboardEntry(username: 'CodaPop', score: 37720),
        LeaderboardEntry(username: 'GigaGate', score: 36540),
        LeaderboardEntry(username: 'ZenBug', score: 34980),
        LeaderboardEntry(username: 'ArcNova', score: 34020),
      ],
    },
    LeaderboardMode.oneOrNone: {
      LeaderboardDifficulty.basic: const [
        LeaderboardEntry(username: 'NullByte', score: 13100),
        LeaderboardEntry(username: 'PinkTaco', score: 12420),
        LeaderboardEntry(username: 'Kiro', score: 11990),
        LeaderboardEntry(username: 'MintRush', score: 11310),
        LeaderboardEntry(username: 'GateJr', score: 10840),
        LeaderboardEntry(username: 'DartFury', score: 10010),
      ],
      LeaderboardDifficulty.logic: const [
        LeaderboardEntry(username: 'PinkTaco', score: 23100),
        LeaderboardEntry(username: 'NullByte', score: 22780),
        LeaderboardEntry(username: 'DartFury', score: 22090),
        LeaderboardEntry(username: 'Kiro', score: 21440),
        LeaderboardEntry(username: 'MintRush', score: 20850),
      ],
      LeaderboardDifficulty.manic: const [
        LeaderboardEntry(username: 'NullByte', score: 40120),
        LeaderboardEntry(username: 'Kiro', score: 39580),
        LeaderboardEntry(username: 'PinkTaco', score: 38210),
        LeaderboardEntry(username: 'DartFury', score: 37050),
      ],
    },
  };

  List<LeaderboardEntry> get currentEntries {
    return leaderboardData[selectedMode]?[selectedDifficulty] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.blueBg,
        child: SafeArea(
          child: Column(
            children: [
              // Row with Back and Sound buttons (Consistent with Logic Guide)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Image.asset(AppAssets.backBtn, width: 30),
                      onPressed: () {
                        unawaited(SfxController.instance.playMenuBack()); 
                        Navigator.pop(context);
                      } 
                    ),
                    const MusicButton(size: 32),
                  ],
                ),
              ),

              const Text(
                'LEADERBOARDS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      _buildSectionLabel('MODE'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: BeveledMenuButton(
                              label: 'GATEKEEPING',
                              color: selectedMode == LeaderboardMode.gatekeeping
                                  ? AppColors.orangeButton
                                  : AppColors.greyButton,
                              width: double.infinity,
                              height: 58,
                              textColor: Colors.white,
                              fontSize: 14,
                              onTap: () {
                                setState(() {
                                  selectedMode = LeaderboardMode.gatekeeping;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BeveledMenuButton(
                              label: 'ONE OR NONE',
                              color: selectedMode == LeaderboardMode.oneOrNone
                                  ? AppColors.purpleButton
                                  : AppColors.greyButton,
                              width: double.infinity,
                              height: 58,
                              textColor: Colors.white,
                              fontSize: 14,
                              onTap: () {
                                setState(() {
                                  selectedMode = LeaderboardMode.oneOrNone;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      _buildSectionLabel('DIFFICULTY'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: BeveledMenuButton(
                              label: 'BASIC',
                              color: selectedDifficulty == LeaderboardDifficulty.basic
                                  ? AppColors.yellowButton
                                  : AppColors.greyButton,
                              width: double.infinity,
                              height: 54,
                              textColor: Colors.white,
                              fontSize: 14,
                              onTap: () {
                                setState(() {
                                  selectedDifficulty = LeaderboardDifficulty.basic;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BeveledMenuButton(
                              label: 'LOGIC',
                              color: selectedDifficulty == LeaderboardDifficulty.logic
                                  ? AppColors.pinkButton
                                  : AppColors.greyButton,
                              width: double.infinity,
                              height: 54,
                              textColor: Colors.white,
                              fontSize: 14,
                              onTap: () {
                                setState(() {
                                  selectedDifficulty = LeaderboardDifficulty.logic;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BeveledMenuButton(
                              label: 'MANIC',
                              color: selectedDifficulty == LeaderboardDifficulty.manic
                                  ? AppColors.redButton
                                  : AppColors.greyButton,
                              width: double.infinity,
                              height: 54,
                              textColor: Colors.white,
                              fontSize: 14,
                              onTap: () {
                                setState(() {
                                  selectedDifficulty = LeaderboardDifficulty.manic;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.28),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pinkBg.withOpacity(0.5),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.28),
                                    width: 2,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      child: Text(
                                        'RANK',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'USERNAME',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        'SCORE',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              Expanded(
                                child: StreamBuilder<List<LeaderboardEntryModel>>(
                                  stream: _leaderboardService.streamLeaderboard(
                                    modeId: _modeId,
                                    difficultyId: _difficultyId,
                                    limit: 50,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(color: Colors.white),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return const Center(
                                        child: Text(
                                          'Failed to load leaderboard.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }

                                    final entries = snapshot.data ?? [];

                                    if (entries.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'No leaderboard entries yet.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                      itemCount: entries.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final entry = entries[index];
                                        return _LeaderboardRow(
                                          rank: index + 1,
                                          entry: LeaderboardEntry(
                                            username: entry.username,
                                            score: entry.bestScore,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _LeaderboardRow({
    required this.rank,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    Color rowColor;
    switch (rank) {
      case 1:
        rowColor = AppColors.yellowButton.withOpacity(0.5);
        break;
      case 2:
        rowColor = AppColors.greyButton.withOpacity(0.4);
        break;
      case 3:
        rowColor = AppColors.darkOrangeButton.withOpacity(0.35);
        break;
      default:
        rowColor = AppColors.blueBg.withOpacity(0.5);
    }

    Color medalColor;
    switch (rank) {
      case 1:
        medalColor = const Color(0xFFFFC107);
        break;
      case 2:
        medalColor = const Color(0xFFB0BEC5);
        break;
      case 3:
        medalColor = const Color(0xFFFF8A65);
        break;
      default:
        medalColor = Colors.white.withOpacity(0.20);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.28),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Row(
              children: [
                if (rank <= 3)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: medalColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              entry.username,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              entry.score.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardEntry {
  final String username;
  final int score;

  const LeaderboardEntry({
    required this.username,
    required this.score,
  });
}
