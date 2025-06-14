import 'package:flutter/material.dart';
import 'product.dart';
import '../constants/app_strings.dart';

class DataSource {
  // 产品列表
  static List<Product> get products => [
    const Product(
      name: '沙发',
      price: '￥5,999',
      icon: Icons.chair,
      description: '舒适现代沙发',
    ),
    const Product(
      name: '床',
      price: '￥3,999',
      icon: Icons.bed,
      description: '优质睡眠床具',
    ),
    const Product(
      name: '餐桌',
      price: '￥2,999',
      icon: Icons.table_restaurant,
      description: '实木餐桌',
    ),
    const Product(
      name: '衣柜',
      price: '￥4,999',
      icon: Icons.door_sliding,
      description: '大容量衣柜',
    ),
    const Product(
      name: '书桌',
      price: '￥1,999',
      icon: Icons.desk,
      description: '学习办公桌',
    ),
    const Product(
      name: '电视柜',
      price: '￥2,499',
      icon: Icons.tv,
      description: '多功能电视柜',
    ),
    const Product(
      name: '茶几',
      price: '￥1,599',
      icon: Icons.table_bar,
      description: '客厅茶几',
    ),
    const Product(
      name: '装饰画',
      price: '￥599',
      icon: Icons.image,
      description: '艺术装饰画',
    ),
  ];

  // 礼包列表
  static List<PackageModel> get packages => [
    const PackageModel(
      name: AppStrings.modernPackage,
      price: AppStrings.modernPrice,
      icon: Icons.home,
      color: Colors.orange,
      description: AppStrings.modernDescription,
    ),
    const PackageModel(
      name: AppStrings.nordicPackage,
      price: AppStrings.nordicPrice,
      icon: Icons.nature,
      color: Colors.blue,
      description: AppStrings.nordicDescription,
    ),
    const PackageModel(
      name: AppStrings.chinesePackage,
      price: AppStrings.chinesePrice,
      icon: Icons.account_balance,
      color: Colors.brown,
      description: AppStrings.chineseDescription,
    ),
  ];

  // 套装推荐列表
  static List<SuiteModel> get suites => [
    const SuiteModel(
      title: AppStrings.modernSuite,
      description: AppStrings.modernDescription,
      price: AppStrings.modernPrice,
      color: Colors.orange,
    ),
    const SuiteModel(
      title: AppStrings.nordicSuite,
      description: AppStrings.nordicDescription,
      price: AppStrings.nordicPrice,
      color: Colors.blue,
    ),
    const SuiteModel(
      title: AppStrings.chineseSuite,
      description: AppStrings.chineseDescription,
      price: AppStrings.chinesePrice,
      color: Colors.brown,
    ),
  ];
}
