import 'package:recomart/models/product.model.dart';
import 'package:recomart/test/categories.dart';

const String PICSUM_BASE_URL = 'https://picsum.photos';

// --- Danh mục Giả lập ---
final List<Category> mockupCategories = [
  Category(
    id: 'c1',
    name: 'Rau Củ Quả',
    // Ảnh 100x100
    imageUrl: '$PICSUM_BASE_URL/100/100?random=1', 
  ),
  Category(
    id: 'c2',
    name: 'Thịt & Hải Sản',
    // Ảnh 100x100, số random khác để có ảnh khác
    imageUrl: '$PICSUM_BASE_URL/100/100?random=2', 
  ),
  Category(
    id: 'c3',
    name: 'Đồ Uống',
    imageUrl: '$PICSUM_BASE_URL/100/100?random=3', 
  ),
  Category(
    id: 'c4',
    name: 'Gia Vị',
    imageUrl: '$PICSUM_BASE_URL/100/100?random=4', 
  ),
  Category(
    id: 'c5',
    name: 'Thực Phẩm Đông Lạnh',
    imageUrl: '$PICSUM_BASE_URL/100/100?random=5', 
  ),
];

// --- Sản phẩm Giả lập (Sử dụng ProductModel) ---
final List<ProductModel> mockupProducts = [
  // 1. Cà Chua Bi (Variant của Sản phẩm Nông Sản)
  ProductModel(
    id: 'v101', // ID của Variant
    productId: 'p001', // ID của Sản phẩm gốc (vd: 'Nông Sản')
    variantName: 'Cà Chua Bi - Đỏ',
    variantColor: '#FF0000',
    variantDescription: 'Cà chua bi tươi, vị ngọt thanh, thích hợp làm salad.',
    price: 35000.0,
    discount: 5000.0, // Giảm 5.000 VNĐ
    quantity: 150,
    brandId: 'b001', // Ví dụ: 'Đà Lạt Farm'
    categoryId: 'c1', // Rau Củ Quả
    averageRating: 4.8,
    reviewCount: 125,
    images: [
      ProductImage(url: '$PICSUM_BASE_URL/300/300?random=11', publicId: 'img_p001_v101_1'),
      ProductImage(url: '$PICSUM_BASE_URL/300/300?random=12', publicId: 'img_p001_v101_2'),
    ],
    isActive: true,
  ),

  // 2. Thịt Bò Phi Lê (Variant của Sản phẩm Thịt)
  ProductModel(
    id: 'v201',
    productId: 'p002', // Vd: 'Thịt Tươi Sống'
    variantName: 'Thịt Bò Úc Phi Lê (500g)',
    variantColor: '#A52A2A', // Màu nâu đỏ
    variantDescription: 'Thịt bò Úc nhập khẩu, cắt phi lê, đóng gói 500g.',
    price: 250000.0,
    discount: 0.0,
    quantity: 50,
    brandId: 'b002', // Ví dụ: 'Meat King'
    categoryId: 'c2', // Thịt Tươi
    averageRating: 4.5,
    reviewCount: 88,
    images: [
      ProductImage(url: '$PICSUM_BASE_URL/300/300?random=21', publicId: 'img_p002_v201_1'),
    ],
    isActive: true,
  ),

  // 3. Nồi Cơm Điện (Variant của Sản phẩm Đồ Gia Dụng)
  ProductModel(
    id: 'v301',
    productId: 'p003', // Vd: 'Đồ Gia Dụng Bếp'
    variantName: 'Nồi Cơm Điện 1.8L - Trắng',
    variantColor: '#FFFFFF',
    variantDescription: 'Nồi cơm điện tử dung tích 1.8L, có hẹn giờ nấu.',
    price: 890000.0,
    discount: 100000.0, // Giảm 100.000 VNĐ
    quantity: 30,
    brandId: 'b003', // Ví dụ: 'Electro Home'
    categoryId: 'c3', // Đồ Gia Dụng
    averageRating: 5.0,
    reviewCount: 35,
    images: [
      ProductImage(url: '$PICSUM_BASE_URL/300/300?random=31', publicId: 'img_p003_v301_1'),
      ProductImage(url: '$PICSUM_BASE_URL/300/300?random=32', publicId: 'img_p003_v301_2'),
    ],
    isActive: true,
  ),

  // 4. Sản phẩm hết hàng (Inactive)
  ProductModel(
    id: 'v401',
    productId: 'p004',
    variantName: 'Táo Mỹ Ambrosia',
    variantColor: '#FFA07A',
    variantDescription: 'Táo nhập khẩu từ Mỹ, hiện đang hết hàng.',
    price: 120000.0,
    discount: 0.0,
    quantity: 0, // Hết hàng
    brandId: 'b001',
    categoryId: 'c1',
    averageRating: 4.2,
    reviewCount: 50,
    images: [
      ProductImage(url: '$PICSUM_BASE_URL/300/300?random=41', publicId: 'img_p004_v401_1'),
    ],
    isActive: false, // Không hoạt động
  ),
];