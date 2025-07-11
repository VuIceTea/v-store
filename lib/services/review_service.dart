import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v_store/models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addReview({
    required String productId,
    required double rating,
    required String content,
    List<String>? images,
  }) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        final UserCredential userCredential = await _auth.signInAnonymously();
        currentUser = userCredential.user;

        if (currentUser == null) {
          throw Exception('Không thể đăng nhập để đánh giá sản phẩm');
        }
      }

      final reviewId = _firestore.collection('reviews').doc().id;

      String? validatedAvatarUrl;
      if (currentUser.photoURL != null && currentUser.photoURL!.isNotEmpty) {
        final url = currentUser.photoURL!;
        if (url.startsWith('http') && !url.contains('w=100&h=100&fit=crop')) {
          validatedAvatarUrl = url;
        }
      }

      final review = Review(
        reviewId: reviewId,
        productId: productId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Người dùng ẩn danh',
        userAvatar: validatedAvatarUrl,
        content: content,
        rating: rating,
        date: DateTime.now(),
        images: images,
        isVerifiedPurchase: await _isVerifiedPurchase(
          productId,
          currentUser.uid,
        ),
      );

      await _firestore.collection('reviews').doc(reviewId).set(review.toJson());

      await _updateProductRating(productId);

      print('Đánh giá đã được thêm thành công');
    } catch (e) {
      print('Lỗi khi thêm đánh giá: $e');
      rethrow;
    }
  }

  Future<List<Review>> getProductReviews(String productId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Lỗi lấy đánh giá với sort: $e');

      try {
        final QuerySnapshot fallbackSnapshot = await _firestore
            .collection('reviews')
            .where('productId', isEqualTo: productId)
            .get();

        final reviews = fallbackSnapshot.docs
            .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        reviews.sort((a, b) {
          final dateA = a.date ?? DateTime.now();
          final dateB = b.date ?? DateTime.now();
          return dateB.compareTo(dateA);
        });

        return reviews;
      } catch (fallbackError) {
        print('Lỗi fallback lấy đánh giá: $fallbackError');
        return [];
      }
    }
  }

  Future<bool> hasUserReviewed(String productId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Lỗi kiểm tra đánh giá người dùng: $e');
      return false;
    }
  }

  Future<bool> _isVerifiedPurchase(String productId, String userId) async {
    try {
      return true;
    } catch (e) {
      print('Lỗi xác minh mua hàng: $e');
      return false;
    }
  }

  Future<void> _updateProductRating(String productId) async {
    try {
      final reviews = await getProductReviews(productId);

      if (reviews.isEmpty) return;

      final averageRating =
          reviews.map((review) => review.rating).reduce((a, b) => a + b) /
          reviews.length;

      await _firestore.collection('products').doc(productId).update({
        'rating': averageRating,
        'reviewCount': reviews.length,
      });

      print('Cập nhật rating sản phẩm thành công');
    } catch (e) {
      print('Lỗi cập nhật rating sản phẩm: $e');
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Cần đăng nhập để xóa đánh giá');
      }

      final doc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!doc.exists) {
        throw Exception('Đánh giá không tồn tại');
      }

      final reviewData = doc.data() as Map<String, dynamic>;
      if (reviewData['userId'] != currentUser.uid) {
        throw Exception('Bạn chỉ có thể xóa đánh giá của mình');
      }

      await _firestore.collection('reviews').doc(reviewId).delete();

      await _updateProductRating(reviewData['productId']);

      print('Xóa đánh giá thành công');
    } catch (e) {
      print('Lỗi xóa đánh giá: $e');
      rethrow;
    }
  }

  Future<List<Review>> getUserReviews() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Lỗi lấy đánh giá người dùng: $e');
      return [];
    }
  }

  Future<List<Review>> getAllReviews({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('reviews')
          .orderBy('date', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Lỗi lấy tất cả đánh giá: $e');
      return [];
    }
  }
}
