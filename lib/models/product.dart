import 'package:flutter/material.dart';

class Product {
  final String name;
  final String price;
  final IconData icon;
  final String? description;
  final String? imageUrl;

  const Product({
    required this.name,
    required this.price,
    required this.icon,
    this.description,
    this.imageUrl,
  });

  @override
  String toString() {
    return 'Product{name: $name, price: $price, icon: $icon}';
  }
}

class PackageModel {
  final String name;
  final String price;
  final IconData icon;
  final Color color;
  final String description;

  const PackageModel({
    required this.name,
    required this.price,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class SuiteModel {
  final String title;
  final String description;
  final String price;
  final Color color;

  const SuiteModel({
    required this.title,
    required this.description,
    required this.price,
    required this.color,
  });
}
