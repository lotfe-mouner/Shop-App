import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/cart_screen.dart';
import 'package:shop/screens/product_grid.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/badge.dart';

import '../providers/cart.dart';
import '../providers/products.dart';

enum FilterOption { Favorite, All }

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isLoading = false;
  var _showOnlyFavorite = false;

  @override
  void initState() {
    _isLoading = true;
    Provider.of<Products>(context, listen: false).fetchAndSetProducts();

   _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOption.Favorite,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOption.All,
              ),
            ],
            onSelected: (FilterOption selectedVal) {
              setState(() {
                if (selectedVal == FilterOption.Favorite) {
                  _showOnlyFavorite = true;
                } else {
                  _showOnlyFavorite = false;
                }
              });
            },
          ),
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined),
              onPressed: () => Navigator.of(context).pushNamed(CartScreen.routeName),),
            builder: (_, cart, child) => Badge(
              child: child!,
              value: cart.itemCount.toString(),color: Theme.of(context).colorScheme.secondary,
            ),
          )
        ],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : ProductsGrid(_showOnlyFavorite),
      drawer: AppDrawer(),
    );
  }
}
