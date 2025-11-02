import 'package:flutter/material.dart';

class ScreenTimeScreen extends StatefulWidget {
  const ScreenTimeScreen({super.key});

  @override
  State<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends State<ScreenTimeScreen> {
  bool _isEnabled = true;
  final Map<String, int> _dailyLimits = {
    'Social Media': 60,
    'Games': 30,
    'Entertainment': 90,
    'Education': 180,
  };

  final Map<String, int> _todayUsage = {
    'Social Media': 45,
    'Games': 25,
    'Entertainment': 60,
    'Education': 120,
  };

  @override
  Widget build(BuildContext context) {
    final totalLimit = _dailyLimits.values.reduce((a, b) => a + b);
    final totalUsage = _todayUsage.values.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Time'),
        actions: [
          Switch(
            value: _isEnabled,
            onChanged: (value) {
              setState(() => _isEnabled = value);
            },
            activeColor: Colors.white,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Today\'s Screen Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: totalUsage / totalLimit,
                              strokeWidth: 15,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                totalUsage > totalLimit * 0.9
                                    ? Colors.red
                                    : totalUsage > totalLimit * 0.7
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(totalUsage / 60).toStringAsFixed(1)}h',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'of ${(totalLimit / 60).toStringAsFixed(1)}h',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category breakdown
            const Text(
              'Usage by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ..._dailyLimits.keys.map((category) {
              final limit = _dailyLimits[category]!;
              final usage = _todayUsage[category]!;
              final percentage = (usage / limit * 100).round();

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$usage / $limit min',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: usage / limit,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                usage > limit
                                    ? Colors.red
                                    : percentage > 90
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: usage > limit
                                  ? Colors.red
                                  : percentage > 90
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _showEditLimitDialog(category, limit);
                            },
                            child: const Text('Edit Limit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Quick actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: View detailed report
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('View Report'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Set schedule
                    },
                    icon: const Icon(Icons.schedule),
                    label: const Text('Schedule'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLimitDialog(String category, int currentLimit) {
    final controller = TextEditingController(text: currentLimit.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $category Limit'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Daily Limit (minutes)',
            suffixText: 'min',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newLimit = int.tryParse(controller.text);
              if (newLimit != null && newLimit > 0) {
                setState(() {
                  _dailyLimits[category] = newLimit;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
