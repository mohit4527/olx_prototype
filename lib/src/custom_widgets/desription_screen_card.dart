import 'package:flutter/material.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';

class Product {
  final String name;
  final String brand;
  final String imageUrl;

  Product({
    required this.name,
    required this.brand,
    required this.imageUrl,
  });
}

List<Product> productList = [
  Product(
    name: "Ola Electric",
    brand: "Smarter Ride",
    imageUrl: "assets/images/ola.jpeg",
  ),
  Product(
    name: "Fastway Car Rental",
    brand: "Luxury Thar",
    imageUrl: "assets/images/thaar.jpg",
  ),
  Product(
    name: "Intruder",
    brand: "Best bike like a bullet",
    imageUrl: "assets/images/bike1.jpeg",
  ),
  Product(
    name: "Mercedees S class",
    brand: "Top Brands of car",
    imageUrl: "assets/images/car2.jpg",
  ),
  Product(
    name: "Swift Vxi",
    brand: "The Smartest ride ever",
    imageUrl: "assets/images/poster5.jpg",
  ),
  Product(
    name: "I phone 14 pro max",
    brand: "In best condition ",
    imageUrl: "assets/images/phone2.jpg",
  ),
  Product(
    name: "Bugati",
    brand: "Racing car",
    imageUrl: "assets/images/cars.jpg",
  ),
  Product(
    name: "KTM",
    brand: "The Best racing bike",
    imageUrl: "assets/images/bike.jpeg",
  ),

];

class CustomProductCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;

  const CustomProductCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding:EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizer().fontSize18,
                ),
              ),
            ),

            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                  imageUrl!.replaceAll('\\', '/').trim(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset(
                        "assets/images/placeholder.jpg",
                        fit: BoxFit.cover,
                      ),
                )
                    : Image.asset(
                  "assets/images/placeholder.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppSizer().fontSize16,
                  color: AppColors.appGrey.shade800,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
