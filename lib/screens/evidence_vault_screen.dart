import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EvidenceVaultScreen extends StatelessWidget {
  const EvidenceVaultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add evidence
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        children: [
          _buildEvidenceCard(
            context,
            'Scam Call Recording',
            'Audio',
            '2.3 MB',
            '2 days ago',
            Icons.mic,
            Colors.blue,
          ),
          _buildEvidenceCard(
            context,
            'Phishing SMS Screenshot',
            'Image',
            '1.1 MB',
            '5 days ago',
            Icons.image,
            Colors.green,
          ),
          _buildEvidenceCard(
            context,
            'Fake Website URL',
            'Link',
            '0.1 KB',
            '1 week ago',
            Icons.link,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(
    BuildContext context,
    String title,
    String type,
    String size,
    String date,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text('\$type • \$size'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
        onTap: () {
          // View evidence
        },
      ),
    );
  }
}
