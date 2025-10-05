import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_screen.dart';
import '../CustomerDashbord/global_user.dart';
import 'global_businessInfo.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  Map<String, String> get currentUser {
    return users.firstWhere(
          (user) => user['email'] == loggedInEmail,
      orElse: () => {'name': 'Unknown', 'email': 'unknown@example.com'},
    );
  }

  void _editProfile() {
    final nameController = TextEditingController(text: currentUser['name']);
    final emailController = TextEditingController(text: currentUser['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final index = users.indexWhere((user) => user['email'] == loggedInEmail);
              if (index != -1) {
                setState(() {
                  users[index]['name'] = nameController.text.trim();
                  users[index]['email'] = emailController.text.trim();
                  loggedInEmail = users[index]['email'];
                });

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('email', loggedInEmail!);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile updated")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current Password"),
            ),
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              // You can validate old password here if needed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password updated")),
              );
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('email');
      loggedInEmail = null;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue[900];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blue,
              child: Icon(Icons.store, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text("${businessInfo['shopName']}",style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),

            Text(currentUser['name'] ?? "", style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(currentUser['email'] ?? "", style: const TextStyle(fontSize: 16, color: Colors.grey)),
            Text("Owner: ${businessInfo['ownerName']}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const Divider(height: 40),


            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Profile"),
              onTap: _editProfile,
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              onTap: _changePassword,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
