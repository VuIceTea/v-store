const admin = require('firebase-admin');
const fs = require('fs');

// Khởi tạo Firebase Admin
admin.initializeApp({
    credential: admin.credential.cert('v-store-e2e87-firebase-adminsdk-fbsvc-d4b7fdc6aa.json'),
});

const products = JSON.parse(fs.readFileSync('products.json', 'utf8'));

async function simpleImport() {
    try {
        console.log('Bắt đầu import', products.length, 'sản phẩm...');

        const collectionRef = admin.firestore().collection('products');

        // Xóa tất cả sản phẩm cũ
        console.log('Xóa sản phẩm cũ...');
        const existingDocs = await collectionRef.get();
        const deleteBatch = admin.firestore().batch();
        existingDocs.docs.forEach(doc => {
            deleteBatch.delete(doc.ref);
        });
        await deleteBatch.commit();
        console.log('Đã xóa', existingDocs.size, 'sản phẩm cũ');

        // Import từng sản phẩm một
        for (let i = 0; i < products.length; i++) {
            const product = products[i];
            console.log(`Import sản phẩm ${i + 1}/${products.length}: ${product.name}`);

            await collectionRef.doc(product.productId).set({
                productId: product.productId,
                name: product.name,
                category: product.category,
                description: product.description || null,
                price: product.price,
                imageUrl: product.imageUrl,
                stockQuantity: product.stockQuantity,
                rating: product.rating || null,
                reviewCount: product.reviewCount || null,
                reviews: product.reviews || null,
                isAvailable: product.isAvailable !== undefined ? product.isAvailable : true,
                tags: product.tags || null,
                colors: product.colors || null,
                sizes: product.sizes || null,
                images: product.images || null,
                brand: product.brand || null,
                manufacturer: product.manufacturer || null,
                origin: product.origin || null,
                dimensions: product.dimensions || null,
                weight: product.weight || null,
                material: product.material || null,
                videoUrl: product.videoUrl || null,
                barcode: product.barcode || null,
                productType: product.productType || null,
                returnPolicy: product.returnPolicy || null,
                discount: product.discount || null,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }

        console.log('Đã import thành công tất cả', products.length, 'sản phẩm!');

        // Kiểm tra lại
        const finalSnapshot = await collectionRef.get();
        console.log('Firestore hiện có', finalSnapshot.size, 'sản phẩm');

    } catch (error) {
        console.error('Lỗi khi import:', error);
    }
}

simpleImport();
