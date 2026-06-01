import 'package:flutter/material.dart';
import 'package:app_jobfind/features/cv/views/cv_edit_screen.dart';
import 'package:app_jobfind/features/cv/views/widgets/cv_template_impression.dart';
import 'package:app_jobfind/features/cv/views/widgets/cv_template_modern.dart';
import 'package:app_jobfind/features/cv/views/widgets/cv_template_basic.dart';
import 'package:app_jobfind/features/cv/models/cv_dummy_data.dart';

class CvTemplatesScreen extends StatelessWidget {
  const CvTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text(
          'Chọn mẫu CV',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTemplateCard(
            context,
            templateType: 'impression',
            label: 'Mẫu Ấn Tượng',
            templateWidget: CvTemplateImpression(cvData: defaultDummyCv),
          ),
          _buildTemplateCard(
            context,
            templateType: 'modern',
            label: 'Mẫu Hiện Đại',
            templateWidget: CvTemplateModern(cvData: defaultDummyCv),
          ),
          _buildTemplateCard(
            context,
            templateType: 'basic',
            label: 'Mẫu Cơ Bản',
            templateWidget: CvTemplateBasic(cvData: defaultDummyCv),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context, {
    required String templateType,
    required String label,
    required Widget templateWidget,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFF4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // CV Preview
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 424),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AbsorbPointer(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      child: templateWidget,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Action button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFE8ECEF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9D58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CvEditScreen(templateType: templateType),
                    ),
                  );
                },
                child: const Text(
                  'Dùng mẫu này',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
