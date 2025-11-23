import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';
import '../models/user.dart';
import '../widgets/votenam_logo.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  List<User> users = [];
  List<User> filteredUsers = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      filteredUsers = users.where((user) {
        return user.email.toLowerCase().contains(query) ||
            user.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final loaded = await AdminApiService.getAllUsers();
      setState(() {
        users = loaded;
        filteredUsers = loaded;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Failed to load users: ${e.toString()}');
    }
  }

  Future<void> _delete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
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
        await AdminApiService.deleteUser(id);
        if (mounted) {
          _showSuccess('User deleted successfully');
          loadData();
        }
      } catch (e) {
        _showError('Failed to delete: ${e.toString()}');
      }
    }
  }

  void _showAddEditDialog({User? user}) {
    showDialog(
      context: context,
      builder: (context) => _AddEditDialog(
        user: user,
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
                            hintText: 'Search users...',
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
                        label: const Text('Add User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF41479B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredUsers.isEmpty
                      ? const Center(child: Text('No users found'))
                      : isWide
                          ? DataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Username')),
                                DataColumn(label: Text('Role')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredUsers.map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(user.id.toString())),
                                    DataCell(Text(user.email)),
                                    DataCell(Text(user.username)),
                                    DataCell(Text(user.role)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Color(0xFF41479B)),
                                            onPressed: () =>
                                                _showAddEditDialog(user: user),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => _delete(user.id!),
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
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: const Icon(Icons.person),
                                    title: Text(user.username),
                                    subtitle: Text(user.email),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () =>
                                              _showAddEditDialog(user: user),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _delete(user.id!),
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
  final User? user;
  final VoidCallback onSaved;

  const _AddEditDialog({
    required this.user,
    required this.onSaved,
  });

  @override
  State<_AddEditDialog> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<_AddEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _emailController.text = widget.user!.email;
      _usernameController.text = widget.user!.username;
      _passwordController.text = widget.user!.password;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = User(
        id: widget.user?.id,
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'ADMIN',
      );

      if (widget.user == null) {
        await AdminApiService.createUser(user);
      } else {
        await AdminApiService.updateUser(widget.user!.id!, user);
      }

      if (mounted) {
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user == null
                ? 'User created successfully'
                : 'User updated successfully'),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.user == null ? 'Add User' : 'Edit User',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: widget.user == null ? 'Password' : 'Password (leave empty to keep current)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (widget.user == null && (value == null || value.isEmpty)) {
                      return 'Please enter password';
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
      ),
    );
  }
}

