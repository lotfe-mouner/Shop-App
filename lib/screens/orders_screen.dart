import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/orders.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  static const routeName = 'order';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Order'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: Provider.of<Orders>(context,listen: false).fetchAndSetOrders(),
            builder: (ctx, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else  {
                if (snapshot.error != null) {
                  return Center(child: Text('An error Occurred!'));
                } else {
                  return Consumer<Orders>(builder: (ctx, orderData, child) =>
                      ListView.builder(
                          itemCount: orderData.orders.length,
                          itemBuilder: (ctx,index) =>
                              OrderItems(
                                orderData.orders[index]
                              )));
                }
              }
            }
        )

    );
  }
}
