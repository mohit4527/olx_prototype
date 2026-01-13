import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KmRangeBottomSheet extends StatefulWidget {
  final Function(double km) onKmSelected;
  final double? initialKm;

  const KmRangeBottomSheet({
    super.key,
    required this.onKmSelected,
    this.initialKm,
  });

  @override
  State<KmRangeBottomSheet> createState() => _KmRangeBottomSheetState();
}

class _KmRangeBottomSheetState extends State<KmRangeBottomSheet> {
  late double _selectedKm;

  @override
  void initState() {
    super.initState();
    _selectedKm = widget.initialKm ?? 5.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(height: 20),

          // Title
          Row(
            children: [
              Icon(Icons.near_me, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Search within range',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          SizedBox(height: 30),

          // Current Value
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Text(
              '${_selectedKm.toStringAsFixed(0)} KM',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.orange,
              inactiveTrackColor: Colors.orange[100],
              thumbColor: Colors.orange,
              overlayColor: Colors.orange.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _selectedKm,
              min: 1,
              max: 50,
              divisions: 49,
              onChanged: (value) {
                setState(() => _selectedKm = value);
              },
            ),
          ),

          // Range Labels
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 KM', style: TextStyle(color: Colors.grey[600])),
                Text('50 KM', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onKmSelected(_selectedKm);
                Navigator.of(
                  context,
                ).pop(); // Use Navigator instead of Get.back()
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Apply Range',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}
