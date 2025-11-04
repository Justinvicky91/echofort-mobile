import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class GPSTrackingScreen extends StatefulWidget {
  const GPSTrackingScreen({super.key});

  @override
  State<GPSTrackingScreen> createState() => _GPSTrackingScreenState();
}

class _GPSTrackingScreenState extends State<GPSTrackingScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _familyMembers = [];
  bool _isTrackingEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getFamilyMembers();
      
      if (response['members'] != null) {
        // Get location for each family member
        List<dynamic> membersWithLocation = [];
        for (var member in response['members']) {
          try {
            final locationResponse = await _apiService.getFamilyMemberLocation(member['user_id']);
            membersWithLocation.add({
              'id': member['user_id'],
              'name': member['name'] ?? 'Unknown',
              'phone': member['identity'] ?? '',
              'role': member['role'] ?? 'member',
              'location': locationResponse['location'],
              'lastUpdate': locationResponse['last_update'] ?? 'Unknown',
              'battery': locationResponse['battery'] ?? 0,
            });
          } catch (e) {
            // If location fetch fails, add member without location
            membersWithLocation.add({
              'id': member['user_id'],
              'name': member['name'] ?? 'Unknown',
              'phone': member['identity'] ?? '',
              'role': member['role'] ?? 'member',
              'location': null,
              'lastUpdate': 'No location data',
              'battery': 0,
            });
          }
        }
        
        setState(() {
          _familyMembers = membersWithLocation;
          _isLoading = false;
        });
      } else {
        setState(() {
          _familyMembers = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading family members: $e');
      setState(() {
        _familyMembers = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Tracking'),
        actions: [
          Switch(
            value: _isTrackingEnabled,
            onChanged: (value) {
              setState(() => _isTrackingEnabled = value);
              // TODO: Call API to enable/disable tracking
            },
            activeColor: Colors.white,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFamilyMembers,
              child: _familyMembers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _familyMembers.length,
                      itemBuilder: (context, index) {
                        final member = _familyMembers[index];
                        return _buildMemberCard(member);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add family member
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Family Members Added',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add family members to track their location',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to add family member
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Add Family Member'),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to member details with map
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      member['name'].substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          member['phone'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.place, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            member['location']['address'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              member['lastUpdate'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.battery_full,
                              size: 16,
                              color: member['battery'] > 20 ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${member['battery']}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Call member
                      },
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Show on map
                      },
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('View Map'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
