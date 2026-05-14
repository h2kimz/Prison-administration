import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:autoswift/features/auth/auth_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E3C72),
                  Color(0xFF2A5298),
                ],
              ),
            ),

            accountName: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text("Loading...");
                }
                final data =
                snapshot.data!.data() as Map<String, dynamic>;
                return Text(data["name"] ?? "No Name");
              },
            ),
            accountEmail: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text("Loading...");
                }
                final data =
                snapshot.data!.data() as Map<String, dynamic>;
                return Text(data["email"] ?? "No Email");
              },
            ),

            currentAccountPicture: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const CircleAvatar(
                    child: Icon(Icons.person),
                  );
                }

                final data =
                snapshot.data!.data() as Map<String, dynamic>;

                final path = data["photoPath"];

                if (path == null || path == "") {
                  return const CircleAvatar(
                    child: Icon(Icons.person),
                  );
                }

                return CircleAvatar(
                  backgroundImage: FileImage(File(path)),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profile"),
            onTap: () {
              _showEditProfile(context);
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("conferm"),
                    content: const Text("do you want to leave realy؟"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const AuthPage()),
                                (route) => false,
                          );
                        },
                        child: const Text(
                          "logout",
                          style: TextStyle(color: Colors.red),
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
  void _showEditProfile(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      builder: (_) {
        final nameController = TextEditingController();
        final emailController =
        TextEditingController(text: user?.email ?? "");
        final phoneController = TextEditingController();
        File? imageFile;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: imageFile != null
                            ? FileImage(imageFile!)
                            : null,
                        child: imageFile == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      TextButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            setState(() {
                              imageFile = File(picked.path);
                            });
                          }
                        },
                        child: const Text("Change Photo"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameController,
                        decoration:
                        const InputDecoration(labelText: "Name"),
                      ),
                      TextField(
                        controller: emailController,
                        decoration:
                        const InputDecoration(labelText: "Email"),
                      ),
                      TextField(
                        controller: phoneController,
                        decoration:
                        const InputDecoration(labelText: "Phone"),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              child: const Text("Save"),
                              onPressed: () async {
                                try {
                                  final uid = user?.uid;
                                  if (uid == null) return;
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(uid)
                                      .set({
                                    "name": nameController.text.trim(),
                                    "email": emailController.text.trim(),
                                    "phone": phoneController.text.trim(),
                                    "photoPath": imageFile?.path ?? "",
                                  }, SetOptions(merge: true));
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                      Text("Done ✅"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text("error: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}