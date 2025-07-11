import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:v_store/config/vnpay_config.dart';
import 'package:url_launcher/url_launcher.dart';

class VNPayService {
  static String generateTxnRef() {
    final now = DateTime.now();
    final random = Random().nextInt(999999);
    return '${now.millisecondsSinceEpoch}_$random';
  }

  static String createPaymentUrl({
    required double amount,
    required String orderInfo,
    required String orderId,
    String? bankCode,
  }) {
    final txnRef = generateTxnRef();
    final createDate = DateTime.now();
    final formattedDate =
        '${createDate.year}${createDate.month.toString().padLeft(2, '0')}${createDate.day.toString().padLeft(2, '0')}${createDate.hour.toString().padLeft(2, '0')}${createDate.minute.toString().padLeft(2, '0')}${createDate.second.toString().padLeft(2, '0')}';

    Map<String, String> vnpParams = {
      'vnp_Version': VNPayConfig.vnpVersion,
      'vnp_Command': VNPayConfig.vnpCommand,
      'vnp_TmnCode': VNPayConfig.vnpTmnCode,
      'vnp_Amount': (amount * 100).toInt().toString(),
      'vnp_CurrCode': VNPayConfig.vnpCurrCode,
      'vnp_TxnRef': txnRef,
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': 'other',
      'vnp_Locale': VNPayConfig.vnpLocale,
      'vnp_ReturnUrl': VNPayConfig.vnpReturnUrl,
      'vnp_IpnUrl': VNPayConfig.vnpIpnUrl,
      'vnp_CreateDate': formattedDate,
      'vnp_IpAddr': '127.0.0.1',
    };

    if (bankCode != null && bankCode.isNotEmpty) {
      vnpParams['vnp_BankCode'] = bankCode;
    }

    final sortedKeys = vnpParams.keys.toList()..sort();

    final queryString = sortedKeys
        .map((key) => '$key=${Uri.encodeComponent(vnpParams[key]!)}')
        .join('&');

    final secureHash = _createSecureHash(queryString);

    final paymentUrl =
        '${VNPayConfig.vnpUrl}?$queryString&vnp_SecureHash=$secureHash';

    return paymentUrl;
  }

  static String _createSecureHash(String data) {
    final key = utf8.encode(VNPayConfig.vnpHashSecret);
    final bytes = utf8.encode(data);
    final hmacSha512 = Hmac(sha512, key);
    final digest = hmacSha512.convert(bytes);
    return digest.toString().toUpperCase();
  }

  static Future<bool> launchPayment({
    required double amount,
    required String orderInfo,
    required String orderId,
    String? bankCode,
  }) async {
    try {
      final paymentUrl = createPaymentUrl(
        amount: amount,
        orderInfo: orderInfo,
        orderId: orderId,
        bankCode: bankCode,
      );

      print('🔗 VNPAY Payment URL: $paymentUrl');

      final uri = Uri.parse(paymentUrl);

      if (!uri.isAbsolute) {
        print('❌ Invalid URL: $paymentUrl');
        return false;
      }

      print('📱 Checking if can launch URL...');

      try {
        print('🚀 Trying external application mode...');
        final result = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (result) {
          print('✅ External application launch successful');
          return true;
        }
      } catch (e) {
        print('⚠️ External application mode failed: $e');
      }

      try {
        print('🚀 Trying platform default mode...');
        final result = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (result) {
          print('✅ Platform default launch successful');
          return true;
        }
      } catch (e) {
        print('⚠️ Platform default mode failed: $e');
      }

      try {
        print('🚀 Trying external non-browser mode...');
        final result = await launchUrl(
          uri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
        if (result) {
          print('✅ External non-browser launch successful');
          return true;
        }
      } catch (e) {
        print('⚠️ External non-browser mode failed: $e');
      }

      try {
        print('🚀 Trying in-app web view mode...');
        final result = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        if (result) {
          print('✅ In-app web view launch successful');
          return true;
        }
      } catch (e) {
        print('⚠️ In-app web view mode failed: $e');
      }

      print('❌ All launch modes failed');
      return false;
    } catch (e) {
      print('❌ Error launching VNPAY payment: $e');
      return false;
    }
  }

  static bool verifyReturnUrl(Map<String, String> params) {
    try {
      final vnpSecureHash = params['vnp_SecureHash'];
      if (vnpSecureHash == null) return false;

      final verifyParams = Map<String, String>.from(params);
      verifyParams.remove('vnp_SecureHash');
      verifyParams.remove('vnp_SecureHashType');

      final sortedKeys = verifyParams.keys.toList()..sort();

      final queryString = sortedKeys
          .map((key) => '$key=${Uri.encodeComponent(verifyParams[key]!)}')
          .join('&');

      final expectedHash = _createSecureHash(queryString);

      return vnpSecureHash.toUpperCase() == expectedHash;
    } catch (e) {
      print('Error verifying VNPAY return URL: $e');
      return false;
    }
  }

  static VNPayResult parsePaymentResult(Map<String, String> params) {
    final isSuccess = params['vnp_ResponseCode'] == '00';
    final transactionStatus = params['vnp_TransactionStatus'] ?? '';
    final amount = double.tryParse(params['vnp_Amount'] ?? '0') ?? 0;
    final actualAmount = amount / 100;

    return VNPayResult(
      isSuccess: isSuccess && transactionStatus == '00',
      responseCode: params['vnp_ResponseCode'] ?? '',
      transactionStatus: transactionStatus,
      txnRef: params['vnp_TxnRef'] ?? '',
      amount: actualAmount,
      orderInfo: params['vnp_OrderInfo'] ?? '',
      payDate: params['vnp_PayDate'] ?? '',
      transactionNo: params['vnp_TransactionNo'] ?? '',
      bankCode: params['vnp_BankCode'] ?? '',
      cardType: params['vnp_CardType'] ?? '',
    );
  }
}

class VNPayResult {
  final bool isSuccess;
  final String responseCode;
  final String transactionStatus;
  final String txnRef;
  final double amount;
  final String orderInfo;
  final String payDate;
  final String transactionNo;
  final String bankCode;
  final String cardType;

  VNPayResult({
    required this.isSuccess,
    required this.responseCode,
    required this.transactionStatus,
    required this.txnRef,
    required this.amount,
    required this.orderInfo,
    required this.payDate,
    required this.transactionNo,
    required this.bankCode,
    required this.cardType,
  });

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'responseCode': responseCode,
      'transactionStatus': transactionStatus,
      'txnRef': txnRef,
      'amount': amount,
      'orderInfo': orderInfo,
      'payDate': payDate,
      'transactionNo': transactionNo,
      'bankCode': bankCode,
      'cardType': cardType,
    };
  }
}
