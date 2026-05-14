import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:autoswift/core/components/pro_app_bar.dart';

class GuardsPage extends StatefulWidget {
  const GuardsPage({super.key});

  @override
  State<GuardsPage> createState() => _GuardsPageState();
}

class _GuardsPageState extends State<GuardsPage> {
  String searchText = "";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? imageFile;

  String? selectedShift;

  final List<String> shifts = ["Morning", "Evening", "Night"];
  Future<void> pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }
  String safeGet(DocumentSnapshot doc, String key) {
    final data = doc.data() as Map<String, dynamic>?;
    return (data != null && data[key] != null)
        ? data[key].toString()
        : "";
  }
  void showAddGuardDialog() {
    nameController.clear();
    phoneController.clear();
    imageFile = null;
    selectedShift = null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Add Guard"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                    const InputDecoration(labelText: "Name"),
                  ),

                  TextField(
                    controller: phoneController,
                    decoration:
                    const InputDecoration(labelText: "Phone"),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: imageFile != null
                          ? ClipOval(
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(Icons.camera_alt),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedShift,
                    decoration:
                    const InputDecoration(labelText: "Shift"),
                    items: shifts.map((shift) {
                      return DropdownMenuItem(
                        value: shift,
                        child: Text(shift),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedShift = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  String id =
                  DateTime.now().millisecondsSinceEpoch.toString();
                  FirebaseFirestore.instance.collection("guards").add({
                    "guardId": id,
                    "name": nameController.text,
                    "phone": phoneController.text,
                    "shift": selectedShift ?? "-",
                    "image": imageFile?.path ?? "",
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

  void showGuardDetails(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                  image: safeGet(doc, "image") != ""
                      ? DecorationImage(
                    image: FileImage(
                        File(safeGet(doc, "image"))),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: safeGet(doc, "image") == ""
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                safeGet(doc, "name"),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              infoRow("Guard ID", safeGet(doc, "guardId")),
              infoRow("Phone", safeGet(doc, "phone")),
              infoRow("Shift", safeGet(doc, "shift")),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showEditGuard(doc);
                      },
                      child: const Text("Edit"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection("guards")
                            .doc(doc.id)
                            .delete();

                        Navigator.pop(context);
                      },
                      child: const Text("Delete"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void showEditGuard(DocumentSnapshot doc) {
    nameController.text = safeGet(doc, "name");
    phoneController.text = safeGet(doc, "phone");
    selectedShift = safeGet(doc, "shift");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Guard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController),
            TextField(controller: phoneController),
            DropdownButtonFormField<String>(
              value: selectedShift,
              items: shifts.map((shift) {
                return DropdownMenuItem(
                  value: shift,
                  child: Text(shift),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedShift = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("guards")
                  .doc(doc.id)
                  .update({
                "name": nameController.text,
                "phone": phoneController.text,
                "shift": selectedShift,
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
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
            width: 100,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProAppBar(
        title: "Guardsu",
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddGuardDialog,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search guards...",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("guards")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs =
                snapshot.data!.docs.where((doc) {
                  final name =
                  safeGet(doc, "name").toLowerCase();
                  return name.contains(searchText);
                }).toList();
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: safeGet(doc, "image") != ""
                                ? DecorationImage(
                              image: FileImage(File(
                                  safeGet(doc, "image"))),
                              fit: BoxFit.cover,
                            )
                                : null,
                            color: Colors.grey[300],
                          ),
                          child: safeGet(doc, "image") == ""
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(safeGet(doc, "name")),
                        subtitle: Text(
                            "Shift: ${safeGet(doc, "shift")}"),
                        onTap: () => showGuardDetails(doc),
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
}