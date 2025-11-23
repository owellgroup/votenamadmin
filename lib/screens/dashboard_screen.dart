import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/admin_api_service.dart';
import '../models/candidate.dart';
import '../models/voters_details.dart';
import '../widgets/votenam_logo.dart';
import '../widgets/stat_card.dart';
import '../theme/app_theme.dart';
import 'candidate_detail_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<Candidate> candidates = [];
  List<VotersDetails> votes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void refresh() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedCandidates = await AdminApiService.getAllCandidates();
      final loadedVotes = await AdminApiService.getAllVotes();

      setState(() {
        candidates = loadedCandidates;
        votes = loadedVotes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load dashboard data: ${e.toString()}';
      });
    }
  }

  Map<String, int> getCandidateVoteCounts() {
    Map<String, int> counts = {};
    for (var vote in votes) {
      final candidateId = vote.candidate.id.toString();
      counts[candidateId] = (counts[candidateId] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getRegionVoteCounts() {
    Map<String, int> counts = {};
    for (var vote in votes) {
      final regionName = vote.region.regionName.isEmpty 
          ? 'Unknown Region (ID: ${vote.region.id})' 
          : vote.region.regionName;
      counts[regionName] = (counts[regionName] ?? 0) + 1;
    }
    return counts;
  }

  List<Map<String, dynamic>> getTopCandidates() {
    final counts = getCandidateVoteCounts();
    final candidateStats = candidates.map((candidate) {
      final voteCount = counts[candidate.id.toString()] ?? 0;
      return {
        'candidate': candidate,
        'voteCount': voteCount,
      };
    }).toList();

    candidateStats.sort((a, b) => (b['voteCount'] as int).compareTo(a['voteCount'] as int));
    return candidateStats.take(5).toList();
  }

  int getTotalVotes() {
    return votes.length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final isTablet = screenWidth >= 600 && screenWidth <= 900;
    final isDesktop = screenWidth > 900;
    final topCandidates = getTopCandidates();
    final totalVotes = getTotalVotes();
    final regionCounts = getRegionVoteCounts();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: loadData,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF41479B),
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(isWide ? 40.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard Header with Logo
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: const VotenamLogo(
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Dashboard',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF41479B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Statistics Cards - Modern Design
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate responsive aspect ratio based on available width
                            double aspectRatio;
                            int crossAxisCount;
                            double spacing;
                            
                            final availableWidth = constraints.maxWidth;
                            
                            if (isDesktop) {
                              crossAxisCount = 4;
                              // Calculate aspect ratio based on card width
                              final cardWidth = (availableWidth - (3 * 20)) / 4;
                              aspectRatio = cardWidth > 200 ? 1.5 : (cardWidth > 150 ? 1.6 : 1.8);
                              spacing = 20;
                            } else if (isTablet) {
                              crossAxisCount = 2;
                              // Calculate aspect ratio based on card width
                              final cardWidth = (availableWidth - 16) / 2;
                              aspectRatio = cardWidth > 250 ? 1.5 : (cardWidth > 200 ? 1.6 : (cardWidth > 150 ? 1.8 : 2.0));
                              spacing = 16;
                            } else {
                              crossAxisCount = 2;
                              // Calculate aspect ratio based on card width
                              final cardWidth = (availableWidth - 20) / 2;
                              aspectRatio = cardWidth > 200 ? 1.1 : (cardWidth > 150 ? 1.2 : (cardWidth > 100 ? 1.4 : 1.6));
                              spacing = 20;
                            }
                            
                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                              childAspectRatio: aspectRatio,
                              children: [
                            StatCard(
                              title: 'Total Votes',
                              value: totalVotes.toString(),
                              icon: Icons.how_to_vote_rounded,
                              iconColor: AppTheme.primaryBlue,
                            ),
                            StatCard(
                              title: 'Candidates',
                              value: candidates.length.toString(),
                              icon: Icons.people_rounded,
                              iconColor: AppTheme.accentRed,
                            ),
                            StatCard(
                              title: 'Regions',
                              value: regionCounts.keys.length.toString(),
                              icon: Icons.location_on_rounded,
                              iconColor: AppTheme.secondaryGreen,
                            ),
                            StatCard(
                              title: 'Avg per Candidate',
                              value: candidates.isEmpty
                                  ? '0'
                                  : (totalVotes / candidates.length)
                                      .toStringAsFixed(1),
                              icon: Icons.bar_chart_rounded,
                              iconColor: Colors.orange[700]!,
                            ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Overall Performance Chart - Modern Design
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: AppTheme.cardDecoration.copyWith(
                            boxShadow: AppTheme.elevatedShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.bar_chart_rounded,
                                      color: AppTheme.primaryBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Overall Candidate Performance',
                                    style: AppTheme.heading3,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 300,
                                child: topCandidates.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No votes yet',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : BarChart(
                                        BarChartData(
                                          alignment: BarChartAlignment.spaceAround,
                                          maxY: totalVotes > 0
                                              ? (totalVotes * 1.2)
                                              : 100.0,
                                          barTouchData: BarTouchData(
                                            enabled: true,
                                            touchTooltipData: BarTouchTooltipData(
                                              tooltipBgColor:
                                                  const Color(0xFF41479B),
                                              getTooltipItem: (group, groupIndex,
                                                  rod, rodIndex) {
                                                final candidate =
                                                    topCandidates[group.x.toInt()];
                                                final voteCount =
                                                    candidate['voteCount'] as int;
                                                return BarTooltipItem(
                                                  '${candidate['candidate'].fullName}\n$voteCount votes',
                                                  const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  if (value.toInt() >=
                                                      topCandidates.length) {
                                                    return const Text('');
                                                  }
                                                  final candidate = topCandidates[
                                                      value.toInt()];
                                                  final name =
                                                      candidate['candidate']
                                                          .fullName;
                                                  return Padding(
                                                    padding: const EdgeInsets.only(
                                                        top: 8.0),
                                                    child: Text(
                                                      name.split(' ').first,
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  return Text(
                                                    value.toInt().toString(),
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          barGroups: topCandidates
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final voteCount =
                                                entry.value['voteCount'] as int;
                                            return BarChartGroupData(
                                              x: index,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: voteCount.toDouble(),
                                                  color: index == 0
                                                      ? const Color(0xFFD21034)
                                                      : const Color(0xFF41479B),
                                                  width: 20,
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                    top: Radius.circular(5),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Top Candidates - Modern Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: AppTheme.accentRed,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Top Performing Candidates',
                              style: AppTheme.heading2,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Candidates List
                        ...topCandidates.asMap().entries.map((entry) {
                          final index = entry.key;
                          final candidate =
                              entry.value['candidate'] as Candidate;
                          final voteCount = entry.value['voteCount'] as int;
                          final percentage = totalVotes > 0
                              ? (voteCount / totalVotes * 100)
                                  .toStringAsFixed(1)
                              : '0.0';

                          return GestureDetector(
                            onTap: () async {
                              final candidateVotes = votes
                                  .where((v) => v.candidate.id == candidate.id)
                                  .toList();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CandidateDetailDashboardScreen(
                                    candidate: candidate,
                                    votes: candidateVotes,
                                    totalVotes: voteCount,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: index == 0
                                      ? const Color(0xFFD21034)
                                      : Colors.grey[300]!,
                                  width: index == 0 ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Rank Badge
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? const Color(0xFFD21034)
                                          : const Color(0xFF41479B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Candidate Photo
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: candidate.photoUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: candidate.photoUrl!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                Icons.person,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Candidate Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          candidate.fullName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF41479B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          candidate.partyName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$voteCount votes ($percentage%)',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF41479B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Party Logo
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: candidate.partyLogoUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: candidate.partyLogoUrl!,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                Icons.flag,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.flag,
                                              size: 30,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 30),

                        // Region Performance
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Votes by Region',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF41479B),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...() {
                                final sortedEntries = regionCounts.entries.toList()
                                  ..sort((a, b) => b.value.compareTo(a.value));
                                return sortedEntries.map((entry) {
                                  final regionName = entry.key;
                                  final voteCount = entry.value;
                                  final percentage = totalVotes > 0
                                      ? (voteCount / totalVotes * 100)
                                          .toStringAsFixed(1)
                                      : '0.0';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              regionName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF41479B),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            LinearProgressIndicator(
                                              value: totalVotes > 0
                                                  ? voteCount / totalVotes
                                                  : 0,
                                              backgroundColor: Colors.grey[200],
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(
                                                    Color(0xFF41479B),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '$voteCount ($percentage%)',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF41479B),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                });
                              }(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
      ),
    );
  }

}

