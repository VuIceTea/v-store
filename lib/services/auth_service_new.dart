import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/services.dart';
import 'package:v_store/services/user_service.dart';
import 'package:v_store/models/user.dart';

class AuthService {
  static final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static firebase_auth.User? get currentUser => _auth.currentUser;

  static Stream<firebase_auth.User?> get authStateChanges =>
      _auth.authStateChanges();

  static Future<UserProfile?> get currentUserProfile async {
    final user = currentUser;
    if (user == null) return null;
    return await UserService.getUserProfile(user.uid);
  }

  static Future<UserProfile?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        final userProfile = await UserService.createOrUpdateUser(
          userCredential.user!,
          loginProvider: 'email',
        );
        return userProfile;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  static Future<UserProfile?> registerWithEmailPassword(
    String email,
    String password, {
    String? displayName,
    String? phoneNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (displayName != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
      }

      if (userCredential.user != null) {
        final userProfile = await UserService.createOrUpdateUser(
          userCredential.user!,
          loginProvider: 'email',
          additionalData: {'phoneNumber': phoneNumber, ...?additionalData},
        );
        return userProfile;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  static Future<UserProfile?> signInWithGoogle() async {
    try {
      final bool isAvailable = await _googleSignIn.isSignedIn();
      print('Google Sign-In plugin is available: $isAvailable');

      await _googleSignIn.signOut();

      print('Starting Google Sign-In flow...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign-in cancelled by user');
        throw 'Google sign-in was cancelled by user';
      }

      print('Google user signed in: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Failed to obtain Google authentication tokens');
        throw 'Failed to obtain Google authentication tokens';
      }

      print('Got Google auth tokens, creating Firebase credential...');

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase with Google credential...');
      firebase_auth.UserCredential userCredential = await _auth
          .signInWithCredential(credential);

      print(
        'Successfully signed in to Firebase: ${userCredential.user?.email}',
      );

      if (userCredential.user != null) {
        final userProfile = await UserService.createOrUpdateUser(
          userCredential.user!,
          loginProvider: 'google',
        );
        return userProfile;
      }
      return null;
    } on PlatformException catch (e) {
      print('PlatformException during Google Sign-In: ${e.message}');
      if (e.code == 'google_sign_in_unknown_error') {
        throw 'Lỗi Google Sign-In không xác định. Vui lòng thử lại sau.';
      } else if (e.code == 'google_sign_in_canceled') {
        throw 'Google Sign-In đã bị hủy';
      } else {
        throw 'Lỗi Google Sign-In: ${e.message}';
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _getAuthError(e);
    } catch (e) {
      print('General error during Google Sign-In: $e');
      throw 'Lỗi không xác định khi đăng nhập với Google: $e';
    }
  }

  static Future<UserProfile?> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        final firebase_auth.OAuthCredential facebookAuthCredential =
            firebase_auth.FacebookAuthProvider.credential(
              loginResult.accessToken!.token,
            );

        firebase_auth.UserCredential userCredential = await _auth
            .signInWithCredential(facebookAuthCredential);

        if (userCredential.user != null) {
          final userProfile = await UserService.createOrUpdateUser(
            userCredential.user!,
            loginProvider: 'facebook',
          );
          return userProfile;
        }
        return null;
      } else {
        print('Facebook login failed: ${loginResult.status}');
        throw 'Facebook login failed: ${loginResult.message}';
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _getAuthError(e);
    } catch (e) {
      print('General error during Facebook Sign-In: $e');
      throw 'Lỗi không xác định khi đăng nhập với Facebook: $e';
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      throw 'Lỗi khi đăng xuất: $e';
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to: $email');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  static Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw 'Người dùng chưa đăng nhập';

      await user.updatePassword(newPassword);
      print('✅ Password updated successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  static Future<void> updateEmail(String newEmail) async {
    try {
      final user = currentUser;
      if (user == null) throw 'Người dùng chưa đăng nhập';

      await user.updateEmail(newEmail);

      await UserService.updateUserProfile(user.uid, {
        'email': newEmail,
        'isEmailVerified': false,
      });

      print('✅ Email updated successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  static Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) throw 'Người dùng chưa đăng nhập';

      await user.sendEmailVerification();
      print('✅ Email verification sent');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  static Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw 'Người dùng chưa đăng nhập';

      await UserService.deleteUser(user.uid);

      await user.delete();

      print('✅ Account deleted successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  static bool needsReauthentication(firebase_auth.FirebaseAuthException e) {
    return e.code == 'requires-recent-login';
  }

  static Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) throw 'Người dùng chưa đăng nhập';

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ Re-authentication successful');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  static String _getAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng cho tài khoản khác.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này không được phép.';
      case 'requires-recent-login':
        return 'Bạn cần đăng nhập lại để thực hiện thao tác này.';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ.';
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với phương thức đăng nhập khác.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
      default:
        return 'Lỗi xác thực: ${e.message}';
    }
  }
}
