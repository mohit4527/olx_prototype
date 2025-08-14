import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../custom_widgets/history-card.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> dummyHistory = [
      {
        "image": "assets/images/alto.jpg",
        "title": "Maruti Suzuki Alto 800 ",
        "location": "Prayagraj,Up",
        "price": "5,600,00",
      },
      {
        "image": "assets/images/cars.jpg",
        "title": "Mercedees Benz",
        "location": "Gorakhpur,UP",
        "price": "2,950,000",
      },
      {
        "image": "assets/images/ertiga.jpg",
        "title": "Ertiga XL",
        "location": "Gonda,Up",
        "price": "8,80,00",
      },
      {
        "image": "assets/images/Suzuki.jpeg",
        "title": "Maruti Suzuki Swift Dzire",
        "location": "Indore,MP",
        "price": "1,400,00",
      },
      {
        "image": "assets/images/scorpio.jpg",
        "title": "Scorpio Old Model",
        "location": "Raipur,Chhattisgarh",
        "price": "830,00",
      },
      {
        "image": "assets/images/carouselbike.jpg",
        "title": "Kawasaki Ninja H2R",
        "location": "Noida",
        "price": "830,00",
      },
      {
        "image": "assets/images/car2.jpg",
        "title": "Mercedees Top Model",
        "location": "Delhi",
        "price": "830,00",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your History",
          style: TextStyle(
            fontSize: AppSizer().fontSize20,
            color: AppColors.appWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appGreen,
        elevation: 0,
      ),
      body:  Container(
      height: AppSizer().height100,
         decoration: BoxDecoration(
          gradient: LinearGradient(
          colors: AppColors.appGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
       ),
      ),
      child:
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizer().width2),
        child: ListView.builder(
          itemCount: dummyHistory.length,
          itemBuilder: (context, index) {
            final item = dummyHistory[index];
            return HistoryCard(
              image: item["image"]!,
              title: item["title"]!,
              location: item["location"]!,
              price: item["price"]!,
            );
          },
        ),
      ),
      )
    );
  }
}
