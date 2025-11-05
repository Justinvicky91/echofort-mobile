import 'dart:convert';
import 'package:http/http.dart' as http;

class RefundService {
  static const String baseUrl = 'https://echofort-backend.up.railway.app';
  
  /// Request refund
  Future<Map<String, dynamic>> requestRefund({
    required int userId,
    required String paymentId,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/billing/refund/request'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'payment_id': paymentId,
          'reason': reason,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to request refund');
      }
    } catch (e) {
      throw Exception('Error requesting refund: $e');
    }
  }
  
  /// Get refund status
  Future<Map<String, dynamic>> getRefundStatus(int refundRequestId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/billing/refund/status/$refundRequestId'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get refund status');
      }
    } catch (e) {
      throw Exception('Error getting refund status: $e');
    }
  }
  
  /// Get user's refund requests
  Future<List<Map<String, dynamic>>> getUserRefunds(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/billing/refunds?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['refunds'] ?? []);
      } else {
        throw Exception('Failed to get refunds');
      }
    } catch (e) {
      throw Exception('Error getting refunds: $e');
    }
  }
  
  /// Check if payment is eligible for refund
  Future<Map<String, dynamic>> checkRefundEligibility({
    required int userId,
    required String paymentId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/billing/refund/eligibility?user_id=$userId&payment_id=$paymentId'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to check eligibility');
      }
    } catch (e) {
      throw Exception('Error checking eligibility: $e');
    }
  }
}
