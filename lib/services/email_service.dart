import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v_store/config/email_config.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<void> saveOTPToFirestore({
    required String email,
    required String otp,
    int expiryMinutes = 5,
  }) async {
    try {
      await _firestore.collection('otp_verification').doc(email).set({
        'otp': otp,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiryAt': Timestamp.fromDate(
          DateTime.now().add(Duration(minutes: expiryMinutes)),
        ),
        'isUsed': false,
      });
    } catch (e) {
      throw Exception('Lỗi lưu OTP: $e');
    }
  }

  static Future<bool> verifyOTP({
    required String email,
    required String inputOTP,
  }) async {
    try {
      final doc = await _firestore
          .collection('otp_verification')
          .doc(email)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final storedOTP = data['otp'] as String;
      final expiryAt = data['expiryAt'] as Timestamp;
      final isUsed = data['isUsed'] as bool? ?? false;

      if (isUsed) {
        return false;
      }

      if (DateTime.now().isAfter(expiryAt.toDate())) {
        return false;
      }

      if (storedOTP == inputOTP) {
        await _firestore.collection('otp_verification').doc(email).update({
          'isUsed': true,
        });
        return true;
      }

      return false;
    } catch (e) {
      throw Exception('Lỗi xác thực OTP: $e');
    }
  }

  static Future<void> sendOTPEmail({
    required String email,
    required String otp,
  }) async {
    try {
      print('=== SENDING OTP EMAIL ===');
      print('To: $email');
      print('OTP: $otp (for debugging)');
      print('========================');

      try {
        final smtpServer = SmtpServer(
          EmailConfig.smtpHost,
          port: EmailConfig.smtpPort,
          ssl: false,
          allowInsecure: true,
          username: EmailConfig.senderEmail,
          password: EmailConfig.senderPassword,
        );

        await _sendEmailWithServer(smtpServer, email, otp);
        print('Email OTP đã được gửi thành công (method 1) đến $email');
        return;
      } catch (e1) {
        print('Phương pháp 1 thất bại: $e1');

        try {
          final gmailServer = SmtpServer(
            'smtp.gmail.com',
            port: 587,
            ssl: false,
            allowInsecure: true,
            ignoreBadCertificate: true,
            username: EmailConfig.senderEmail,
            password: EmailConfig.senderPassword,
          );

          await _sendEmailWithServer(gmailServer, email, otp);
          print('Email OTP đã được gửi thành công (method 2) đến $email');
          return;
        } catch (e2) {
          print('Phương pháp 2 thất bại: $e2');
          throw Exception(
            'Không thể gửi email sau nhiều lần thử. Lỗi cuối: $e2',
          );
        }
      }
    } catch (e) {
      print('Chi tiết lỗi gửi email: $e');
      throw Exception('Lỗi gửi email: $e');
    }
  }

  static Future<void> _sendEmailWithServer(
    SmtpServer smtpServer,
    String email,
    String otp,
  ) async {
    final message = Message()
      ..from = Address(EmailConfig.senderEmail, EmailConfig.senderName)
      ..recipients.add(email)
      ..subject = 'Mã xác thực tài khoản V-Store'
      ..html =
          '''
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center;">
          <h1 style="color: white; margin: 0; font-size: 28px;">V-Store</h1>
        </div>
        
        <div style="padding: 30px; background-color: #f9f9f9;">
          <h2 style="color: #333; margin-bottom: 20px;">Xác thực tài khoản của bạn</h2>
          
          <p style="color: #666; font-size: 16px; line-height: 1.5;">
            Chúng tôi đã nhận được yêu cầu tạo tài khoản mới với địa chỉ email này.
          </p>
          
          <div style="background: white; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0;">
            <p style="color: #333; margin-bottom: 10px; font-size: 14px;">Mã xác thực của bạn là:</p>
            <h1 style="color: #667eea; font-size: 32px; letter-spacing: 8px; margin: 0; font-weight: bold;">$otp</h1>
          </div>
          
          <p style="color: #666; font-size: 14px;">
            • Mã này có hiệu lực trong 5 phút<br>
            • Không chia sẻ mã này với bất kỳ ai<br>
            • Nếu bạn không yêu cầu tạo tài khoản, hãy bỏ qua email này
          </p>
        </div>
        
        <div style="padding: 20px; text-align: center; background-color: #333; color: white;">
          <p style="margin: 0; font-size: 12px;">© 2025 V-Store. Tất cả quyền được bảo lưu.</p>
        </div>
      </div>
      ''';

    await send(message, smtpServer);
  }

  static Future<void> cleanupExpiredOTPs() async {
    try {
      final querySnapshot = await _firestore
          .collection('otp_verification')
          .where('expiryAt', isLessThan: Timestamp.now())
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Lỗi xóa OTP hết hạn: $e');
    }
  }

  static Future<void> fallbackOTPDisplay({
    required String email,
    required String otp,
  }) async {
    print('');
    print('╔══════════════════════════════════════════════╗');
    print('║               EMAIL FALLBACK                 ║');
    print('╠══════════════════════════════════════════════╣');
    print('║ Email service temporarily unavailable        ║');
    print('║ Your OTP code is displayed below:            ║');
    print('║                                              ║');
    print('║ 📧 Email: $email');
    print('║ 🔢 OTP Code: $otp');
    print('║ ⏰ Valid for: 5 minutes                      ║');
    print('║                                              ║');
    print('║ Please use this code to verify your account  ║');
    print('╚══════════════════════════════════════════════╝');
    print('');

    await saveOTPToFirestore(email: email, otp: otp);
  }
}
