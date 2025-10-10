import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/token_controller.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';

class BikesMarket extends StatelessWidget {
  const BikesMarket({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> carList = [
      {
        'image': 'assets/images/bike.jpeg',
        'price': '₹ 276,000',
        'title': 'KTM DUKE 2020 Model 180cc',
        "place": "Jamshedpur,UP",
      },
      {
        'image': 'assets/images/carouselbike.jpg',
        'price': '₹ 165,000',
        'title': 'Kawasaki Ninja Model 1000cc',
        "place": "Singrauli,Bihar",
      },
      {
        'image': 'assets/images/bike2.jpg',
        'price': '₹ 80,000',
        'title': 'Bullet 2024 Model 230Ccc',
        "place": "America,USA",
      },
      {
        'image': 'assets/images/bike3.jpeg',
        'price': '₹ 1,500,000',
        'title': 'Honda Shine 2018 Model 125cc',
        "place": "Raipur,CG",
      },
      {
        'image': 'assets/images/bike4.png',
        'price': '₹ 1,50,000',
        'title': "Passion Plus 2010 Model 100cc",
        "place": "Prayagraj,UP",
      },
      {
        'image': 'assets/images/bike6.jpg',
        'price': '₹ 1,32,000',
        'title': 'Pulsar 2022 Model 220cc ',
        "place": "Rohtas,Bihar",
      },
      {
        'image': 'assets/images/bike7.jpg',
        'price': '₹ 80,000',
        'title': 'Glamour 2013 Model 120CC',
        "place": "Mumbai,MH",
      },
      {
        'image': 'assets/images/bike5.jpeg',
        'price': '₹ 2,76,000',
        'title': 'Pulsar 2012 Model 150CC',
        "place": "Indore,MP",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appGreen,
        title: const Text(
          "Cars Market",
          style: TextStyle(color: AppColors.appWhite),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: carList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 1.3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            final car = carList[index];
            return InkWell(
              onTap: () {
                final token = Get.find<TokenController>();
                // Debug: log which item was tapped
                print(
                  '[BikesMarket] tapped item index: $index, title: ${car['title']}',
                );
                if (token.isLoggedIn) {
                  // No product id available in this demo list; navigate to All Products listing instead.
                  Get.toNamed(AppRoutes.all_products_screen);
                } else {
                  Get.toNamed(AppRoutes.login);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.appGrey.shade900,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: AppSizer().height25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        image: DecorationImage(
                          image: AssetImage(car['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizer().height2),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        car['price']!,
                        style: TextStyle(
                          color: AppColors.appWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizer().fontSize19,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            car['title']!,
                            style: TextStyle(
                              color: AppColors.appWhite,
                              fontSize: AppSizer().fontSize16,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.place, color: AppColors.appWhite),
                              Text(
                                car['place']!,
                                style: TextStyle(
                                  color: AppColors.appWhite,
                                  fontSize: AppSizer().fontSize16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
