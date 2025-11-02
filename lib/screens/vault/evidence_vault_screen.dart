import 'package:flutter/material.dart';

class EvidenceVaultScreen extends StatefulWidget {
  const EvidenceVaultScreen({super.key});

  @override
  State<EvidenceVaultScreen> createState() => _EvidenceVaultScreenState();
}

class _EvidenceVaultScreenState extends State<EvidenceVaultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _callRecordings = [
    {
      'id': 1,
      'number': '+1234567890',
      'date': '2024-11-01 14:30',
      'duration': '5:23',
      'type': 'Scam',
      'size': '2.3 MB',
    },
    {
      'id': 2,
      'number': '+9876543210',
      'date': '2024-10-31 09:15',
      'duration': '3:45',
      'type': 'Suspicious',
      'size': '1.8 MB',
    },
  ];

  final List<Map<String, dynamic>> _screenshots = [
    {
      'id': 1,
      'title': 'Phishing Email',
      'date': '2024-11-01 10:20',
      'type': 'Email Scam',
      'size': '450 KB',
    },
    {
      'id': 2,
      'title': 'Fake Website',
      'date': '2024-10-30 16:45',
      'type': 'Website Scam',
      'size': '680 KB',
    },
  ];

  final List<Map<String, dynamic>> _messages = [
    {
      'id': 1,
      'sender': '+1234567890',
      'preview': 'Congratulations! You won $1000...',
      'date': '2024-11-01 12:00',
      'type': 'SMS Scam',
    },
    {
      'id': 2,
      'sender': 'unknown',
      'preview': 'Your account has been locked...',
      'date': '2024-10-31 18:30',
      'type': 'Phishing',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence Vault'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Calls'),
            Tab(text: 'Screenshots'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTab(),
          _buildCallsTab(),
          _buildScreenshotsTab(),
          _buildMessagesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEvidenceDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 24),
          const Text(
            'Recent Evidence',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._callRecordings.take(2).map((item) => _buildCallItem(item)),
          ..._screenshots.take(2).map((item) => _buildScreenshotItem(item)),
        ],
      ),
    );
  }

  Widget _buildCallsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _callRecordings.length,
      itemBuilder: (context, index) {
        return _buildCallItem(_callRecordings[index]);
      },
    );
  }

  Widget _buildScreenshotsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _screenshots.length,
      itemBuilder: (context, index) {
        return _buildScreenshotItem(_screenshots[index]);
      },
    );
  }

  Widget _buildMessagesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageItem(_messages[index]);
      },
    );
  }

  Widget _buildSummaryCard() {
    final totalItems = _callRecordings.length + _screenshots.length + _messages.length;
    final totalSize = 8.5; // MB

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Total Items', totalItems.toString(), Icons.folder),
                _buildStat('Storage Used', '${totalSize.toStringAsFixed(1)} MB', Icons.storage),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalSize / 100, // Assuming 100 MB limit
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${totalSize.toStringAsFixed(1)} MB of 100 MB used',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCallItem(Map<String, dynamic> item) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red[100],
          child: const Icon(Icons.call, color: Colors.red),
        ),
        title: Text(item['number']),
        subtitle: Text('${item['date']} • ${item['duration']}'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'play',
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Play'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotItem(Map<String, dynamic> item) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: const Icon(Icons.image, color: Colors.blue),
        ),
        title: Text(item['title']),
        subtitle: Text('${item['date']} • ${item['size']}'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> item) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: const Icon(Icons.message, color: Colors.orange),
        ),
        title: Text(item['sender']),
        subtitle: Text(
          item['preview'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEvidenceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Evidence'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Call Recording'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to add call recording
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Screenshot'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to add screenshot
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to add message
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to add document
              },
            ),
          ],
        ),
      ),
    );
  }
}
