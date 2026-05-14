import 'package:autoswift/core/components/custom_text.dart';
import 'package:autoswift/features/admin/admin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/components/app_drawer.dart';
import '../dashboard/dashboard_page.dart';
import '../guards/guards_page.dart';
import '../list/prisoners_list.dart';
import '../../core/components/custom_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_page.dart';
import '../add/add_prisoner.dart';
import '../visits/visits_page.dart';
import 'package:autoswift/core/components/pro_app_bar.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  String? selectedBrand;
  final List<String> brands = ['All', 'Bmw', 'Lamborghini', 'Audi' , 'Shelby' , 'Dodge' , 'Mercedes'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: const ProAppBar(
        title: "Home",
      ),
        drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _buildCard(Icons.person_add, "Add Prisoner", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPrisoner()),
              );
            }),
            _buildCard(Icons.list, "Prisoners List", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrisonersList()),
              );
            }),

            _buildCard(Icons.calendar_month, "Visits", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VisitsPage()),
              );
            }),
            _buildCard(Icons.dashboard, "Dashboard", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),

              );
            }),
            _buildCard(Icons.security, "Guards", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GuardsPage()),
              );
            }),
          ],
        ),
      ),
    );
  }
  Widget _buildCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

}
