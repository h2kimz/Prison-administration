import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autoswift/core/components/pro_app_bar.dart';

class VisitsPage extends StatefulWidget {
  const VisitsPage({super.key});

  @override
  State<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  String searchText = "";

  List<QueryDocumentSnapshot> prisoners = [];
  String? selectedPrisonerId;
  String? selectedPrisonerName;

  final TextEditingController visitorName = TextEditingController();
  final TextEditingController relation = TextEditingController();
  final TextEditingController phone = TextEditingController();

  DateTime? selectedDate;
  @override
  void initState() {
    super.initState();
    loadPrisoners();
  }

  void loadPrisoners() async {
    final snapshot =
    await FirebaseFirestore.instance.collection("prisoners").get();
    setState(() {
      prisoners = snapshot.docs;
    });
  }
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      DateTime date = DateTime.parse(dateStr);
      return "${date.year}/${date.month}/${date.day}";
    } catch (e) {
      return dateStr;
    }
  }

  void showAddVisitDialog() {
    String visitorId =
    DateTime.now().millisecondsSinceEpoch.toString();
    visitorName.clear();
    relation.clear();
    phone.clear();
    selectedPrisonerId = null;
    selectedPrisonerName = null;
    selectedDate = null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Add Visit"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: visitorName,
                    decoration: const InputDecoration(
                      labelText: "Visitor Name",
                    ),
                  ),
                  TextField(
                    controller: relation,
                    decoration: const InputDecoration(
                      labelText: "Relation",
                    ),
                  ),
                  TextField(
                    controller: phone,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedPrisonerId,
                    decoration: const InputDecoration(
                      labelText: "Select Prisoner",
                    ),
                    items: prisoners.map((doc) {
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(doc["name"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedPrisonerId = value;
                        selectedPrisonerName = prisoners
                            .firstWhere((p) => p.id == value)["name"];
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setStateDialog(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        selectedDate == null
                            ? "Select Visit Date"
                            : "${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}",
                      ),
                    ),
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
                  FirebaseFirestore.instance.collection("visits").add({
                    "visitorId": visitorId,
                    "visitorName": visitorName.text,
                    "relation": relation.text,
                    "phone": phone.text,
                    "prisonerId": selectedPrisonerId,
                    "prisonerName": selectedPrisonerName,

                    // 🔥 USER SELECTED DATE
                    "date": selectedDate != null
                        ? selectedDate!.toIso8601String()
                        : DateTime.now().toIso8601String(),
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

  void showEditVisitDialog(DocumentSnapshot doc) {
    final visitorNameEdit =
    TextEditingController(text: doc["visitorName"]);
    final relationEdit =
    TextEditingController(text: doc["relation"]);
    final phoneEdit =
    TextEditingController(text: doc["phone"]);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Visit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: visitorNameEdit),
            TextField(controller: relationEdit),
            TextField(controller: phoneEdit),
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
                  .collection("visits")
                  .doc(doc.id)
                  .update({
                "visitorName": visitorNameEdit.text,
                "relation": relationEdit.text,
                "phone": phoneEdit.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void deleteVisit(String id) {
    FirebaseFirestore.instance
        .collection("visits")
        .doc(id)
        .delete();
  }

  void showVisitDetails(DocumentSnapshot doc) {
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
              Text(
                doc["visitorName"],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              infoRow("Visitor ID", doc["visitorId"]),
              infoRow("Prisoner", doc["prisonerName"]),
              infoRow("Relation", doc["relation"]),
              infoRow("Phone", doc["phone"]),
              infoRow("Visit Date", formatDate(doc["date"])),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showEditVisitDialog(doc);
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
                        deleteVisit(doc.id);
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

  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 120,
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
        title: "Visits",
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddVisitDialog,
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
                hintText: "Search visits...",
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
                  .collection("visits")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs =
                snapshot.data!.docs.where((doc) {
                  final visitor =
                  doc["visitorName"].toString().toLowerCase();
                  final prisoner =
                  doc["prisonerName"].toString().toLowerCase();

                  return visitor.contains(searchText) ||
                      prisoner.contains(searchText);
                }).toList();
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(doc["visitorName"]),
                        subtitle: Text(
                          "Prisoner: ${doc["prisonerName"]}",
                        ),
                        onTap: () => showVisitDetails(doc),
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