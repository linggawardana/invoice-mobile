import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfInvoiceService {
  // Palet Warna Brand
  static final PdfColor kPrimaryColor = PdfColor.fromHex('#11213D');
  static final PdfColor kAccentColor = PdfColor.fromHex('#F9C895');
  static final PdfColor kGreyColor = PdfColor.fromHex('#757575');
  static final PdfColor kLightGrey = PdfColor.fromHex('#F8F9FB');

  static Future<void> generateInvoice({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();

    // Memuat Font agar identik dengan UI Aplikasi
    final fontRegular = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();
    final fontItalic = await PdfGoogleFonts.poppinsItalic();

    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(orderData, fontBold, fontItalic),
            pw.SizedBox(height: 25),
            _buildCustomerInfo(orderData, fontBold),
            pw.SizedBox(height: 25),
            _buildTable(items, formatter, fontBold),
            pw.SizedBox(height: 20),
            _buildTotal(orderData, formatter, fontBold),
            pw.SizedBox(height: 40),
            _buildSignature(fontBold),
          ];
        },
        footer: (pw.Context context) => _buildFooter(fontItalic),
      ),
    );

    // Langsung buka preview cetak
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${orderData['invoice_number']}',
    );
  }

  // --- HEADER: Identitas PT & Judul Invoice ---
  static pw.Widget _buildHeader(
      Map<String, dynamic> orderData, pw.Font fontBold, pw.Font fontItalic) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "PT. MAMED INDONESIA GROUP",
              style: pw.TextStyle(
                  color: kPrimaryColor, fontSize: 18, font: fontBold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              "Perdagangan & Distribusi Alat Medis",
              style: pw.TextStyle(
                  color: kAccentColor,
                  fontSize: 10,
                  font: fontBold,
                  fontStyle: pw.FontStyle.italic),
            ),
            pw.SizedBox(height: 8),
            pw.Text("Jl. Muwuh, Sumberagung, Plaosan, Magetan",
                style: const pw.TextStyle(fontSize: 9)),
            pw.Text("WhatsApp: 0823-3211-6115",
                style: const pw.TextStyle(fontSize: 9)),
            pw.Text("Email: medicalmagetan@gmail.com",
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "INVOICE",
              style: pw.TextStyle(
                  fontSize: 32,
                  font: fontBold,
                  color: kPrimaryColor,
                  letterSpacing: 2),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: kLightGrey,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: kPrimaryColor, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("No. Faktur: ${orderData['invoice_number']}",
                      style: pw.TextStyle(font: fontBold, fontSize: 9)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                      "Tanggal: ${DateFormat('dd MMM yyyy', 'id').format(DateTime.now())}",
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- INFO PELANGGAN: Kartu Nama Penerima ---
  static pw.Widget _buildCustomerInfo(
      Map<String, dynamic> orderData, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: kLightGrey,
        border: pw.Border(left: pw.BorderSide(color: kAccentColor, width: 4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("INFORMASI PENAGIHAN:",
              style:
                  pw.TextStyle(fontSize: 8, color: kGreyColor, font: fontBold)),
          pw.SizedBox(height: 5),
          pw.Text(orderData['recipient_name'] ?? "Pelanggan Umum",
              style: pw.TextStyle(
                  fontSize: 13, font: fontBold, color: kPrimaryColor)),
          pw.SizedBox(height: 2),
          pw.Text("Telp: ${orderData['phone'] ?? '-'}",
              style: const pw.TextStyle(fontSize: 10)),
          pw.Text("Alamat: ${orderData['address'] ?? '-'}",
              style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  // --- TABEL: Daftar Produk ---
  static pw.Widget _buildTable(List<Map<String, dynamic>> items,
      NumberFormat formatter, pw.Font fontBold) {
    return pw.TableHelper.fromTextArray(
      // INI PERBAIKANNYA: Langsung panggil .all atau buat custom border
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),

      headerStyle:
          pw.TextStyle(color: PdfColors.white, font: fontBold, fontSize: 10),
      headerDecoration: pw.BoxDecoration(color: kPrimaryColor),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
        ),
      ),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      headers: ['NO', 'DESKRIPSI BARANG', 'QTY', 'HARGA', 'TOTAL'],
      data: List<List<String>>.generate(items.length, (index) {
        final item = items[index];
        final price = item['price'] ?? 0;
        final qty = item['qty'] ?? 0;
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

  // --- TOTAL: Perhitungan Akhir ---
  static pw.Widget _buildTotal(Map<String, dynamic> orderData,
      NumberFormat formatter, pw.Font fontBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 210,
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("GRAND TOTAL",
                      style: pw.TextStyle(
                          font: fontBold, fontSize: 12, color: kPrimaryColor)),
                  pw.Text(formatter.format(orderData['grand_total'] ?? 0),
                      style: pw.TextStyle(
                          font: fontBold, fontSize: 14, color: kPrimaryColor)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Divider(color: kAccentColor, thickness: 2),
            ],
          ),
        ),
      ],
    );
  }

  // --- SIGNATURE: Tanda Tangan Direktur ---
  static pw.Widget _buildSignature(pw.Font fontBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          children: [
            pw.Text("Hormat Kami,", style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 50),
            pw.Text("DANAR SETIAWAN",
                style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 11,
                    decoration: pw.TextDecoration.underline)),
            pw.Text("Direktur Utama",
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
      ],
    );
  }

  // --- FOOTER: Terima Kasih ---
  static pw.Widget _buildFooter(pw.Font fontItalic) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 5),
        pw.Text(
          "Dokumen ini diterbitkan secara resmi oleh sistem PT. Mamed Indonesia Group",
          style: pw.TextStyle(fontSize: 7, color: kGreyColor, font: fontItalic),
        ),
      ],
    );
  }
}
