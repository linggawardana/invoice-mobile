class Order {
  final int id;
  final String invoiceNumber;
  final int grandTotal;
  final String? status;
  final List<OrderItem> items;
  final OrderShipping? shipping;

  Order({
    required this.id,
    required this.invoiceNumber,
    required this.grandTotal,
    this.status,
    required this.items,
    this.shipping,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      // Parsing aman jika dari API Laravel terkirim sebagai String
      grandTotal: json['grand_total'] is String
          ? int.tryParse(json['grand_total']) ?? 0
          : json['grand_total'] ?? 0,
      status: json['status'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : [],
      shipping: json['shipping'] != null
          ? OrderShipping.fromJson(json['shipping'])
          : null,
    );
  }
}

// --- CLASS ORDER ITEM (Daftar Barang) ---
class OrderItem {
  final String productName;
  final int quantity;
  final int price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] is String
          ? int.tryParse(json['quantity']) ?? 0
          : json['quantity'] ?? 0,
      price: json['price'] is String
          ? int.tryParse(json['price']) ?? 0
          : json['price'] ?? 0,
    );
  }
}

// --- CLASS ORDER SHIPPING (Data Pengiriman) ---
class OrderShipping {
  final String recipientName;
  final String fullAddress;
  final String phone;

  OrderShipping({
    required this.recipientName,
    required this.fullAddress,
    required this.phone,
  });

  factory OrderShipping.fromJson(Map<String, dynamic> json) {
    return OrderShipping(
      recipientName: json['recipient_name'] ?? '',
      fullAddress: json['full_address'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
