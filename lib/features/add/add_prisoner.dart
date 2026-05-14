import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:autoswift/core/components/pro_app_bar.dart';

class AddPrisoner extends StatefulWidget {
  const AddPrisoner({super.key});

  @override
  State<AddPrisoner> createState() => _AddPrisonerState();
}

class _AddPrisonerState extends State<AddPrisoner> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController crimeController = TextEditingController();

  DateTime? entryDate;
  DateTime? exitDate;

  bool loading = false;

  File? _image;
  final ImagePicker _picker = ImagePicker();
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  Future<void> addPrisoner() async {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        crimeController.text.isEmpty ||
        entryDate == null ||
        exitDate == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      String? imagePath = _image?.path;

      await FirebaseFirestore.instance.collection("prisoners").add({
        "name": nameController.text.trim(),
        "age": ageController.text.trim(),
        "crime": crimeController.text.trim(),
        "entryDate": entryDate!.toIso8601String(),
        "exitDate": exitDate!.toIso8601String(),
        "image": imagePath,
        "createdAt": Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prisoner added successfully")),
      );
      nameController.clear();
      ageController.clear();
      crimeController.clear();
      setState(() {
        entryDate = null;
        exitDate = null;
        _image = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }
  Future<void> pickEntryDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        entryDate = picked;
      });
    }
  }
  Future<void> pickExitDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        exitDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProAppBar(
        title: "Add Prisoner",
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _image != null
                  ? Image.file(_image!, height: 150)
                  : const Text("No image selected"),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: pickImage,
                child: const Text("Choose Image"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
              ),
              TextField(
                controller: crimeController,
                decoration: const InputDecoration(labelText: "Crime"),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entryDate == null
                        ? "Entry Date not selected"
                        : "Entry: ${entryDate!.day}/${entryDate!.month}/${entryDate!.year}",
                  ),
                  ElevatedButton(
                    onPressed: pickEntryDate,
                    child: const Text("Select Entry"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exitDate == null
                        ? "Exit Date not selected"
                        : "Exit: ${exitDate!.day}/${exitDate!.month}/${exitDate!.year}",
                  ),
                  ElevatedButton(
                    onPressed: pickExitDate,
                    child: const Text("Select Exit"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await addPrisoner();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Add Prisoner",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}