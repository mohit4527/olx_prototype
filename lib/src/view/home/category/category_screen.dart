import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/custom_widgets/cards.dart';

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
    "assets/images/ertiga.jpg",
    "assets/images/alto.jpg",
    "assets/images/Suzuki.jpeg",
  ];

  final List<String> listviewImages2 = [
    "assets/images/scorpio.jpg",
    "assets/images/phonescarousel.jpg",
    "assets/images/carouselbike.jpg",
    "assets/images/bike.jpeg",
    "assets/images/phone.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon:
        Icon(Icons.arrow_back,color: AppColors.appWhite,)),
        title: Text("Category Screen",style: TextStyle(color: AppColors.appWhite,),),
      ),
      body:SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizer().height3),
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 2),
                  height: AppSizer().height23,
                ),
                items: carouselImages.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin:  EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          border: Border.all(color:Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.appWhite,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
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
              SizedBox(height: AppSizer().height2,),
              Padding(
                padding: EdgeInsets.all(AppSizer().height1),
                child: Text("Second Hand Cars...",style: TextStyle(color: AppColors.appGreen,fontWeight: FontWeight.w600,fontSize: AppSizer().fontSize18),),
              ),
              Divider(height:2,color: AppColors.appGreen,thickness: 3,),
              SizedBox(height: AppSizer().height3,),
              SizedBox(
                    height: AppSizer().height60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listviewImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: AppSizer().width55,
                          margin: EdgeInsets.symmetric(horizontal: AppSizer().width1),
                          child: ProductCard(
                            imagePath: listviewImages[index],
                            price: "₹ 1,15,000",
                            roomInfo: "iPhone 14 Pro",
                            description: "iPhone 13 4 month old Bill Box and warranty available",
                            location: "Prayagraj",
                            date: "23 July",
                          ),
                        );
                      },
                    ),
                  ),
              SizedBox(height: AppSizer().height1,),
              Padding(
                padding: EdgeInsets.all(AppSizer().height1),
                child: Text("All Old Items...",style: TextStyle(color: AppColors.appGreen,fontWeight: FontWeight.w600,fontSize: AppSizer().fontSize18),),
              ),
              Divider(height:2,color: AppColors.appGreen,thickness: 3,),
              SizedBox(height: AppSizer().height3,),
              SizedBox(
                height: AppSizer().height60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: listviewImages2.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: AppSizer().width55,
                      margin: EdgeInsets.symmetric(horizontal: AppSizer().width1),
                      child: ProductCard(
                        imagePath: listviewImages2[index],
                        price: "₹ 1,15,000",
                        roomInfo: "iPhone 14 Pro",
                        description: "iPhone 13 4 month old Bill Box and warranty available",
                        location: "Prayagraj",
                        date: "23 July",
                      ),
                    );
                  },
                ),
              )
                ],
              ),
        ),
      ),

    );
  }
}
