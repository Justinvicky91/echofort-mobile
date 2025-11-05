import 'dart:convert';
import 'package:http/http.dart' as http;

class VerificationService {
  static const String baseUrl = 'https://echofort-backend.up.railway.app';
  
  /// Complete user verification (address + ID)
  Future<Map<String, dynamic>> completeVerification({
    required int userId,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String pincode,
    required String idType,
    required String idNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/verification/complete'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'address_line1': addressLine1,
          'address_line2': addressLine2,
          'city': city,
          'state': state,
          'pincode': pincode,
          'id_type': idType,
          'id_number': idNumber,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to complete verification: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error completing verification: $e');
    }
  }
  
  /// Get verification status
  Future<Map<String, dynamic>> getVerificationStatus(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/verification/status/$userId'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get verification status');
      }
    } catch (e) {
      throw Exception('Error getting verification status: $e');
    }
  }
  
  /// Update address only
  Future<Map<String, dynamic>> updateAddress({
    required int userId,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String pincode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/verification/address'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'address_line1': addressLine1,
          'address_line2': addressLine2,
          'city': city,
          'state': state,
          'pincode': pincode,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update address');
      }
    } catch (e) {
      throw Exception('Error updating address: $e');
    }
  }
  
  /// Update ID only
  Future<Map<String, dynamic>> updateID({
    required int userId,
    required String idType,
    required String idNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/verification/id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'id_type': idType,
          'id_number': idNumber,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update ID');
      }
    } catch (e) {
      throw Exception('Error updating ID: $e');
    }
  }
}
