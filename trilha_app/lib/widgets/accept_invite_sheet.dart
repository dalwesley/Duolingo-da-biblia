import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

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
        margin: const EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, AppSpace.md),
        padding: EdgeInsets.fromLTRB(
          AppSpace.xxl,
          AppSpace.screen,
          AppSpace.xxl,
          AppSpace.screen + bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.night,
          borderRadius: BorderRadius.circular(AppRadii.xl),
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
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aceitar convite',
              textAlign: TextAlign.center,
              style: AppTypography.display(
                size: 24,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              'Escaneie o QR ou digite o código do amigo',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpace.screen),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              maxLength: 8,
              style: AppTypography.title(
                color: Colors.white,
                size: 22,
                weight: FontWeight.w800,
              ).copyWith(letterSpacing: 4),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'CÓDIGO',
                hintStyle: AppTypography.title(
                  color: Colors.white.withValues(alpha: 0.25),
                  size: 22,
                  weight: FontWeight.w700,
                ).copyWith(letterSpacing: 4),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.35),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.35),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
              onSubmitted: _submit,
            ),
            const SizedBox(height: AppSpace.md),
            GestureDetector(
              onTap: _scanQr,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CinematicIcon(
                      glyph: CinematicGlyph.qr,
                      size: 20,
                      accent: AppColors.accent,
                      framed: false,
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Text(
                      'ESCANEAR QR',
                      style: AppTypography.cta(size: 13, color: AppColors.accent)
                          .copyWith(letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            GestureDetector(
              onTap: () => _submit(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Text(
                  'ENTRAR',
                  textAlign: TextAlign.center,
                  style: AppTypography.cta(size: 13).copyWith(letterSpacing: 0.8),
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
          style: AppTypography.display(
            weight: FontWeight.w700,
            size: 22,
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
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.accent, width: 2),
              ),
            ),
          ),
          Positioned(
            left: AppSpace.xxl,
            right: AppSpace.xxl,
            bottom: 48 + MediaQuery.viewPaddingOf(context).bottom,
            child: Text(
              'Aponte para o QR do convite',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                color: Colors.white.withValues(alpha: 0.85),
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
