import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'pdf_service.dart';

class ManualInvoiceScreen extends StatefulWidget {
  const ManualInvoiceScreen({super.key});

  @override
  State<ManualInvoiceScreen> createState() => _ManualInvoiceScreenState();
}

class _ManualInvoiceScreenState extends State<ManualInvoiceScreen> {
  // Palet Warna Konsisten
  static const Color kPrimary = Color(0xFF11213D);
  static const Color kAccent = Color(0xFFF9C895);
  static const Color kBackground = Color(0xFFF8F9FB);

  // Controller untuk Data Pelanggan
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _shippingController =
      TextEditingController(text: "0");

  // State untuk Daftar Barang
  List<Map<String, dynamic>> _items = [
    {
      "controller_name": TextEditingController(),
      "controller_price": TextEditingController(),
      "qty": 1
    },
  ];

  // Hitung-hitungan
  int get _subtotal {
    int total = 0;
    for (var item in _items) {
      int price = int.tryParse(item['controller_price'].text) ?? 0;
      total += price * (item['qty'] as int);
    }
    return total;
  }

  int get _shipping => int.tryParse(_shippingController.text) ?? 0;
  int get _grandTotal => _subtotal + _shipping;

  void _addNewItem() {
    setState(() {
      _items.add({
        "controller_name": TextEditingController(),
        "controller_price": TextEditingController(),
        "qty": 1,
      });
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() => _items.removeAt(index));
    }
  }

  String _formatIDR(dynamic amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  Future<void> _generatePDF() async {
    // Validasi Sederhana
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama pelanggan wajib diisi!")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: kPrimary)),
    );

    try {
      // Mapping data untuk PDF Service
      List<Map<String, dynamic>> formattedItems = _items.map((item) {
        return {
          "product": item['controller_name'].text.isEmpty
              ? "Produk Tanpa Nama"
              : item['controller_name'].text,
          "price": int.tryParse(item['controller_price'].text) ?? 0,
          "qty": item['qty'],
        };
      }).toList();

      await PdfInvoiceService.generateInvoice(
        orderData: {
          'invoice_number':
              "INV-${DateTime.now().millisecondsSinceEpoch}", // Auto generate ID
          'recipient_name': _nameController.text,
          'grand_total': _grandTotal,
          'phone': _phoneController.text,
          'address': _addressController.text,
        },
        items: formattedItems,
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
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text("Buat Invoice Manual",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 16, color: kPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kPrimary, size: 20),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("DATA PELANGGAN"),
                  _buildCustomerForm(),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader("ITEM / BARANG"),
                      TextButton.icon(
                        onPressed: _addNewItem,
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.blue, size: 18),
                        label: Text("Tambah Item",
                            style: GoogleFonts.poppins(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      )
                    ],
                  ),
                  _buildItemList(),
                  const SizedBox(height: 25),
                  _buildSectionHeader("PENGIRIMAN"),
                  _buildShippingInput(),
                ],
              ),
            ),
          ),
          _buildSummaryBar(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1)),
    );
  }

  Widget _buildCustomerForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
          ]),
      child: Column(
        children: [
          _customTextField(
              "Nama Lengkap", _nameController, Icons.person_outline),
          const SizedBox(height: 15),
          _customTextField(
              "No. WhatsApp", _phoneController, Icons.phone_android_outlined,
              isPhone: true),
          const SizedBox(height: 15),
          _customTextField(
              "Alamat Pengiriman", _addressController, Icons.map_outlined,
              maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade100)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: _customTextField("Nama Barang",
                          _items[index]['controller_name'], null)),
                  const SizedBox(width: 10),
                  IconButton(
                      onPressed: () => _removeItem(index),
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 20)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: _customTextField(
                          "Harga (Rp)", _items[index]['controller_price'], null,
                          isPhone: true)),
                  const SizedBox(width: 15),
                  Row(
                    children: [
                      _qtyBtn(Icons.remove, () {
                        if (_items[index]['qty'] > 1)
                          setState(() => _items[index]['qty']--);
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text("${_items[index]['qty']}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                      ),
                      _qtyBtn(Icons.add,
                          () => setState(() => _items[index]['qty']++)),
                    ],
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildShippingInput() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: _customTextField("Biaya Ongkir (Rp)", _shippingController,
          Icons.local_shipping_outlined,
          isPhone: true),
    );
  }

  Widget _buildSummaryBar() {
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Pembayaran",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
              Text(_formatIDR(_grandTotal),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: kPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _generatePDF,
              icon: const Icon(Icons.picture_as_pdf_rounded, color: kPrimary),
              label: Text("SIMPAN & CETAK PDF",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: kPrimary)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customTextField(
      String hint, TextEditingController ctrl, IconData? icon,
      {bool isPhone = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isPhone ? TextInputType.number : TextInputType.text,
      onChanged: (v) => setState(() {}), // Refresh hitungan total
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            icon != null ? Icon(icon, size: 18, color: Colors.grey) : null,
        filled: true,
        fillColor: kBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: kPrimary, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
