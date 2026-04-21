import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'edit_invoice_screen.dart';

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

  // --- TAMBAHAN: State untuk navigasi Tab ---
  int _activeTab = 0; // 0 untuk Antrean, 1 untuk Riwayat

  @override
  void initState() {
    super.initState();
    _fetchOrdersFromWeb();
  }

  // Mengambil data (disesuaikan untuk mengambil semua/sesuai tab jika API mendukung)
  Future<void> _fetchOrdersFromWeb() async {
    setState(() => _isLoading = true);
    try {
      // Kamu bisa sesuaikan endpoint ini jika ada api khusus riwayat (misal /api/invoice/history)
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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: kPrimary, onSurface: kPrimary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // --- LOGIKA FILTER: Tanggal + Status (Antrean vs Riwayat) ---
  List<dynamic> get _filteredOrders {
    List<dynamic> list = _orders;

    // Filter berdasarkan Tab
    if (_activeTab == 0) {
      list = list
          .where((o) => o['status']?.toString().toLowerCase() != 'paid')
          .toList();
    } else {
      list = list
          .where((o) => o['status']?.toString().toLowerCase() == 'paid')
          .toList();
    }

    // Filter berdasarkan Tanggal
    if (_selectedDate == null) return list;
    return list.where((order) {
      DateTime orderDate = DateTime.parse(order['created_at']);
      return orderDate.year == _selectedDate!.year &&
          orderDate.month == _selectedDate!.month &&
          orderDate.day == _selectedDate!.day;
    }).toList();
  }

  void _showProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
                radius: 40,
                backgroundColor: kPrimary,
                child: Icon(Icons.person, size: 40, color: Colors.white)),
            const SizedBox(height: 15),
            Text("Admin Alkes Mamed",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const Text("admin@mamed.com", style: TextStyle(color: Colors.grey)),
            const Divider(height: 30),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Keluar Aplikasi",
                  style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Notifikasi Terbaru",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            const ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue),
                title: Text("Tagihan INV/011 telah lunas")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        child: const Icon(Icons.add, color: kAccent),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const EditInvoiceScreen(orderId: "NEW", clientName: ""))),
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
              IconButton(
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: Colors.white),
                  onPressed: () => _showNotifications(context)),
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

          // STAT SECTION
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  _buildStatCard(
                      "Antrean",
                      "${_orders.where((o) => o['status'] != 'paid').length}",
                      Icons.receipt_long_rounded,
                      Colors.blue),
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

          // --- TAMBAHAN: TAB SWITCHER (Antrean vs Riwayat) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    _buildTabItem(0, "Belum Lunas"),
                    _buildTabItem(1, "Riwayat Lunas"),
                  ],
                ),
              ),
            ),
          ),

          // FILTER TANGGAL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Icon(Icons.calendar_today,
                        size: 18, color: kPrimary.withOpacity(0.5)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          _selectedDate == null
                              ? "Semua Tanggal"
                              : DateFormat('dd MMM yyyy')
                                  .format(_selectedDate!),
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: kPrimary)),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                          icon: const Icon(Icons.close,
                              size: 16, color: Colors.red),
                          onPressed: () =>
                              setState(() => _selectedDate = null)),
                    TextButton(
                        onPressed: _pickDate, child: const Text("Pilih")),
                  ],
                ),
              ),
            ),
          ),

          // LIST HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 10),
              child: Text(_activeTab == 0 ? "Daftar Antrean" : "Riwayat Cetak",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimary)),
            ),
          ),

          // LIST DATA
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _isLoading
                ? const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()))
                : _filteredOrders.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                            child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text("Data tidak ditemukan",
                                    style: TextStyle(color: Colors.grey)))))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _buildOrderCard(_filteredOrders[index]);
                        }, childCount: _filteredOrders.length),
                      ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // --- HELPER: WIDGET UNTUK TAB ITEM ---
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
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 5)
                  ]
                : [],
          ),
          child: Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? kPrimary : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 15),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: kPrimary)),
            Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(var item) {
    String invNumber = item['invoice_number'] ?? "INV/XXX";
    String clientName = (item['shipping'] != null)
        ? item['shipping']['recipient_name']
        : "Pelanggan Baru";
    String status = item['status'] ?? "Pending";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
          ]),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: kPrimary.withOpacity(0.05),
            child: Icon(
                _activeTab == 0 ? Icons.description_outlined : Icons.check,
                color: kPrimary,
                size: 20)),
        title: Text(invNumber,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(clientName, style: const TextStyle(fontSize: 12)),
        trailing: _buildStatusBadge(status),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditInvoiceScreen(
                    orderId: invNumber, clientName: clientName))),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status.toLowerCase() == 'paid' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
