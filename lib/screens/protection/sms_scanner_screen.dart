import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SMSScannerScreen extends StatefulWidget {
  const SMSScannerScreen({super.key});

  @override
  State<SMSScannerScreen> createState() => _SMSScannerScreenState();
}

class _SMSScannerScreenState extends State<SMSScannerScreen> {
  final _senderController = TextEditingController();
  final _messageController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _senderController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _scanSMS() async {
    if (_senderController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter sender and message')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await _apiService.scanSMS(
        _senderController.text.trim(),
        _messageController.text.trim(),
        'en',
      );
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Color _getThreatColor(String threatLevel) {
    switch (threatLevel.toLowerCase()) {
      case 'safe':
        return Colors.green;
      case 'low':
        return Colors.yellow;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sender input
            TextField(
              controller: _senderController,
              decoration: InputDecoration(
                labelText: 'Sender',
                hintText: '+1234567890 or Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Message input
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Enter the SMS message to scan',
                prefixIcon: const Icon(Icons.message),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Scan button
            ElevatedButton(
              onPressed: _isLoading ? null : _scanSMS,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Scan SMS',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 24),

            // Result card
            if (_result != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Threat level badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Threat Level',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getThreatColor(_result!['threatLevel'] ?? 'safe')
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (_result!['threatLevel'] ?? 'SAFE').toString().toUpperCase(),
                              style: TextStyle(
                                color: _getThreatColor(_result!['threatLevel'] ?? 'safe'),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Scam probability
                      if (_result!['scamProbability'] != null) ...[
                        const Text(
                          'Scam Probability',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: (_result!['scamProbability'] ?? 0) / 100,
                                minHeight: 12,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getThreatColor(_result!['threatLevel'] ?? 'safe'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_result!['scamProbability']}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Category
                      if (_result!['category'] != null) ...[
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result!['category'].toString(),
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Detected patterns
                      if (_result!['detectedPatterns'] != null &&
                          (_result!['detectedPatterns'] as List).isNotEmpty) ...[
                        const Text(
                          'Detected Patterns',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (_result!['detectedPatterns'] as List)
                              .map((pattern) => Chip(
                                    label: Text(pattern.toString()),
                                    backgroundColor: Colors.red[50],
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Recommendation
                      if (_result!['recommendation'] != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _result!['recommendation'].toString(),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
