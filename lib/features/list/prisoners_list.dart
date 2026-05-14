import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autoswift/core/components/pro_app_bar.dart';

class PrisonersList extends StatefulWidget {
  const PrisonersList({super.key});

  @override
  State<PrisonersList> createState() => _PrisonersListState();
}

class _PrisonersListState extends State<PrisonersList> {

  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController crimeController = TextEditingController();

  String searchText = "";
  DateTime? entryDate;
  DateTime? exitDate;

  void showPasswordDialog(VoidCallback onSuccess) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Password"),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "Enter your account password",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null || user.email == null) return;
              try {
                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: passController.text,
                );
                await user.reauthenticateWithCredential(cred);
                Navigator.pop(context);
                onSuccess();
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Wrong password"),
                  ),
                );
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
  Future<void> deletePrisoner(String id) async {
    await FirebaseFirestore.instance
        .collection("prisoners")
        .doc(id)
        .delete();
  }
  void showEditDialog(DocumentSnapshot doc) {
    nameController.text = doc["name"];
    ageController.text = doc["age"];
    crimeController.text = doc["crime"];
    entryDate = DateTime.tryParse(doc["entryDate"] ?? "");
    exitDate = DateTime.tryParse(doc["exitDate"] ?? "");

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Edit Prisoner"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: "Age"),
                  ),
                  TextField(
                    controller: crimeController,
                    decoration: const InputDecoration(labelText: "Crime"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("prisoners")
                      .doc(doc.id)
                      .update({
                    "name": nameController.text,
                    "age": ageController.text,
                    "crime": crimeController.text,
                  });

                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }
  void showDetailsDialog(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: doc["image"] != null && doc["image"] != ""
                    ? FileImage(File(doc["image"]))
                    : null,
                child: doc["image"] == null || doc["image"] == ""
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 15),
              Text(
                doc["name"] ?? "Unknown",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              infoRow("Age", doc["age"]),
              infoRow("Crime", doc["crime"]),
              infoRow("Entry Date", formatDate2(formatDate(doc["entryDate"]))),
              infoRow("Exit Date", formatDate2(formatDate(doc["exitDate"]))),
              const SizedBox(height: 20),

              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showEditDialog(doc);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text("Edit",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showPasswordDialog(() => deletePrisoner(doc.id));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text("Delete",
                          style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text("Close",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProAppBar(
        title: "Prisoners List",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchText = "";
                    });
                  },
                )
                    : null,

                hintText: "Search prisoner...",
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("prisoners")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs.where((doc) {
                  final name = doc["name"].toString().toLowerCase();
                  final crime = doc["crime"].toString().toLowerCase();

                  return name.contains(searchText) ||
                      crime.contains(searchText);
                }).toList();
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(doc["name"]),
                        subtitle: Text(
                          "Age: ${doc["age"]}\nCrime: ${doc["crime"]}",
                        ),
                        onTap: () => showDetailsDialog(doc),

                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$title:",
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      DateTime date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }
  String formatDate2(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";

    try {
      DateTime date = DateTime.parse(dateStr);
      return "${date.year}/${date.month}/${date.day}";
    } catch (e) {
      return dateStr;
    }
  }
}