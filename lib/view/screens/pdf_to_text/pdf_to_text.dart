import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofline_map/core/app_routes/app_routes.dart';
// CHANGE THIS IMPORT to match your actual project structure
import 'controller/pdf_to_text_controller.dart';

class PdfToText extends StatelessWidget {
  const PdfToText({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final controller = Get.put(PdfToTextController());

    return Scaffold(
      appBar: AppBar(title: const Text('Camino Stages')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Stages (Loaded from PDF):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Use Expanded to let the list take up remaining space
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.stage.isEmpty) {
                  return const Center(
                    child: Text("No stages found in the PDF."),
                  );
                }

                return ListView.separated(
                  itemCount: controller.stage.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    var item = controller.stage[index];
                    return ListTile(
                      onTap: () {
                        Get.toNamed(AppRoutes.stageDetails, arguments: item);
                      },
                      contentPadding: EdgeInsets.zero,
                      // Stage Number Badge
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          // Extract just the number "1" from "Stage 1" for the badge
                          item['stage'].toString().replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      title: Text(
                        item['route'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        item['distance'],
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.menu_book,
                            size: 16,
                            color: Colors.grey,
                          ),
                          Text(
                            "Pg ${item['page']}",
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
