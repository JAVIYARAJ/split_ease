import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';

class ExpensePdfGenerator {
  static Future<String> generatePdf(ExpenseDetailEntity entity) async {
    WidgetsFlutterBinding.ensureInitialized();
    final pdf = pw.Document();

    final formatter = NumberFormat('#,##0.00', 'en_IN');
    final dateFormatter = DateFormat('MMM dd, yyyy');
    String formattedDate = "Unknown Date";
    try {
      final parsed = DateTime.parse(entity.expenseDate);
      formattedDate = dateFormatter.format(parsed);
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'SplitEase Receipt',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal),
                  ),
                  pw.Text(formattedDate, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 20),

              // Expense Title and Total
              pw.Text('Expense Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(entity.description, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 8),
                          if (entity.notes != null && entity.notes!.isNotEmpty)
                            pw.Text('Notes: ${entity.notes}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                    pw.Text(
                      'Rs. ${formatter.format(entity.totalAmount)}',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Detailed Info Grid
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('General Info', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text('Date: $formattedDate', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('Added By: ${entity.createdBy.fullName}', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('Scope: ${entity.splits.isEmpty ? 'Personal Expense' : 'Group - ${entity.group?.name ?? "N/A"}'}', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Classification', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text('Category: ${entity.category?.name ?? "N/A"}', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('Payment Method: ${entity.paymentMethod?.name ?? "N/A"}', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Paid By
              pw.Text('Payment Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('${entity.paidBy.fullName} paid Rs. ${formatter.format(entity.totalAmount)}', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),

              if (entity.splits.isNotEmpty) ...[
                // Splits Title
                pw.Text('Split Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),

                // Splits Table
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
                  cellHeight: 30,
                  cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight},
                  headers: ['Name', 'Role', 'Amount (Rs.)'],
                  data: entity.splits.map((split) {
                    final amountText = split.type != "participant" ? "Owes" : "Participated";
                    return [split.fullName, amountText, formatter.format(split.amount)];
                  }).toList(),
                ),
              ],

              pw.Spacer(),

              // Footer
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              if (entity.updatedAt != null && entity.updatedBy != null) ...[
                pw.Center(
                  child: pw.Text(
                    'Last updated by ${entity.updatedBy!.fullName}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
                pw.SizedBox(height: 2),
              ],
              pw.Center(
                child: pw.Text(
                  'Generated with SplitEase - Keep your expenses in check',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to a temporary file
    final bytes = await pdf.save();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/expense_receipt_${entity.id}.pdf');
    await file.writeAsBytes(bytes);

    return file.path;
  }
}
