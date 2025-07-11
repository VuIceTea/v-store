import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:v_store/models/user.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _usersCollection = _firestore.collection(
    'users',
  );

  static Future<UserProfile> createOrUpdateUser(
    firebase_auth.User firebaseUser, {
    String loginProvider = 'email',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        final existingUser = UserProfile.fromFirestore(
          userDoc as DocumentSnapshot<Map<String, dynamic>>,
        );

        final updatedUser = existingUser.copyWith(
          displayName: firebaseUser.displayName?.isNotEmpty == true
              ? firebaseUser.displayName
              : existingUser.displayName,
          email: firebaseUser.email ?? existingUser.email,
          photoURL: firebaseUser.photoURL ?? existingUser.photoURL,
          isEmailVerified: firebaseUser.emailVerified,
          isPhoneVerified: firebaseUser.phoneNumber != null,
          loginProvider: loginProvider,
          updatedAt: DateTime.now(),
        );

        await _usersCollection
            .doc(firebaseUser.uid)
            .update(updatedUser.toFirestore());

        print('✅ Updated existing user: ${updatedUser.displayName}');
        return updatedUser;
      } else {
        final newUser = UserProfile.fromFirebaseUser(
          firebaseUser,
          loginProvider: loginProvider,
          phoneNumber: additionalData?['phoneNumber'],
          dateOfBirth: additionalData?['dateOfBirth'],
          gender: additionalData?['gender'],
          address: additionalData?['address'],
          city: additionalData?['city'],
          country: additionalData?['country'],
          preferences: additionalData?['preferences'],
        );

        await _usersCollection.doc(firebaseUser.uid).set(newUser.toFirestore());

        print('✅ Created new user: ${newUser.displayName}');
        return newUser;
      }
    } catch (e) {
      print('❌ Error creating/updating user: $e');
      throw Exception('Không thể tạo/cập nhật thông tin người dùng: $e');
    }
  }

  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (userDoc.exists) {
        return UserProfile.fromFirestore(
          userDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  static Future<UserProfile> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _usersCollection.doc(userId).update(updates);

      final updatedUser = await getUserProfile(userId);
      if (updatedUser == null) {
        throw Exception('Không thể lấy thông tin người dùng sau khi cập nhật');
      }

      print('✅ Updated user profile: ${updatedUser.displayName}');
      return updatedUser;
    } catch (e) {
      print('❌ Error updating user profile: $e');
      throw Exception('Không thể cập nhật thông tin người dùng: $e');
    }
  }

  static Future<UserProfile> updateDisplayName(
    String userId,
    String displayName,
  ) async {
    return await updateUserProfile(userId, {'displayName': displayName});
  }

  static Future<UserProfile> updatePhoneNumber(
    String userId,
    String phoneNumber,
  ) async {
    return await updateUserProfile(userId, {
      'phoneNumber': phoneNumber,
      'isPhoneVerified': false,
    });
  }

  static Future<UserProfile> updateDateOfBirth(
    String userId,
    DateTime dateOfBirth,
  ) async {
    return await updateUserProfile(userId, {
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
    });
  }

  static Future<UserProfile> updateGender(String userId, String gender) async {
    return await updateUserProfile(userId, {'gender': gender});
  }

  static Future<UserProfile> updateAddress(
    String userId, {
    String? address,
    String? city,
    String? country,
  }) async {
    final updates = <String, dynamic>{};
    if (address != null) updates['address'] = address;
    if (city != null) updates['city'] = city;
    if (country != null) updates['country'] = country;

    return await updateUserProfile(userId, updates);
  }

  static Future<UserProfile> updatePhotoURL(
    String userId,
    String photoURL,
  ) async {
    return await updateUserProfile(userId, {'photoURL': photoURL});
  }

  static Future<UserProfile> updatePreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    return await updateUserProfile(userId, {'preferences': preferences});
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      print('✅ Deleted user: $userId');
    } catch (e) {
      print('❌ Error deleting user: $e');
      throw Exception('Không thể xóa tài khoản người dùng: $e');
    }
  }

  static Future<List<UserProfile>> getAllUsers({
    int limit = 50,
    String? lastUserId,
  }) async {
    try {
      Query query = _usersCollection
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastUserId != null) {
        final lastDoc = await _usersCollection.doc(lastUserId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => UserProfile.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Error getting all users: $e');
      throw Exception('Không thể lấy danh sách người dùng: $e');
    }
  }

  static Future<List<UserProfile>> searchUsersByEmail(String email) async {
    try {
      final snapshot = await _usersCollection
          .where('email', isEqualTo: email)
          .get();

      return snapshot.docs
          .map(
            (doc) => UserProfile.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Error searching users by email: $e');
      throw Exception('Không thể tìm kiếm người dùng: $e');
    }
  }

  static Stream<UserProfile?> getUserProfileStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    });
  }

  static Future<bool> isEmailTaken(String email) async {
    try {
      final snapshot = await _usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking email: $e');
      return false;
    }
  }

  static Future<void> updateEmailVerificationStatus(
    String userId,
    bool isVerified,
  ) async {
    try {
      await _usersCollection.doc(userId).update({
        'isEmailVerified': isVerified,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('❌ Error updating email verification status: $e');
    }
  }

  static Future<void> updatePhoneVerificationStatus(
    String userId,
    bool isVerified,
  ) async {
    try {
      await _usersCollection.doc(userId).update({
        'isPhoneVerified': isVerified,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('❌ Error updating phone verification status: $e');
    }
  }

  static Future<UserProfile> switchLoginProvider(
    String userId,
    String newProvider,
  ) async {
    try {
      final updates = {
        'loginProvider': newProvider,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _usersCollection.doc(userId).update(updates);

      final updatedUser = await getUserProfile(userId);
      if (updatedUser == null) {
        throw Exception(
          'Không thể lấy thông tin người dùng sau khi chuyển đổi',
        );
      }

      print('✅ Switched login provider to: $newProvider');
      return updatedUser;
    } catch (e) {
      print('❌ Error switching login provider: $e');
      throw Exception('Không thể chuyển đổi phương thức đăng nhập: $e');
    }
  }
}
