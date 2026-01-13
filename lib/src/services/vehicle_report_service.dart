import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as path;

class VehicleReportService {
  static Future<void> generateVehicleReport({
    required String vehicleNo,
    required Map<String, dynamic>? rcData,
    required List<dynamic> challanList,
  }) async {
    try {
      print(
        "🚀🚀🚀 [VehicleReport] generateVehicleReport called for: $vehicleNo 🚀🚀🚀",
      );

      // IMMEDIATE PDF CREATION - NO DIALOG BULLSHIT
      print("� [VehicleReport] SKIPPING DIALOG - DIRECT PDF CREATION!");

      Get.snackbar(
        '🚀 PDF Starting',
        'Creating PDF directly for $vehicleNo',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade200,
        colorText: Colors.blue.shade800,
        duration: const Duration(seconds: 2),
      );

      // Direct PDF generation
      await _createDirectPDF(vehicleNo, rcData);

      return; // Skip dialog completely

      Get.dialog(
        WillPopScope(
          onWillPop: () async {
            print("🚀 [VehicleReport] Dialog close attempt detected");
            return true; // Allow closing
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue.shade700, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Verification Receipt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        'Vehicle No: $vehicleNo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Report Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Vehicle: $vehicleNo'),
                        Text(
                          'Generated: ${DateTime.now().toString().split('.')[0]}',
                        ),
                        if (rcData != null)
                          Text('Owner: ${rcData['owner_name'] ?? 'N/A'}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // RC Data Section
                  if (rcData != null) ...[
                    Text(
                      'RC Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rcData.entries
                            .take(5) // Show only first 5 fields
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '${_formatFieldName(entry.key)}: ${entry.value ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Additional Info Section
                  Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt,
                              color: Colors.blue.shade600,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Professional Invoice Ready for Download',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This professional receipt includes: Complete RC verification, Owner details, Vehicle specifications, Registration status, Digital verification stamp, and official formatting - just like any business invoice!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BIG DOWNLOAD BUTTON IN CONTENT AREA
                  const SizedBox(height: 20),
                  Center(
                    child: InkWell(
                      onTap: () {
                        print(
                          "🔥🔥🔥 [VehicleReport] CONTENT AREA BUTTON TAPPED! 🔥🔥🔥",
                        );
                        print(
                          "🔥 [VehicleReport] InkWell in content area clicked!",
                        );

                        // Close dialog
                        Get.back();

                        // Show success message
                        Get.snackbar(
                          '🚀 PDF Generation',
                          'Creating vehicle invoice PDF now!',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.blue.shade100,
                          colorText: Colors.blue.shade800,
                          duration: const Duration(seconds: 2),
                        );

                        // Generate PDF
                        _handlePDFGeneration(vehicleNo, rcData);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade600,
                              Colors.green.shade400,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              '📄 DOWNLOAD VEHICLE INVOICE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Close'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  print(
                    "🔥🔥🔥 [VehicleReport] BUTTON TAPPED - IMMEDIATE LOG! 🔥🔥🔥",
                  );
                  print("🔥 [VehicleReport] Button onPressed fired!");

                  // IMMEDIATE action - close dialog first
                  Get.back();

                  // Show immediate test message
                  Get.snackbar(
                    '� BUTTON WORKS!',
                    'Button click detected! PDF generation starting...',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green.shade200,
                    colorText: Colors.green.shade800,
                    duration: const Duration(seconds: 3),
                    margin: const EdgeInsets.all(16),
                  );

                  // Start PDF generation in background
                  _handlePDFGeneration(vehicleNo, rcData);
                },
                icon: const Icon(Icons.receipt_long, size: 18),
                label: const Text('📄 Download Invoice'),
              ),
            ],
          ),
        ),
        barrierDismissible: true,
        useSafeArea: true,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate vehicle report: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // DIRECT PDF CREATION - NO DIALOG
  static Future<void> _createDirectPDF(
    String vehicleNo,
    Map<String, dynamic>? rcData,
  ) async {
    try {
      print("🔥 [PDF] DIRECT PDF creation for $vehicleNo");

      final pdf = pw.Document();
      final now = DateTime.now();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Simple header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  color: PdfColors.blue800,
                  child: pw.Text(
                    '🚗 VEHICLE INVOICE - $vehicleNo',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.SizedBox(height: 20),

                // Basic info
                pw.Text(
                  'Vehicle Number: $vehicleNo',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Generated: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}',
                  style: pw.TextStyle(fontSize: 12),
                ),

                pw.SizedBox(height: 20),

                // COMPLETE RC DATA
                if (rcData != null && rcData.isNotEmpty) ...[
                  pw.Text(
                    '🔍 COMPLETE VEHICLE DETAILS',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 15),

                  // Owner Information Section
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    color: PdfColors.blue50,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '👤 OWNER INFORMATION',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        if (rcData['rc_owner_name'] != null)
                          pw.Text(
                            'Owner Name: ${rcData['rc_owner_name']}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        if (rcData['rc_father_name'] != null)
                          pw.Text(
                            'Father Name: ${rcData['rc_father_name'] ?? "Not Available"}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_owner_sr'] != null)
                          pw.Text(
                            'Owner Sr: ${rcData['rc_owner_sr']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_present_address'] != null)
                          pw.Text(
                            'Present Address: ${rcData['rc_present_address'] ?? "Not Available"}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_permanent_address'] != null)
                          pw.Text(
                            'Permanent Address: ${rcData['rc_permanent_address'] ?? "Not Available"}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  // Vehicle Specifications
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    color: PdfColors.green50,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '🚗 VEHICLE SPECIFICATIONS',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        if (rcData['rc_regn_no'] != null)
                          pw.Text(
                            'Registration No: ${rcData['rc_regn_no']}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        if (rcData['rc_chasi_no'] != null)
                          pw.Text(
                            'Chassis Number: ${rcData['rc_chasi_no']}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red700,
                            ),
                          ),
                        if (rcData['rc_eng_no'] != null)
                          pw.Text(
                            'Engine Number: ${rcData['rc_eng_no']}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red700,
                            ),
                          ),
                        if (rcData['rc_maker_desc'] != null)
                          pw.Text(
                            'Manufacturer: ${rcData['rc_maker_desc']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_maker_model'] != null)
                          pw.Text(
                            'Model: ${rcData['rc_maker_model']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_vch_catg'] != null)
                          pw.Text(
                            'Vehicle Category: ${rcData['rc_vch_catg']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_vh_class_desc'] != null)
                          pw.Text(
                            'Vehicle Class: ${rcData['rc_vh_class_desc']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_cubic_cap'] != null)
                          pw.Text(
                            'Engine Capacity: ${rcData['rc_cubic_cap']} CC',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_fuel_desc'] != null)
                          pw.Text(
                            'Fuel Type: ${rcData['rc_fuel_desc']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_seat_cap'] != null)
                          pw.Text(
                            'Seating Capacity: ${rcData['rc_seat_cap']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_wheelbase'] != null)
                          pw.Text(
                            'Wheelbase: ${rcData['rc_wheelbase'] ?? "Not Available"}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_manu_month_yr'] != null)
                          pw.Text(
                            'Manufacturing Year: ${rcData['rc_manu_month_yr']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  // Registration & Legal Details
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    color: PdfColors.orange50,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '📋 REGISTRATION & LEGAL DETAILS',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.orange800,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        if (rcData['rc_regn_dt'] != null)
                          pw.Text(
                            'Registration Date: ${rcData['rc_regn_dt']}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        if (rcData['rc_registered_at'] != null)
                          pw.Text(
                            'Registered At: ${rcData['rc_registered_at']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_fit_upto'] != null)
                          pw.Text(
                            'Fitness Valid Till: ${rcData['rc_fit_upto']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_tax_upto'] != null)
                          pw.Text(
                            'Tax Valid Till: ${rcData['rc_tax_upto'] ?? "Not Available"}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_status_as_on'] != null)
                          pw.Text(
                            'Status As On: ${rcData['rc_status_as_on']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_financer'] != null)
                          pw.Text(
                            'Financer: ${rcData['rc_financer'] ?? "Not Available"}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  // Insurance & PUC Details
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    color: PdfColors.purple50,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '🛡️ INSURANCE & PUC DETAILS',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple800,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        if (rcData['rc_insurance_comp'] != null)
                          pw.Text(
                            'Insurance Company: ${rcData['rc_insurance_comp']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_insurance_policy_no'] != null)
                          pw.Text(
                            'Policy Number: ${rcData['rc_insurance_policy_no']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_insurance_upto'] != null)
                          pw.Text(
                            'Insurance Valid Till: ${rcData['rc_insurance_upto']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_pucc_no'] != null)
                          pw.Text(
                            'PUC Number: ${rcData['rc_pucc_no'] ?? "Not Available"}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_pucc_upto'] != null)
                          pw.Text(
                            'PUC Valid Till: ${rcData['rc_pucc_upto'] ?? "Not Available"}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  // Technical Details
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    color: PdfColors.grey100,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '⚙️ TECHNICAL DETAILS',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        if (rcData['rc_version'] != null)
                          pw.Text(
                            'RC Version: ${rcData['rc_version']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_state_code'] != null)
                          pw.Text(
                            'State Code: ${rcData['rc_state_code']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_rto_code'] != null)
                          pw.Text(
                            'RTO Code: ${rcData['rc_rto_code']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_data_source'] != null)
                          pw.Text(
                            'Data Source: ${rcData['rc_data_source']}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        if (rcData['rc_is_bh_no_plate'] != null)
                          pw.Text(
                            'BH Number Plate: ${rcData['rc_is_bh_no_plate'] ?? "No"}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                ] else ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    color: PdfColors.red50,
                    child: pw.Text(
                      '⚠️ No RC data available for this vehicle',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.red800,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],

                pw.Spacer(),

                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.grey200,
                  child: pw.Text(
                    'Generated by Old Market - ${now.millisecondsSinceEpoch}',
                    style: pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save and share
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Invoice_${vehicleNo}_${now.millisecondsSinceEpoch}.pdf';
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());

      print("🔥 [PDF] Saved at: $filePath");

      // Success message
      Get.snackbar(
        '✅ PDF Created',
        'Invoice saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
      );

      // Share immediately
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Vehicle Invoice for $vehicleNo');

      print("🔥 [PDF] Share completed!");
    } catch (e) {
      print("🔥🔥🔥 [PDF] Direct PDF ERROR: $e");

      Get.snackbar(
        '❌ PDF Error',
        'Failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // SIMPLE TEST - Just show message
  static void _handlePDFGeneration(
    String vehicleNo,
    Map<String, dynamic>? rcData,
  ) {
    print("🔥🔥🔥 [VehicleReport] _handlePDFGeneration called! 🔥🔥🔥");

    // Show simple test message
    Get.snackbar(
      '✅ SUCCESS!',
      'Button click worked! Vehicle: $vehicleNo',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 3),
    );

    // Simple background task
    Future.delayed(const Duration(milliseconds: 500), () {
      print("🔥 [VehicleReport] Background task completed for $vehicleNo");

      Get.snackbar(
        '📄 PDF Ready',
        'PDF would be created for $vehicleNo',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        duration: const Duration(seconds: 2),
      );
    });
  }

  // Simple PDF creation function
  static Future<void> _createSimplePDF(
    String vehicleNo,
    Map<String, dynamic>? rcData,
  ) async {
    try {
      print("🔥 [PDF] Creating simple PDF for $vehicleNo");

      final pdf = pw.Document();
      final now = DateTime.now();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  color: PdfColors.blue900,
                  child: pw.Text(
                    '🚗 VEHICLE INVOICE - $vehicleNo',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.SizedBox(height: 30),

                // Vehicle info
                pw.Text(
                  'Vehicle Number: $vehicleNo',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Generated: ${now.day}/${now.month}/${now.year} at ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),

                pw.SizedBox(height: 20),

                // RC Data
                if (rcData != null && rcData.isNotEmpty) ...[
                  pw.Text(
                    'Vehicle Details:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  ...rcData.entries
                      .where(
                        (e) => e.value != null && e.value.toString().isNotEmpty,
                      )
                      .take(10)
                      .map(
                        (entry) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 150,
                                child: pw.Text(
                                  '${entry.key}:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  '${entry.value}',
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ] else ...[
                  pw.Text(
                    'No vehicle data available',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],

                pw.Spacer(),

                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  color: PdfColors.grey100,
                  child: pw.Text(
                    'OLD MARKET - Vehicle Services | Generated: ${now.millisecondsSinceEpoch}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      );

      print("🔥 [PDF] Saving PDF file...");

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Vehicle_Invoice_${vehicleNo.replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}.pdf';
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());

      print("🔥 [PDF] PDF saved at: $filePath");

      // Success message
      Get.snackbar(
        '✅ PDF Ready',
        'Invoice created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );

      // Share the file
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Vehicle Invoice for $vehicleNo');

      print("🔥 [PDF] Share dialog opened!");
    } catch (e) {
      print("🔥🔥🔥 [PDF] Error in _createSimplePDF: $e");
      rethrow;
    }
  }

  static String _formatFieldName(String field) {
    return field
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : word,
        )
        .join(' ');
  }

  // Super Simple PDF creation and share
  static Future<void> _createAndSharePDF(
    String vehicleNo,
    Map<String, dynamic>? rcData,
  ) async {
    try {
      print("🔥 [PDF] Step 1: Creating PDF document");

      final pdf = pw.Document();
      final now = DateTime.now();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(color: PdfColors.blue900),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        '🚗 VEHICLE INVOICE REPORT',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Professional Vehicle Documentation',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Vehicle Details Section
                pw.Container(
                  width: double.infinity,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Vehicle Registration: $vehicleNo',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Generated: ${now.day}/${now.month}/${now.year} at ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // RC Information
                if (rcData != null && rcData.isNotEmpty) ...[
                  pw.Text(
                    '📋 Vehicle Information',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 15),

                  // Key vehicle details in table format
                  ...rcData.entries
                      .where(
                        (e) => e.value != null && e.value.toString().isNotEmpty,
                      )
                      .take(15)
                      .map(
                        (entry) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 180,
                                child: pw.Text(
                                  '${entry.key.replaceAll('_', ' ').toUpperCase()}:',
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  '${entry.value}',
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    color: PdfColors.grey800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ] else ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      '⚠️ RC data not available for this vehicle',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.orange800,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                ],

                pw.Spacer(),

                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        '🏢 OLD MARKET - VEHICLE SERVICES',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'This is a computer-generated invoice. No signature required.',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        'Document ID: ${now.millisecondsSinceEpoch}',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      print("🔥 [PDF] Step 2: Saving PDF file");

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Invoice_${vehicleNo.replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}.pdf';
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);

      // Save PDF
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      print("🔥 [PDF] Step 3: PDF saved at: $filePath");

      // Success feedback
      Get.snackbar(
        '✅ Success',
        'Invoice created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
      );

      print("🔥 [PDF] Step 4: Opening share dialog");

      // Share the file
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Vehicle Invoice for $vehicleNo');

      print("🔥 [PDF] Step 5: Share completed!");
    } catch (e) {
      print("🔥🔥🔥 [PDF] ERROR in _createAndSharePDF: $e");
      rethrow;
    }
  }

  // OLD Simplified PDF generation function
  static Future<void> _generateSimplePDF(
    String vehicleNo,
    Map<String, dynamic>? rcData,
  ) async {
    try {
      print("🔥 [VehicleReport] Creating PDF document...");

      final pdf = pw.Document();

      // Simple PDF content
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  color: PdfColors.blue50,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'VEHICLE REPORT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Text(
                        'Generated: ${DateTime.now().toString().substring(0, 19)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Vehicle Info
                pw.Text(
                  'Vehicle Number: $vehicleNo',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),

                pw.SizedBox(height: 20),

                // RC Data
                if (rcData != null && rcData.isNotEmpty) ...[
                  pw.Text(
                    'RC Details:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  ...rcData.entries.map(
                    (entry) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 3),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 150,
                            child: pw.Text(
                              '${entry.key}:',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              '${entry.value ?? "N/A"}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  pw.Text(
                    'No RC data available',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],

                pw.SizedBox(height: 40),

                // Footer
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  color: PdfColors.grey100,
                  child: pw.Text(
                    'This is a computer-generated report. Generated on ${DateTime.now().toString().substring(0, 19)}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      );

      print("🔥 [VehicleReport] PDF created, now saving...");

      // Save PDF
      final output = await getApplicationDocumentsDirectory();
      final fileName =
          'Vehicle_Report_${vehicleNo.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path.join(output.path, fileName));

      await file.writeAsBytes(await pdf.save());

      print("🔥 [VehicleReport] PDF saved at: ${file.path}");

      // Close loading dialog
      Get.back();

      // Success message and share
      Get.snackbar(
        '✅ Success',
        'PDF generated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
      );

      // Share the file
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Vehicle Report for $vehicleNo');
    } catch (e) {
      print("🔥🔥🔥 [VehicleReport] Error in _generateSimplePDF: $e");
      rethrow;
    }
  }

  static Future<void> _generateAndSavePDF(
    String vehicleNo,
    Map<String, dynamic>? rcData,
    List<dynamic> challanList,
  ) async {
    print(
      "🔥🔥🔥 [VehicleReport] _generateAndSavePDF START for: $vehicleNo 🔥🔥🔥",
    );

    // STEP 1: Input validation with user feedback
    Get.snackbar(
      '📋 Step 1/6',
      'Validating input data...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade100,
      duration: const Duration(seconds: 1),
    );

    try {
      print("🔥 [VehicleReport] STEP 1: Input validation");
      print("🔥 [VehicleReport] - Vehicle No: '$vehicleNo'");
      print("🔥 [VehicleReport] - RC Data present: ${rcData != null}");
      print("🔥 [VehicleReport] - RC Data length: ${rcData?.length ?? 0}");
      print("🔥 [VehicleReport] - Challan List length: ${challanList.length}");

      if (vehicleNo.isEmpty) {
        throw Exception("Vehicle number is empty");
      }

      // STEP 2: PDF Document Creation
      Get.snackbar(
        '📄 Step 2/6',
        'Creating PDF document...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade100,
        duration: const Duration(seconds: 1),
      );

      print("🔥 [VehicleReport] STEP 2: Creating PDF document");
      final pdf = pw.Document();
      final DateTime now = DateTime.now();
      final String reportId =
          'VR-${now.millisecondsSinceEpoch.toString().substring(7)}';

      print("🔥 [VehicleReport] - Report ID generated: $reportId");
      print("🔥 [VehicleReport] - Current time: $now");
      print("🔥 [VehicleReport] Creating professional invoice-style PDF...");

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Professional Invoice Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue300, width: 2),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'OLX VEHICLE SERVICES',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Vehicle Verification Report',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.blue600,
                          ),
                        ),
                        pw.Text(
                          'Authorized Digital Report',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.blue500,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'REPORT ID: $reportId',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Date: ${_formatDate(now)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.blue600,
                          ),
                        ),
                        pw.Text(
                          'Time: ${_formatTime(now)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.blue600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Vehicle Information Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 4,
                          height: 20,
                          color: PdfColors.green,
                        ),
                        pw.SizedBox(width: 12),
                        pw.Text(
                          'VEHICLE INFORMATION',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 15),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Vehicle Number',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.Text(
                              vehicleNo,
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Report Status',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.green100,
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(15),
                                ),
                              ),
                              child: pw.Text(
                                'VERIFIED ✓',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // RC Data Section with Professional Styling
              if (rcData != null && rcData.isNotEmpty) ...[
                pw.Row(
                  children: [
                    pw.Container(width: 4, height: 20, color: PdfColors.blue),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      'REGISTRATION CERTIFICATE (RC) DETAILS',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),

                // Professional Table
                pw.Table(
                  border: pw.TableBorder(
                    top: pw.BorderSide(color: PdfColors.blue, width: 2),
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                    left: pw.BorderSide(color: PdfColors.grey300),
                    right: pw.BorderSide(color: PdfColors.grey300),
                    horizontalInside: pw.BorderSide(color: PdfColors.grey200),
                    verticalInside: pw.BorderSide(color: PdfColors.grey200),
                  ),
                  children: _buildProfessionalRCDataRows(rcData),
                ),
                pw.SizedBox(height: 25),
              ] else ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange50,
                    border: pw.Border.all(color: PdfColors.orange200),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 40,
                        height: 40,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.orange100,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(20),
                          ),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            '!',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.orange800,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'RC DATA UNAVAILABLE',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.orange800,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Unable to fetch registration details for this vehicle from government databases.',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.orange700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 25),
              ],

              // Report Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 4,
                          height: 20,
                          color: PdfColors.purple,
                        ),
                        pw.SizedBox(width: 12),
                        pw.Text(
                          'REPORT SUMMARY',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Fields Verified:',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          '${rcData?.length ?? 0}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Data Source:',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Government RC Database',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Verification Level:',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Official',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Professional Footer with Terms & Conditions
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TERMS & CONDITIONS',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '• This report is generated based on official government RC database records.\n'
                      '• Information accuracy depends on the data available in government systems.\n'
                      '• This report is for verification purposes only and not a legal document.\n'
                      '• OLX is not responsible for any discrepancies in government data.',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.blue700,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Digital Signature Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Generated by: OLX Vehicle Services',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Digital Report - No physical signature required',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(4),
                          ),
                        ),
                        child: pw.Text(
                          'DIGITALLY VERIFIED',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      // STEP 3: PDF Content Generation
      Get.snackbar(
        '⚙️ Step 3/6',
        'Building PDF content...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade100,
        duration: const Duration(seconds: 1),
      );

      print("🔥 [VehicleReport] STEP 3: PDF document created successfully");
      print("🔥 [VehicleReport] Converting PDF to bytes...");

      // Generate PDF bytes
      final pdfBytes = await pdf.save();
      print("🔥 [VehicleReport] ✅ PDF bytes generated successfully!");
      print("🔥 [VehicleReport] - File size: ${pdfBytes.length} bytes");
      print(
        "🔥 [VehicleReport] - Size in KB: ${(pdfBytes.length / 1024).toStringAsFixed(2)} KB",
      );

      // STEP 4: Filename Generation
      Get.snackbar(
        '📁 Step 4/6',
        'Generating filename...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade100,
        duration: const Duration(seconds: 1),
      );

      print("🔥 [VehicleReport] STEP 4: Generating filename");
      final String dateStr = _formatDate(
        now,
      ).replaceAll(' ', '_').replaceAll(',', '');
      final String timeStr = _formatTime(
        now,
      ).replaceAll(':', '').replaceAll(' ', '');
      final String fileName =
          'Vehicle_Receipt_${vehicleNo}_${dateStr}_${timeStr}.pdf';

      print("🔥 [VehicleReport] ✅ Filename generated: $fileName");
      print("🔥 [VehicleReport] - Date string: $dateStr");
      print("🔥 [VehicleReport] - Time string: $timeStr");

      // STEP 5: File Operations
      Get.snackbar(
        '💾 Step 5/6',
        'Saving file to device...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        duration: const Duration(seconds: 1),
      );

      print("🔥 [VehicleReport] STEP 5: Starting file operations");

      try {
        print("🔥 [VehicleReport] STEP 5a: Getting application directory...");
        // Save PDF to app's document directory and then share it
        print(
          "🔥 [VehicleReport] STEP 5b: Requesting app documents directory...",
        );
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        print("🔥 [VehicleReport] ✅ Got app documents directory successfully!");
        print("🔥 [VehicleReport] - Directory path: ${appDocDir.path}");
        print(
          "🔥 [VehicleReport] - Directory exists: ${await appDocDir.exists()}",
        );

        final String appDocPath = '${appDocDir.path}/$fileName';
        print("🔥 [VehicleReport] STEP 5c: Full file path generated");
        print("🔥 [VehicleReport] - Complete path: $appDocPath");

        print(
          "🔥 [VehicleReport] STEP 5d: Creating File object and writing bytes...",
        );
        final File pdfFile = File(appDocPath);

        // Show progress to user
        Get.snackbar(
          '✍️ Writing File',
          'Saving ${(pdfBytes.length / 1024).toStringAsFixed(1)} KB to device...',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          duration: const Duration(seconds: 2),
        );

        await pdfFile.writeAsBytes(pdfBytes);
        print("🔥 [VehicleReport] ✅ PDF file written successfully!");
        print(
          "🔥 [VehicleReport] - File size on disk: ${await pdfFile.length()} bytes",
        );
        print(
          "🔥 [VehicleReport] - File exists check: ${await pdfFile.exists()}",
        );

        print("🔥 [VehicleReport] STEP 5e: Preparing to share file...");

        // STEP 6: File Sharing
        Get.snackbar(
          '📤 Step 6/6',
          'Opening share dialog...',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          duration: const Duration(seconds: 2),
        );

        print("🔥 [VehicleReport] STEP 6: About to share PDF file...");
        print("🔥 [VehicleReport] STEP 6a: Creating XFile object...");
        final XFile xFile = XFile(appDocPath);
        print("🔥 [VehicleReport] - XFile created: ${xFile.path}");

        print("🔥 [VehicleReport] STEP 6b: Calling Share.shareXFiles...");
        await Share.shareXFiles([
          xFile,
        ], text: 'Professional Vehicle Verification Receipt for $vehicleNo');

        print("🔥🔥🔥 [VehicleReport] ✅ PDF SHARED SUCCESSFULLY! 🔥🔥🔥");

        // Close loading dialog if open
        print("🔥 [VehicleReport] STEP 7: Closing loading dialog...");
        if (Get.isDialogOpen ?? false) {
          Get.back();
          print("🔥 [VehicleReport] ✅ Loading dialog closed successfully");
        }

        // Show success notification
        Get.snackbar(
          '🎉 Success!',
          'PDF generated and shared successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade200,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 3),
          icon: Icon(Icons.check_circle, color: Colors.green),
        );

        // Show professional success message
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Colors.green.shade700,
                    size: 28,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice Generated! ✓',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Professional Receipt Ready',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.green.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Professional Invoice Ready!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your vehicle verification receipt has been generated with complete RC details, professional formatting, and official verification status.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red.shade600,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice File:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Save this receipt to your Downloads folder using the share menu for future reference.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  Get.back();
                  await Share.shareXFiles(
                    [XFile(appDocPath)],
                    text:
                        'Professional Vehicle Verification Receipt for $vehicleNo',
                  );
                },
                icon: Icon(Icons.share, size: 18, color: Colors.blue.shade600),
                label: Text(
                  'Share Receipt',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: Icon(Icons.check_circle, size: 18),
                label: Text('Perfect!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          barrierDismissible: true,
        );
      } catch (shareError) {
        print("🔥🔥🔥 [VehicleReport] ❌ SHARE OPERATION FAILED! 🔥🔥🔥");
        print("🔥 [VehicleReport] Share error type: ${shareError.runtimeType}");
        print("🔥 [VehicleReport] Share error message: $shareError");
        print("🔥 [VehicleReport] Attempting fallback save method...");

        // Show error to user but continue with fallback
        Get.snackbar(
          '⚠️ Share Failed',
          'Trying alternative save method...',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 2),
        );

        // Close loading dialog if open before trying fallback
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        // Fallback: try to save directly to device storage
        try {
          print("🔥 [VehicleReport] Trying fallback save method...");

          // Try multiple directory options
          Directory? directory;
          try {
            directory = await getExternalStorageDirectory();
            print(
              "🔥 [VehicleReport] Got external storage: ${directory?.path}",
            );
          } catch (e) {
            print("🔥 [VehicleReport] External storage failed: $e");
            directory = await getApplicationDocumentsDirectory();
            print("🔥 [VehicleReport] Using app documents: ${directory.path}");
          }

          if (directory != null) {
            final String filePath = '${directory.path}/$fileName';
            final File file = File(filePath);
            await file.writeAsBytes(pdfBytes);

            print("🔥 [VehicleReport] PDF saved to: $filePath");

            // Close loading dialog if open
            if (Get.isDialogOpen ?? false) {
              Get.back();
            }

            Get.snackbar(
              '📄 Invoice Saved Successfully!',
              'Professional receipt saved to device: $fileName',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade800,
              duration: const Duration(seconds: 5),
              icon: const Icon(Icons.receipt_long, color: Colors.green),
              margin: EdgeInsets.all(16),
              borderRadius: 12,
            );
          } else {
            throw Exception('Cannot access device storage');
          }
        } catch (saveError) {
          print("🔥 [VehicleReport] Direct save also failed: $saveError");

          // Close loading dialog if open
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          // Show error message as final fallback
          Get.snackbar(
            '⚠️ Invoice Generation Issue',
            'Unable to save receipt automatically. Please check permissions and try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.warning_amber, color: Colors.orange),
            margin: EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      }

      print("🔥 [VehicleReport] PDF generation completed successfully!");
    } catch (e) {
      print(
        "🔥🔥🔥 [VehicleReport] ❌ CRITICAL ERROR in _generateAndSavePDF! 🔥🔥🔥",
      );
      print("🔥 [VehicleReport] Error type: ${e.runtimeType}");
      print("🔥 [VehicleReport] Error message: $e");
      print("🔥 [VehicleReport] Stack trace: ${StackTrace.current}");

      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
        print("🔥 [VehicleReport] Closed loading dialog after error");
      }

      // Show detailed error to user
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.bug_report, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('🚨 PDF Generation Error'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'An error occurred during PDF generation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error Type: ${e.runtimeType}',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Message: ${e.toString()}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Please try again or contact support if the problem persists.',
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Close')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Retry the operation
                _generateAndSavePDF(vehicleNo, rcData, challanList);
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  // Helper method to format date for professional invoice
  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  // Helper method to format time for professional invoice
  static String _formatTime(DateTime time) {
    String period = time.hour >= 12 ? 'PM' : 'AM';
    int hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  // Professional table rows for invoice-style RC data
  static List<pw.TableRow> _buildProfessionalRCDataRows(
    Map<String, dynamic> rcData,
  ) {
    List<pw.TableRow> rows = [];

    // Professional header row
    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.blue100),
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(
              'FIELD',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
                color: PdfColors.blue800,
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Text(
              'DETAILS',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
                color: PdfColors.blue800,
              ),
            ),
          ),
        ],
      ),
    );

    // Professional data rows with alternating colors
    int index = 0;
    rcData.entries.forEach((entry) {
      bool isEven = index % 2 == 0;
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isEven ? PdfColors.grey50 : PdfColors.white,
          ),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              child: pw.Text(
                _formatFieldName(entry.key),
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              child: pw.Text(
                '${entry.value ?? 'N/A'}',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
              ),
            ),
          ],
        ),
      );
      index++;
    });

    return rows;
  }
}
