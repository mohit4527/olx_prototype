import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterSection extends StatelessWidget {
  final VoidCallback onSearchByCity;
  final VoidCallback onSearchByKm;
  final VoidCallback onNearby;
  final VoidCallback? onClearFilters;
  final String? selectedCity;
  final double? selectedKm;
  final bool isLoading;

  const FilterSection({
    super.key,
    required this.onSearchByCity,
    required this.onSearchByKm,
    required this.onNearby,
    this.onClearFilters,
    this.selectedCity,
    this.selectedKm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Full Width Search by City Button
          SizedBox(
            width: double.infinity,
            child: _FilterButton(
              icon: Icons.location_city,
              label: selectedCity ?? 'Search by City',
              isSelected: selectedCity != null,
              color: Colors.green,
              onTap: isLoading ? null : onSearchByCity,
            ),
          ),

          // Clear Filters Button (show only when filters are active)
          if (selectedCity != null && onClearFilters != null)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: isLoading ? null : onClearFilters,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear, size: 16, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'Clear Filters',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;
  final bool disabled;

  const _FilterButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: double.infinity, // Full width
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey[200]
              : isSelected
              ? color.withOpacity(0.15)
              : Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(25),
          border: isSelected && !disabled
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: disabled
                  ? Colors.grey[400]
                  : isSelected
                  ? color
                  : Colors.grey[600],
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: disabled
                    ? Colors.grey[400]
                    : isSelected
                    ? color
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
