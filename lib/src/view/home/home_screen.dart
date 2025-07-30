import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/get_profile_controller.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/view/home/chat/chat_screen.dart';
import 'package:olx_prototype/src/view/home/description/description_screen.dart';
import '../../controller/navigation_controller.dart';
import '../../custom_widgets/cards.dart';
import '../../custom_widgets/circle_avatar.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<IconData> drawerIcons = [
    Icons.person,
    Icons.directions_car,
    Icons.settings,
    Icons.logout,

  ];

  final List<VoidCallback> buttonOnTap = [
    () => Get.toNamed(AppRoutes.profile),
    () => Get.toNamed(AppRoutes.sellCars),
    () => Get.toNamed(AppRoutes.setting),
        () => Get.toNamed(AppRoutes.logout),

  ];

  final List<String> items = [
    "Profile",
    "Sell Your Car",
    "Setting",
    "LogOut",

  ];

  final List<String> carouselImages = [
    "assets/images/carousel1.jpg",
    "assets/images/carouselbike.jpg",
    "assets/images/carouselproperty.jpg",
    "assets/images/phonescarousel.jpg",
    "assets/images/business.carouseljpeg.jpeg"
  ];

  @override
  Widget build(BuildContext context) {
    final getProfileController = Get.put(GetProfileController());
    final controller = Get.put(NavigationController());

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: AppColors.appGreen
        ),
        title: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/OldMarketLogo.png',
                    height: 55,
                  ),
                  SizedBox(width: AppSizer().width3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome',
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
              Get.to(ChatScreen());
            },
            icon: Icon(
              Icons.send,
              color: AppColors.appGreen,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
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
                                  child: getProfileController.imagePath.value.isNotEmpty
                                      ? Image.file(File(getProfileController.imagePath.value))
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
                            backgroundImage: getProfileController.imagePath.value.isNotEmpty
                                ? FileImage(File(getProfileController.imagePath.value))
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
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  getProfileController.getImageByCamera();
                                                  Get.back();
                                                },
                                                icon: Icon(Icons.camera_alt, color: AppColors.appBlue),
                                              ),
                                              Text(
                                                "Camera",
                                                style: TextStyle(
                                                  color: AppColors.appPurple,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: AppSizer().fontSize16,
                                                ),
                                              )
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  getProfileController.getImageByGallery();
                                                  Get.back();
                                                },
                                                icon: Icon(Icons.image, color: AppColors.appBlue),
                                              ),
                                              Text(
                                                "Gallery",
                                                style: TextStyle(
                                                  color: AppColors.appPurple,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: AppSizer().fontSize16,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor:AppColors.appBlack,
                              child: Icon(Icons.camera_alt, size: AppSizer().height2, color: AppColors.appWhite),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSizer().width5,),
                  Text("Mohit Kumar",style: TextStyle(fontWeight: FontWeight.w600,fontSize: AppSizer().fontSize18),)
                ],
              ),

              SizedBox(height: AppSizer().height3),
              Divider(height: 1.2, thickness: 2,color: AppColors.appGrey,),
              SizedBox(height: AppSizer().height1),


              Expanded(
                child: ListView.builder(
                  itemCount: drawerIcons.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap:(){
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
                  autoPlayInterval: const Duration(seconds: 2),
                  height: AppSizer().height20,
                ),
                items: carouselImages.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
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
                padding: EdgeInsets.only(left: AppSizer().height1,right: AppSizer().height1),
                child: Text(
                  "Browse Categories.",
                  style: TextStyle(
                    color: AppColors.appGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizer().fontSize18,
                  ),
                ),
              ),
              SizedBox(height: AppSizer().height2),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CategoryItem(
                      imagePath: 'assets/images/phone.png',
                      title: 'Mobiles',
                    ),
                    SizedBox(width: AppSizer().width2),
                    CategoryItem(
                      imagePath: 'assets/images/laptop.jpg',
                      title: 'Laptops',
                    ),
                    SizedBox(width: AppSizer().width2),
                    CategoryItem(
                      imagePath: 'assets/images/property.jpg',
                      title: 'Property for Sale',
                    ),
                    SizedBox(width: AppSizer().width2),
                    CategoryItem(
                      imagePath: 'assets/images/cars.jpg',
                      title: 'Vehicles',
                    ),
                    SizedBox(width: AppSizer().width2),
                    CategoryItem(
                      imagePath: 'assets/images/bike.jpeg',
                      title: 'Bikes',
                    ),
                    SizedBox(width: AppSizer().width2),
                    CategoryItem(
                      imagePath: 'assets/images/business.jpeg',
                      title: 'Business Industrial...',
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizer().height3),
              Padding(
                padding: EdgeInsets.only(left: AppSizer().height1,right: AppSizer().height1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      " Mobiles..",
                      style: TextStyle(
                        color: AppColors.appGreen,
                        fontSize: AppSizer().fontSize18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        "See More",
                        style: TextStyle(
                          color: AppColors.appGreen,
                          fontSize: AppSizer().fontSize17,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.appBlack,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizer().height1),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.50,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: (){
                      Get.toNamed(AppRoutes.description);
                    },
                    child: ProductCard(
                      imagePath: "assets/images/phone2.jpg",
                      roomInfo: "iPhone 14 Pro",
                      price: "₹ 1,15,000",
                      description: "iPhone 13 4 month old Bill Box and warranty available",
                      location: "Prayagraj",
                      date: "23 July",
                    ),
                  );
                },
              ),
              SizedBox(height: AppSizer().height2),
              Padding(
                padding: EdgeInsets.only(left: AppSizer().height1,right: AppSizer().height1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      " Cars New Models..",
                      style: TextStyle(
                        color: AppColors.appGreen,
                        fontSize: AppSizer().fontSize18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        "See More",
                        style: TextStyle(
                          color: AppColors.appGreen,
                          fontSize: AppSizer().fontSize17,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.appBlack,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizer().height1),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.50,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(
                    imagePath: "assets/images/cars.jpg",
                    roomInfo: "iPhone 14 Pro",
                    price: "₹ 1,40,000",
                    description: "iPhone 13 4 month old Bill Box and warranty available",
                    location: "Lucknow",
                    date: "20 July",
                  );
                },
              ),
              SizedBox(height: AppSizer().height3),
              Padding(
                padding: EdgeInsets.only(left: AppSizer().height1,right: AppSizer().height1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      " Bikes Top Model..",
                      style: TextStyle(
                        color: AppColors.appGreen,
                        fontSize: AppSizer().fontSize18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        "See More",
                        style: TextStyle(
                          color: AppColors.appGreen,
                          fontSize: AppSizer().fontSize17,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.appBlack,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizer().height1),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.50,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(
                    imagePath: "assets/images/carouselbike.jpg",
                    roomInfo: "iPhone 14 Pro",
                    price: "₹ 1,40,000",
                    description: "iPhone 13 4 month old Bill Box and warranty available",
                    location: "Noida",
                    date: "12 June",
                  );
                },
              ),
              SizedBox(height: AppSizer().height3),
              Padding(
                padding: EdgeInsets.only(left: AppSizer().height1,right: AppSizer().height1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      " Properties as your's choice..",
                      style: TextStyle(
                        color: AppColors.appGreen,
                        fontSize: AppSizer().fontSize18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        "See More",
                        style: TextStyle(
                          color: AppColors.appGreen,
                          fontSize: AppSizer().fontSize17,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.appBlack,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizer().height1),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.50,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(
                    imagePath: "assets/images/property.jpg",
                    roomInfo: "iPhone 14 Pro",
                    price: "₹ 1,40,000",
                    description: "iPhone 13 4 month old Bill Box and warranty available",
                    location: "Mirjapur",
                    date: "23 July",
                  );
                },
              ),
              SizedBox(height: AppSizer().height3),
              Padding(
                padding: EdgeInsets.only(left: AppSizer().height1,right: AppSizer().height1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      " Business Ideas..",
                      style: TextStyle(
                        color: AppColors.appGreen,
                        fontSize: AppSizer().fontSize18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        "See More",
                        style: TextStyle(
                          color: AppColors.appGreen,
                          fontSize: AppSizer().fontSize17,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.appBlack,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizer().height1),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.50,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(
                    imagePath: "assets/images/business2.jpg",
                    roomInfo: "iPhone 14 Pro",
                    price: "₹ 1,40,000",
                    description: "iPhone 13 4 month old Bill Box and warranty available",
                    location: "Prayagraj",
                    date: "23 July",
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        backgroundColor: AppColors.appGreen,
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.selectedIndex.value,
        onTap: controller.onItemTapped,
        selectedItemColor: AppColors.appWhite,
        unselectedItemColor: AppColors.appBlack,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Old Market"),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_filled), label: "Video Market"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Car Market"),
        ],
      )),
    );
  }
}