import 'package:http/http.dart' as http;
import 'dart:convert';

class RealBankPaymentService {
  static const String _momoApiUrl = 'https://payment.momo.vn/v2/gateway/api';
  static const String _vnpayApiUrl =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String _zalopayApiUrl =
      'https://openapi.zalopay.vn/v001/tpe/createorder';

  static Future<String> createMoMoPayment({
    required double amount,
    required String orderId,
    required String orderInfo,
  }) async {
    final requestData = {
      'partnerCode': 'PARTNER_CODE',
      'accessKey': 'ACCESS_KEY',
      'requestId': orderId,
      'amount': amount.toInt().toString(),
      'orderId': orderId,
      'orderInfo': orderInfo,
      'returnUrl': 'https://your-app.com/return',
      'notifyUrl': 'https://your-app.com/notify',
      'requestType': 'captureWallet',
      'signature': _generateMoMoSignature(),
    };

    try {
      final response = await http.post(
        Uri.parse('$_momoApiUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payUrl'];
      }
    } catch (e) {
      print('MoMo Payment Error: $e');
    }

    throw Exception('Không thể tạo thanh toán MoMo');
  }

  static String createVNPayPayment({
    required double amount,
    required String orderId,
    required String orderInfo,
  }) {
    final params = {
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': 'TMN_CODE',
      'vnp_Amount': (amount * 100).toInt().toString(),
      'vnp_CurrCode': 'VND',
      'vnp_TxnRef': orderId,
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': 'other',
      'vnp_Locale': 'vn',
      'vnp_ReturnUrl': 'https://your-app.com/vnpay-return',
      'vnp_CreateDate': DateTime.now()
          .toIso8601String()
          .replaceAll(RegExp(r'[^\d]'), '')
          .substring(0, 14),
      'vnp_IpAddr': '127.0.0.1',
    };

    final signature = _generateVNPaySignature(params);
    params['vnp_SecureHash'] = signature;

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$_vnpayApiUrl?$query';
  }

  static Future<String> createZaloPayPayment({
    required double amount,
    required String orderId,
    required String description,
  }) async {
    final requestData = {
      'app_id': 'APP_ID',
      'app_trans_id': orderId,
      'app_user': 'user123',
      'amount': amount.toInt(),
      'description': description,
      'bank_code': '',
      'item': '[]',
      'embed_data': '{}',
      'callback_url': 'https://your-app.com/zalopay-callback',
      'mac': _generateZaloPaySignature(),
    };

    try {
      final response = await http.post(
        Uri.parse(_zalopayApiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestData.entries.map((e) => '${e.key}=${e.value}').join('&'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['return_code'] == 1) {
          return data['order_url'];
        }
      }
    } catch (e) {
      print('ZaloPay Payment Error: $e');
    }

    throw Exception('Không thể tạo thanh toán ZaloPay');
  }

  static String createInternetBankingPayment({
    required double amount,
    required String orderId,
    required String bankCode,
  }) {
    final params = {
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': 'TMN_CODE',
      'vnp_Amount': (amount * 100).toInt().toString(),
      'vnp_BankCode': bankCode,
      'vnp_CurrCode': 'VND',
      'vnp_TxnRef': orderId,
      'vnp_OrderInfo': 'Thanh toan don hang $orderId',
      'vnp_OrderType': 'other',
      'vnp_Locale': 'vn',
      'vnp_ReturnUrl': 'https://your-app.com/bank-return',
      'vnp_CreateDate': DateTime.now()
          .toIso8601String()
          .replaceAll(RegExp(r'[^\d]'), '')
          .substring(0, 14),
      'vnp_IpAddr': '127.0.0.1',
    };

    final signature = _generateVNPaySignature(params);
    params['vnp_SecureHash'] = signature;

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$_vnpayApiUrl?$query';
  }

  static String _generateMoMoSignature() {
    return 'GENERATED_SIGNATURE';
  }

  static String _generateVNPaySignature(Map<String, String> params) {
    return 'GENERATED_SIGNATURE';
  }

  static String _generateZaloPaySignature() {
    return 'GENERATED_SIGNATURE';
  }

  static Future<bool> verifyPaymentResult({
    required String paymentMethod,
    required Map<String, String> params,
  }) async {
    switch (paymentMethod) {
      case 'momo':
        return _verifyMoMoResult(params);
      case 'vnpay':
        return _verifyVNPayResult(params);
      case 'zalopay':
        return _verifyZaloPayResult(params);
      default:
        return false;
    }
  }

  static bool _verifyMoMoResult(Map<String, String> params) {
    return true;
  }

  static bool _verifyVNPayResult(Map<String, String> params) {
    return true;
  }

  static bool _verifyZaloPayResult(Map<String, String> params) {
    return true;
  }
}
