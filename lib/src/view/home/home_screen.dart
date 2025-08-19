import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/constants/app_strings_constant.dart';
import 'package:olx_prototype/src/controller/get_profile_controller.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/view/home/chat/chat_screen.dart';
import 'package:olx_prototype/src/view/home/notifications/notification_screen.dart';
import '../../controller/all_products_controller.dart';
import '../../controller/home_controller.dart';
import '../../controller/navigation_controller.dart';
import '../../controller/token_controller.dart';
import '../../custom_widgets/cards.dart';
import '../../custom_widgets/circle_avatar.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final productController = Get.put(ProductController());
  final tokenController = Get.find<TokenController>();
  final HomeController homeController = Get.put(HomeController());

  final List<IconData> drawerIcons = [
    Icons.person,
    Icons.store_mall_directory,
    Icons.directions_car,
    Icons.history,
    Icons.settings,
    Icons.logout,
  ];

  final List<VoidCallback> buttonOnTap = [
    () => Get.toNamed(AppRoutes.profile),
    () => Get.toNamed(AppRoutes.dealer),
    () => Get.toNamed(AppRoutes.sellCars),
    () => Get.toNamed(AppRoutes.history),
    () => Get.toNamed(AppRoutes.setting),
    () => Get.toNamed(AppRoutes.logout),
  ];

  final List<String> items = [
    "Profile",
    "Dealer",
    "Sell Your Car",
    "History",
    "Setting",
    "LogOut",
  ];

  final List<String> carouselImages = [
    "assets/images/poster1.jpeg",
    "assets/images/poster2.jpg",
    "assets/images/poster3.jpg",
    "assets/images/poster4.jpg",
    "assets/images/poster5.jpg",
  ];

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';

    try {
      final DateTime dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final getProfileController = Get.put(GetProfileController());
    final controller = Get.put(NavigationController());

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.appGreen),
        title: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/OldMarketLogo.png', height: 55),
                  SizedBox(width: AppSizer().width3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStringConstant.appTitle,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: AppSizer().fontSize16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Mohit Kumar",
                        style: TextStyle(
                          color: AppColors.appGreen,
                          fontSize: AppSizer().fontSize18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(NotificationScreen());
            },
            icon: Icon(Icons.notifications, color: AppColors.appGreen),
          ),
        ],
      ),
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizer().height5),
              Row(
                children: [
                  Obx(
                    () => Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child:
                                      getProfileController
                                          .imagePath
                                          .value
                                          .isNotEmpty
                                      ? Image.file(
                                          File(
                                            getProfileController
                                                .imagePath
                                                .value,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 80,
                                          backgroundColor: Color(0xfffae293),
                                          child: Icon(Icons.person, size: 80),
                                        ),
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Color(0xfffae293),
                            radius: 36,
                            backgroundImage:
                                getProfileController.imagePath.value.isNotEmpty
                                ? FileImage(
                                    File(getProfileController.imagePath.value),
                                  )
                                : null,
                            child: getProfileController.imagePath.value.isEmpty
                                ? Icon(Icons.person, size: 45)
                                : null,
                          ),
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Choose",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppSizer().fontSize19,
                                        color: AppColors.appPurple,
                                      ),
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  getProfileController
                                                      .getImageByCamera();
                                                  Get.back();
                                                },
                                                icon: Icon(
                                                  Icons.camera_alt,
                                                  color: AppColors.appBlue,
                                                ),
                                              ),
                                              Text(
                                                "Camera",
                                                style: TextStyle(
                                                  color: AppColors.appPurple,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      AppSizer().fontSize16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  getProfileController
                                                      .getImageByGallery();
                                                  Get.back();
                                                },
                                                icon: Icon(
                                                  Icons.image,
                                                  color: AppColors.appBlue,
                                                ),
                                              ),
                                              Text(
                                                "Gallery",
                                                style: TextStyle(
                                                  color: AppColors.appPurple,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      AppSizer().fontSize16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.appBlack,
                              child: Icon(
                                Icons.camera_alt,
                                size: AppSizer().height2,
                                color: AppColors.appWhite,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSizer().width5),
                  Column(
                    children: [
                      Obx(
                        () => Text(
                          Get.find<GetProfileController>()
                                  .profileData['Username'] ??
                              '',
                          style: TextStyle(fontSize: AppSizer().fontSize16),
                        ),
                      ),

                      Center(
                        child: Obx(
                          () => Text(
                            "Token: ${homeController.token.value}",
                            style: TextStyle(
                              fontSize: AppSizer().fontSize16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: AppSizer().height3),
              Divider(height: 1.2, thickness: 2, color: AppColors.appGrey),
              SizedBox(height: AppSizer().height1),

              Expanded(
                child: ListView.builder(
                  itemCount: drawerIcons.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          buttonOnTap[index]();
                        },
                        child: Container(
                          height: AppSizer().height6,
                          width: AppSizer().width100,
                          decoration: BoxDecoration(
                            color: AppColors.appGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: AppSizer().width3),
                              Icon(
                                drawerIcons[index],
                                color: AppColors.appWhite,
                              ),
                              SizedBox(width: AppSizer().width2),
                              Text(
                                items[index],
                                style: TextStyle(
                                  color: AppColors.appWhite,
                                  fontSize: AppSizer().fontSize16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizer().height2),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: AppSizer().height6,
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: AppColors.appGreen.withOpacity(0.3),
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xff11a35a),
                        ),
                      ),
                      hintText: 'Search Products...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSizer().height3),
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 2),
                  height: AppSizer().height26,
                  viewportFraction: 1.0,
                ),
                items: carouselImages.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.appGrey),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.appWhite,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item,
                            fit: BoxFit.cover,
                            height: AppSizer().height16,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: AppSizer().height3),
              Padding(
                padding: EdgeInsets.only(
                  left: AppSizer().height1,
                  right: AppSizer().height1,
                ),
                child: Text(
                  "Recently Viewed.",
                  style: TextStyle(
                    color: AppColors.appGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizer().fontSize18,
                  ),
                ),
              ),
              SizedBox(height: AppSizer().height2),
          SizedBox(
            child: Obx(() {
              if (productController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return SizedBox(
                height: AppSizer().height30,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productController.productList.length,
                  itemBuilder: (context, index) {
                    final product = productController.productList[index];
                    final String imageUrl = product.mediaUrl.isNotEmpty
                        ? "https://oldmarket.bhoomi.cloud/${product.mediaUrl.first}"
                        : 'https://via.placeholder.com/150';
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizer().width1),
                      child: AspectRatio(
                        aspectRatio: 2.2/3,
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.description,
                              arguments: product.id,
                            );

                          },
                          child: ProductCard(
                            imagePath: imageUrl,
                            roomInfo: product.title,
                            price: "₹ ${product.price}",
                            description: product.description,
                            location: product.location.city,
                            date: formatDate(product.createdAt),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          SizedBox(height: AppSizer().height2),
              Padding(
                padding: EdgeInsets.only(
                  left: AppSizer().height1,
                  right: AppSizer().height1,
                ),
                child: Text(
                  "All Products.",
                  style: TextStyle(
                    color: AppColors.appGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizer().fontSize18,
                  ),
                ),
              ),
              SizedBox(height: AppSizer().height2),
              Obx(() {
                if (productController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productController.productList.length,
                  padding: const EdgeInsets.all(6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 4,
                    childAspectRatio: 0.73,
                  ),
                  itemBuilder: (context, index) {
                    final product = productController.productList[index];

                    final String imageUrl = product.mediaUrl.isNotEmpty
                        ? "https://oldmarket.bhoomi.cloud/${product.mediaUrl.first}"
                        : 'https://via.placeholder.com/150';

                    return InkWell(
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.description,
                          arguments: product.id,
                        );
                      },
                      child: ProductCard(
                        imagePath: imageUrl,
                        roomInfo: product.title,
                        price: "₹ ${product.price}",
                        description: product.description,
                        location: product.location.city,
                        date: formatDate(product.createdAt),
                      ),
                    );
                  },
                );
              }),
              SizedBox(height: AppSizer().height1),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: AppColors.appGreen,
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.onItemTapped,
          selectedItemColor: AppColors.appWhite,
          unselectedItemColor: AppColors.appBlack,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: "Category",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_filled),
              label: "Short Video",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.ads_click),
              label: "My Aids",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: "Chat",
            ),
          ],
        ),
      ),
    );
  }
}
