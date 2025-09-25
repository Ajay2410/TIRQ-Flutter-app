import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';

import '../../../../resources/multimedia_resources/resources.dart';

class ScanCodeView extends StatefulWidget {
  const ScanCodeView({super.key});

  @override
  State<ScanCodeView> createState() => _ScanCodeViewState();
}

class _ScanCodeViewState extends State<ScanCodeView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;
  MobileScannerController? _scannerController;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _onCodeDetected(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isScanning = false;
        _handleScannedCode(barcode.rawValue!);
        break;
      }
    }
  }

  void _handleScannedCode(String code) {
    // Handle the scanned code here
    print('Scanned code: $code');

    // Show result dialog or navigate to next screen
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Code Scanned'),
            content: Text('Scanned code: $code'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isScanning = true;
                  });
                },
                child: Text('Scan Again'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Done'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (image != null) {
        // Process the selected image for QR/barcode detection
        _processImageFromGallery(image.path);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image from gallery')));
    }
  }

  void _processImageFromGallery(String imagePath) {
    // Here you would process the image to detect QR/barcode
    // For now, just show a placeholder
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Image Selected'),
            content: Text('Processing image from gallery...'),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK'))],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAppBar(),
          Stack(
            children: [
              // Camera view
              if (_isScanning)
                MobileScanner(onDetect: _onCodeDetected, controller: _scannerController)
              else
                Container(color: AppColors.black, child: Center(child: Text('Camera paused', style: TextStyle(color: AppColors.white)))),

              // Scanning overlay
              if (_isScanning) _buildScanningOverlay(),

              // Bottom action bar
              _buildBottomActionBar(),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      leading: IconButton(onPressed: () {}, icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white)),
      title: Text(LanguageService.get('scan_code'), style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      decoration: BoxDecoration(color: AppColors.black.withValues(alpha: 0.3)),
      child: Stack(
        children: [
          // Scanning frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(border: Border.all(color: AppColors.white, width: 3), borderRadius: BorderRadius.circular(20)),
              child: Stack(
                children: [
                  // Corner indicators
                  ..._buildCornerIndicators(),
                  // Scanning line animation
                  _buildScanningLine(),
                ],
              ),
            ),
          ),

          // Instructions
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Position the code within the frame',
                style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerIndicators() {
    return [
      // Top left
      Positioned(
        top: -2,
        left: -2,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.blue, width: 6), left: BorderSide(color: Colors.blue, width: 6))),
        ),
      ),
      // Top right
      Positioned(
        top: -2,
        right: -2,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.blue, width: 6), right: BorderSide(color: Colors.blue, width: 6))),
        ),
      ),
      // Bottom left
      Positioned(
        bottom: -2,
        left: -2,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blue, width: 6), left: BorderSide(color: Colors.blue, width: 6))),
        ),
      ),
      // Bottom right
      Positioned(
        bottom: -2,
        right: -2,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.blue, width: 6), right: BorderSide(color: Colors.blue, width: 6)),
          ),
        ),
      ),
    ];
  }

  Widget _buildScanningLine() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return Positioned(
          top: _scanAnimation.value * 280,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, Colors.blue, Colors.transparent], stops: [0.0, 0.5, 1.0]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: Icons.qr_code,
                label: LanguageService.get('my_qr_code'),
                onTap: () {
                  // Handle My QR Code
                  print('My QR Code tapped');
                },
              ),
              _buildActionButton(
                icon: Icons.camera_alt,
                label: '',
                onTap: () {
                  // Camera is already active, just toggle scanning
                  setState(() {
                    _isScanning = !_isScanning;
                  });
                },
                isActive: _isScanning,
              ),
              _buildActionButton(icon: Icons.photo_library, label: LanguageService.get('album'), onTap: _pickFromGallery),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: isActive ? Border.all(color: Colors.blue, width: 3) : null,
            ),
            child: Center(child: Icon(icon, size: 24, color: AppColors.black)),
          ),
          if (label.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.white)),
          ],
        ],
      ),
    );
  }
}
