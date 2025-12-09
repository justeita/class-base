import 'package:flutter/material.dart';

class SchoolView extends StatelessWidget {
  const SchoolView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFCCFF00)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('SCHOOL_INFO', style: TextStyle(fontFamily: 'Courier', color: Color(0xFFCCFF00), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image / Banner Placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: const Color(0xFFCCFF00).withValues(alpha: 0.1),
              child: Center(
                child: Icon(Icons.school, size: 80, color: const Color(0xFFCCFF00).withValues(alpha: 0.5)),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(child: _buildActionButton('INFORMASI', Icons.info_outline)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildActionButton('FOTO', Icons.photo_camera_outlined)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildActionButton('RATING', Icons.star_outline)),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // School Management Section
                  const Text(
                    'PENGURUS SEKOLAH',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCCFF00),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(height: 2, width: 100, color: const Color(0xFFCCFF00)),
                  const SizedBox(height: 24),
                  
                  _buildStaffCard('Dr. H. Kepala Sekolah, M.Pd', 'Kepala Sekolah', 'assets/headmaster.png'),
                  _buildStaffCard('Drs. Wakil Kurikulum', 'Waka Kurikulum', 'assets/staff1.png'),
                  _buildStaffCard('Siti Kesiswaan, S.Pd', 'Waka Kesiswaan', 'assets/staff2.png'),
                  _buildStaffCard('Budi Sarpras, S.T', 'Waka Sarpras', 'assets/staff3.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCFF00)),
        color: Colors.black,
      ),
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFCCFF00)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Courier',
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(String name, String role, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: const Color(0xFFCCFF00).withValues(alpha: 0.5), width: 4)),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.person, color: Colors.white54),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: const Color(0xFFCCFF00).withValues(alpha: 0.8),
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
