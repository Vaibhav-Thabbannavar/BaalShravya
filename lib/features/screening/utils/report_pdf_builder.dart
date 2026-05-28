import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../presentation/report_provider.dart';

class ReportPdfBuilder {
  static Future<pw.Document> build(ReportData data) async {
    final doc = pw.Document();

    final session = data.session;
    final infant = data.infant;
    final questionnaire = data.questionnaireResponse;
    final boa = data.boaScreening;

    // outcome colors
    final outcomeColor = session.isPassed
        ? PdfColors.green700
        : PdfColors.red700;

    final outcomeBg = session.isPassed
        ? PdfColors.green50
        : PdfColors.red50;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [

          // header
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF00838F),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BaalShravya',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Early Hearing Screening Report',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  session.sessionDate,
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // outcome banner
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: outcomeBg,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: outcomeColor),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  session.isPassed ? 'PASS' : 'REFER',
                  style: pw.TextStyle(
                    color: outcomeColor,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (session.isReferred && session.referralType != null)
                  pw.Text(
                    'Refer for ${session.referralType!.toUpperCase()} diagnosis',
                    style: pw.TextStyle(
                      color: outcomeColor,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // infant details section
          _buildSection(
            title: 'Infant Details',
            rows: [
              _row('Name', infant.name),
              _row('Date of Birth', infant.dateOfBirth),
              _row('Age', infant.ageString),
              _row('Gender', infant.gender),
              if (infant.birthWeightKg != null)
                _row('Birth Weight', '${infant.birthWeightKg} kg'),
              if (infant.deliveryType != null)
                _row('Delivery Type', infant.deliveryType!),
            ],
          ),

          pw.SizedBox(height: 12),

          // session details
          _buildSection(
            title: 'Session Details',
            rows: [
              _row('Session Date', session.sessionDate),
              if (session.anmName != null)
                _row('ANM', session.anmName!),
              if (session.parentName != null)
                _row('Parent', session.parentName!),
            ],
          ),

          pw.SizedBox(height: 12),

          // questionnaire results
          if (questionnaire != null) ...[
            _buildSection(
              title: 'Questionnaire Result',
              rows: [
                _row('Risk Factors Found',
                    '${questionnaire.totalYesCount}'),
                _row('Outcome',
                    questionnaire.isPassed ? 'PASS' : 'REFER'),
              ],
            ),
            pw.SizedBox(height: 12),
          ],

          // BOA results
          if (boa != null) ...[
            _buildSection(
              title: 'BOA Screening Result',
              rows: [
                _row('Overall Outcome',
                    boa.isPassed ? 'PASS' : 'REFER'),
                if (boa.notes != null) _row('Notes', boa.notes!),
                ...boa.stimulusResults.map((s) => _row(
                      '${s.frequencyHz} Hz · ${s.intensityDb} dB',
                      s.responseObserved
                          ? s.responseType ?? 'Response observed'
                          : 'No response',
                    )),
              ],
            ),
            pw.SizedBox(height: 12),
          ],

          // referral details
          if (session.isReferred) ...[
            _buildSection(
              title: 'Referral Details',
              rows: [
                if (session.referralType != null)
                  _row('Referral Type',
                      session.referralType!.toUpperCase()),
                if (session.referralNotes != null)
                  _row('Notes', session.referralNotes!),
              ],
            ),
          ],

          pw.SizedBox(height: 24),

          // footer
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated by BaalShravya — Early Hearing Screening App',
            style: const pw.TextStyle(
              color: PdfColors.grey600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );

    return doc;
  }

  // helper — builds a labeled section
  static pw.Widget _buildSection({
    required String title,
    required List<pw.Widget> rows,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF00838F),
            ),
          ),
          pw.Divider(color: PdfColors.grey300),
          ...rows,
        ],
      ),
    );
  }

  // helper — builds one label: value row
  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 11,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}