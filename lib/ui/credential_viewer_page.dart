import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../database/db_helper.dart';
import '../../database/user_model.dart';
import '../../utils/constants.dart';

class CredentialViewerPage extends StatefulWidget {
  const CredentialViewerPage({super.key});

  @override
  State<CredentialViewerPage> createState() => _CredentialViewerPageState();
}

class _CredentialViewerPageState extends State<CredentialViewerPage> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('users');
    setState(() {
      _users = result.map((json) => User.fromMap(json)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credential Viewer (Debug)"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.role == 'guru' ? AppColors.accent : AppColors.secondary,
                      child: Icon(
                        user.role == 'guru' ? Icons.school : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText("NIPD: ${user.nipd}"),
                        SelectableText("Pass: ${user.password}"),
                      ],
                    ),
                    trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                             Clipboard.setData(ClipboardData(text: "${user.nipd}\n${user.password}"));
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!")));
                        },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
