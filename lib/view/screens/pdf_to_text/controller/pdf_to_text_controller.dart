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

    String? extractSection(String header) {
      // Looks for "Header:" followed by content until the next header or end
      final RegExp regex = RegExp(
        '$header:\\s*(.*?)(?=\\s{3,}[A-Z][a-z]+:|Elevation Profile:|\$)',
        caseSensitive: false,
        dotAll: true,
      );
      return regex.firstMatch(cleanText)?.group(1)?.trim();
    }

    // 1. Extract Stats
    selectedStageDetails['distance'] = extract('Distance') ?? "N/A";
    selectedStageDetails['time'] = extract('Time') ?? "N/A";
    selectedStageDetails['ascent'] =
        extract('Accumulated ascent') ?? extract('Ascent') ?? "N/A";
    selectedStageDetails['descent'] =
        extract('Accumulated descent') ?? extract('Descent') ?? "N/A";

    // 2. Extract Sections
    // Walking Surface
    String? walkingSurface = extractSection('Walking Surface');
    if (walkingSurface != null) {
      // Clean up bullet points if they are just dashes or newlines
      walkingSurface = walkingSurface.replaceAll(RegExp(r'\s{3,}'), '\n');
    }
    selectedStageDetails['walking_surface'] = walkingSurface ?? "N/A";

    // Challenges
    String? challenges = extractSection('Challenges');
    if (challenges != null) {
      challenges = challenges.replaceAll(RegExp(r'\s{3,}'), '\n');
    }
    selectedStageDetails['challenges'] = challenges ?? "N/A";

    // Highlights
    String? highlights = extractSection('Highlights');
    if (highlights != null) {
      highlights = highlights.replaceAll(RegExp(r'\s{3,}'), '\n');
    }
    selectedStageDetails['highlights'] = highlights ?? "N/A";

    // 3. Elevation Profile (Placeholder as we can't extract image from text)
    selectedStageDetails['elevation_profile'] =
        "true"; // Flag to show placeholder
  }
}
