const admin = require('firebase-admin');
const fs = require('fs');

admin.initializeApp({
    credential: admin.credential.cert('v-store-e2e87-firebase-adminsdk-fbsvc-d4b7fdc6aa.json'),
});

const products = JSON.parse(fs.readFileSync('products.json', 'utf8'));

async function importProducts() {
    try {
        const batch = admin.firestore().batch();
        const collectionRef = admin.firestore().collection('products');

        const existingDocs = await collectionRef.get();
        const existingIds = new Set(existingDocs.docs.map(doc => doc.id));

        products.forEach(product => {
            const docId = product.productId || collectionRef.doc().id;
            if (!existingIds.has(docId)) {
                batch.set(collectionRef.doc(docId), {
                    productId: docId,
                    name: product.name,
                    category: {
                        categoryId: product.category.categoryId,
                        name: product.category.name,
                        imageUrl: product.category.imageUrl,
                    },
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
        });

        await batch.commit();
        console.log('Đã import sản phẩm thành công!');
    } catch (error) {
        console.error('Lỗi khi import sản phẩm:', error);
    }
}

importProducts();