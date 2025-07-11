import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:v_store/models/product.dart';

class ProductService {
  Future<void> addProductsFromJson() async {
    try {
      String jsonString = await rootBundle.loadString('assets/products.json');
      List<dynamic> products = json.decode(jsonString);

      var snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      if (snapshot.docs.isNotEmpty) {
        print('Danh sách sản phẩm đã tồn tại.');
        return;
      }

      for (var productData in products) {
        Product product = Product.fromJson(productData);
        await FirebaseFirestore.instance
            .collection('products')
            .add(product.toJson());
      }

      print('Đã thêm sản phẩm từ JSON vào Firestore!');
    } catch (e) {
      print('Lỗi khi thêm sản phẩm: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      CollectionReference productsRef = FirebaseFirestore.instance.collection(
        'products',
      );
      QuerySnapshot snapshot = await productsRef.get();
      List<Product> products = [];

      print(
        'ProductService: Tìm thấy ${snapshot.docs.length} documents trong Firestore',
      );

      for (var doc in snapshot.docs) {
        try {
          var data = doc.data();
          if (data != null && data is Map<String, dynamic>) {
            if (!data.containsKey('productId')) {
              data['productId'] = doc.id;
            }
            Product product = Product.fromJson(data);
            products.add(product);
          } else {
            print(
              'Document ${doc.id} có dữ liệu null hoặc không đúng định dạng',
            );
          }
        } catch (e) {
          print('Lỗi khi parse document ${doc.id}: $e');

          continue;
        }
      }

      print('ProductService: Đã parse thành công ${products.length} sản phẩm');
      return products;
    } catch (e) {
      print('Lỗi khi lấy sản phẩm: $e');
      return [];
    }
  }

  Future<void> cleanupInvalidDocuments() async {
    try {
      CollectionReference productsRef = FirebaseFirestore.instance.collection(
        'products',
      );
      QuerySnapshot snapshot = await productsRef.get();

      List<String> invalidDocIds = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data == null || data is! Map<String, dynamic>) {
          invalidDocIds.add(doc.id);
          print('Found invalid document: ${doc.id}');
        }
      }

      for (String docId in invalidDocIds) {
        await productsRef.doc(docId).delete();
        print('Deleted invalid document: $docId');
      }

      print(
        'Cleanup completed. Removed ${invalidDocIds.length} invalid documents.',
      );
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  Future<int> getProductCount() async {
    try {
      CollectionReference productsRef = FirebaseFirestore.instance.collection(
        'products',
      );
      QuerySnapshot snapshot = await productsRef.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting product count: $e');
      return 0;
    }
  }

  Future<void> clearAllProducts() async {
    try {
      CollectionReference productsRef = FirebaseFirestore.instance.collection(
        'products',
      );
      QuerySnapshot snapshot = await productsRef.get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Đã xóa tất cả ${snapshot.docs.length} sản phẩm');
    } catch (e) {
      print('Lỗi khi xóa sản phẩm: $e');
    }
  }

  Future<void> reimportProducts() async {
    print('Bắt đầu reimport products...');

    await clearAllProducts();

    await addProductsFromJson();

    print('Hoàn thành reimport products');
  }

  Future<void> testGetProducts() async {
    try {
      print('=== BẮT ĐẦU TEST GET PRODUCTS ===');
      CollectionReference productsRef = FirebaseFirestore.instance.collection(
        'products',
      );
      QuerySnapshot snapshot = await productsRef.get();

      print('Tổng số documents: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        print('Kiểm tra document đầu tiên...');
        var firstDoc = snapshot.docs.first;
        var data = firstDoc.data();

        print('Document ID: ${firstDoc.id}');
        print('Data type: ${data.runtimeType}');

        if (data is Map<String, dynamic>) {
          print('Data keys: ${data.keys.toList()}');

          try {
            var testProduct = Product.fromJson(data);
            print('✅ Parse thành công document ${firstDoc.id}');
            print('Product name: ${testProduct.name}');
          } catch (e) {
            print('❌ Lỗi parse document ${firstDoc.id}: $e');
          }
        }
      }

      print('=== KẾT THÚC TEST ===');
    } catch (e) {
      print('Lỗi trong test: $e');
    }
  }

  double calculateDiscountedPrice(Product product) {
    if (product.discount != null && product.discount! > 0) {
      return product.price - (product.price * (product.discount! / 100));
    }
    return product.price;
  }

  Future<int> getNumberProducts() async {
    try {
      CollectionReference productsRef = FirebaseFirestore.instance.collection(
        'products',
      );
      QuerySnapshot snapshot = await productsRef.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Lỗi khi lấy số lượng sản phẩm: $e');
      return 0;
    }
  }

  Future<List<Product>> sortProductsByField(
    String field, {
    bool ascending = true,
  }) async {
    try {
      CollectionReference productsRef = FirebaseFirestore.instance.collection(
        'products',
      );
      QuerySnapshot snapshot = await productsRef
          .orderBy(field, descending: !ascending)
          .get();
      List<Product> products = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data != null && data is Map<String, dynamic>) {
          Product product = Product.fromJson(data);
          products.add(product);
        }
      }

      return products;
    } catch (e) {
      print('Lỗi khi sắp xếp sản phẩm: $e');
      return [];
    }
  }

  Future<void> clearAndReloadProducts() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('Đã xóa tất cả sản phẩm cũ');

      await addProductsFromJson();
      print('Đã tải lại sản phẩm từ JSON với dữ liệu review mới');
    } catch (e) {
      print('Lỗi khi reload sản phẩm: $e');
      rethrow;
    }
  }
}
