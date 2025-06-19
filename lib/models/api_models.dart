class FeaturedProduct {
  final String id;
  final String name;
  final int price;

  FeaturedProduct({required this.id, required this.name, required this.price});

  factory FeaturedProduct.fromJson(Map<String, dynamic> json) {
    return FeaturedProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
    );
  }

  // 格式化价格显示
  String get formattedPrice => '¥${(price / 100).toStringAsFixed(2)}';
}

class Category {
  final String id;
  final String name;
  final String created;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.created,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      created: json['created'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class AppHomeData {
  final List<FeaturedProduct> featuredProducts;
  final List<Category> categories;

  AppHomeData({required this.featuredProducts, required this.categories});

  factory AppHomeData.fromJson(Map<String, dynamic> json) {
    return AppHomeData(
      featuredProducts:
          (json['featured_products'] as List<dynamic>?)
              ?.map((item) => FeaturedProduct.fromJson(item))
              .toList() ??
          [],
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((item) => Category.fromJson(item))
              .toList() ??
          [],
    );
  }
}

// 用户模型
class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String role;
  final String created;
  final String updated;
  final String collectionId;
  final String collectionName;
  final bool emailVisibility;
  final bool verified;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.role,
    required this.created,
    required this.updated,
    required this.collectionId,
    required this.collectionName,
    required this.emailVisibility,
    required this.verified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? '',
      created: json['created'] ?? '',
      updated: json['updated'] ?? '',
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      emailVisibility: json['emailVisibility'] ?? false,
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'role': role,
      'created': created,
      'updated': updated,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'emailVisibility': emailVisibility,
      'verified': verified,
    };
  }
}

// 认证响应模型
class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['record'] ?? {}),
    );
  }
}

// 登录输入模型
class LoginInput {
  final String identity;
  final String password;

  LoginInput({required this.identity, required this.password});

  Map<String, dynamic> toJson() {
    return {'identity': identity, 'password': password};
  }
}
