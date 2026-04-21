import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfInvoiceService {
  // Menggunakan warna Navy Blue & Gold agar serasi dengan Dashboard
  static final PdfColor kPrimaryColor = PdfColor.fromHex('#11213D');
  static final PdfColor kAccentColor = PdfColor.fromHex('#F9C895');
  static final PdfColor kGreyColor = PdfColor.fromHex('#757575');
  static final PdfColor kLightGrey = PdfColor.fromHex('#F8F9FB');

  static Future<void> generateInvoice({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40), // Margin profesional standar A4
        build: (pw.Context context) {
          return [
            _buildHeader(orderData),
            pw.SizedBox(height: 30),
            _buildCustomerInfo(orderData),
            pw.SizedBox(height: 30),
            _buildTable(items, formatter),
            pw.SizedBox(height: 20),
            _buildTotal(orderData, formatter),
            pw.SizedBox(height: 50),
            _buildSignature(),
          ];
        },
        footer: (pw.Context context) => _buildFooter(),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${orderData['invoice_number']}',
    );
  }

  // --- KOMPONEN HEADER (IDENTITAS PERUSAHAAN) ---
  static pw.Widget _buildHeader(Map<String, dynamic> orderData) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Kiri: Info Perusahaan
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "PT. MAMED INDONESIA GROUP",
                style: pw.TextStyle(
                  color: kPrimaryColor,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "Perdagangan & Distribusi Alat Medis",
                style: pw.TextStyle(
                  color: kAccentColor,
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text("Jl. Muwuh, Sumberagung, Plaosan, Magetan",
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text("Telp: 082332116115 / 085784899882",
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text("Email: medicalmagetan@gmail.com",
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ),
        // Kanan: Tulisan INVOICE besar
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "INVOICE",
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: kPrimaryColor,
                letterSpacing: 2,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: kLightGrey,
                borderRadius: pw.BorderRadius.circular(5),
                border: pw.Border.all(color: kPrimaryColor, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("No. Faktur: ${orderData['invoice_number']}",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                      "Tanggal: ${DateFormat('dd MMMM yyyy', 'id').format(DateTime.now())}",
                      style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- KOMPONEN INFO PELANGGAN ---
  static pw.Widget _buildCustomerInfo(Map<String, dynamic> orderData) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                  left: pw.BorderSide(color: kPrimaryColor, width: 3)),
              color: kLightGrey,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("TAGIHAN KEPADA:",
                    style: pw.TextStyle(
                        fontSize: 9,
                        color: kGreyColor,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(
                  orderData['recipient_name'] ?? "Nama Pelanggan / Instansi",
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: kPrimaryColor),
                ),
                pw.SizedBox(height: 4),
                pw.Text("No. Telp : ${orderData['phone'] ?? '-'}",
                    style: const pw.TextStyle(fontSize: 10)),
                pw.Text("Alamat   : ${orderData['address'] ?? '-'}",
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 80), // Spacer agar tidak terlalu penuh
      ],
    );
  }

  // --- KOMPONEN TABEL BARANG ---
  static pw.Widget _buildTable(
      List<Map<String, dynamic>> items, NumberFormat formatter) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(
          color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: pw.BoxDecoration(color: kPrimaryColor),
      cellHeight: 30,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      cellStyle: const pw.TextStyle(fontSize: 10),
      columnWidths: {
        0: const pw.FixedColumnWidth(30), // No
        1: const pw.FlexColumnWidth(3), // Deskripsi Barang
        2: const pw.FixedColumnWidth(40), // Qty
        3: const pw.FixedColumnWidth(80), // Harga Satuan
        4: const pw.FixedColumnWidth(90), // Total
      },
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      headers: ['NO', 'DESKRIPSI BARANG', 'QTY', 'HARGA SATUAN', 'TOTAL HARGA'],
      data: List<List<String>>.generate(items.length, (index) {
        final item = items[index];
        final int price = (item['price'] as num).toInt();
        final int qty = (item['qty'] as num).toInt();
        return [
          (index + 1).toString(),
          item['product'].toString(),
          qty.toString(),
          formatter.format(price),
          formatter.format(price * qty),
        ];
      }),
    );
  }

  // --- KOMPONEN TOTAL HARGA ---
  static pw.Widget _buildTotal(
      Map<String, dynamic> orderData, NumberFormat formatter) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        child: pw.Column(
          children: [
            pw.Divider(color: kPrimaryColor, thickness: 1.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("TOTAL TAGIHAN",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        color: kPrimaryColor)),
                pw.Text(
                  formatter.format(orderData['grand_total'] ?? 0),
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: kPrimaryColor),
                ),
              ],
            ),
            pw.Divider(color: kPrimaryColor, thickness: 1.5),
          ],
        ),
      ),
    );
  }

  // --- KOMPONEN TANDA TANGAN ---
  static pw.Widget _buildSignature() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text("Hormat Kami,", style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 60), // Space untuk cap/tanda tangan asli
            pw.Text(
              "Danar Setiawan",
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                  decoration: pw.TextDecoration.underline),
            ),
            pw.Text("Direktur",
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
      ],
    );
  }

  // --- KOMPONEN FOOTER BAWAH ---
  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 5),
        pw.Text(
          "Terima kasih atas kepercayaan Anda bermitra dengan PT. Mamed Indonesia Group.",
          style: pw.TextStyle(
              fontSize: 9, color: kGreyColor, fontStyle: pw.FontStyle.italic),
        ),
      ],
    );
  }
}
