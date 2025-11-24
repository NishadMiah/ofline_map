import 'package:flutter/material.dart';
import 'package:get/get.dart';
// CHANGE THIS IMPORT to match your project
import 'package:ofline_map/view/screens/pdf_to_text/controller/pdf_to_text_controller.dart';
import 'package:ofline_map/view/components/custom_text/custom_text.dart';

class StageDetails extends StatefulWidget {
  const StageDetails({super.key});

  @override
  State<StageDetails> createState() => _StageDetailsState();
}

class _StageDetailsState extends State<StageDetails> {
  // Get the controller instance
  final controller = Get.find<PdfToTextController>();

  // Get the arguments passed from the list (The Map: {stage:..., page:...})
  final Map<String, dynamic> args = Get.arguments;

  @override
  void initState() {
    super.initState();
    // Trigger loading the specific page when screen opens
    controller.loadStageDetail(args['page']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(args['stage'] ?? "Details")),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.selectedStageDetails;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              CustomText(
                text: args['route'] ?? "",
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 20),

              // --- STATS GRID ---
              _buildStatRow("Distance", data['distance'], Icons.straighten),
              _buildStatRow("Time", data['time'], Icons.access_time),
              _buildStatRow("Ascent", data['ascent'], Icons.arrow_upward),
              _buildStatRow("Descent", data['descent'], Icons.arrow_downward),

              const Divider(height: 40),

              // --- STOPS SECTION ---
              const CustomText(
                text: "Stops & Facilities",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  data['stops'] ?? "No info",
                  style: const TextStyle(height: 1.5, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatRow(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value ?? "--",
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
