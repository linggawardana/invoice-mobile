import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'pdf_service.dart';

class EditInvoiceScreen extends StatefulWidget {
  final String orderId;
  final String clientName;

  const EditInvoiceScreen({
    super.key,
    required this.orderId,
    required this.clientName,
  });

  @override
  State<EditInvoiceScreen> createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  final Color kPrimary = const Color(0xFF11213D);
  final Color kAccent = const Color(0xFFF9C895);

  // ===========================================================================
  // DATA SUMBER DARI DATABASE (Ambil dari tabel orders & order_shippings)
  // ===========================================================================
  final String phone = "0812-3456-7890"; // order_shippings -> phone
  final String address =
      "Jl. Ahmad Yani No. 123, Sidoarjo"; // order_shippings -> full_address
  final String orderDate = "20 April 2026"; // orders -> created_at
  final String paymentMethod = "Midtrans"; // orders -> payment_method
  final String notes = "Packing aman ya"; // orders -> notes

  List<Map<String, dynamic>> items = [
    {"product": "Kursi Roda Standar", "price": 1500000, "qty": 1},
    {"product": "Tensimeter Digital", "price": 650000, "qty": 2},
    {"product": "Oksigen Portable", "price": 55000, "qty": 5},
  ];

  int shippingCost = 35000;

  int get subtotal => items.fold(
      0, (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)));
  int get grandTotal => subtotal + shippingCost;

  String formatIDR(dynamic amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(amount ?? 0);
  }

  Future<void> _handleFinalize() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF11213D))),
    );

    try {
      await PdfInvoiceService.generateInvoice(
        orderData: {
          'invoice_number': widget.orderId,
          'recipient_name': widget.clientName,
          'grand_total': grandTotal,
          'phone': phone,
          'address': address,
        },
        items: items,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Detail Invoice",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: kPrimary, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: kPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildOrderHeader(), // Menampilkan No Invoice & Tanggal
                _buildCustomerInfoCard(), // Data Lengkap Pemesan
                _buildSectionTitle("Daftar Barang"),
                ...List.generate(
                    items.length, (index) => _buildItemCard(index)),
              ],
            ),
          ),
          _buildBottomSummary(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.orderId,
            style: GoogleFonts.exo2(
                fontWeight: FontWeight.bold, fontSize: 24, color: kPrimary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                "Pesanan pada $orderDate",
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_rounded, color: kPrimary, size: 22),
              const SizedBox(width: 8),
              Text(
                "Informasi Pelanggan",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 15, color: kPrimary),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 1),
          _infoTile(Icons.person_outline, "Nama Penerima", widget.clientName),
          _infoTile(Icons.phone_android_outlined, "No. Telepon", phone),
          _infoTile(Icons.location_on_outlined, "Alamat Lengkap", address),
          _infoTile(Icons.account_balance_wallet_outlined, "Metode Pembayaran",
              paymentMethod),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                "Catatan: \"$notes\"",
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey.shade500)),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: kPrimary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = items[index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['product'],
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(formatIDR(item['price']),
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text("x${item['qty']}",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: kPrimary)),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _rowSummary("Total Barang", formatIDR(subtotal), false),
          const SizedBox(height: 8),
          _rowSummary("Biaya Kirim", formatIDR(shippingCost), false),
          const Divider(height: 24),
          _rowSummary("Grand Total", formatIDR(grandTotal), true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleFinalize,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                "CETAK INVOICE SEKARANG",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowSummary(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: isBold ? 15 : 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: isBold ? 18 : 14,
                fontWeight: FontWeight.bold,
                color: isBold ? kPrimary : Colors.black87)),
      ],
    );
  }
}
