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
  static final PdfColor kWhite70 = PdfColor.fromHex('#B3FFFFFF');

  static Future<Uint8List> generateInvoiceBytes({
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
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(orderData, fontBold, fontItalic),
            pw.SizedBox(height: 12),
            _buildCustomerInfo(orderData, fontBold),
            pw.SizedBox(height: 12),
            _buildTable(items, formatter, fontBold),
            pw.SizedBox(height: 12),
            _buildTotal(orderData, items, formatter, fontBold),
            pw.SizedBox(height: 12),
            _buildTerms(orderData['notes'] ?? '', fontBold),
          ];
        },
        footer: (pw.Context context) => _buildFooter(fontItalic),
      ),
    );

    return pdf.save();
  }

  static Future<void> generateInvoice({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdfBytes = await generateInvoiceBytes(
      orderData: orderData,
      items: items,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice_${orderData['invoice_number']}',
    );
  }

  static Future<void> shareInvoice({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdfBytes = await generateInvoiceBytes(
      orderData: orderData,
      items: items,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Invoice_${orderData['invoice_number'] ?? 'invoice'}.pdf',
    );
  }

  // --- HEADER: Identitas PT & Judul Invoice ---
  static pw.Widget _buildHeader(
      Map<String, dynamic> orderData, pw.Font fontBold, pw.Font fontItalic) {
    final invoiceNumber = orderData['invoice_number'] ?? '-';
    final invoiceDate = orderData['invoice_date'] ??
        DateFormat('dd MMM yyyy', 'id').format(DateTime.now());
    final dueDate = orderData['due_date'] ?? '-';
    final paymentMethod = orderData['payment_method'] ?? '-';
    final paymentStatus = orderData['payment_status'] ?? '-';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "PT. MAMED INDONESIA GROUP",
                    style: pw.TextStyle(
                        font: fontBold, fontSize: 16, color: kPrimaryColor),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text("Perdagangan & Distribusi Alat Medis",
                      style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 8,
                          color: kGreyColor,
                          fontStyle: pw.FontStyle.italic)),
                  pw.SizedBox(height: 8),
                  pw.Text("Jl. Muwuh, Sumberagung, Plaosan, Magetan",
                      style: const pw.TextStyle(fontSize: 8, height: 1.4)),
                  pw.Text("WhatsApp: 0823-3211-6115",
                      style: const pw.TextStyle(fontSize: 8, height: 1.4)),
                ],
              ),
            ),
            pw.SizedBox(width: 18),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text("INVOICE",
                    style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 15,
                        color: kPrimaryColor,
                        letterSpacing: 0.8)),
                pw.SizedBox(height: 4),
                pw.Text("No. Faktur: $invoiceNumber",
                    style: const pw.TextStyle(fontSize: 9)),
                pw.SizedBox(height: 2),
                pw.Text("Tanggal: $invoiceDate",
                    style: const pw.TextStyle(fontSize: 9)),
                pw.SizedBox(height: 2),
                pw.Text("Jatuh Tempo: $dueDate",
                    style: const pw.TextStyle(fontSize: 9)),
                pw.SizedBox(height: 8),
                pw.Text("Metode: $paymentMethod",
                    style: pw.TextStyle(fontSize: 8, color: kGreyColor)),
                pw.SizedBox(height: 2),
                pw.Text("Status: $paymentStatus",
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: paymentStatus == 'DP'
                          ? PdfColors.orange700
                          : PdfColors.green800,
                    )),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: kGreyColor, thickness: 0.5),
      ],
    );
  }

  // --- INFO PELANGGAN: Kartu Nama Penerima ---
  static pw.Widget _buildCustomerInfo(
      Map<String, dynamic> orderData, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("INFORMASI PENAGIHAN:",
            style:
                pw.TextStyle(fontSize: 8, color: kGreyColor, font: fontBold)),
        pw.SizedBox(height: 4),
        pw.Text(orderData['recipient_name'] ?? "Pelanggan Umum",
            style: pw.TextStyle(
                fontSize: 13, font: fontBold, color: kPrimaryColor)),
        pw.SizedBox(height: 2),
        pw.Text("Telp: ${orderData['phone'] ?? '-'}",
            style: const pw.TextStyle(fontSize: 9, height: 1.4)),
        pw.Text("Alamat: ${orderData['address'] ?? '-'}",
            style: const pw.TextStyle(fontSize: 9, height: 1.4)),
      ],
    );
  }

  // --- TABEL: Daftar Produk ---
  static pw.Widget _buildTable(List<Map<String, dynamic>> items,
      NumberFormat formatter, pw.Font fontBold) {
    return pw.TableHelper.fromTextArray(
      tableWidth: pw.TableWidth.max,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      headerStyle:
          pw.TextStyle(color: PdfColors.white, font: fontBold, fontSize: 9),
      headerDecoration: pw.BoxDecoration(color: kPrimaryColor),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
        num price = _toNum(item['price']);
        num qty = _toNum(item['qty']);
        if (qty == 0) qty = 1;
        if (price == 0) {
          final num totalField = _toNum(item['total'] ?? item['amount'] ?? item['subtotal']);
          if (totalField > 0 && qty > 0) {
            price = totalField / qty;
          }
        }
        final lineTotal = price * qty;
        return [
          (index + 1).toString(),
          item['product'].toString(),
          qty.toString(),
          formatter.format(price),
          formatter.format(lineTotal),
        ];
      }),
    );
  }

  static num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    var s = v.toString().trim();
    if (s.isEmpty) return 0;
    // Remove currency symbols and spaces
    s = s.replaceAll(RegExp(r"[^0-9,\.-]"), '');
    if (s.contains(',') && !s.contains('.')) {
      s = s.replaceAll(',', '');
    } else if (s.contains('.') && !s.contains(',')) {
      // if multiple dots, likely thousand separators
      if (s.split('.').length > 2) {
        s = s.replaceAll('.', '');
      }
    } else if (s.contains('.') && s.contains(',')) {
      // assume format like 1.234.567,89 -> remove dots, convert comma to dot
      s = s.replaceAll('.', '');
      s = s.replaceAll(',', '.');
    }
    try {
      return double.parse(s);
    } catch (e) {
      return 0;
    }
  }

  // --- TOTAL: Perhitungan Akhir ---
  static pw.Widget _buildTotal(Map<String, dynamic> orderData,
      List<Map<String, dynamic>> items, NumberFormat formatter, pw.Font fontBold) {
    // Compute total from items to ensure correctness when some prices are missing
    num computedTotal = 0;
    for (final item in items) {
      final num price = _toNum(item['price']);
      num qty = _toNum(item['qty']);
      if (qty == 0) qty = 1;
      num lineTotal = price * qty;
      if (lineTotal == 0) {
        final num totalField = _toNum(item['total'] ?? item['amount'] ?? item['subtotal']);
        if (totalField > 0) {
          lineTotal = totalField;
        }
      }
      computedTotal += lineTotal;
    }

    final total = (orderData['grand_total'] ?? computedTotal) as num;
    final paid = (orderData['paid_amount'] ?? 0) as num;
    final balance = total - paid;

    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: kLightGrey,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildAmountLine("Subtotal", formatter.format(total), fontBold),
          pw.SizedBox(height: 6),
          _buildAmountLine("Jumlah Dibayar", formatter.format(paid), fontBold),
          if (balance > 0) ...[
            pw.SizedBox(height: 6),
            _buildAmountLine("Sisa Tagihan", formatter.format(balance),
                fontBold,
                isHighlight: true),
          ],
          pw.Divider(color: kAccentColor, thickness: 1.5),
          pw.SizedBox(height: 6),
          _buildAmountLine("GRAND TOTAL", formatter.format(total), fontBold,
              isGrandTotal: true),
        ],
      ),
    );
  }

  static pw.Widget _buildAmountLine(String title, String value, pw.Font font,
      {bool isHighlight = false, bool isGrandTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                font: font,
                fontSize: isGrandTotal ? 13 : 11,
                color: isHighlight ? PdfColors.red900 : kPrimaryColor,
                fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value,
            style: pw.TextStyle(
                font: font,
                fontSize: isGrandTotal ? 15 : 11,
                color: isHighlight ? PdfColors.red900 : kPrimaryColor,
                fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }

  static pw.Widget _buildTerms(String notes, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: kLightGrey,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (notes.isNotEmpty) ...[
            pw.Text("Catatan:",
                style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    color: kPrimaryColor,
                    letterSpacing: 0.2)),
            pw.SizedBox(height: 6),
            pw.Text(notes,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.black)),
            pw.SizedBox(height: 12),
          ],
          pw.Text("DETAIL BANK",
              style: pw.TextStyle(
                  font: fontBold, fontSize: 10, color: kPrimaryColor)),
          pw.SizedBox(height: 6),
          pw.Text(
              "BCA Cab. Surabaya - CV. KIAN RAYA CEMERLANG - Rek. 258-285-8001",
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.black)),
          pw.SizedBox(height: 6),
          pw.Text("Harga sudah termasuk ongkir.",
              style: pw.TextStyle(fontSize: 8, color: kGreyColor)),
        ],
      ),
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
