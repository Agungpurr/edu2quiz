import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/hasil_model.dart';

class PdfService {
  static Future<void> generateHasilReport(
    List<HasilModel> hasilList, {
    String? kelas,
    String? mapel,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final now = DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN HASIL QUIZ',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      'EduQuiz - Aplikasi Belajar SD',
                      style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.Text(
                  'Cetak: $now',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                ),
              ],
            ),
            if (kelas != null || mapel != null)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  'Filter: ${kelas != null ? "Kelas $kelas" : "Semua Kelas"}${mapel != null ? " | $mapel" : ""}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
            pw.Divider(color: PdfColors.blue300, thickness: 2),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'EduQuiz © ${DateTime.now().year}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
            pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
        build: (context) => [
          // Summary stats
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Total Siswa', '${hasilList.map((h) => h.siswaId).toSet().length}', PdfColors.blue700),
                _buildStatBox('Total Quiz', '${hasilList.length}', PdfColors.purple700),
                _buildStatBox('Rata-rata', '${hasilList.isEmpty ? 0 : (hasilList.map((h) => h.persentase).reduce((a, b) => a + b) / hasilList.length).toStringAsFixed(1)}%', PdfColors.orange700),
                _buildStatBox('Lulus', '${hasilList.where((h) => h.lulus).length}', PdfColors.green700),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(1),
              6: const pw.FlexColumnWidth(1),
              7: const pw.FlexColumnWidth(0.8),
              8: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue700),
                children: [
                  _tableHeader('No'),
                  _tableHeader('Nama Siswa'),
                  _tableHeader('Kelas'),
                  _tableHeader('Mata Pelajaran'),
                  _tableHeader('Benar'),
                  _tableHeader('Total Soal'),
                  _tableHeader('Nilai'),
                  _tableHeader('Grade'),
                  _tableHeader('Tanggal'),
                ],
              ),
              // Data rows
              ...hasilList.asMap().entries.map((entry) {
                final i = entry.key;
                final hasil = entry.value;
                final isEven = i % 2 == 0;
                final lulusColor = hasil.lulus ? PdfColors.green700 : PdfColors.red700;

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : PdfColors.grey50,
                  ),
                  children: [
                    _tableCell('${i + 1}'),
                    _tableCell(hasil.siswaNama),
                    _tableCell(hasil.siswaKelas),
                    _tableCell(hasil.mapel),
                    _tableCell('${hasil.jawabanBenar}', color: PdfColors.green700),
                    _tableCell('${hasil.totalSoal}'),
                    _tableCell('${hasil.persentase.toStringAsFixed(0)}%', color: lulusColor, bold: true),
                    _tableCell(hasil.grade, color: lulusColor, bold: true),
                    _tableCell(dateFormat.format(hasil.selesaiAt), small: true),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  static pw.Widget _buildStatBox(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color)),
        pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _tableCell(String text, {PdfColor? color, bool bold = false, bool small = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: small ? 7 : 8,
          color: color ?? PdfColors.grey800,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static Future<void> generateDetailHasil(HasilModel hasil) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy HH:mm', 'id_ID');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue700,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('DETAIL HASIL QUIZ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('Nama: ${hasil.siswaNama}', style: pw.TextStyle(fontSize: 10, color: PdfColors.white)),
                      pw.Text('Kelas: ${hasil.siswaKelas}', style: pw.TextStyle(fontSize: 10, color: PdfColors.white)),
                      pw.Text('Mapel: ${hasil.mapel}', style: pw.TextStyle(fontSize: 10, color: PdfColors.white)),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                      pw.Text('Nilai: ${hasil.persentase.toStringAsFixed(0)}%', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.yellow200)),
                      pw.Text('Grade: ${hasil.grade}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      pw.Text('${hasil.jawabanBenar}/${hasil.totalSoal} Benar', style: pw.TextStyle(fontSize: 10, color: PdfColors.white)),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Detail soal
          pw.Text('Detail Jawaban', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          pw.SizedBox(height: 8),
          ...hasil.detailJawaban.asMap().entries.map((entry) {
            final i = entry.key;
            final detail = entry.value;
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: detail.benar ? PdfColors.green50 : PdfColors.red50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: detail.benar ? PdfColors.green300 : PdfColors.red300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${i + 1}. ${detail.pertanyaan}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: detail.benar ? PdfColors.green600 : PdfColors.red600,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(detail.benar ? '✓ BENAR' : '✗ SALAH', style: pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Jawaban kamu: ${detail.jawabanSiswa}', style: pw.TextStyle(fontSize: 9, color: detail.benar ? PdfColors.green700 : PdfColors.red700)),
                  if (!detail.benar)
                    pw.Text('Jawaban benar: ${detail.jawabanBenar}', style: pw.TextStyle(fontSize: 9, color: PdfColors.green700)),
                ],
              ),
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
