import 'package:flutter/material.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFF003C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('INCIDENT_REPORT', style: TextStyle(fontFamily: 'Courier', color: Color(0xFFFF003C), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REPORT_FORM',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF003C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ALL SUBMISSIONS ARE ENCRYPTED AND ANONYMOUS IF REQUESTED.',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            _buildField('SUBJECT', 'Enter incident subject...'),
            const SizedBox(height: 24),
            _buildField('DATE', 'YYYY-MM-DD'),
            const SizedBox(height: 24),
            _buildField('DESCRIPTION', 'Describe what happened...', maxLines: 5),
            const SizedBox(height: 24),
            _buildField('WITNESSES', 'Names of witnesses (optional)...'),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('REPORT SUBMITTED TO SECURE SERVER')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF003C),
                  foregroundColor: Colors.black,
                  shape: const BeveledRectangleBorder(),
                ),
                child: const Text(
                  'SUBMIT_REPORT',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Courier',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontFamily: 'Courier'),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF003C)),
            ),
          ),
        ),
      ],
    );
  }
}
