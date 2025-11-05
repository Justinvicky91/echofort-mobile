import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class URLCheckerScreen extends StatefulWidget {
  const URLCheckerScreen({Key? key}) : super(key: key);
  @override
  State<URLCheckerScreen> createState() => _URLCheckerScreenState();
}

class _URLCheckerScreenState extends State<URLCheckerScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isChecking = false;
  Map<String, dynamic>? _urlInfo;

  Future<void> _checkURL() async {
    if (_urlController.text.isEmpty) return;
    setState(() { _isChecking = true; _urlInfo = null; });
    try {
      final response = await ApiService.post('/api/mobile/url/check', {
        'url': _urlController.text,
      });
      setState(() { _urlInfo = response; _isChecking = false; });
    } catch (e) {
      setState(() { _isChecking = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('URL Checker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMD),
                child: Column(
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Enter URL',
                        hintText: 'https://example.com',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMD),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isChecking ? null : _checkURL,
                        icon: _isChecking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isChecking ? 'Checking...' : 'Check URL'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_urlInfo != null) ...[
              const SizedBox(height: AppTheme.spaceMD),
              Card(
                color: _urlInfo!['is_safe'] == true
                    ? AppTheme.success.withOpacity(0.1)
                    : AppTheme.error.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  child: Column(
                    children: [
                      Icon(
                        _urlInfo!['is_safe'] == true
                            ? Icons.check_circle
                            : Icons.dangerous,
                        size: 64,
                        color: _urlInfo!['is_safe'] == true
                            ? AppTheme.success
                            : AppTheme.error,
                      ),
                      const SizedBox(height: AppTheme.spaceMD),
                      Text(
                        _urlInfo!['is_safe'] == true ? 'Safe URL' : 'Dangerous URL',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_urlInfo!['threat_type'] != null) ...[
                        const SizedBox(height: AppTheme.spaceXS),
                        Text(
                          _urlInfo!['threat_type'],
                          style: Theme.of(context).textTheme.bodyMedium,
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

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
