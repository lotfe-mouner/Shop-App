import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/widgets/app_drawer.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  const UserProductScreen({Key? key}) : super(key: key);

  static const routeName = 'user-product';

  Future<void> _refreshProducts(BuildContext context) async {
    Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton( icon: Icon(Icons.add),onPressed:()=>Navigator.of(context).pushNamed(EditProductScreen.routeName))
        ],
      ),
      body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (ctx, AsyncSnapshot snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: Consumer<Products>(
                        builder: (ctx, productData, _) => Padding(
                          padding: EdgeInsets.all(8),
                          child: ListView.builder(
                              itemCount: productData.items.length,
                              itemBuilder: (_, index) => Column(
                                    children: [
                                      UserProductItem(
                                          productData.items[index].id,
                                          productData.items[index].title,
                                          productData.items[index].imageUrl),
                                      Divider()
                                    ],
                                  )),
                        ),
                      ))),
      drawer: AppDrawer(),
    );
  }
}
