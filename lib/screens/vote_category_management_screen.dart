import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';
import '../models/vote_category.dart';
import '../widgets/votenam_logo.dart';

class VoteCategoryManagementScreen extends StatefulWidget {
  const VoteCategoryManagementScreen({super.key});

  @override
  State<VoteCategoryManagementScreen> createState() =>
      _VoteCategoryManagementScreenState();
}

class _VoteCategoryManagementScreenState
    extends State<VoteCategoryManagementScreen> {
  List<VoteCategory> categories = [];
  List<VoteCategory> filteredCategories = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredCategories = categories.where((cat) {
        return cat.categoryName.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final loaded = await AdminApiService.getAllVoteCategories();
      setState(() {
        categories = loaded;
        filteredCategories = loaded;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Failed to load categories: ${e.toString()}');
    }
  }

  Future<void> _delete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
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
        await AdminApiService.deleteVoteCategory(id);
        if (mounted) {
          _showSuccess('Category deleted successfully');
          loadData();
        }
      } catch (e) {
        _showError('Failed to delete: ${e.toString()}');
      }
    }
  }

  void _showAddEditDialog({VoteCategory? category}) {
    showDialog(
      context: context,
      builder: (context) => _AddEditDialog(
        category: category,
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
                            hintText: 'Search categories...',
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
                        label: const Text('Add Category'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF41479B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredCategories.isEmpty
                      ? const Center(child: Text('No categories found'))
                      : isWide
                          ? DataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Category Name')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredCategories.map((cat) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(cat.id?.toString() ?? 'N/A')),
                                    DataCell(Text(
                                      cat.categoryName.isEmpty 
                                          ? 'Category ${cat.id ?? "N/A"}' 
                                          : cat.categoryName
                                    )),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Color(0xFF41479B)),
                                            onPressed: () =>
                                                _showAddEditDialog(category: cat),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => _delete(cat.id!),
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
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, index) {
                                final cat = filteredCategories[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(
                                      cat.categoryName.isEmpty 
                                          ? 'Category ${cat.id ?? "N/A"}' 
                                          : cat.categoryName
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () =>
                                              _showAddEditDialog(category: cat),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _delete(cat.id!),
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
  final VoteCategory? category;
  final VoidCallback onSaved;

  const _AddEditDialog({
    required this.category,
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
    if (widget.category != null) {
      // Show the actual category name, even if it's a fallback
      _nameController.text = widget.category!.categoryName;
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
      final category = VoteCategory(
        id: widget.category?.id,
        categoryName: _nameController.text.trim(),
      );

      if (widget.category == null) {
        await AdminApiService.createVoteCategory(category);
      } else {
        await AdminApiService.updateVoteCategory(widget.category!.id!, category);
      }

      if (mounted) {
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.category == null
                ? 'Category created successfully'
                : 'Category updated successfully'),
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
                widget.category == null ? 'Add Category' : 'Edit Category',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter category name';
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

