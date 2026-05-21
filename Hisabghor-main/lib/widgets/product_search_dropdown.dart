import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class ProductSearchDropdown extends StatefulWidget {
  final Function(Product) onProductSelected;
  final DatabaseService databaseService;

  const ProductSearchDropdown({
    Key? key,
    required this.onProductSelected,
    required this.databaseService,
  }) : super(key: key);

  @override
  State<ProductSearchDropdown> createState() => _ProductSearchDropdownState();
}

class _ProductSearchDropdownState extends State<ProductSearchDropdown> {
  final TextEditingController _controller = TextEditingController();
  List<Product> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    
    // Simple delay to prevent too many queries
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_controller.text.trim() != query) return;

    final results = await widget.databaseService.searchProducts(query);
    
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Search Product (বাংলা/English)',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
        ),
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final product = _searchResults[index];
                return ListTile(
                  title: Text(product.displayName),
                  subtitle: Text('Stock: ${product.stockQuantity} | Price: ৳${product.sellPrice}'),
                  onTap: () {
                    widget.onProductSelected(product);
                    _controller.clear();
                    setState(() => _searchResults = []);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
