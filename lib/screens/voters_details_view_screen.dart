import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';
import '../models/voters_details.dart';
import '../widgets/votenam_logo.dart';

class VotersDetailsViewScreen extends StatefulWidget {
  const VotersDetailsViewScreen({super.key});

  @override
  State<VotersDetailsViewScreen> createState() =>
      _VotersDetailsViewScreenState();
}

class _VotersDetailsViewScreenState extends State<VotersDetailsViewScreen> {
  List<VotersDetails> votes = [];
  List<VotersDetails> filteredVotes = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    _searchController.addListener(_filterVotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterVotes() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredVotes = votes.where((vote) {
        return vote.fullName.toLowerCase().contains(query) ||
            vote.nationalIdNumber.toLowerCase().contains(query) ||
            vote.email.toLowerCase().contains(query) ||
            vote.phoneNumber.toLowerCase().contains(query) ||
            vote.candidate.fullName.toLowerCase().contains(query) ||
            vote.region.regionName.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final loaded = await AdminApiService.getAllVotes();
      setState(() {
        votes = loaded;
        filteredVotes = loaded;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load votes: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF41479B)))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 16),
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
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search votes...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: loadData,
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredVotes.isEmpty
                      ? const Center(child: Text('No votes found'))
                      : isWide
                          ? SingleChildScrollView(
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Voter Name')),
                                  DataColumn(label: Text('National ID')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Phone')),
                                  DataColumn(label: Text('Region')),
                                  DataColumn(label: Text('Candidate')),
                                  DataColumn(label: Text('Vote Date')),
                                ],
                                rows: filteredVotes.map((vote) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(vote.fullName)),
                                      DataCell(Text(vote.nationalIdNumber)),
                                      DataCell(Text(vote.email)),
                                      DataCell(Text(vote.phoneNumber)),
                                      DataCell(Text(
                                        vote.region.regionName.isEmpty 
                                            ? 'Unknown Region (ID: ${vote.region.id})' 
                                            : vote.region.regionName
                                      )),
                                      DataCell(Text(vote.candidate.fullName)),
                                      DataCell(Text(
                                        vote.voteDate != null
                                            ? vote.voteDate!
                                                .toIso8601String()
                                                .split('T')[0]
                                            : 'N/A',
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredVotes.length,
                              itemBuilder: (context, index) {
                                final vote = filteredVotes[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ExpansionTile(
                                    title: Text(vote.fullName),
                                    subtitle: Text(vote.candidate.fullName),
                                    children: [
                                      ListTile(
                                        title: const Text('National ID'),
                                        trailing: Text(vote.nationalIdNumber),
                                      ),
                                      ListTile(
                                        title: const Text('Email'),
                                        trailing: Text(vote.email),
                                      ),
                                      ListTile(
                                        title: const Text('Phone'),
                                        trailing: Text(vote.phoneNumber),
                                      ),
                                      ListTile(
                                        title: const Text('Region'),
                                        trailing: Text(
                                          vote.region.regionName.isEmpty 
                                              ? 'Unknown Region (ID: ${vote.region.id})' 
                                              : vote.region.regionName
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('Vote Date'),
                                        trailing: Text(
                                          vote.voteDate != null
                                              ? vote.voteDate!
                                                  .toIso8601String()
                                                  .split('T')[0]
                                              : 'N/A',
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
    );
  }
}

