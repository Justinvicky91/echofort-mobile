import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // Add family member
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        children: [
          _buildMemberCard(
            context,
            'John Doe',
            'Father',
            'Active',
            true,
            Colors.green,
          ),
          _buildMemberCard(
            context,
            'Jane Doe',
            'Mother',
            'Active',
            true,
            Colors.green,
          ),
          _buildMemberCard(
            context,
            'Jimmy Doe',
            'Son',
            'Offline',
            false,
            Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    String name,
    String relation,
    String status,
    bool isOnline,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSM),
      child: ListTile(
        leading: Stack(
          children: [
            const CircleAvatar(
              radius: 24,
              child: Icon(Icons.person, size: 28),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(name),
        subtitle: Text(relation),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
        onTap: () {
          // View member details
        },
      ),
    );
  }
}
