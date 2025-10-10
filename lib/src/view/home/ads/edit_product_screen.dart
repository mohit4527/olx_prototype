import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../../../services/apiServices/apiServices.dart';
import '../../../model/all_product_model/all_product_model.dart';

class EditProductScreen extends StatefulWidget {
  final AllProductModel product;
  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtr;
  late TextEditingController _priceCtr;
  late TextEditingController _descCtr;
  late TextEditingController _cityCtr;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtr = TextEditingController(text: widget.product.title);
    _priceCtr = TextEditingController(text: widget.product.price.toString());
    _descCtr = TextEditingController(text: widget.product.description);
    _cityCtr = TextEditingController(text: widget.product.location.city);
  }

  @override
  void dispose() {
    _titleCtr.dispose();
    _priceCtr.dispose();
    _descCtr.dispose();
    _cityCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = {
      'title': _titleCtr.text.trim(),
      'price': _priceCtr.text.trim(),
      'description': _descCtr.text.trim(),
      'location': {
        'city': _cityCtr.text.trim(),
        'state': widget.product.location.state,
        'country': widget.product.location.country,
      },
    };

    final ok = await ApiService.editProduct(widget.product.id, updated);
    setState(() => _saving = false);
    if (ok) {
      // Build an updated AllProductModel to return to caller so UI can update immediately
      final updatedProduct = AllProductModel(
        id: widget.product.id,
        title: _titleCtr.text.trim(),
        description: _descCtr.text.trim(),
        price: int.tryParse(_priceCtr.text.trim()) ?? widget.product.price,
        userId: widget.product.userId,
        mediaUrl: widget.product.mediaUrl,
        isBoosted: widget.product.isBoosted,
        whatsapp: widget.product.whatsapp,
        location: Location(
          country: widget.product.location.country,
          state: widget.product.location.state,
          city: _cityCtr.text.trim(),
        ),
        createdAt: widget.product.createdAt,
      );

      Get.snackbar(
        'Saved',
        'Product updated',
        backgroundColor: AppColors.appGreen,
        colorText: Colors.white,
      );
      // Return the updated product to the caller for an immediate local update
      Get.back(result: {'product': updatedProduct});
    } else {
      Get.snackbar(
        'Error',
        ApiService.apiLastError.isNotEmpty
            ? ApiService.apiLastError
            : 'Failed to update',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: AppColors.appGreen,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizer().height2),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtr,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtr,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtr,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtr,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appGreen,
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
