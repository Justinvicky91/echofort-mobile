import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService;
  late Razorpay _razorpay;
  
  // Razorpay configuration - will be fetched from backend
  String? _razorpayKeyId;
  
  PaymentService(this._apiService) {
    _razorpay = Razorpay();
  }

  /// Initialize Razorpay with key from backend config
  Future<void> initialize() async {
    try {
      // Fetch Razorpay key from backend environment
      // In production, this should come from backend API
      // For now, using environment variable or default test key
      _razorpayKeyId = const String.fromEnvironment(
        'RAZORPAY_KEY_ID',
        defaultValue: 'rzp_test_xxxxxx', // Will be replaced with actual key
      );
    } catch (e) {
      print('Failed to initialize payment service: $e');
      rethrow;
    }
  }

  /// Create Razorpay payment and handle subscription
  Future<Map<String, dynamic>> createPayment({
    required String planId,
    required int amount,
    required String userName,
    required String userEmail,
    required String userPhone,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // Ensure Razorpay is initialized
      if (_razorpayKeyId == null) {
        await initialize();
      }

      // Configure Razorpay options
      var options = {
        'key': _razorpayKeyId,
        'amount': amount * 100, // Convert to paise
        'currency': 'INR',
        'name': 'EchoFort',
        'description': 'Subscription - 24-Hour Money-Back Guarantee',
        'image': 'https://echofort.ai/logo.png',
        'prefill': {
          'name': userName,
          'email': userEmail,
          'contact': userPhone,
        },
        'theme': {
          'color': '#1E3A8A', // Navy blue - professional
        },
        'notes': {
          'plan_id': planId,
          'trial_period': '24 hours',
        },
      };

      // Set up payment handlers
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
        try {
          // Verify payment with backend and activate subscription
          final result = await _verifyAndActivateSubscription(
            planId: planId,
            paymentId: response.paymentId!,
            orderId: response.orderId,
            signature: response.signature,
          );
          
          onSuccess(result);
        } catch (e) {
          onError('Payment verification failed: $e');
        }
      });

      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
        onError('Payment failed: ${response.message}');
      });

      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
        onError('External wallet not supported');
      });

      // Open Razorpay checkout
      _razorpay.open(options);

      return {'status': 'initiated'};
    } catch (e) {
      print('Payment creation error: $e');
      onError('Failed to initiate payment: $e');
      rethrow;
    }
  }

  /// Verify payment and activate subscription on backend
  Future<Map<String, dynamic>> _verifyAndActivateSubscription({
    required String planId,
    required String paymentId,
    String? orderId,
    String? signature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/subscription/upgrade'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _apiService.getToken()}',
        },
        body: json.encode({
          'plan': planId,
          'payment_method': 'razorpay',
          'payment_id': paymentId,
          'auto_renew': true,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Subscription activated successfully',
          'data': data,
        };
      } else {
        throw Exception('Failed to activate subscription: ${response.body}');
      }
    } catch (e) {
      print('Subscription activation error: $e');
      rethrow;
    }
  }

  /// Get subscription plans from backend
  Future<Map<String, dynamic>> getSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/subscription/plans'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch subscription plans');
      }
    } catch (e) {
      print('Error fetching subscription plans: $e');
      rethrow;
    }
  }

  /// Get current subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/subscription/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _apiService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch subscription status');
      }
    } catch (e) {
      print('Error fetching subscription status: $e');
      rethrow;
    }
  }

  /// Cancel subscription
  Future<Map<String, dynamic>> cancelSubscription() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/subscription/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _apiService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to cancel subscription');
      }
    } catch (e) {
      print('Error cancelling subscription: $e');
      rethrow;
    }
  }

  /// Request refund (within 24-hour money-back guarantee)
  Future<Map<String, dynamic>> requestRefund({required String reason}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/refund/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _apiService.getToken()}',
        },
        body: json.encode({
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to request refund');
      }
    } catch (e) {
      print('Error requesting refund: $e');
      rethrow;
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
