import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             Container(
                 padding: const EdgeInsets.all(4),
                 decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     border: Border.all(color: AppColors.primary, width: 3)
                 ),
                 child: const CircleAvatar(
                     radius: 50,
                     backgroundColor: AppColors.secondary,
                     child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
                 ),
             ),
             const SizedBox(height: 24),
             Text(user.name, style: AppStyles.title.copyWith(fontSize: 24), textAlign: TextAlign.center),
             const SizedBox(height: 8),
             Container(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                 decoration: BoxDecoration(
                     color: AppColors.primary.withAlpha(20),
                     borderRadius: BorderRadius.circular(20),
                 ),
                 child: Text("NIPD: ${user.nipd}", style: AppStyles.header.copyWith(color: AppColors.primary, fontSize: 16)),
             ),
             
             const SizedBox(height: 48),
             
             Card(
                 elevation: 2,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 child: Column(
                     children: [
                         ListTile(
                             title: Text("Ganti Password", style: AppStyles.header.copyWith(fontSize: 16)),
                             leading: Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(color: Colors.orange.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                                 child: const Icon(Icons.lock_reset, color: Colors.orange),
                             ),
                             trailing: const Icon(Icons.chevron_right),
                             onTap: () => _showChangePasswordDialog(context),
                         ),
                         const Divider(height: 1),
                         ListTile(
                             title: const Text("Keluar", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                             leading: Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(color: AppColors.error.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                                 child: const Icon(Icons.logout, color: AppColors.error),
                             ),
                             onTap: () => _showLogoutDialog(context, auth),
                         ),
                     ],
                 ),
             )
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: const Text("Ganti Password"),
              content: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Password Baru"),
                  obscureText: true,
              ),
              actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                  ElevatedButton(
                      onPressed: () async {
                          if (_passwordController.text.isNotEmpty) {
                             bool success = await Provider.of<AuthProvider>(context, listen: false)
                                 .changePassword(_passwordController.text);
                             if (context.mounted) {
                                 Navigator.pop(context);
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: Text(success ? "Password berhasil diganti" : "Gagal mengganti password"))
                                 );
                                 _passwordController.clear();
                             }
                          }
                      }, 
                      child: const Text("Simpan")
                  ),
              ],
          ),
      );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error),
              const SizedBox(width: 12),
              Text('Konfirmasi Logout', style: AppStyles.header.copyWith(fontSize: 18)),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: AppStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal', style: AppStyles.body.copyWith(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                auth.logout();
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Logout', style: AppStyles.buttonText),
            ),
          ],
        );
      },
    );
  }
}
