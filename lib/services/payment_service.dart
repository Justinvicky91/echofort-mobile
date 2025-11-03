import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

class PaymentService {
  late Razorpay _razorpay;
  final ApiService _apiService = ApiService();
  
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onError;
  
  void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  void dispose() {
    _razorpay.clear();
  }
  
  Future<void> startPayment({
    required String planId,
    required String planName,
    required int amount,
    required String userEmail,
    required String userName,
    required String userPhone,
  }) async {
    try {
      // Create order on backend
      final orderResponse = await _apiService.post(
        '/api/payment/create-order',
        {'amount': amount * 100}, // Convert to paise
      );
      
      var options = {
        'key': 'YOUR_RAZORPAY_KEY_ID', // TODO: Get from backend
        'amount': amount * 100, // Amount in paise
        'currency': 'INR',
        'name': 'EchoFort',
        'description': '$planName Plan - 24-Hour Money-Back Guarantee',
        'order_id': orderResponse['orderId'],
        'prefill': {
          'contact': userPhone,
          'email': userEmail,
          'name': userName,
        },
        'notes': {
          'plan': planId,
          'plan_name': planName,
        },
        'theme': {
          'color': '#2196F3',
        },
      };
      
      _razorpay.open(options);
    } catch (e) {
      print('Error starting payment: $e');
      if (onError != null) {
        onError!(PaymentFailureResponse(
          1,
          'Failed to initiate payment: $e',
          null,
        ));
      }
    }
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Verify payment on backend
      final verifyResponse = await _apiService.post(
        '/api/payment/verify',
        {
          'razorpay_payment_id': response.paymentId,
          'razorpay_order_id': response.orderId,
          'razorpay_signature': response.signature,
        },
      );
      
      if (verifyResponse['success'] == true) {
        if (onSuccess != null) {
          onSuccess!(response);
        }
      } else {
        if (onError != null) {
          onError!(PaymentFailureResponse(
            2,
            'Payment verification failed',
            null,
          ));
        }
      }
    } catch (e) {
      print('Error verifying payment: $e');
      if (onError != null) {
        onError!(PaymentFailureResponse(
          3,
          'Payment verification error: $e',
          null,
        ));
      }
    }
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    if (onError != null) {
      onError!(response);
    }
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet selected: ${response.walletName}');
  }
}
