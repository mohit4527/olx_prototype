import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/view/home/dealer_products_description/dealer_product_description_screen.dart';
import '../../../controller/dealer_details_controller.dart';
import '../../../controller/dealer_details_product_controller.dart';

class DealerDetailsProductScreen extends StatefulWidget {
  final String dealerId;
  final bool showSoldOnly;
  final bool showStockOnly;

  const DealerDetailsProductScreen({
    Key? key,
    required this.dealerId,
    this.showSoldOnly = false,
    this.showStockOnly = false,
  }) : super(key: key);

  @override
  State<DealerDetailsProductScreen> createState() => _DealerDetailsProductScreenState();
}

class _DealerDetailsProductScreenState extends State<DealerDetailsProductScreen> {
  final DealerDetailsController controller = Get.put(DealerDetailsController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      controller.fetchDealerDetails(widget.dealerId);
      controller.fetchDealerProducts(widget.dealerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Dealer Product Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        elevation: 4,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (controller.isDealerStatsLoading.value || controller.isProductListLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        final dealer = controller.dealerStats.value;
        final allProducts = controller.products;
        final soldProducts = controller.soldProducts;
        final stockProducts =
        allProducts.where((p) => !soldProducts.contains(p)).toList();

        List productsToShow;
        if (widget.showSoldOnly) {
          productsToShow = soldProducts;
        } else if (widget.showStockOnly) {
          productsToShow = stockProducts;
        } else {
          productsToShow = allProducts;
        }

        if (dealer == null) {
          return const Center(
            child: Text("No dealer found", style: TextStyle(color: Colors.grey)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dealer Info Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Business Name:",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      Text(dealer.businessName,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      const Text("Phone:",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      Text(dealer.phone ?? "Not available",
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section Heading
              Text(
                widget.showSoldOnly
                    ? "Sold Products"
                    : widget.showStockOnly
                    ? "Available Stock"
                    : "All Products",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 10),

              // Product List
              if (productsToShow.isEmpty)
                Center(
                    child: Text(
                      widget.showSoldOnly
                          ? "No items sold"
                          : widget.showStockOnly
                          ? "No stock available"
                          : "No products found",
                      style: const TextStyle(color: Colors.grey),
                    ))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productsToShow.length,
                  itemBuilder: (context, index) {
                    final product = productsToShow[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(() =>
                            DealerDescriptionScreen(productId: product.id));
                      },
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.title,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800)),
                              const SizedBox(height: 5),
                              Text(product.description,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 5),
                              Text("Price: ₹${product.price}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green.shade700)),
                              const SizedBox(height: 5),
                              Text("Location: ${dealer.businessName}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
