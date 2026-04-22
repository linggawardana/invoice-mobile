import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'edit_invoice_screen.dart';
import 'login_screen.dart'; // <--- PASTIKAN FILE INI ADA

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
        final query = _searchQuery.toLowerCase();
        return invNumber.contains(query) || clientName.contains(query);
      }).toList();
    }

    if (_selectedDate == null) return list;
    return list.where((order) {
      DateTime orderDate = DateTime.parse(order['created_at']);
      return orderDate.year == _selectedDate!.year &&
          orderDate.month == _selectedDate!.month &&
          orderDate.day == _selectedDate!.day;
    }).toList();
  }

  // --- DESAIN PROFIL BARU ---
  void _showProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kAccent, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: kPrimary,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Admin Alkes Mamed",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 18, color: kPrimary),
              ),
              Text(
                "admin@mamed.com",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Tutup Dialog Profil
                    _showLogoutConfirmation(context); // Buka Dialog Konfirmasi
                  },
                  icon: const Icon(Icons.logout_rounded,
                      color: Colors.white, size: 20),
                  label: Text("Logout dari Akun",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- POP UP KONFIRMASI LOGOUT ---
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Konfirmasi Logout",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin keluar dari aplikasi?",
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Kembali ke halaman Login & hapus semua tumpukan halaman
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Ya, Keluar",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
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

          // TAB SWITCHER
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

          // SEARCH BAR & FILTER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Cari ID, Nama Klien...",
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.grey, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      size: 18, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = "";
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _selectedDate == null ? _pickDate : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: 50,
                      padding: EdgeInsets.symmetric(
                          horizontal: _selectedDate == null ? 0 : 12),
                      width: _selectedDate == null ? 50 : null,
                      decoration: BoxDecoration(
                        color: _selectedDate == null ? Colors.white : kPrimary,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            color: _selectedDate == null
                                ? kPrimary.withOpacity(0.6)
                                : kAccent,
                            size: 22,
                          ),
                          if (_selectedDate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd MMM').format(_selectedDate!),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() => _selectedDate = null),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

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

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _isLoading
                ? const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()))
                : _filteredOrders.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off_rounded,
                                        size: 50, color: Colors.grey.shade300),
                                    const SizedBox(height: 10),
                                    Text("Data tidak ditemukan",
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey)),
                                  ],
                                ))))
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
