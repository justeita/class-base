import 'package:flutter/material.dart';

class RulesView extends StatefulWidget {
  const RulesView({super.key});

  @override
  State<RulesView> createState() => _RulesViewState();
}

class _RulesViewState extends State<RulesView> {
  final List<Map<String, String>> _staff = List.generate(100, (index) {
    final roles = ['TEACHER', 'ADMIN', 'SECURITY', 'MAINTENANCE', 'LAB_TECH'];
    final depts = ['SCIENCE', 'MATH', 'LANG', 'ARTS', 'SPORTS', 'IT'];
    return {
      'id': 'ID-${(1000 + index).toString()}',
      'name': 'PERSONNEL_#${(index + 1).toString().padLeft(3, '0')}',
      'role': roles[index % roles.length],
      'dept': depts[index % depts.length],
    };
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF9900); // Orange

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('FACULTY_DATABASE', style: TextStyle(fontFamily: 'Courier', color: primaryColor, fontWeight: FontWeight.bold)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'COUNT: ${_staff.length}',
                style: TextStyle(
                  fontFamily: 'Courier',
                  color: primaryColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _staff.length,
        itemBuilder: (context, index) {
          final staff = _staff[index];
          return _buildStaffItem(staff, index, primaryColor);
        },
      ),
    );
  }

  Widget _buildStaffItem(Map<String, String> staff, int index, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index % 10 * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: color.withValues(alpha: 0.3)),
                  left: BorderSide(color: color, width: 2),
                ),
                color: Colors.white.withValues(alpha: 0.02),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Text(
                    staff['name']!.substring(11, 12),
                    style: TextStyle(
                      fontFamily: 'Courier',
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  staff['name']!,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        staff['role']!,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '[${staff['dept']}]',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  staff['id']!,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
