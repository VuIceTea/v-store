const admin = require('firebase-admin');

// Khởi tạo Firebase Admin
admin.initializeApp({
    credential: admin.credential.cert('v-store-e2e87-firebase-adminsdk-fbsvc-d4b7fdc6aa.json'),
});

// Xóa tất cả documents trong collection products
async function clearProducts() {
    try {
        const collectionRef = admin.firestore().collection('products');
        const snapshot = await collectionRef.get();

        console.log(`Tìm thấy ${snapshot.docs.length} documents để xóa`);

        const batch = admin.firestore().batch();

        snapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
        });

        await batch.commit();
        console.log('Đã xóa tất cả sản phẩm thành công!');
    } catch (error) {
        console.error('Lỗi khi xóa sản phẩm:', error);
    }
}

clearProducts();
