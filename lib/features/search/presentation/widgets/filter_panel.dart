import 'package:flutter/material.dart';
import 'package:wetravellers/features/search/domain/search_filters.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';

class FilterPanel extends StatefulWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;
  const FilterPanel({super.key, required this.filters, required this.onChanged});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late double _minPrice;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.filters.priceMin ?? 0;
    _maxPrice = widget.filters.priceMax ?? 1000;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: 'Price range filter',
          child: Text('Price Range'),
        ),
        Semantics(
          label: 'Price range slider, minimum ${_minPrice.toStringAsFixed(0)}, maximum ${_maxPrice.toStringAsFixed(0)}',
          child: RangeSlider(
            min: 0,
            max: 1000,
            values: RangeValues(_minPrice, _maxPrice),
            onChanged: (v) {
              setState(() {
                _minPrice = v.start;
                _maxPrice = v.end;
              });
              widget.onChanged(widget.filters.copyWith(priceMin: _minPrice, priceMax: _maxPrice));
            },
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Semantics(
          button: true,
          label: 'Reset filters',
          child: ElevatedButton(
            onPressed: () {
              widget.onChanged(const SearchFilters());
            },
            child: const Text('Reset Filters'),
          ),
        ),
      ],
    );
  }
}
