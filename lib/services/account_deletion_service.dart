import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v_store/services/registration_service.dart';
import 'package:v_store/services/auth_service.dart';

class AccountDeletionService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> deleteCurrentUserCompletely() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ No user currently signed in');
        return false;
      }

      final email = currentUser.email;
      final uid = currentUser.uid;

      print('🗑️ Starting complete deletion for:');
      print('   Email: $email');
      print('   UID: $uid');

      print('1️⃣ Deleting Firestore data...');
      if (email != null) {
        await RegistrationService.debugCleanupAllDataForEmail(email);
      }

      try {
        await _firestore.collection('users').doc(uid).delete();
        print('✅ User document deleted by UID');
      } catch (e) {
        print('⚠️ User document by UID not found: $e');
      }

      print('2️⃣ Deleting Firebase Auth account...');
      await currentUser.delete();
      print('✅ Firebase Auth account deleted');

      print('3️⃣ Force signing out and clearing cache...');
      await AuthService.forceSignOut();
      print('✅ Force signed out successfully');

      print('🎉 Account deleted completely!');
      return true;
    } catch (e) {
      print('💥 Error deleting account: $e');

      if (e.toString().contains('requires-recent-login')) {
        print('⚠️ Requires recent login. User needs to sign in again first.');
        return false;
      }

      throw Exception('Failed to delete account: $e');
    }
  }

  static Future<bool> deleteAccountByEmail(String email) async {
    try {
      print('🗑️ Deleting account by email: $email');

      await RegistrationService.debugCleanupAllDataForEmail(email);

      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email == email) {
        await currentUser.delete();
        await AuthService.signOut();
        print('✅ Firebase Auth account deleted');
      } else {
        print('⚠️ Cannot delete Firebase Auth (user not currently signed in)');
        print('💡 Please delete manually from Firebase Console');
      }

      return true;
    } catch (e) {
      print('💥 Error deleting account by email: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  static Future<Map<String, dynamic>> checkAccountDeletion(String email) async {
    try {
      print('🔍 Checking account deletion status for: $email');

      final result = {
        'email': email,
        'deletedFromFirestore': false,
        'deletedFromAuth': false,
        'canLogin': false,
        'message': '',
      };

      final firestoreCheck = await RegistrationService.debugCheckEmailExistence(
        email,
      );
      final existsInFirestore =
          firestoreCheck['existsInUsers'] == true ||
          firestoreCheck['existsInCustomers'] == true;

      result['deletedFromFirestore'] = !existsInFirestore;

      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: '123456',
        );

        if (userCredential.user != null) {
          result['canLogin'] = true;
          result['deletedFromAuth'] = false;

          await _auth.signOut();
        }
      } catch (e) {
        if (e.toString().contains('user-not-found')) {
          result['deletedFromAuth'] = true;
        } else if (e.toString().contains('wrong-password')) {
          result['deletedFromAuth'] = false;
          result['canLogin'] = false;
        }
      }

      final deletedFromFirestore = result['deletedFromFirestore'] as bool;
      final deletedFromAuth = result['deletedFromAuth'] as bool;

      if (deletedFromFirestore && deletedFromAuth) {
        result['message'] = '✅ Account completely deleted';
      } else if (!deletedFromFirestore && !deletedFromAuth) {
        result['message'] = '❌ Account still exists in both Firestore and Auth';
      } else if (!deletedFromFirestore) {
        result['message'] =
            '⚠️ Account deleted from Auth but still in Firestore';
      } else {
        result['message'] =
            '⚠️ Account deleted from Firestore but still in Auth';
      }

      print('📊 Deletion check result: ${result['message']}');
      return result;
    } catch (e) {
      print('💥 Error checking account deletion: $e');
      return {
        'email': email,
        'error': e.toString(),
        'message': '💥 Error checking deletion status',
      };
    }
  }

  static Future<void> forceSignOutAllSessions() async {
    try {
      await _auth.signOut();
      print('✅ Force signed out all sessions');
    } catch (e) {
      print('💥 Error force signing out: $e');
    }
  }
}
