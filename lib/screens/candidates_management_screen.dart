import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:typed_data';
import '../services/admin_api_service.dart';
import '../models/candidate.dart';
import '../models/vote_category.dart';
import '../widgets/votenam_logo.dart';

class CandidatesManagementScreen extends StatefulWidget {
  const CandidatesManagementScreen({super.key});

  @override
  State<CandidatesManagementScreen> createState() =>
      _CandidatesManagementScreenState();
}
//

class _CandidatesManagementScreenState
    extends State<CandidatesManagementScreen> {
  List<Candidate> candidates = [];
  List<VoteCategory> categories = [];
  List<Candidate> filteredCandidates = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    _searchController.addListener(_filterCandidates);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCandidates() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      filteredCandidates = candidates.where((candidate) {
        return candidate.fullName.toLowerCase().contains(searchQuery) ||
            candidate.partyName.toLowerCase().contains(searchQuery) ||
            candidate.position.toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final loadedCandidates = await AdminApiService.getAllCandidates();
      final loadedCategories = await AdminApiService.getAllVoteCategories();

      setState(() {
        candidates = loadedCandidates;
        filteredCandidates = loadedCandidates;
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to load candidates: ${e.toString()}');
    }
  }

  Future<void> _deleteCandidate(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Candidate'),
        content: const Text('Are you sure you want to delete this candidate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminApiService.deleteCandidate(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Candidate deleted successfully')),
          );
          loadData();
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Failed to delete candidate: ${e.toString()}');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({Candidate? candidate}) {
    showDialog(
      context: context,
      builder: (context) => CandidateAddEditDialog(
        candidate: candidate,
        categories: categories,
        onSaved: () {
          Navigator.pop(context);
          loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF41479B),
              ),
            )
          : Column(
              children: [
                // Header with Logo, Search and Add Button
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
                            hintText: 'Search candidates...',
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
                        color: const Color(0xFF41479B),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Candidate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF41479B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Candidates Table/List
                Expanded(
                  child: filteredCandidates.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty
                                    ? 'No candidates found'
                                    : 'No candidates match your search',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : isWide
                          ? _buildTable()
                          : _buildList(),
                ),
              ],
            ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
      child: DataTable(
          columnSpacing: 24,
          headingRowHeight: 60,
          dataRowMinHeight: 150,
          dataRowMaxHeight: 180,
          headingRowColor: MaterialStateProperty.all(const Color(0xFF41479B)),
        columns: const [
            DataColumn(
              label: Text(
                'Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Party',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Position',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Party Logo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
        ],
        rows: filteredCandidates.map((candidate) {
          return DataRow(
            cells: [
              DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      width: 120,
                      height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                  ),
                  child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                    child: candidate.photoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: candidate.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                    const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            errorWidget: (context, url, error) =>
                                    const Icon(Icons.person, size: 50),
                          )
                            : const Icon(Icons.person, size: 50),
                  ),
                ),
              ),
                ),
              DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      candidate.fullName,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      candidate.partyName,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      candidate.position,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      candidate.voteCategory?.categoryName ?? 'N/A',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      width: 100,
                      height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                  ),
                  child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                    child: candidate.partyLogoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: candidate.partyLogoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) =>
                                    const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            errorWidget: (context, url, error) =>
                                    const Icon(Icons.flag, size: 40),
                          )
                            : const Icon(Icons.flag, size: 40),
                      ),
                  ),
                ),
              ),
              DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF41479B), size: 28),
                      onPressed: () => _showAddEditDialog(candidate: candidate),
                          tooltip: 'Edit',
                    ),
                    IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                      onPressed: () => _deleteCandidate(candidate.id!),
                          tooltip: 'Delete',
                    ),
                  ],
                    ),
                ),
              ),
            ],
          );
        }).toList(),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCandidates.length,
      itemBuilder: (context, index) {
        final candidate = filteredCandidates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: candidate.photoUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: candidate.photoUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.person),
                      ),
                    )
                  : const Icon(Icons.person),
            ),
            title: Text(
              candidate.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(candidate.partyName),
                Text(candidate.position),
                Text(candidate.voteCategory?.categoryName ?? 'N/A'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF41479B)),
                  onPressed: () => _showAddEditDialog(candidate: candidate),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCandidate(candidate.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CandidateAddEditDialog extends StatefulWidget {
  final Candidate? candidate;
  final List<VoteCategory> categories;
  final VoidCallback onSaved;

  const CandidateAddEditDialog({
    super.key,
    this.candidate,
    required this.categories,
    required this.onSaved,
  });

  @override
  State<CandidateAddEditDialog> createState() =>
      _CandidateAddEditDialogState();
}

class _CandidateAddEditDialogState extends State<CandidateAddEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _partyNameController = TextEditingController();
  final _positionController = TextEditingController();
  VoteCategory? _selectedCategory;
  File? _photoFile;
  File? _partyLogoFile;
  XFile? _photoXFile; // For web
  XFile? _partyLogoXFile; // For web
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.candidate != null) {
      _fullNameController.text = widget.candidate!.fullName;
      _partyNameController.text = widget.candidate!.partyName;
      _positionController.text = widget.candidate!.position;
      // Find matching category by ID to avoid DropdownButton equality issues
      if (widget.candidate!.voteCategory != null) {
        _selectedCategory = widget.categories.firstWhere(
          (cat) => cat.id == widget.candidate!.voteCategory?.id,
          orElse: () => widget.candidate!.voteCategory!,
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _partyNameController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      if (kIsWeb) {
        // Use image_picker for web (better web support)
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _photoXFile = image;
            _photoFile = null; // Clear non-web file
          });
        }
      } else {
        // Use file_picker for mobile/desktop
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _photoFile = File(result.files.single.path!);
            _photoXFile = null; // Clear web file
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickPartyLogo() async {
    try {
      if (kIsWeb) {
        // Use image_picker for web (better web support)
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _partyLogoXFile = image;
            _partyLogoFile = null; // Clear non-web file
          });
        }
      } else {
        // Use file_picker for mobile/desktop
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _partyLogoFile = File(result.files.single.path!);
            _partyLogoXFile = null; // Clear web file
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Category is required for create, but can be null for update (to keep existing)
    if (widget.candidate == null && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vote category')),
      );
      return;
    }

    // Photo and logo are required when creating
    if (widget.candidate == null) {
      if (_photoFile == null && _photoXFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a candidate photo')),
        );
        return;
      }
      if (_partyLogoFile == null && _partyLogoXFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a party logo')),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare file data for web or non-web
      Uint8List? photoBytes;
      String? photoName;
      Uint8List? partyLogoBytes;
      String? partyLogoName;
      
      if (kIsWeb) {
        // For web, use XFile and convert to bytes
        // Only read bytes if a new file was selected (not for updates without new files)
        if (_photoXFile != null) {
          try {
            photoBytes = await _photoXFile!.readAsBytes();
            photoName = _photoXFile!.name.isNotEmpty 
                ? _photoXFile!.name 
                : 'photo.jpg';
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error reading photo: ${e.toString()}')),
              );
            }
            return;
          }
        }
        if (_partyLogoXFile != null) {
          try {
            partyLogoBytes = await _partyLogoXFile!.readAsBytes();
            partyLogoName = _partyLogoXFile!.name.isNotEmpty 
                ? _partyLogoXFile!.name 
                : 'logo.jpg';
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error reading logo: ${e.toString()}')),
              );
            }
            return;
          }
        }
      }
      // For non-web, we use File objects directly (photo and partyLogo parameters)

      if (widget.candidate == null) {
        // Create
        await AdminApiService.createCandidate(
          fullName: _fullNameController.text.trim(),
          partyName: _partyNameController.text.trim(),
          position: _positionController.text.trim(),
          voteCategoryId: _selectedCategory!.id!,
          photo: kIsWeb ? null : _photoFile,
          partyLogo: kIsWeb ? null : _partyLogoFile,
          photoBytes: photoBytes,
          photoName: photoName,
          partyLogoBytes: partyLogoBytes,
          partyLogoName: partyLogoName,
        );
      } else {
        // Update - always send required fields, only send files if new ones are selected
        await AdminApiService.updateCandidate(
          id: widget.candidate!.id!,
          fullName: _fullNameController.text.trim(),
          partyName: _partyNameController.text.trim(),
          position: _positionController.text.trim(),
          voteCategoryId: _selectedCategory?.id ?? widget.candidate!.voteCategory?.id,
          photo: kIsWeb ? null : (_photoFile != null ? _photoFile : null),
          partyLogo: kIsWeb ? null : (_partyLogoFile != null ? _partyLogoFile : null),
          photoBytes: photoBytes,
          photoName: photoName,
          partyLogoBytes: partyLogoBytes,
          partyLogoName: partyLogoName,
        );
      }

      if (mounted) {
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.candidate == null
                ? 'Candidate created successfully'
                : 'Candidate updated successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 600 : double.infinity,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.candidate == null
                      ? 'Add Candidate'
                      : 'Edit Candidate',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF41479B),
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Party Name
                TextFormField(
                  controller: _partyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Party Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter party name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Position
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter position';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Vote Category Dropdown
                DropdownButtonFormField<VoteCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Vote Category',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.categoryName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: widget.candidate == null
                      ? (value) {
                    if (value == null) {
                      return 'Please select a vote category';
                    }
                    return null;
                        }
                      : null, // Category is optional for updates
                ),
                const SizedBox(height: 16),

                // Photo Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Candidate Photo *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF41479B),
                      ),
                    ),
                    const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickPhoto,
                            icon: Icon(
                              _photoFile != null || _photoXFile != null
                                  ? Icons.check_circle
                                  : Icons.image,
                              color: _photoFile != null || _photoXFile != null
                                  ? Colors.green
                                  : null,
                            ),
                            label: Text(
                              _photoFile == null && _photoXFile == null
                                  ? 'Pick Photo (Required)'
                                  : 'Photo Selected ✓',
                              style: TextStyle(
                                color: _photoFile != null || _photoXFile != null
                                    ? Colors.green
                                    : null,
                                fontWeight: _photoFile != null || _photoXFile != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _photoFile != null || _photoXFile != null
                                    ? Colors.green
                                    : Colors.grey,
                                width: _photoFile != null || _photoXFile != null ? 2 : 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Preview
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _photoFile != null || _photoXFile != null
                                  ? Colors.green
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _photoXFile != null
                                ? FutureBuilder<Uint8List>(
                                    future: _photoXFile!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  )
                                : _photoFile != null
                                    ? Image.file(
                                        _photoFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : widget.candidate?.photoUrl != null
                                        ? CachedNetworkImage(
                                    imageUrl: widget.candidate!.photoUrl!,
                                    fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                            errorWidget: (context, url, error) =>
                                                const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                  ],
                ),
                const SizedBox(height: 20),

                // Party Logo Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Party Logo *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF41479B),
                      ),
                    ),
                    const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickPartyLogo,
                            icon: Icon(
                              _partyLogoFile != null || _partyLogoXFile != null
                                  ? Icons.check_circle
                                  : Icons.flag,
                              color: _partyLogoFile != null || _partyLogoXFile != null
                                  ? Colors.green
                                  : null,
                            ),
                            label: Text(
                              _partyLogoFile == null && _partyLogoXFile == null
                                  ? 'Pick Party Logo (Required)'
                                  : 'Logo Selected ✓',
                              style: TextStyle(
                                color: _partyLogoFile != null || _partyLogoXFile != null
                                    ? Colors.green
                                    : null,
                                fontWeight: _partyLogoFile != null || _partyLogoXFile != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _partyLogoFile != null || _partyLogoXFile != null
                                    ? Colors.green
                                    : Colors.grey,
                                width: _partyLogoFile != null || _partyLogoXFile != null ? 2 : 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Preview
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _partyLogoFile != null || _partyLogoXFile != null
                                  ? Colors.green
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _partyLogoXFile != null
                                ? FutureBuilder<Uint8List>(
                                    future: _partyLogoXFile!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.contain,
                                        );
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  )
                                : _partyLogoFile != null
                                    ? Image.file(
                                        _partyLogoFile!,
                                        fit: BoxFit.contain,
                                      )
                                    : widget.candidate?.partyLogoUrl != null
                                        ? CachedNetworkImage(
                                    imageUrl: widget.candidate!.partyLogoUrl!,
                                    fit: BoxFit.contain,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                            errorWidget: (context, url, error) =>
                                                const Icon(
                                              Icons.flag,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.flag,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                          ),
                        ),
                      ],
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF41479B),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

