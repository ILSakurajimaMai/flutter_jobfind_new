import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app_jobfind/features/cv/viewmodels/cv_provider.dart';

class UploadCvScreen extends ConsumerStatefulWidget {
  const UploadCvScreen({super.key});

  @override
  ConsumerState<UploadCvScreen> createState() => _UploadCvScreenState();
}

class _UploadCvScreenState extends ConsumerState<UploadCvScreen> {
  PlatformFile? _pickedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true, // Cần thiết cho Web (path luôn null trên trình duyệt)
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      // Kích thước < 10MB
      if (file.size > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kích thước file không được vượt quá 10MB.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
      setState(() {
        _pickedFile = file;
      });
    }
  }

  Future<void> _uploadCv() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn 1 tệp CV trước khi tải lên.'),
        ),
      );
      return;
    }

    final bytes = _pickedFile!.bytes;
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đọc file. Vui lòng thử chọn file khác.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final success = await ref
        .read(cvProvider.notifier)
        .uploadAndCreateCv(bytes, _pickedFile!.name);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tải CV lên thành công!'),
            backgroundColor: Color(0xFF0D9D58),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xảy ra lỗi khi tải CV lên.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvState = ref.watch(cvProvider);
    final isLoading = cvState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tải CV lên',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Lời kêu gọi
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: const BoxDecoration(color: Color(0xFFE8F5E9)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Upload CV để các cơ hội việc làm tự tìm đến bạn',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF14003E),
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Giảm đến 50% thời gian cần thiết để tìm được một công việc phù hợp',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.description,
                          color: Color(0xFF0D9D58),
                          size: 64,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Khung kéo thả Upload
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GestureDetector(
                      onTap: isLoading ? null : _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: _pickedFile != null
                              ? const Color(0xFFE8F5E9)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF0D9D58,
                            ).withValues(alpha: 0.5),
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _pickedFile == null
                            ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.cloud_upload,
                                      color: Color(0xFF0D9D58),
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Nhấn để tải lên',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF14003E),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Hỗ trợ định dạng .doc, .docx, pdf có kích thước dưới 5MB',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    color: Color(0xFF0D9D58),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _pickedFile!.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF14003E),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _pickedFile = null;
                                            });
                                          },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Huỷ chọn',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom button
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9D58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : _uploadCv,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Tải CV lên',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
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
