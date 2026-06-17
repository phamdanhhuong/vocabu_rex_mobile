class ShopItemModel {
  final String id;
  final String name;
  final String? description;
  final String category;
  final int price;
  final String currencyType;
  final String? imageUrl;
  final bool isActive;

  ShopItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    required this.currencyType,
    this.imageUrl,
    required this.isActive,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      price: json['price'],
      currencyType: json['currencyType'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
    );
  }
}

class UserInventoryModel {
  final String id;
  final String itemId;
  final int quantity;
  final ShopItemModel item;

  UserInventoryModel({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.item,
  });

  factory UserInventoryModel.fromJson(Map<String, dynamic> json) {
    return UserInventoryModel(
      id: json['id'],
      itemId: json['itemId'],
      quantity: json['quantity'],
      item: ShopItemModel.fromJson(json['item']),
    );
  }
}

class UserEquippedItemModel {
  final String? frameId;
  final String? backgroundId;

  UserEquippedItemModel({this.frameId, this.backgroundId});

  factory UserEquippedItemModel.fromJson(Map<String, dynamic> json) {
    return UserEquippedItemModel(
      frameId: json['frameId'],
      backgroundId: json['backgroundId'],
    );
  }
}
