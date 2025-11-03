import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RealtimeCallScreen extends StatefulWidget {
  final String phoneNumber;
  final String? callerName;

  const RealtimeCallScreen({
    super.key,
    required this.phoneNumber,
    this.callerName,
  });

  @override
  State<RealtimeCallScreen> createState() => _RealtimeCallScreenState();
}

class _RealtimeCallScreenState extends State<RealtimeCallScreen> {
  final ApiService _apiService = ApiService();
  String? _callId;
  List<Map<String, dynamic>> _transcriptions = [];
  bool _isCallActive = false;
  bool _isRecording = false;
  int _callDuration = 0;
  Timer? _durationTimer;
  Timer? _transcriptionPollTimer;
  Map<String, dynamic>? _scamAnalysis;

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _transcriptionPollTimer?.cancel();
    if (_isCallActive) {
      _endCall();
    }
    super.dispose();
  }

  Future<void> _startCall() async {
    try {
      final response = await _apiService.startRealtimeCall(
        widget.phoneNumber,
        widget.callerName ?? 'Unknown',
      );

      if (response['success'] == true) {
        setState(() {
          _callId = response['callId'];
          _isCallActive = true;
          _isRecording = response['recording'] ?? false;
        });

        // Start duration timer
        _durationTimer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) {
            if (mounted) {
              setState(() => _callDuration++);
            }
          },
        );

        // Start polling for transcriptions
        _transcriptionPollTimer = Timer.periodic(
          const Duration(seconds: 2),
          (timer) => _fetchTranscription(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start call monitoring: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchTranscription() async {
    if (_callId == null || !_isCallActive) return;

    try {
      final response = await _apiService.getRealtimeCallTranscription(_callId!);

      if (response['success'] == true) {
        setState(() {
          _transcriptions = List<Map<String, dynamic>>.from(
            response['transcriptions'] ?? [],
          );
          _scamAnalysis = response['scamAnalysis'];
        });
      }
    } catch (e) {
      // Silently fail for polling errors
      debugPrint('Transcription fetch error: $e');
    }
  }

  Future<void> _endCall() async {
    if (_callId == null) return;

    _durationTimer?.cancel();
    _transcriptionPollTimer?.cancel();

    try {
      await _apiService.endRealtimeCall(_callId!);
      setState(() => _isCallActive = false);
    } catch (e) {
      debugPrint('End call error: $e');
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getScamRiskColor(String? risk) {
    switch (risk?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Call Monitoring'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_isCallActive)
            IconButton(
              icon: const Icon(Icons.call_end),
              onPressed: () {
                _endCall();
                Navigator.of(context).pop();
              },
              tooltip: 'End Monitoring',
            ),
        ],
      ),
      body: Column(
        children: [
          // Call info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _scamAnalysis != null && _scamAnalysis!['riskLevel'] == 'high'
                      ? Colors.red[100]!
                      : Colors.blue[50]!,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _isCallActive ? Colors.green : Colors.grey,
                  child: Icon(
                    _isCallActive ? Icons.phone_in_talk : Icons.phone_disabled,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.callerName ?? 'Unknown Caller',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.phoneNumber,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatDuration(_callDuration),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                if (_isRecording) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record, size: 12, color: Colors.red[700]),
                        const SizedBox(width: 6),
                        Text(
                          'Recording',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Scam analysis warning
          if (_scamAnalysis != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _getScamRiskColor(_scamAnalysis!['riskLevel']),
              child: Row(
                children: [
                  Icon(
                    _scamAnalysis!['riskLevel'] == 'high'
                        ? Icons.warning
                        : Icons.info_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_scamAnalysis!['riskLevel']?.toUpperCase()} RISK',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (_scamAnalysis!['reason'] != null)
                          Text(
                            _scamAnalysis!['reason'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Transcription section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.transcribe, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Live Transcription',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_isCallActive)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _transcriptions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mic_none,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isCallActive
                                      ? 'Listening...'
                                      : 'No transcription available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _transcriptions.length,
                            itemBuilder: (context, index) {
                              final transcription = _transcriptions[index];
                              final speaker = transcription['speaker'] ?? 'Unknown';
                              final text = transcription['text'] ?? '';
                              final timestamp = transcription['timestamp'] ?? '';
                              final isScammer = speaker.toLowerCase() == 'caller';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: isScammer
                                          ? Colors.red[100]
                                          : Colors.blue[100],
                                      child: Icon(
                                        isScammer ? Icons.person : Icons.person_outline,
                                        size: 16,
                                        color: isScammer ? Colors.red : Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                speaker,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isScammer
                                                      ? Colors.red[700]
                                                      : Colors.blue[700],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                timestamp,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            text,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
