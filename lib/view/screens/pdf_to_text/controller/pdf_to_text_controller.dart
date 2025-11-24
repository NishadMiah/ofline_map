import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfToTextController extends GetxController {
  final pdfAssetPath =
      'assets/pdf/Litoral-Way-Portuguese-Camino-walking-stages.pdf';

  final stage = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    extractStagesDynamically();
  }

  Future<void> extractStagesDynamically() async {
    try {
      isLoading.value = true;
      stage.clear();

      // 1. Load PDF
      final ByteData data = await rootBundle.load(pdfAssetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // 2. Extract Text from Page 1 (Index 0)
      String rawText = PdfTextExtractor(
        document,
      ).extractText(startPageIndex: 0, endPageIndex: 0);
      document.dispose();

      // 3. Parse with Robust Logic
      _parseStages(rawText);
    } catch (e) {
      print("Error reading PDF: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _parseStages(String text) {
    String cleanText = text.replaceAll('\n', ' ').replaceAll('\r', ' ');

    final RegExp regex = RegExp(
      r"(Stage\s*\d+)\.\s*(.+?),\s*(\d.*?mi)\s*(\d+)",
    );

    // Step 3: Find ALL matches in the stream of text
    final matches = regex.allMatches(cleanText);

    if (matches.isEmpty) {
      print("DEBUG: No matches found. Raw text dump:\n$cleanText");
    }

    for (var match in matches) {
      stage.add({
        "stage": match.group(1)?.trim() ?? "", // e.g. "Stage 1"
        "route": match.group(2)?.trim() ?? "", // e.g. "Se Cathedral..."
        "distance": match.group(3)?.trim() ?? "", // e.g. "26 km/16 mi"
        "page": match.group(4)?.trim() ?? "", // e.g. "2"
      });
    }
  }

  //============= details ===================
  // Add this inside your PdfToTextController class

  // Holds the details for the currently selected stage
  final selectedStageDetails = <String, String>{}.obs;
  final isDetailLoading = false.obs;

  Future<void> loadStageDetail(String pageNumberStr) async {
    try {
      isDetailLoading.value = true;
      selectedStageDetails.clear();

      // 1. Convert page string to index (PDF pages start at 1, Index starts at 0)
      // Note: The TOC says "2" for Stage 1. This usually corresponds to Index 1.
      int pageIndex = int.parse(pageNumberStr) - 1;

      // 2. Load PDF
      final ByteData data = await rootBundle.load(pdfAssetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // 3. Extract text ONLY from that specific page
      String pageText = PdfTextExtractor(
        document,
      ).extractText(startPageIndex: pageIndex, endPageIndex: pageIndex);

      document.dispose();

      // 4. Parse the raw text into UI fields
      _parsePageText(pageText);
    } catch (e) {
      print("Error loading detail: $e");
      selectedStageDetails['error'] = "Could not load details.";
    } finally {
      isDetailLoading.value = false;
    }
  }

  void _parsePageText(String text) {
    // Clean up newlines for easier regex
    String cleanText = text.replaceAll('\r', ' ').replaceAll('\n', '   ');

    // --- REGEX HELPERS ---
    String? extract(String label) {
      // Looks for "Label - Value" pattern
      final RegExp regex = RegExp(
        '$label\\s*-\\s*(.*?)(?=\\s{3,}|•|\$)',
        caseSensitive: false,
      );
      return regex.firstMatch(cleanText)?.group(1)?.trim();
    }

    // 1. Extract Stats
    selectedStageDetails['distance'] = extract('Distance') ?? "N/A";
    selectedStageDetails['time'] = extract('Time') ?? "N/A";
    selectedStageDetails['ascent'] = extract('Ascent') ?? "N/A";
    selectedStageDetails['descent'] = extract('Descent') ?? "N/A";

    // 2. Extract Stops / Table
    // The Syncfusion extractor often marks tables with "The following table:"
    // We try to grab everything after "Stops along the route"
    final RegExp stopsRegex = RegExp(
      r"Stops along the route.*?(The following table:.*)",
      caseSensitive: false,
    );
    final match = stopsRegex.firstMatch(cleanText);

    if (match != null) {
      // Clean up the table text to make it readable
      String rawTable = match.group(1)!;
      // Remove regex artifacts like quotes or brackets if present
      selectedStageDetails['stops'] = rawTable
          .replaceAll('","', ' | ')
          .replaceAll('"', '')
          .replaceAll('   ', '\n');
    } else {
      selectedStageDetails['stops'] = "No specific stops listed on this page.";
    }
  }
}
