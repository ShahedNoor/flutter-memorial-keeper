import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

/// Horizontal scrollable category filter chips.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;

    final filters = [
      {'id': 'all', 'label': 'home.filter_all'.tr()},
      {'id': 'parents', 'label': 'home.filter_parents'.tr()},
      {'id': 'grandparents', 'label': 'home.filter_grandparents'.tr()},
      {'id': 'relatives', 'label': 'home.filter_relatives'.tr()},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedCategory == f['id'];
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: cs.primary,
              backgroundColor: cs.surfaceContainerLow,
              side: BorderSide(
                color: isSelected ? cs.primary : cs.outlineVariant,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : cs.onSurface,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(f['id']!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
