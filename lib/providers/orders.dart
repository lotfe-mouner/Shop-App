import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'cart.dart';




class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier{

  List<OrderItem> _orders = [];
  String? authToken;
  String? userId;

  getData(String? authTok, String? uId, List<OrderItem> orders) {
    authToken = authTok;
    userId = uId;
    _orders=orders;
    notifyListeners();
  }
  List<OrderItem> get orders{
    return [..._orders];
  }



  Future<void> fetchAndSetOrders() async {

    final url=Uri.parse('https://flutter-app-47850-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');

    try{
      final res=await http.get(url);

      final extractedData=json.decode(res.body)as Map<String,dynamic>;
      if(extractedData ==null){
        return;
      }


      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((prodId, orderData) {
        loadedOrders.add(OrderItem(
            id:prodId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products']as List<dynamic>).map((item) =>
                CartItem(id: item['id'], title: item['title'], quantity: item['quantity'], price: item['price'])).toList(),
        ));
        _orders = loadedOrders.reversed.toList();
        notifyListeners();
      });
    }catch(error){
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {

    var url=Uri.parse('https://flutter-app-47850-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');

    try{
      final timeStamp= DateTime.now();
      final res =await http.post(url,body: json.encode({
        'amount': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProduct.map((cartProd)=>{
          'id': cartProd.id,
          'title':cartProd.title,
          'quantity': cartProd.quantity,
          'price' : cartProd.price
        }).toList(),
      }));

      _orders.insert(0, OrderItem(id: json.decode(res.body)['name'], amount: total, products: cartProduct, dateTime: timeStamp));
      notifyListeners();
    }catch(error){throw error;}
  }


}