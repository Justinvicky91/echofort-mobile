import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  static const String baseUrl = 'https://api.echofort.ai';
  static const String razorpayKeyId = 'rzp_live_RaVY92nlBc6XrE';
  
  late Razorpay _razorpay;
  
  /// Initialize Razorpay
  void initializeRazorpay({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Map<String, dynamic>) onError,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
      onSuccess(response as Map<String, dynamic>);
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
      onError(response as Map<String, dynamic>);
    });
  }
  
  /// Create Razorpay order
  Future<Map<String, dynamic>> createOrder({
    required int userId,
    required String planName,
    required double amount,
    required String billingPeriod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/billing/create-order'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'plan_name': planName,
          'amount': amount,
          'billing_period': billingPeriod,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }
  
  /// Open Razorpay checkout
  void openCheckout({
    required String orderId,
    required double amount,
    required String planName,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) {
    var options = {
      'key': razorpayKeyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'currency': 'INR',
      'name': 'EchoFort',
      'description': '$planName Plan',
      'order_id': orderId,
      'prefill': {
        'name': userName,
        'email': userEmail,
        'contact': userPhone,
      },
      'theme': {
        'color': '#1565C0',
      },
      'notes': {
        'plan_name': planName,
      },
    };
    
    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
    }
  }
  
  /// Verify payment on backend
  Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    required int userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/billing/verify-payment'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'payment_id': paymentId,
          'order_id': orderId,
          'signature': signature,
          'user_id': userId,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Payment verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error verifying payment: $e');
    }
  }
  
  /// Create subscription (₹1 auto-debit)
  Future<Map<String, dynamic>> createSubscription({
    required int userId,
    required String planName,
    required double amount,
    required String billingPeriod,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/billing/create-subscription'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'plan_name': planName,
          'amount': amount,
          'billing_period': billingPeriod,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create subscription: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating subscription: $e');
    }
  }
  
  /// Verify ₹1 auto-debit
  Future<Map<String, dynamic>> verifyAutoDebit({
    required int userId,
    required String subscriptionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/billing/verify-auto-debit'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'subscription_id': subscriptionId,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Auto-debit verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error verifying auto-debit: $e');
    }
  }
  
  /// Get subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/billing/subscription/status/$userId'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get subscription status');
      }
    } catch (e) {
      throw Exception('Error getting subscription status: $e');
    }
  }
  
  /// Dispose Razorpay
  void dispose() {
    // Uncomment after adding razorpay_flutter package
    // _razorpay.clear();
  }
}
