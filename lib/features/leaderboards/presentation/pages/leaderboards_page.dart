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

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _PageButton(
          label: '‹',
          enabled: onPrevious != null,
          onTap: onPrevious,
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withOpacity(0.24),
              width: 1.5,
            ),
          ),
          child: Text(
            'PAGE ${currentPage + 1} / $totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),

        _PageButton(
          label: '›',
          enabled: onNext != null,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.42,
        child: Container(
          width: 36,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF00AEEF),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: Colors.white,
              width: 1.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 0.9,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 2,
                    offset: Offset(0, 1.2),
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

  String get _modeTitle {
    switch (selectedMode) {
      case LeaderboardMode.gatekeeping:
        return 'GATEKEEPING';
      case LeaderboardMode.oneOrNone:
        return 'ONE OR NONE';
    }
  }

  String get _difficultyTitle {
    switch (selectedDifficulty) {
      case LeaderboardDifficulty.basic:
        return 'BASIC';
      case LeaderboardDifficulty.logic:
        return 'LOGIC';
      case LeaderboardDifficulty.manic:
        return 'MANIC';
    }
  }

  Color get _modeAccentColor {
    switch (selectedMode) {
      case LeaderboardMode.gatekeeping:
        return AppColors.orangeButton;
      case LeaderboardMode.oneOrNone:
        return AppColors.purpleButton;
    }
  }

  Color get _difficultyAccentColor {
    switch (selectedDifficulty) {
      case LeaderboardDifficulty.basic:
        return AppColors.yellowButton;
      case LeaderboardDifficulty.logic:
        return AppColors.pinkButton;
      case LeaderboardDifficulty.manic:
        return AppColors.redButton;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.blueBg,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SmallSquareIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () {
                        unawaited(SfxController.instance.playMenuBack());
                        Navigator.pop(context);
                      },
                    ),
                    const MusicButton(size: 28),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'LEADERBOARDS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(0, 3),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              _BoardStatusChip(
                modeTitle: _modeTitle,
                difficultyTitle: _difficultyTitle,
                accentColor: _difficultyAccentColor,
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  child: Column(
                    children: [
                      _buildModeSelector(),

                      const SizedBox(height: 8),

                      _buildDifficultySelector(),

                      const SizedBox(height: 8),

                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: _LeaderboardBoard(
                            key: ValueKey('$_modeId-$_difficultyId'),
                            modeId: _modeId,
                            difficultyId: _difficultyId,
                            modeAccentColor: _modeAccentColor,
                            difficultyAccentColor: _difficultyAccentColor,
                          ),
                        ),
                      ),
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

  Widget _buildModeSelector() {
    return Column(
      children: [
        const _MiniSectionTitle(label: 'MODE'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: BeveledMenuButton(
                label: 'GATEKEEPING',
                color: selectedMode == LeaderboardMode.gatekeeping
                    ? AppColors.orangeButton
                    : AppColors.greyButton,
                width: double.infinity,
                height: 50,
                textColor: Colors.white,
                fontSize: 13,
                onTap: () {
                  setState(() {
                    unawaited(SfxController.instance.playMenuPress());
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
                height: 50,
                textColor: Colors.white,
                fontSize: 13,
                onTap: () {
                  setState(() {
                    unawaited(SfxController.instance.playMenuPress());
                    selectedMode = LeaderboardMode.oneOrNone;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      children: [
        const _MiniSectionTitle(label: 'DIFFICULTY'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: BeveledMenuButton(
                label: 'BASIC',
                color: selectedDifficulty == LeaderboardDifficulty.basic
                    ? AppColors.yellowButton
                    : AppColors.greyButton,
                width: double.infinity,
                height: 48,
                textColor: Colors.white,
                fontSize: 13,
                onTap: () {
                  setState(() {
                    unawaited(SfxController.instance.playMenuPress());
                    selectedDifficulty = LeaderboardDifficulty.basic;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: BeveledMenuButton(
                label: 'LOGIC',
                color: selectedDifficulty == LeaderboardDifficulty.logic
                    ? AppColors.pinkButton
                    : AppColors.greyButton,
                width: double.infinity,
                height: 48,
                textColor: Colors.white,
                fontSize: 13,
                onTap: () {
                  setState(() {
                    unawaited(SfxController.instance.playMenuPress());
                    selectedDifficulty = LeaderboardDifficulty.logic;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: BeveledMenuButton(
                label: 'MANIC',
                color: selectedDifficulty == LeaderboardDifficulty.manic
                    ? AppColors.redButton
                    : AppColors.greyButton,
                width: double.infinity,
                height: 48,
                textColor: Colors.white,
                fontSize: 13,
                onTap: () {
                  setState(() {
                    unawaited(SfxController.instance.playMenuPress());
                    selectedDifficulty = LeaderboardDifficulty.manic;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LeaderboardBoard extends StatefulWidget {
  const _LeaderboardBoard({
    super.key,
    required this.modeId,
    required this.difficultyId,
    required this.modeAccentColor,
    required this.difficultyAccentColor,
  });

  final String modeId;
  final String difficultyId;
  final Color modeAccentColor;
  final Color difficultyAccentColor;

  @override
  State<_LeaderboardBoard> createState() => _LeaderboardBoardState();
}

class _LeaderboardBoardState extends State<_LeaderboardBoard> {
  static const int _firstPageRows = 2; // ranks 4 and 5 only
  static const int _otherPageRows = 6; // page 2 onward

  int _currentPage = 0;

  bool get _showPinnedTopThree => _currentPage == 0;

  int _totalPagesForRemaining(int remainingCount) {
    if (remainingCount <= _firstPageRows) return 1;

    final afterFirstPage = remainingCount - _firstPageRows;
    return 1 + (afterFirstPage / _otherPageRows).ceil();
  }

  int _startIndexForPage(int page) {
    if (page == 0) return 0;

    return _firstPageRows + ((page - 1) * _otherPageRows);
  }

  int _rowCountForPage(int page) {
    return page == 0 ? _firstPageRows : _otherPageRows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.30),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: StreamBuilder<List<LeaderboardEntryModel>>(
        stream: _leaderboardService.streamLeaderboard(
          modeId: widget.modeId,
          difficultyId: widget.difficultyId,
          limit: 50,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LeaderboardLoadingState();
          }

          if (snapshot.hasError) {
            return const _LeaderboardMessageState(
              icon: Icons.error_outline_rounded,
              title: 'LOAD FAILED',
              message: 'Could not load the leaderboard.',
            );
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return const _LeaderboardMessageState(
              icon: Icons.emoji_events_outlined,
              title: 'NO SCORES YET',
              message: 'Be the first player on this board!',
            );
          }

          final mappedEntries = entries
              .map(
                (entry) => LeaderboardEntry(
              username: entry.username,
              score: entry.bestScore,
            ),
          )
              .toList();

          final topThree = mappedEntries.take(3).toList();
          final remaining = mappedEntries.skip(3).toList();

          final totalPages = _totalPagesForRemaining(remaining.length);

          if (_currentPage >= totalPages) {
            _currentPage = totalPages - 1;
          }

          final startIndex = _startIndexForPage(_currentPage);
          final rowCount = _rowCountForPage(_currentPage);

          final pagedEntries = remaining
              .skip(startIndex)
              .take(rowCount)
              .toList();

          return Column(
            children: [
              if (_showPinnedTopThree) ...[
                _TopPodiumPanel(
                  entries: topThree,
                  accentColor: widget.difficultyAccentColor,
                ),
                const SizedBox(height: 20),
              ],

              _LeaderboardHeader(
                accentColor: widget.modeAccentColor,
              ),

              const SizedBox(height: 8),

              Expanded(
                child: remaining.isEmpty
                    ? const _LeaderboardMessageState(
                  icon: Icons.format_list_numbered_rounded,
                  title: 'ONLY TOP PLAYERS SO FAR',
                  message: 'More ranks will appear after more scores.',
                  compact: true,
                )
                    : _LeaderboardRowsArea(
                  pagedEntries: pagedEntries,
                  startIndex: startIndex,
                  maxRows: rowCount,
                ),
              ),

              if (remaining.isNotEmpty && totalPages > 1) ...[
                const SizedBox(height: 8),
                _PaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  onPrevious: _currentPage <= 0
                      ? null
                      : () {
                    setState(() {
                      unawaited(SfxController.instance.playMenuPress());
                      _currentPage--;
                    });
                  },
                  onNext: _currentPage >= totalPages - 1
                      ? null
                      : () {
                    setState(() {
                      unawaited(SfxController.instance.playMenuPress());
                      _currentPage++;
                    });
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TopPodiumPanel extends StatelessWidget {
  const _TopPodiumPanel({
    required this.entries,
    required this.accentColor,
  });

  final List<LeaderboardEntry> entries;
  final Color accentColor;

  LeaderboardEntry? _entryAtRank(int rank) {
    final index = rank - 1;
    if (index < 0 || index >= entries.length) return null;
    return entries[index];
  }

  @override
  Widget build(BuildContext context) {
    final first = _entryAtRank(1);
    final second = _entryAtRank(2);
    final third = _entryAtRank(3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 25),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC107),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'TOP CIRCUIT MASTERS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(0, 1.4),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 166,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _PodiumTile(
                    rank: 2,
                    entry: second,
                    height: 126,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PodiumTile(
                    rank: 1,
                    entry: first,
                    height: 154,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PodiumTile(
                    rank: 3,
                    entry: third,
                    height: 122,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumTile extends StatelessWidget {
  const _PodiumTile({
    required this.rank,
    required this.entry,
    required this.height,
  });

  final int rank;
  final LeaderboardEntry? entry;
  final double height;

  bool get hasEntry => entry != null;

  @override
  Widget build(BuildContext context) {
    final badgeColor = switch (rank) {
      1 => const Color(0xFFFFC107),
      2 => const Color(0xFFCFD8DC),
      3 => const Color(0xFFFF8A65),
      _ => Colors.white,
    };

    final darkText = switch (rank) {
      1 => const Color(0xFF5B3A00),
      2 => const Color(0xFF263238),
      3 => const Color(0xFF5B2A12),
      _ => Colors.white,
    };

    final icon = rank == 1
        ? Icons.emoji_events_rounded
        : Icons.military_tech_rounded;

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(7, 7, 7, 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(rank == 1 ? 0.78 : 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(rank == 1 ? 0.72 : 0.46),
          width: rank == 1 ? 2.4 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.26),
            blurRadius: rank == 1 ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: darkText,
            size: rank == 1 ? 38 : 32,
            shadows: const [
              Shadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),

          const SizedBox(height: 2),

          Text(
            '#$rank',
            style: TextStyle(
              color: darkText,
              fontSize: rank == 1 ? 16 : 14,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: Center(
              child: Text(
                hasEntry ? entry!.username : '---',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: rank == 1 ? const Color(0xFF4A2F00) : Colors.white,
                  fontSize: rank == 1 ? 13 : 11.5,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    if (rank != 1)
                      const Shadow(
                        color: Colors.black38,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                  ],
                ),
              ),
            ),
          ),

          _TinyScorePill(
            score: hasEntry ? entry!.score : null,
            darkText: rank == 1,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader({
    required this.accentColor,
  });

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.52),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 2,
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              'RANK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'PLAYER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: 82,
            child: Text(
              'SCORE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRowsArea extends StatelessWidget {
  const _LeaderboardRowsArea({
    required this.pagedEntries,
    required this.startIndex,
    required this.maxRows,
  });

  final List<LeaderboardEntry> pagedEntries;
  final int startIndex;
  final int maxRows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = maxRows <= 2 ? 8.0 : 6.0;

        final availableHeight = constraints.maxHeight;
        final totalGapHeight = gap * (maxRows - 1);

        final rawRowHeight = maxRows <= 0
            ? availableHeight
            : (availableHeight - totalGapHeight) / maxRows;

        final rowHeight = rawRowHeight.clamp(
          maxRows <= 2 ? 54.0 : 42.0,
          maxRows <= 2 ? 76.0 : 58.0,
        );

        final contentHeight = (rowHeight * maxRows) + totalGapHeight;
        final shouldScroll = contentHeight > availableHeight;

        final rows = List.generate(maxRows, (index) {
          final hasEntry = index < pagedEntries.length;
          final rank = startIndex + index + 4;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == maxRows - 1 ? 0 : gap,
            ),
            child: SizedBox(
              height: rowHeight,
              child: hasEntry
                  ? _LeaderboardRow(
                rank: rank,
                entry: pagedEntries[index],
              )
                  : const SizedBox.shrink(),
            ),
          );
        });

        final rowColumn = Column(
          children: rows,
        );

        if (shouldScroll) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: rowColumn,
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: contentHeight,
            child: rowColumn,
          ),
        );
      },
    );
  }
}
class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.entry,
  });

  final int rank;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowHeight = constraints.maxHeight;

        final compact = rowHeight < 50;
        final horizontalPadding = compact ? 8.0 : 10.0;
        final verticalPadding = compact ? 6.0 : 8.0;

        final usernameFontSize = compact ? 13.0 : 15.0;
        final scoreFontSize = compact ? 12.5 : 14.0;

        return Container(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(compact ? 12 : 15),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: compact ? 1.3 : 1.6,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: compact ? 46 : 52,
                child: _RankBadge(
                  rank: rank,
                  compact: compact,
                ),
              ),

              SizedBox(width: compact ? 4 : 6),

              Expanded(
                child: Text(
                  entry.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: usernameFontSize,
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: compact ? 6 : 8),

              _ScorePill(
                score: entry.score,
                compact: compact,
                fontSize: scoreFontSize,
              ),
            ],
          ),
        );
      },
    );
  }
}
class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    this.compact = false,
  });

  final int rank;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 30 : 34,
      height: compact ? 26 : 30,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        border: Border.all(
          color: Colors.white.withOpacity(0.28),
          width: compact ? 1.3 : 1.6,
        ),
      ),
      child: Center(
        child: Text(
          '$rank',
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 12.5 : 14,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(
                color: Colors.black38,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.score,
    this.compact = false,
    this.fontSize = 14,
  });

  final int score;
  final bool compact;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: compact ? 66 : 76,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
          width: compact ? 1.2 : 1.4,
        ),
      ),
      child: Text(
        score.toString(),
        textAlign: TextAlign.center,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _TinyScorePill extends StatelessWidget {
  const _TinyScorePill({
    required this.score,
    required this.darkText,
  });

  final int? score;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 58),
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: darkText
            ? Colors.white.withOpacity(0.42)
            : Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.24),
          width: 1.2,
        ),
      ),
      child: Text(
        score == null ? '---' : score.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: darkText ? const Color(0xFF4A2F00) : Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BoardStatusChip extends StatelessWidget {
  const _BoardStatusChip({
    required this.modeTitle,
    required this.difficultyTitle,
    required this.accentColor,
  });

  final String modeTitle;
  final String difficultyTitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.46),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.36),
          width: 1.6,
        ),
      ),
      child: Text(
        '$modeTitle  •  $difficultyTitle',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: Colors.black38,
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSectionTitle extends StatelessWidget {
  const _MiniSectionTitle({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
            shadows: [
              Shadow(
                color: Colors.black38,
                offset: Offset(0, 1.5),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallSquareIconButton extends StatelessWidget {
  const _SmallSquareIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const double size = 28;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF00AEEF),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: Colors.white,
            width: 1.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 19,
            shadows: [
              Shadow(
                color: Colors.black38,
                blurRadius: 2,
                offset: Offset(0, 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardLoadingState extends StatelessWidget {
  const _LeaderboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }
}

class _LeaderboardMessageState extends StatelessWidget {
  const _LeaderboardMessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.86),
              size: compact ? 28 : 40,
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 14 : 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
        ),
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