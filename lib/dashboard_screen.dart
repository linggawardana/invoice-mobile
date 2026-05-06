import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'edit_invoice_screen.dart';
import 'login_screen.dart';
import 'manual_invoice_screen.dart'; // Pastikan import ini benar

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color kPrimary = Color(0xFF11213D);
  static const Color kAccent = Color(0xFFF9C895);
  static const Color kBackground = Color(0xFFF8F9FB);

  List<dynamic> _orders = [];
  bool _isLoading = false;
  DateTime? _selectedDate;

  int _activeTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchOrdersFromWeb();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrdersFromWeb() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/invoice/pending'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _orders = data['orders'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  void _showOrderDetail(BuildContext context, dynamic item) {
    String invNumber = item['invoice_number'] ?? "INV/XXX";
    String clientName =
        (item['shipping'] != null && item['shipping']['recipient_name'] != null)
            ? item['shipping']['recipient_name']
            : "Pelanggan Baru";
    String phone = (item['shipping'] != null &&
            item['shipping']['recipient_phone'] != null)
        ? item['shipping']['recipient_phone']
        : "-";
    String address = (item['shipping'] != null &&
            item['shipping']['recipient_address'] != null)
        ? item['shipping']['recipient_address']
        : "Alamat belum tersedia";
    String status = item['status'] ?? "Pending";
    bool isPaid = status.toLowerCase() == 'paid';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              decoration: const BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Detail Pesanan",
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 12)),
                      Text(invNumber,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  _buildStatusBadge(status, large: true),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("INFORMASI PENGIRIMAN",
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                        Icons.person_pin_rounded, "Nama Penerima", clientName),
                    const Divider(height: 30),
                    _buildDetailRow(
                        Icons.phone_android_rounded, "Kontak", phone),
                    const Divider(height: 30),
                    _buildDetailRow(
                        Icons.location_on_rounded, "Alamat Lengkap", address),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Kembali",
                          style: GoogleFonts.poppins(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditInvoiceScreen(
                                    orderId: invNumber,
                                    clientName: clientName)));
                      },
                      icon: const Icon(Icons.print, color: kPrimary),
                      label: Text("PROSES INVOICE",
                          style: GoogleFonts.poppins(
                              color: kPrimary, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: kPrimary, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  List<dynamic> get _filteredOrders {
    List<dynamic> list = _orders;
    if (_activeTab == 0) {
      list = list
          .where((o) => o['status']?.toString().toLowerCase() != 'paid')
          .toList();
    } else {
      list = list
          .where((o) => o['status']?.toString().toLowerCase() == 'paid')
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((order) {
        final invNumber =
            (order['invoice_number'] ?? "").toString().toLowerCase();
        final clientName = (order['shipping'] != null &&
                order['shipping']['recipient_name'] != null)
            ? order['shipping']['recipient_name'].toString().toLowerCase()
            : "pelanggan baru";
        return invNumber.contains(_searchQuery.toLowerCase()) ||
            clientName.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        child: const Icon(Icons.add_rounded, color: kAccent, size: 30),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ManualInvoiceScreen())),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            elevation: 0,
            backgroundColor: kPrimary,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  icon: const Icon(Icons.sync, color: Colors.white),
                  onPressed: _fetchOrdersFromWeb),
              GestureDetector(
                onTap: () => _showProfile(context),
                child: const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: CircleAvatar(
                        radius: 18, child: Icon(Icons.person, size: 20))),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient:
                        LinearGradient(colors: [kPrimary, Color(0xFF1B355B)])),
                child: Padding(
                  padding: const EdgeInsets.only(left: 25, bottom: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Selamat Pagi, Admin",
                          style: GoogleFonts.poppins(
                              color: kAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text("Kelola Invoice",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildStatCard(
                      "Antrean",
                      "${_orders.where((o) => o['status'] != 'paid').length}",
                      Icons.pending_actions_rounded,
                      Colors.orange),
                  const SizedBox(width: 15),
                  _buildStatCard(
                      "Lunas",
                      "${_orders.where((o) => o['status'] == 'paid').length}",
                      Icons.check_circle_rounded,
                      Colors.green),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    _buildTabItem(0, "Belum Lunas"),
                    _buildTabItem(1, "Riwayat Lunas")
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: "Cari invoice atau nama...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _isLoading
                ? const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()))
                : _filteredOrders.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(child: Text("Tidak ada data")))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildOrderCard(_filteredOrders[index]),
                          childCount: _filteredOrders.length,
                        ),
                      ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kPrimary)),
            Text(label,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10)),
          child: Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? kPrimary : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic item) {
    String inv = item['invoice_number'] ?? "INV/XXX";
    String name = (item['shipping'] != null)
        ? item['shipping']['recipient_name']
        : "Pelanggan Baru";
    String status = item['status'] ?? "Pending";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: CircleAvatar(
            backgroundColor: kPrimary.withOpacity(0.05),
            child: Icon(Icons.receipt_long, color: kPrimary)),
        title: Text(inv,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(name, style: GoogleFonts.poppins(fontSize: 12)),
        trailing: _buildStatusBadge(status),
        onTap: () => _showOrderDetail(context, item),
      ),
    );
  }

  Widget _buildStatusBadge(String status, {bool large = false}) {
    Color color = status.toLowerCase() == 'paid' ? Colors.green : Colors.orange;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 15 : 10, vertical: large ? 8 : 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Text(status.toUpperCase(),
          style: GoogleFonts.poppins(
              color: color,
              fontSize: large ? 12 : 10,
              fontWeight: FontWeight.bold)),
    );
  }

  void _showProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                  radius: 40,
                  backgroundColor: kPrimary,
                  child: Icon(Icons.person, size: 40, color: Colors.white)),
              const SizedBox(height: 16),
              Text("Admin Alkes Mamed",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showLogoutConfirmation(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: const Text("Logout",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (r) => false),
              child: const Text("Ya")),
        ],
      ),
    );
  }
}
