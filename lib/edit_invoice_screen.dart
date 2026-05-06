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
  // Palet Warna Konsisten dengan Dashboard
  static const Color kPrimary = Color(0xFF11213D);
  static const Color kAccent = Color(0xFFF9C895);
  static const Color kBackground = Color(0xFFF8F9FB);

  // Mock Data (Nanti bisa dihubungkan ke API)
  final String phone = "0812-3456-7890";
  final String address = "Jl. Ahmad Yani No. 123, Sidoarjo, Jawa Timur";
  final String orderDate = "20 April 2026";
  final String paymentMethod = "Transfer Bank (Midtrans)";
  final String notes = "Packing kayu, pastikan segel utuh.";

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
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: kPrimary)),
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
          .showSnackBar(SnackBar(content: Text("Gagal Mencetak: $e")));
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(
          "Review & Print",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: kPrimary, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: kPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  _buildHeaderStatus(),
                  _buildCustomerSection(),
                  _buildItemSection(),
                  _buildNotesSection(),
                ],
              ),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildHeaderStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: const NetworkImage(
              'https://www.transparenttextures.com/patterns/carbon-fibre.png'),
          opacity: 0.1,
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("INVOICE NUMBER",
              style: GoogleFonts.poppins(
                  color: kAccent.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 5),
          Text(widget.orderId,
              style: GoogleFonts.exo2(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.event_note_rounded,
                  color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text(orderDate,
                  style:
                      GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_rounded,
                  color: kPrimary, size: 20),
              const SizedBox(width: 10),
              Text("TUJUAN PENGIRIMAN",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: kPrimary)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(height: 1),
          ),
          _infoLine(Icons.person, "Nama Penerima", widget.clientName),
          _infoLine(Icons.phone, "Kontak", phone),
          _infoLine(Icons.map, "Alamat", address),
          _infoLine(Icons.payments, "Metode", paymentMethod),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Text("RINCIAN PESANAN",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text("${item['qty']}x",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, color: kPrimary))),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['product'],
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(formatIDR(item['price']),
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(formatIDR(item['price'] * item['qty']),
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: kPrimary)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFFB8860B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Catatan: \"$notes\"",
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.brown),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 35),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Pembayaran",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
              Text(formatIDR(grandTotal),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: kPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _handleFinalize,
              icon: const Icon(Icons.print_rounded, color: kPrimary),
              label: Text("CETAK SEKARANG",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                      fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
