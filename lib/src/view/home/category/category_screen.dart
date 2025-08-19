import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/custom_widgets/cards.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import '../../../constants/app_sizer.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});

  final List<String> carouselImages = [
    "assets/images/poster6.jpg",
    "assets/images/poster7.png",
    "assets/images/poster8.jpg",
    "assets/images/poster9.png",
    "assets/images/poster10.jpg",
  ];

  final List<String> listviewImages = [
    "assets/images/car2.jpg",
    "assets/images/cars.jpg",
    "assets/images/thaar.jpg",
    "assets/images/ola.jpeg",
    "assets/images/phonescarousel.jpg",
  ];

  final List<String> listviewImages2 = [
    "assets/images/poster2.jpg",
    "assets/images/poster4.jpg",
    "assets/images/carouselbike.jpg",
    "assets/images/poster5.jpg",
    "assets/images/poster10.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight = screenHeight * 0.30;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
        title: Text(
          "Category Screen",
          style: TextStyle(color: AppColors.appWhite),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizer().height2),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizer().width2),
                child: Row(
                  children: [
                    _buildTopButton("All Items", Icons.category, () {
                      Get.toNamed(AppRoutes.category);
                    }),
                    _buildTopButton("Cars", Icons.directions_car, () {
                      Get.toNamed(AppRoutes.carsMarket);
                    }),
                    _buildTopButton("Bikes", Icons.pedal_bike, () {
                      Get.toNamed(AppRoutes.bikes_market);
                    }),
                  ],
                ),
              ),
              SizedBox(height: AppSizer().height2),
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  viewportFraction: 1.0,
                  autoPlayInterval: const Duration(seconds: 2),
                  height: screenHeight * 0.26,
                ),
                items: carouselImages.map((item) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      item,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: AppSizer().height2),

              // === First List ===
              _buildSectionTitle("Second Hand Cars..."),
              SizedBox(height: AppSizer().height2),
              SizedBox(
                height: cardHeight,
                child: _buildHorizontalList(listviewImages),
              ),

              SizedBox(height: AppSizer().height2),

              // === Second List ===
              _buildSectionTitle("All Old Items..."),
              SizedBox(height: AppSizer().height2),
              SizedBox(
                height: cardHeight,
                child: _buildHorizontalList(listviewImages2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButton(String text, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal:AppSizer().width1),
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: Color(0xffb0b5b7),
            padding: EdgeInsets.symmetric(vertical:1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: Icon(icon, color: AppColors.appBlack, size: 20),
          label: Text(
            text,
            style: TextStyle(
              fontSize: AppSizer().fontSize15,
              color: AppColors.appBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.all(AppSizer().height1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.appGreen,
              fontWeight: FontWeight.w600,
              fontSize: AppSizer().fontSize18,
            ),
          ),
          Divider(height: 2, color: AppColors.appGreen, thickness: 2),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<String> images) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.45,
          margin: EdgeInsets.symmetric(horizontal: AppSizer().width1),
          child: ProductCard(
            imagePath: images[index],
            price: "₹ 1,15,000",
            roomInfo: "iPhone 14 Pro",
            description: "iPhone 13 4 month old Bill Box and warranty available",
            location: "Prayagraj",
            date: "23 July",
          ),
        );
      },
    );
  }
}
