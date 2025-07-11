import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v_store/models/category.dart';

class CategoryService {
  final CollectionReference _categoriesRef = FirebaseFirestore.instance
      .collection('categories');

  Future<List<Categories>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _categoriesRef.get();
      List<Categories> categories = [];

      print(
        'CategoryService: Tìm thấy ${snapshot.docs.length} categories trong Firestore',
      );

      for (var doc in snapshot.docs) {
        try {
          var data = doc.data();
          if (data != null && data is Map<String, dynamic>) {
            if (!data.containsKey('categoryId')) {
              data['categoryId'] = doc.id;
            }

            Categories category = Categories.fromJson(data);
            categories.add(category);

            print('CategoryService: Loaded category: ${category.name}');
          }
        } catch (e) {
          print(
            'CategoryService: Error parsing category document ${doc.id}: $e',
          );
        }
      }

      print(
        'CategoryService: Successfully loaded ${categories.length} categories',
      );
      return categories;
    } catch (e) {
      print('CategoryService: Error fetching categories: $e');
      rethrow;
    }
  }

  Future<void> addCategory(Categories category) async {
    try {
      await _categoriesRef.add(category.toJson());
      print('CategoryService: Added category: ${category.name}');
    } catch (e) {
      print('CategoryService: Error adding category: $e');
      rethrow;
    }
  }

  Future<void> addCategories(List<Categories> categories) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (Categories category in categories) {
        DocumentReference docRef = _categoriesRef.doc();
        batch.set(docRef, category.toJson());
      }

      await batch.commit();
      print('CategoryService: Added ${categories.length} categories');
    } catch (e) {
      print('CategoryService: Error adding categories: $e');
      rethrow;
    }
  }

  Future<void> initializeCategories() async {
    try {
      QuerySnapshot snapshot = await _categoriesRef.get();

      if (snapshot.docs.isEmpty) {
        print(
          'CategoryService: No categories found, initializing with default data...',
        );

        List<Categories> defaultCategories = [
          Categories(
            categoryId: "bt001",
            name: 'Làm Đẹp',
            imageUrl: 'assets/images/category/beauty.png',
          ),
          Categories(
            categoryId: "fs001",
            name: 'Thời Trang',
            imageUrl: 'assets/images/category/fashion.png',
          ),
          Categories(
            categoryId: "k001",
            name: 'Trẻ Em',
            imageUrl: 'assets/images/category/kid.png',
          ),
          Categories(
            categoryId: "m001",
            name: 'Nam',
            imageUrl: 'assets/images/category/men.png',
          ),
          Categories(
            categoryId: "wm001",
            name: 'Nữ',
            imageUrl: 'assets/images/category/womens.png',
          ),
        ];

        await addCategories(defaultCategories);
        print('CategoryService: Default categories initialized');
      } else {
        print(
          'CategoryService: Categories already exist (${snapshot.docs.length} found)',
        );
      }
    } catch (e) {
      print('CategoryService: Error initializing categories: $e');
      rethrow;
    }
  }
}
