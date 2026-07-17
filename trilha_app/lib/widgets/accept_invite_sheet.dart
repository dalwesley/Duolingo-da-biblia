import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';

/// Sheet para aceitar convite: digitar código ou escanear QR.
Future<String?> showAcceptInviteSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _AcceptInviteSheet(),
  );
}

class _AcceptInviteSheet extends StatefulWidget {
  const _AcceptInviteSheet();

  @override
  State<_AcceptInviteSheet> createState() => _AcceptInviteSheetState();
}

class _AcceptInviteSheetState extends State<_AcceptInviteSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit([String? raw]) {
    final code = (raw ?? _controller.text).trim().toUpperCase();
    if (code.isEmpty) return;
    Navigator.pop(context, code);
  }

  Future<void> _scanQr() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _QrScanPage()),
    );
    if (!mounted || code == null || code.isEmpty) return;
    _submit(code);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottom),
        decoration: BoxDecoration(
          color: const Color(0xFF121816),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aceitar convite',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Escaneie o QR ou digite o código do amigo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              maxLength: 8,
              style: const TextStyle(
                color: Colors.white,
                letterSpacing: 4,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'CÓDIGO',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.35),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.35),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
              onSubmitted: _submit,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _scanQr,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.45),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 20,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'ESCANEAR QR',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _submit(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'ENTRAR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.inkOnAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrScanPage extends StatefulWidget {
  const _QrScanPage();

  @override
  State<_QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<_QrScanPage> {
  final _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _handled = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw == null || raw.isEmpty) continue;
      final match = RegExp(r'[A-Z0-9]{4,8}', caseSensitive: false)
          .firstMatch(raw.toUpperCase());
      if (match == null) continue;
      _handled = true;
      Navigator.pop(context, match.group(0));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Escanear QR',
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _scanner, onDetect: _onDetect),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.accent, width: 2),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48 + MediaQuery.viewPaddingOf(context).bottom,
            child: Text(
              'Aponte para o QR do convite',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
