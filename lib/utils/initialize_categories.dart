import 'package:v_store/services/category_service.dart';

Future<void> initializeCategoriesInFirestore() async {
  try {
    CategoryService categoryService = CategoryService();

    print('Đang khởi tạo categories trong Firestore...');
    await categoryService.initializeCategories();
    print('Hoàn thành khởi tạo categories!');
  } catch (e) {
    print('Lỗi khi khởi tạo categories: $e');
  }
}
