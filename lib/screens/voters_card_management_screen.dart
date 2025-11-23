import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';
import '../models/voters_card.dart';
import '../widgets/votenam_logo.dart';

class VotersCardManagementScreen extends StatefulWidget {
  const VotersCardManagementScreen({super.key});

  @override
  State<VotersCardManagementScreen> createState() =>
      _VotersCardManagementScreenState();
}

class _VotersCardManagementScreenState
    extends State<VotersCardManagementScreen> {
  List<VotersCard> cards = [];
  List<VotersCard> filteredCards = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    _searchController.addListener(_filterCards);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCards() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredCards = cards.where((card) {
        return card.cardNumber.toLowerCase().contains(query) ||
            card.cardName.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final loaded = await AdminApiService.getAllVotersCards();
      setState(() {
        cards = loaded;
        filteredCards = loaded;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Failed to load cards: ${e.toString()}');
    }
  }

  Future<void> _delete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
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
        await AdminApiService.deleteVotersCard(id);
        if (mounted) {
          _showSuccess('Card deleted successfully');
          loadData();
        }
      } catch (e) {
        _showError('Failed to delete: ${e.toString()}');
      }
    }
  }

  void _showAddEditDialog({VotersCard? card}) {
    showDialog(
      context: context,
      builder: (context) => _AddEditDialog(
        card: card,
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
                            hintText: 'Search cards...',
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
                        label: const Text('Add Card'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF41479B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredCards.isEmpty
                      ? const Center(child: Text('No cards found'))
                      : isWide
                          ? DataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Card Number')),
                                DataColumn(label: Text('Card Name')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredCards.map((card) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(card.id.toString())),
                                    DataCell(Text(card.cardNumber)),
                                    DataCell(Text(card.cardName)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Color(0xFF41479B)),
                                            onPressed: () =>
                                                _showAddEditDialog(card: card),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => _delete(card.id!),
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
                              itemCount: filteredCards.length,
                              itemBuilder: (context, index) {
                                final card = filteredCards[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(card.cardNumber),
                                    subtitle: Text(card.cardName),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () =>
                                              _showAddEditDialog(card: card),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _delete(card.id!),
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
  final VotersCard? card;
  final VoidCallback onSaved;

  const _AddEditDialog({
    required this.card,
    required this.onSaved,
  });

  @override
  State<_AddEditDialog> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<_AddEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _cardNumberController.text = widget.card!.cardNumber;
      _cardNameController.text = widget.card!.cardName;
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final card = VotersCard(
        id: widget.card?.id,
        cardNumber: _cardNumberController.text.trim(),
        cardName: _cardNameController.text.trim(),
      );

      if (widget.card == null) {
        await AdminApiService.createVotersCard(card);
      } else {
        await AdminApiService.updateVotersCard(widget.card!.id!, card);
      }

      if (mounted) {
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.card == null
                ? 'Card created successfully'
                : 'Card updated successfully'),
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
                widget.card == null ? 'Add Card' : 'Edit Card',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNameController,
                decoration: const InputDecoration(
                  labelText: 'Card Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter card name';
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

