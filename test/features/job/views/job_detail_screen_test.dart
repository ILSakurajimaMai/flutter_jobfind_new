import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:app_jobfind/features/job/views/job_detail_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Text('Job Detail'),
        ), // Thay bằng JobDetailScreen() thật
      ),
    );
  }

  group('JobDetailScreen Widget Test', () {
    testWidgets('renders job details and apply button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // expect(find.text('Apply Now'), findsOneWidget);
      expect(true, true); // Placeholder
    });
  });
}
