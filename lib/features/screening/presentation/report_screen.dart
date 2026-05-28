import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/services/report_service.dart';
import '../utils/report_pdf_builder.dart';
import 'report_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const ReportScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  bool _isGenerating = false;
  File? _generatedFile;

  Future<void> _generateAndSave(ReportData data) async {
    setState(() => _isGenerating = true);
    try {
      final doc = await ReportPdfBuilder.build(data);
      final file = await ReportService.saveToDevice(
        doc,
        'BaalShravya_${data.infant.name}_${data.session.sessionDate}',
      );
      setState(() {
        _generatedFile = file;
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report saved successfully'),
            backgroundColor: AppColors.pass,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _print(ReportData data) async {
    try {
      final doc = await ReportPdfBuilder.build(data);
      await ReportService.print(doc);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }
    }
  }

  Future<void> _share(ReportData data) async {
    try {
      final doc = await ReportPdfBuilder.build(data);
      final file = _generatedFile ??
          await ReportService.saveToDevice(
            doc,
            'BaalShravya_${data.infant.name}_${data.session.sessionDate}',
          );
      await ReportService.share(file, data.infant.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reportAsync =
        ref.watch(reportDataProvider(widget.sessionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.screeningReport),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // go home after viewing report
          onPressed: () => context.go('/home'),
        ),
      ),
      body: reportAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading report...'),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(reportDataProvider(widget.sessionId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (reportData) => _ReportContent(
          data: reportData,
          l10n: l10n,
          isGenerating: _isGenerating,
          generatedFile: _generatedFile,
          onDownload: () => _generateAndSave(reportData),
          onPrint: () => _print(reportData),
          onShare: () => _share(reportData),
        ),
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  final ReportData data;
  final AppLocalizations l10n;
  final bool isGenerating;
  final File? generatedFile;
  final VoidCallback onDownload;
  final VoidCallback onPrint;
  final VoidCallback onShare;

  const _ReportContent({
    required this.data,
    required this.l10n,
    required this.isGenerating,
    required this.generatedFile,
    required this.onDownload,
    required this.onPrint,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final session = data.session;
    final infant = data.infant;
    final questionnaire = data.questionnaireResponse;
    final boa = data.boaScreening;
    final isRefer = session.isReferred;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // outcome banner — most prominent element
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isRefer
                  ? AppColors.referSurface
                  : AppColors.passSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRefer ? AppColors.refer : AppColors.pass,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  isRefer ? '⚠️' : '✅',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  isRefer ? l10n.refer : l10n.pass,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isRefer ? AppColors.refer : AppColors.pass,
                  ),
                ),
                if (isRefer && session.referralType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.referralType == 'oae'
                        ? l10n.referForOae
                        : l10n.referForAabr,
                    style: TextStyle(
                      fontSize: 13,
                      color: isRefer
                          ? AppColors.refer
                          : AppColors.pass,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // download / print / share buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: isGenerating
                      ? Icons.hourglass_empty
                      : generatedFile != null
                          ? Icons.check
                          : Icons.download_outlined,
                  label: l10n.downloadPdf,
                  isLoading: isGenerating,
                  onTap: onDownload,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.print_outlined,
                  label: l10n.printReport,
                  onTap: onPrint,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.share_outlined,
                  label: l10n.sharePdf,
                  onTap: onShare,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // PDF preview
          Container(
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.border, width: 0.5),
            ),
            clipBehavior: Clip.hardEdge,
            child: PdfPreview(
              // PdfPreview from printing package
              // renders the PDF inline
              build: (format) async {
                final doc = await ReportPdfBuilder.build(data);
                return doc.save();
              },
              // hide action buttons — we have our own
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName:
                  'BaalShravya_${infant.name}_${session.sessionDate}.pdf',
            ),
          ),

          const SizedBox(height: 20),

          // infant details card
          _DetailCard(
            title: l10n.infantDetails,
            rows: [
              _DetailRow(label: l10n.infantName, value: infant.name),
              _DetailRow(
                  label: l10n.dateOfBirth,
                  value: infant.dateOfBirth),
              _DetailRow(label: 'Age', value: infant.ageString),
              _DetailRow(label: l10n.gender, value: infant.gender),
              if (infant.birthWeightKg != null)
                _DetailRow(
                    label: l10n.birthWeight,
                    value: '${infant.birthWeightKg} kg'),
              if (infant.deliveryType != null)
                _DetailRow(
                    label: l10n.deliveryType,
                    value: infant.deliveryType!),
            ],
          ),

          const SizedBox(height: 12),

          // questionnaire result card
          if (questionnaire != null)
            _DetailCard(
              title: l10n.questionnaire,
              rows: [
                _DetailRow(
                  label: 'Risk Factors',
                  value: '${questionnaire.totalYesCount} found',
                ),
                _DetailRow(
                  label: 'Outcome',
                  value: questionnaire.isPassed ? 'PASS' : 'REFER',
                  valueColor: questionnaire.isPassed
                      ? AppColors.pass
                      : AppColors.refer,
                ),
                if (questionnaire.filledByName != null)
                  _DetailRow(
                    label: 'Filled By',
                    value: questionnaire.filledByName!,
                  ),
              ],
            ),

          if (questionnaire != null) const SizedBox(height: 12),

          // BOA result card
          if (boa != null) ...[
            _DetailCard(
              title: l10n.boaScreening,
              rows: [
                _DetailRow(
                  label: 'Outcome',
                  value: boa.isPassed ? 'PASS' : 'REFER',
                  valueColor:
                      boa.isPassed ? AppColors.pass : AppColors.refer,
                ),
                if (boa.conductedByName != null)
                  _DetailRow(
                      label: 'Conducted By',
                      value: boa.conductedByName!),
                if (boa.notes != null)
                  _DetailRow(label: 'Notes', value: boa.notes!),
                // stimulus results
                ...boa.stimulusResults.map((s) => _DetailRow(
                      label:
                          '${s.frequencyHz} Hz · ${s.intensityDb} dB',
                      value: s.responseObserved
                          ? s.responseType ?? 'Response'
                          : 'No response',
                      valueColor: s.responseObserved
                          ? AppColors.pass
                          : AppColors.refer,
                    )),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // referral card
          if (isRefer) ...[
            _DetailCard(
              title: 'Referral Details',
              rows: [
                if (session.referralType != null)
                  _DetailRow(
                    label: l10n.referralType,
                    value: session.referralType!.toUpperCase(),
                  ),
                if (session.referralNotes != null)
                  _DetailRow(
                    label: l10n.referralNotes,
                    value: session.referralNotes!,
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // session info card
          _DetailCard(
            title: 'Session Info',
            rows: [
              _DetailRow(
                  label: 'Session Date',
                  value: session.sessionDate),
              if (session.anmName != null)
                _DetailRow(label: 'ANM', value: session.anmName!),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// action button — download / print / share
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isLoading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;

  const _DetailCard({
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}