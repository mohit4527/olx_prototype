import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/fuel_controller.dart';

class CheckFuelScreen extends StatelessWidget {
  final String city;
  final String state;

  const CheckFuelScreen({
    super.key,
    required this.city,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FuelController());
    controller.loadFuelPrices(city, state);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fuel Prices",
          style: TextStyle(
            color: AppColors.appWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
        body:  Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.fuelList.isEmpty) {
            return const Center(child: Text("No fuel data available"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppSizer().height2),
            itemCount: controller.fuelList.length,
            itemBuilder: (context, index) {
              final fuel = controller.fuelList[index];
              final isUp = fuel.trend.toLowerCase() == "up";

              return Card(
                margin: EdgeInsets.symmetric(vertical: AppSizer().height1),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(
                    isUp ? Icons.trending_up : Icons.trending_down,
                    color: isUp ? Colors.green : Colors.red,
                    size: AppSizer().fontSize20,
                  ),
                  title: Text(
                    fuel.fuel,
                    style: TextStyle(
                      fontSize: AppSizer().fontSize18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Updated: ${fuel.date}\nChange: ${fuel.change}",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: Text(
                    fuel.price,
                    style: TextStyle(
                      fontSize: AppSizer().fontSize17,
                      color: AppColors.appBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          );
        }),
    );
  }
}
