import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v_store/models/customer.dart';
import 'package:v_store/services/email_service.dart';

class RegistrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> isEmailExist(String email) async {
    try {
      print('🔍 Checking if email exists: $email');

      final normalizedEmail = email.toLowerCase().trim();
      print('📧 Normalized email: $normalizedEmail');

      print('🔍 Checking in users collection...');
      final usersQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      print('🔍 Checking in customers collection...');
      final customersQuery = await _firestore
          .collection('customers')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      final usersCount = usersQuery.docs.length;
      final customersCount = customersQuery.docs.length;

      print('📊 Users collection: $usersCount documents found');
      print('📊 Customers collection: $customersCount documents found');

      final exists = usersCount > 0 || customersCount > 0;

      if (exists) {
        print('❌ Email already exists in Firestore');
        if (usersCount > 0) {
          for (var doc in usersQuery.docs) {
            final data = doc.data();
            print(
              '👤 Existing user: ${data['displayName'] ?? data['name'] ?? 'N/A'} (${data['email']})',
            );
            print('🆔 User document ID: ${doc.id}');
          }
        }
        if (customersCount > 0) {
          for (var doc in customersQuery.docs) {
            final data = doc.data();
            print(
              '👤 Existing customer: ${data['name'] ?? 'N/A'} (${data['email']})',
            );
            print('🆔 Customer document ID: ${doc.id}');
          }
        }
      } else {
        print('✅ Email not found in any collection - OK to register');
      }

      return exists;
    } catch (e) {
      print('💥 Error checking email existence: $e');
      throw Exception('Lỗi kiểm tra email: $e');
    }
  }

  static Future<String> createAccountAndSendOTP({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      print('🚀 Starting account creation process...');
      print('📧 Email: $email');
      print('👤 Name: $name');
      print('📱 Phone: $phone');

      print('1️⃣ Checking if email exists...');
      final emailExists = await isEmailExist(email);
      if (emailExists) {
        print('❌ Email already exists, throwing exception');
        throw Exception('Email đã được sử dụng cho tài khoản khác');
      }
      print('✅ Email available for registration');

      print('2️⃣ Generating OTP...');
      final otp = EmailService.generateOTP();
      print('🔢 Generated OTP: $otp');

      print('3️⃣ Saving to pending_registrations...');
      await _firestore.collection('pending_registrations').doc(email).set({
        'email': email.toLowerCase().trim(),
        'password': password,
        'name': name.trim(),
        'phone': phone.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'expiryAt': Timestamp.fromDate(
          DateTime.now().add(Duration(minutes: 10)),
        ),
        'isVerified': false,
      });
      print('✅ Pending registration saved');

      print('4️⃣ Saving OTP to Firestore...');
      await EmailService.saveOTPToFirestore(
        email: email.toLowerCase().trim(),
        otp: otp,
      );
      print('✅ OTP saved to Firestore');

      print('5️⃣ Sending OTP email...');
      try {
        await EmailService.sendOTPEmail(
          email: email.toLowerCase().trim(),
          otp: otp,
        );
        print('✅ Email OTP sent successfully');
      } catch (emailError) {
        print('⚠️ Email sending failed: $emailError');
        print('📱 Using console OTP as backup');

        print('🔔 IMPORTANT: Use the OTP shown above to verify your account');
      }

      return otp;
    } catch (e) {
      print('💥 Error in createAccountAndSendOTP: $e');
      throw Exception('Lỗi tạo tài khoản: $e');
    }
  }

  static Future<bool> verifyOTPAndCompleteRegistration({
    required String email,
    required String otp,
  }) async {
    try {
      print('🔄 Starting OTP verification and registration completion...');
      print('📧 Email: $email');
      print('🔢 OTP: $otp');

      print('1️⃣ Verifying OTP...');
      final isOTPValid = await EmailService.verifyOTP(
        email: email.toLowerCase().trim(),
        inputOTP: otp,
      );

      if (!isOTPValid) {
        print('❌ OTP verification failed');
        return false;
      }
      print('✅ OTP verified successfully');

      print('2️⃣ Getting pending registration data...');
      final pendingDoc = await _firestore
          .collection('pending_registrations')
          .doc(email.toLowerCase().trim())
          .get();

      if (!pendingDoc.exists) {
        print('❌ Pending registration not found');
        throw Exception('Không tìm thấy thông tin đăng ký');
      }

      final pendingData = pendingDoc.data()!;
      print('✅ Pending registration data found');
      print('👤 Name: ${pendingData['name']}');
      print('📱 Phone: ${pendingData['phone']}');

      print('3️⃣ Checking expiry time...');
      final expiryAt = pendingData['expiryAt'] as Timestamp;
      if (DateTime.now().isAfter(expiryAt.toDate())) {
        print('❌ Registration expired');
        throw Exception('Thông tin đăng ký đã hết hạn');
      }
      print('✅ Registration not expired');

      print('4️⃣ Creating Firebase Authentication account...');
      UserCredential userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: pendingData['email'],
          password: pendingData['password'],
        );
        print('✅ Firebase Auth account created successfully');
        print('🆔 Firebase Auth UID: ${userCredential.user!.uid}');
      } catch (authError) {
        print('❌ Firebase Auth creation failed: $authError');
        throw Exception('Lỗi tạo tài khoản Firebase Auth: $authError');
      }

      final userId = userCredential.user!.uid;
      print('🆔 Using Firebase Auth UID as userId: $userId');

      print('5️⃣ Creating Customer object...');
      final customer = Customer(
        userId: userId,
        username: pendingData['email'],
        password: '',
        email: pendingData['email'],
        name: pendingData['name'],
        phone: pendingData['phone'],
        address: [],
        orderHistory: [],
        listCreditCards: [],
      );
      print('✅ Customer object created');

      print('6️⃣ Saving customer to Firestore users collection...');
      final customerData = {
        ...customer.toJson(),
        'role': 'customer',
        'isEmailVerified': true,
        'isActive': true,
        'firebaseAuthUid': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      customerData.remove('password');

      print('📝 Customer data to save: $customerData');

      try {
        await _firestore.collection('users').doc(userId).set(customerData);
        print('✅ Customer saved to Firestore successfully!');
        print('🔗 Customer document path: users/$userId');
      } catch (firestoreError) {
        print('❌ Firestore save failed: $firestoreError');

        try {
          await userCredential.user!.delete();
          print('🗑️ Firebase Auth account deleted due to Firestore failure');
        } catch (deleteError) {
          print('⚠️ Failed to delete Auth account: $deleteError');
        }
        throw Exception('Lỗi lưu thông tin người dùng: $firestoreError');
      }

      try {
        await userCredential.user!.updateDisplayName(pendingData['name']);
        print('✅ Firebase Auth display name updated');
      } catch (e) {
        print('⚠️ Failed to update display name: $e');
      }

      await _auth.signOut();
      print('🚪 User signed out, ready for manual login');

      print('7️⃣ Cleaning up temporary data...');
      await _firestore
          .collection('pending_registrations')
          .doc(email.toLowerCase().trim())
          .delete();
      print('✅ Pending registration deleted');

      await _firestore
          .collection('otp_verification')
          .doc(email.toLowerCase().trim())
          .delete();
      print('✅ OTP verification data deleted');

      print('🎉 Registration completed successfully!');
      return true;
    } catch (e) {
      print('❌ Error in verifyOTPAndCompleteRegistration: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      throw Exception('Lỗi xác thực: $e');
    }
  }

  static Future<String> resendOTP(String email) async {
    try {
      final pendingDoc = await _firestore
          .collection('pending_registrations')
          .doc(email.toLowerCase().trim())
          .get();

      if (!pendingDoc.exists) {
        throw Exception('Không tìm thấy thông tin đăng ký');
      }

      final otp = EmailService.generateOTP();

      await EmailService.saveOTPToFirestore(
        email: email.toLowerCase().trim(),
        otp: otp,
      );

      await EmailService.sendOTPEmail(
        email: email.toLowerCase().trim(),
        otp: otp,
      );

      return otp;
    } catch (e) {
      throw Exception('Lỗi gửi lại OTP: $e');
    }
  }

  static Future<void> cleanupExpiredRegistrations() async {
    try {
      final querySnapshot = await _firestore
          .collection('pending_registrations')
          .where('expiryAt', isLessThan: Timestamp.now())
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Lỗi xóa đăng ký hết hạn: $e');
    }
  }

  static Future<void> debugDeleteCustomerByEmail(String email) async {
    try {
      print('🗑️ DEBUG: Deleting customer with email: $email');

      print('🗑️ Checking users collection...');
      final usersQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .get();

      print('🗑️ Checking customers collection...');
      final customersQuery = await _firestore
          .collection('customers')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .get();

      final batch = _firestore.batch();
      bool foundAny = false;

      if (usersQuery.docs.isNotEmpty) {
        foundAny = true;
        for (var doc in usersQuery.docs) {
          print('🗑️ Deleting user document: ${doc.id}');
          batch.delete(doc.reference);
        }
      }

      if (customersQuery.docs.isNotEmpty) {
        foundAny = true;
        for (var doc in customersQuery.docs) {
          print('🗑️ Deleting customer document: ${doc.id}');
          batch.delete(doc.reference);
        }
      }

      if (foundAny) {
        await batch.commit();
        print('✅ All documents deleted successfully');
      } else {
        print('ℹ️ No documents found with email: $email');
      }
    } catch (e) {
      print('💥 Error deleting customer: $e');
    }
  }

  static Future<void> debugDeleteUserCompletely(String email) async {
    try {
      print('🗑️ Debug: Deleting user completely for email: $email');

      await debugDeleteCustomerByEmail(email);

      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          await currentUser.delete();
          print('🗑️ Firebase Auth user deleted');
        } else {
          print(
            '⚠️ Cannot delete Auth user: not currently signed in as this user',
          );
        }
      } catch (authError) {
        print('⚠️ Auth deletion error: $authError');
      }

      print('✅ Complete deletion attempted');
    } catch (e) {
      print('💥 Error in complete deletion: $e');
    }
  }

  static Future<void> debugCleanupAllDataForEmail(String email) async {
    try {
      print('🧹 Complete cleanup for email: $email');
      final normalizedEmail = email.toLowerCase().trim();

      await debugDeleteCustomerByEmail(normalizedEmail);

      try {
        await _firestore
            .collection('pending_registrations')
            .doc(normalizedEmail)
            .delete();
        print('🗑️ Pending registration deleted');
      } catch (e) {
        print('ℹ️ No pending registration found');
      }

      try {
        await _firestore
            .collection('otp_verification')
            .doc(normalizedEmail)
            .delete();
        print('🗑️ OTP verification data deleted');
      } catch (e) {
        print('ℹ️ No OTP verification data found');
      }

      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email == normalizedEmail) {
        print('⚠️ Firebase Auth user is currently signed in');
        print('🔄 Signing out...');
        await _auth.signOut();
      }

      print('✅ Complete cleanup finished for: $normalizedEmail');
    } catch (e) {
      print('💥 Error in complete cleanup: $e');
    }
  }

  static Future<Map<String, dynamic>> debugCheckEmailExistence(
    String email,
  ) async {
    try {
      print('🔍 DEBUG: Detailed email existence check for: $email');
      final normalizedEmail = email.toLowerCase().trim();

      final result = <String, dynamic>{
        'email': normalizedEmail,
        'existsInUsers': false,
        'existsInCustomers': false,
        'existsInPending': false,
        'existsInOTP': false,
        'usersDocs': [],
        'customersDocs': [],
        'pendingDoc': null,
        'otpDoc': null,
      };

      final usersQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      if (usersQuery.docs.isNotEmpty) {
        result['existsInUsers'] = true;
        result['usersDocs'] = usersQuery.docs
            .map((doc) => {'id': doc.id, 'data': doc.data()})
            .toList();
      }

      final customersQuery = await _firestore
          .collection('customers')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      if (customersQuery.docs.isNotEmpty) {
        result['existsInCustomers'] = true;
        result['customersDocs'] = customersQuery.docs
            .map((doc) => {'id': doc.id, 'data': doc.data()})
            .toList();
      }

      final pendingDoc = await _firestore
          .collection('pending_registrations')
          .doc(normalizedEmail)
          .get();

      if (pendingDoc.exists) {
        result['existsInPending'] = true;
        result['pendingDoc'] = {'id': pendingDoc.id, 'data': pendingDoc.data()};
      }

      final otpDoc = await _firestore
          .collection('otp_verification')
          .doc(normalizedEmail)
          .get();

      if (otpDoc.exists) {
        result['existsInOTP'] = true;
        result['otpDoc'] = {'id': otpDoc.id, 'data': otpDoc.data()};
      }

      print('📊 DEBUG Results:');
      print(
        '  Users: ${result['existsInUsers']} (${result['usersDocs'].length} docs)',
      );
      print(
        '  Customers: ${result['existsInCustomers']} (${result['customersDocs'].length} docs)',
      );
      print('  Pending: ${result['existsInPending']}');
      print('  OTP: ${result['existsInOTP']}');

      return result;
    } catch (e) {
      print('💥 Error in debug email check: $e');
      return {'error': e.toString()};
    }
  }

  static Future<void> debugTestLogin(String email, String password) async {
    try {
      print('🔐 DEBUG: Testing login for: $email');
      print('🔑 Password: $password');

      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        print('✅ Firebase Auth login successful!');
        print('🆔 Logged in user UID: ${userCredential.user!.uid}');
        print('📧 Logged in user email: ${userCredential.user!.email}');
        print('👤 Display name: ${userCredential.user!.displayName}');
        print('✉️ Email verified: ${userCredential.user!.emailVerified}');

        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          print('✅ Firestore user document found');
          final userData = userDoc.data()!;
          print('👤 User data: ${userData['name']}');
          print('📱 Phone: ${userData['phone']}');
          print('🎭 Role: ${userData['role']}');
        } else {
          print('❌ Firestore user document NOT found');
        }

        await _auth.signOut();
        print('🚪 Signed out after test');
      } catch (authError) {
        print('❌ Firebase Auth login failed: $authError');

        if (authError.toString().contains('user-not-found')) {
          print('🔍 Error: User not found in Firebase Auth');
        } else if (authError.toString().contains('wrong-password')) {
          print('🔍 Error: Wrong password');
        } else if (authError.toString().contains('invalid-credential')) {
          print('🔍 Error: Invalid credentials');
        }
      }
    } catch (e) {
      print('💥 Debug login error: $e');
    }
  }
}
