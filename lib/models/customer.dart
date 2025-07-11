import 'package:v_store/models/address.dart';
import 'package:v_store/models/cart.dart';
import 'package:v_store/models/order.dart';
import 'package:v_store/models/user.dart';

class Customer extends User {
  String name;
  String phone;
  List<Address>? address;
  List<Order>? orderHistory;
  List<String>? listCreditCards;
  Cart? cart;

  Customer({
    required super.userId,
    required super.username,
    required super.password,
    super.email,
    required this.name,
    required this.phone,
    this.address,
    this.orderHistory,
    this.listCreditCards,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      password: json['password']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: (json['address'] as List<dynamic>?)
          ?.map((item) => Address.fromJson(item as Map<String, dynamic>))
          .toList(),
      orderHistory: (json['orderHistory'] as List<dynamic>?)
          ?.map((item) => Order.fromFirestore(item as Map<String, dynamic>))
          .toList(),
      listCreditCards: (json['listCreditCards'] as List<dynamic>?)
          ?.map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'address': address?.map((item) => item.toJson()).toList(),
      'orderHistory': orderHistory?.map((item) => item.toFirestore()).toList(),
      'listCreditCards': listCreditCards,
    };
  }
}
