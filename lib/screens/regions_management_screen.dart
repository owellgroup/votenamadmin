import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';
import '../models/region.dart';
import '../widgets/votenam_logo.dart';

class RegionsManagementScreen extends StatefulWidget {
  const RegionsManagementScreen({super.key});

  @override
  State<RegionsManagementScreen> createState() =>
      _RegionsManagementScreenState();
}

class _RegionsManagementScreenState extends State<RegionsManagementScreen> {
  List<Region> regions = [];
  List<Region> filteredRegions = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    _searchController.addListener(_filterRegions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRegions() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredRegions = regions.where((region) {
        return region.regionName.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final loaded = await AdminApiService.getAllRegions();
      setState(() {
        regions = loaded;
        filteredRegions = loaded;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Failed to load regions: ${e.toString()}');
    }
  }

  Future<void> _delete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Region'),
        content: const Text('Are you sure?'),
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
        await AdminApiService.deleteRegion(id);
        if (mounted) {
          _showSuccess('Region deleted successfully');
          loadData();
        }
      } catch (e) {
        _showError('Failed to delete: ${e.toString()}');
      }
    }
  }

  void _showAddEditDialog({Region? region}) {
    showDialog(
      context: context,
      builder: (context) => _AddEditDialog(
        region: region,
        onSaved: () {
          Navigator.pop(context);
          loadData();
        },
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
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
                            hintText: 'Search regions...',
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
                        label: const Text('Add Region'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF41479B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredRegions.isEmpty
                      ? const Center(child: Text('No regions found'))
                      : isWide
                          ? DataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Region Name')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredRegions.map((region) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(region.id?.toString() ?? 'N/A')),
                                    DataCell(Text(region.regionName.isEmpty 
                                        ? 'Unknown Region (ID: ${region.id})' 
                                        : region.regionName)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Color(0xFF41479B)),
                                            onPressed: () =>
                                                _showAddEditDialog(region: region),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => _delete(region.id!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredRegions.length,
                              itemBuilder: (context, index) {
                                final region = filteredRegions[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: Text(region.regionName.isEmpty 
                                        ? 'Unknown Region (ID: ${region.id})' 
                                        : region.regionName),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () =>
                                              _showAddEditDialog(region: region),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _delete(region.id!),
                                        ),
                                      ],
                                    ),
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

class _AddEditDialog extends StatefulWidget {
  final Region? region;
  final VoidCallback onSaved;

  const _AddEditDialog({
    required this.region,
    required this.onSaved,
  });

  @override
  State<_AddEditDialog> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<_AddEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.region != null) {
      // Show the actual region name
      String regionName = widget.region!.regionName;
      // If it's a fallback name like "Region 1", extract just the number part for editing
      if (regionName.startsWith('Region ') && regionName.length > 7) {
        // Keep it as is, user can edit
        _nameController.text = regionName;
      } else if (regionName.startsWith('Unknown Region')) {
        // Clear it so user can enter a proper name
        _nameController.text = '';
      } else {
        _nameController.text = regionName;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final region = Region(
        id: widget.region?.id,
        regionName: _nameController.text.trim(),
      );

      if (widget.region == null) {
        await AdminApiService.createRegion(region);
      } else {
        await AdminApiService.updateRegion(widget.region!.id!, region);
      }

      if (mounted) {
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.region == null
                ? 'Region created successfully'
                : 'Region updated successfully'),
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
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.region == null ? 'Add Region' : 'Edit Region',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Region Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter region name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
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
    );
  }
}

