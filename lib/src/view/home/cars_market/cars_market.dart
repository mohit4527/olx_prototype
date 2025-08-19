import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';

class CarsMarket extends StatelessWidget {
  const CarsMarket({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> carList = [
      {
        'image': 'assets/images/thaar.jpg',
        'price': '₹ 276,000',
        'title': 'Maruti Suzuki',
        "place" : "Jamshedpur,UP"
      },
      {
        'image': 'assets/images/alto.jpg',
        'price': '₹ 165,000',
        'title': 'Alto 800 2015',
        "place" : "Singrauli,Bihar"
      },
      {
        'image': 'assets/images/ertiga.jpg',
        'price': '₹ 80,000',
        'title': 'Ertiga',
        "place" : "America,USA"
      },
      {
        'image': 'assets/images/scorpio.jpg',
        'price': '₹ 1,500,000',
        'title': 'Mahindra Scorpio',
        "place" : "Raipur,CG"
      },
      {
        'image': 'assets/images/car2.jpg',
        'price': '₹ 1,50,000',
        'title': "Mercedes",
        "place" : "Prayagraj,UP"
      },
      {
        'image': 'assets/images/cars.jpg',
        'price': '₹ 1,32,000',
        'title': 'Bugati',
        "place" : "Rohtas,Bihar"
      },
      {
        'image': 'assets/images/ertiga.jpg',
        'price': '₹ 80,000',
        'title': 'Ertiga',
        "place" : "Mumbai,MH"
      },
      {
        'image': 'assets/images/Suzuki.jpeg',
        'price': '₹ 2,76,000',
        'title': 'Maruti Suzuki',
        "place" : "Indore,MP"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appGreen,
        title: const Text("Cars Market",style: TextStyle(color: AppColors.appWhite),),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back,color: AppColors.appWhite,),
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
              onTap: (){
                Get.toNamed(AppRoutes.description);
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
                        borderRadius:
                       BorderRadius.vertical(top: Radius.circular(8)),
                        image: DecorationImage(
                          image: AssetImage(car['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizer().height2),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 8.0),
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
                      padding:
                     EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
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
                              Icon(Icons.place,color: AppColors.appWhite,),
                              Text(car['place']!,style: TextStyle(
                                color: AppColors.appWhite,
                                fontSize: AppSizer().fontSize16,),),
                            ],
                          )
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
