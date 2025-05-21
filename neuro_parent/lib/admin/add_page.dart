import 'package:flutter/material.dart';


class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add/Edit Content'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '# Add',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildClickableCard(
              context,
              title: 'Tips and Tricks',
              subtitle: 'Add tips and tricks',
              onTap: () => Navigator.pushNamed(context, '/articles/create_article'),
            ),
            SizedBox(height: 16),
            _buildClickableCard(
              context,
              title: '31 Event',
              subtitle: 'Add Event',
              onTap: () => Navigator.pushNamed(context, '/events/create_event'),
            ),
            SizedBox(height: 32),
            Text(
              '# Edit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildClickableCard(
              context,
              title: 'Tips and Tricks',
              subtitle: 'Edit my tips and tricks',
              onTap: () => Navigator.pushNamed(context, '/articles/edit_article'),
            ),
            SizedBox(height: 16),
            _buildClickableCard(
              context,
              title: '31 Event',
              subtitle: 'Edit my Event',
              onTap: () => Navigator.pushNamed(context, '/events/edit_event'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
        child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      );
  }
}