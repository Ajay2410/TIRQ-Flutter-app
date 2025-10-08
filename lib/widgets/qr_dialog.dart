import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';

import '../resources/app_resources/app_resources.dart';
import '../services/language.service.dart';
import '../core/models/hive/user/user.dart';
import '../core/models/customer.dart';
import '../core/utils/app_logger.dart';
import '../routes/routes.dart';
import '../features/home/my_customers/scan_code/scan_code.view.dart';
import '../core/locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'common_elevated_button.dart';

class QRDialog extends StatefulWidget {
  final User user;
  final String? organizationName;
  final Customer? customer;

  const QRDialog({
    super.key,
    required this.user,
    this.organizationName,
    this.customer,
  });

  @override
  State<QRDialog> createState() => _QRDialogState();
}

class _QRDialogState extends State<QRDialog> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;
  bool _isSharing = false;
  final _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),

            Container(
              decoration: BoxDecoration(
                color: AppColors.periwinkleBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              padding: EdgeInsets.all(8),
              child: ClipOval(
                child:
                    (widget.customer?.userImage ?? widget.user.logoUrl) != null
                        ? CachedNetworkImage(
                          imageUrl:
                              widget.customer?.userImage ??
                              widget.user.logoUrl ??
                              'https://img.freepik.com/free-vector/search-engine-logo_1071-76.jpg',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: const Color(0xFFE8E8E8),
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: AppColors.textGrey,
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                        : Icon(Icons.person, size: 40, color: Colors.grey),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.customer?.customerName ??
                      widget.organizationName ??
                      widget.user.name ??
                      'User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.customer?.email ??
                      widget.user.email ??
                      'yourmail@gmail.com',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // QR Code
            RepaintBoundary(
              key: _qrKey,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textGrey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child:
                        widget.customer?.qrCode != null
                            ? Image.memory(
                              base64Decode(
                                widget.customer!.qrCode!.split(',')[1],
                              ),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                            : QrImageView(
                              data:
                                  widget.user.id ?? 'user_${widget.user.email}',
                              version: QrVersions.auto,
                              size: 200,
                              gapless: true,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.black,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Colors.black,
                              ),
                            ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Image.asset(
                      AppImages.triqLogo2,
                      height: 12,
                      width: 21,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: CommonElevatedButton(
                    imagePath: AppImages.scan,
                    label: LanguageService.get("scan"),
                    backgroundColor: AppColors.primary,
                    onPressed: _onScanPressed,
                    borderRadius: 45,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CommonElevatedButton(
                    imagePath: AppImages.share,
                    label: LanguageService.get("share"),
                    backgroundColor: AppColors.primaryLight,
                    onPressed: _onSharePressed,
                    isLoading: _isSharing,
                    borderRadius: 45,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CommonElevatedButton(
                    imagePath: AppImages.save,
                    label: LanguageService.get("save"),
                    backgroundColor: Colors.white,
                    textColor: AppColors.textGrey,
                    borderColor: AppColors.textGrey,
                    onPressed: _onSavePressed,
                    borderRadius: 45,
                    isLoading: _isSaving,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onScanPressed() {
    Navigator.of(context).pop();
    _navigationService.navigateTo(
      Routes.scanCode,
      arguments: ScanCodeViewAttributes(isFromProfile: true),
    );
  }

  Future<void> _onSharePressed() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final qrImage = await _captureQRImage();
      if (qrImage == null) {
        Fluttertoast.showToast(msg: 'Failed to capture QR image');
        return;
      }

      // Get temporary directory for sharing
      final directory = await getTemporaryDirectory();
      final fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';

      // Write to temporary file
      final file = File(filePath);
      await file.writeAsBytes(qrImage);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'My QR Code',
        text: 'Here is my QR code',
      );

      // Clean up
      await file.delete();
    } catch (e) {
      AppLogger.error('Error sharing QR: $e');
      Fluttertoast.showToast(msg: 'Failed to share QR code: ${e.toString()}');
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  Future<void> _onSavePressed() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Check storage permission
      final permissionStatus = await _checkPermission();
      if (!permissionStatus) {
        Fluttertoast.showToast(
          msg: 'Storage permission is required to save QR code',
        );
        return;
      }

      final qrImage = await _captureQRImage();
      if (qrImage == null) {
        Fluttertoast.showToast(msg: 'Failed to capture QR image');
        return;
      }

      // Get temporary directory for creating the file
      final directory = await getTemporaryDirectory();
      final fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';

      // Write to temporary file
      final file = File(filePath);
      await file.writeAsBytes(qrImage);

      // Save to gallery using saver_gallery
      final result = await SaverGallery.saveImage(
        qrImage,
        fileName: fileName,
        skipIfExists: true,
      );

      AppLogger.info('QR code save result: $result');

      if (result.isSuccess) {
        Fluttertoast.showToast(msg: 'QR code saved to gallery');
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to save QR code to gallery: ${result.errorMessage}',
        );
      }

      // Delete the temporary file
      await file.delete();
    } catch (e) {
      AppLogger.error('Error downloading QR: $e');
      Fluttertoast.showToast(
        msg: 'Failed to download QR code: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<bool> _checkPermission() async {
    // For iOS, we don't need to explicitly check permission as it's handled by the OS
    if (Platform.isIOS) {
      return true;
    }

    // For Android, check and request permission if needed
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted) {
        return true;
      }

      // Request permission
      final result = await Permission.storage.request();
      final resultPhotos = await Permission.photos.request();
      if (result.isGranted || resultPhotos.isGranted) {
        return true;
      }

      if (result.isPermanentlyDenied) {
        // User needs to enable permission from settings
        Fluttertoast.showToast(
          msg:
              'Photo permission is permanently denied. Please enable it in app settings.',
          toastLength: Toast.LENGTH_LONG,
        );

        await openAppSettings();
      }
    }

    return false;
  }

  Future<Uint8List?> _captureQRImage() async {
    try {
      // Find the RenderRepaintBoundary using the key
      final renderObject = _qrKey.currentContext?.findRenderObject();
      if (renderObject == null) {
        AppLogger.error('RenderObject is null - widget not yet rendered');
        return null;
      }

      if (renderObject is! RenderRepaintBoundary) {
        AppLogger.error(
          'RenderObject is not RenderRepaintBoundary: ${renderObject.runtimeType}',
        );
        return null;
      }

      final boundary = renderObject;

      // Convert to image
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        AppLogger.error('ByteData is null');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      AppLogger.error('Error capturing QR image: $e');
      return null;
    }
  }
}
