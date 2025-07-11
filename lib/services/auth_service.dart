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
        throw 'Lỗi platform: ${e.message}';
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _getAuthError(e);
    } catch (e) {
      print('General error during Google Sign-In: $e');

      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('google_sign_in')) {
        throw 'Google Sign-In chưa được cấu hình đúng cách. Vui lòng sử dụng Email/Password để đăng nhập.';
      }

      if (e.toString().contains('network_error')) {
        throw 'Lỗi mạng. Vui lòng kiểm tra kết nối internet.';
      } else if (e.toString().contains('sign_in_canceled')) {
        throw 'Google sign-in đã bị hủy';
      } else if (e.toString().contains('sign_in_failed')) {
        throw 'Google sign-in thất bại. Vui lòng thử lại.';
      }
      throw 'Lỗi Google sign-in: ${e.toString()}';
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

        final userCredential = await _auth.signInWithCredential(
          facebookAuthCredential,
        );

        if (userCredential.user != null) {
          final userProfile = await UserService.createOrUpdateUser(
            userCredential.user!,
            loginProvider: 'facebook',
          );
          return userProfile;
        }
        return null;
      } else {
        throw 'Facebook sign-in was cancelled';
      }
    } catch (e) {
      throw 'Facebook sign-in failed: ${e.toString()}';
    }
  }

  static Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
      FacebookAuth.instance.logOut(),
    ]);
  }

  static Future<void> forceSignOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _googleSignIn.disconnect(),
        FacebookAuth.instance.logOut(),
      ]);

      await _clearUserCache();

      print('Force sign out completed');
    } catch (e) {
      print('Error during force sign out: $e');

      try {
        await _auth.signOut();
      } catch (fallbackError) {
        print('Fallback sign out also failed: $fallbackError');
      }
    }
  }

  static Future<void> _clearUserCache() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.getIdToken(true);
      }
    } catch (e) {
      print('Error clearing user cache: $e');
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }

  static Future<void> updateUserProfileWithDefaultAvatar() async {
    final user = _auth.currentUser;
    if (user != null && user.photoURL == null) {
      try {
        if (user.displayName == null || user.displayName!.isEmpty) {
          String defaultName = user.email?.split('@').first ?? 'User';
          await user.updateDisplayName(defaultName);
        }
      } catch (e) {
        print('Error updating user profile: $e');
      }
    }
  }

  static Future<bool> checkAccountExists(String email) async {
    try {
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> validateCurrentSession() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.getIdToken(true);
      return true;
    } catch (e) {
      await forceSignOut();
      return false;
    }
  }

  static String _getAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different credential.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
