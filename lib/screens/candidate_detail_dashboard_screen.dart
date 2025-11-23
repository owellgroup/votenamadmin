import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/candidate.dart';
import '../models/voters_details.dart';
import '../widgets/votenam_logo.dart';

class CandidateDetailDashboardScreen extends StatelessWidget {
  final Candidate candidate;
  final List<VotersDetails> votes;
  final int totalVotes;

  const CandidateDetailDashboardScreen({
    super.key,
    required this.candidate,
    required this.votes,
    required this.totalVotes,
  });

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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final regionCounts = getRegionVoteCounts();
    // Sort regions by vote count (descending) for better visualization
    final regions = regionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedRegionNames = regions.map((e) => e.key).toList();
    final maxVotes = regionCounts.values.isEmpty
        ? 100.0
        : (regionCounts.values.reduce((a, b) => a > b ? a : b) * 1.2).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const VotenamLogo(
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: Text('${candidate.fullName} - Performance'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF41479B),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 40.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate Info Card
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
              child: Row(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: candidate.photoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: candidate.photoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF41479B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          candidate.partyName,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          candidate.position,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF41479B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Total: $totalVotes votes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: candidate.partyLogoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: candidate.partyLogoUrl!,
                              fit: BoxFit.contain,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(
                                Icons.flag,
                                size: 50,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.flag,
                              size: 50,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Performance by Region Chart
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
                    'Performance by Region',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF41479B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 350,
                    child: regions.isEmpty
                        ? const Center(
                            child: Text(
                              'No votes by region yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: maxVotes,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: const Color(0xFF41479B),
                                  getTooltipItem: (group, groupIndex, rod,
                                      rodIndex) {
                                    final region = sortedRegionNames[group.x.toInt()];
                                    final voteCount = regionCounts[region]!;
                                    return BarTooltipItem(
                                      '$region\n$voteCount votes',
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
                                      if (value.toInt() >= sortedRegionNames.length) {
                                        return const Text('');
                                      }
                                      final region = sortedRegionNames[value.toInt()];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: RotatedBox(
                                          quarterTurns: 3,
                                          child: Text(
                                            region.length > 10
                                                ? '${region.substring(0, 10)}...'
                                                : region,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              barGroups: sortedRegionNames.asMap().entries.map((entry) {
                                final index = entry.key;
                                final region = entry.value;
                                final voteCount = regionCounts[region]!;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: voteCount.toDouble(),
                                      color: const Color(0xFFD21034),
                                      width: 20,
                                      borderRadius: const BorderRadius.vertical(
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

            // Region Breakdown List
            const Text(
              'Vote Breakdown by Region',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF41479B),
              ),
            ),
            const SizedBox(height: 20),

            ...sortedRegionNames.map((region) {
              final voteCount = regionCounts[region]!;
              final percentage = totalVotes > 0
                  ? (voteCount / totalVotes * 100).toStringAsFixed(1)
                  : '0.0';

              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
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
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF41479B),
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            region,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF41479B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$voteCount votes ($percentage%)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF41479B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$voteCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

