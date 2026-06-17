import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/shop_datasource.dart';
import '../../data/models/shop_model.dart';
import 'package:equatable/equatable.dart';

abstract class ShopEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadShopEvent extends ShopEvent {}
class LoadInventoryEvent extends ShopEvent {}
class BuyItemEvent extends ShopEvent {
  final String itemId;
  BuyItemEvent(this.itemId);
  @override
  List<Object?> get props => [itemId];
}
class OpenChestEvent extends ShopEvent {}
class EquipItemEvent extends ShopEvent {
  final String itemId;
  EquipItemEvent(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class ShopState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final String? successMessage;
  final List<ShopItemModel> items;
  final List<UserInventoryModel> inventory;
  final UserEquippedItemModel? equipped;
  final Map<String, dynamic>? chestReward;

  const ShopState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.successMessage,
    this.items = const [],
    this.inventory = const [],
    this.equipped,
    this.chestReward,
  });

  ShopState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    String? successMessage,
    List<ShopItemModel>? items,
    List<UserInventoryModel>? inventory,
    UserEquippedItemModel? equipped,
    Map<String, dynamic>? chestReward,
  }) {
    return ShopState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: error,
      successMessage: successMessage,
      items: items ?? this.items,
      inventory: inventory ?? this.inventory,
      equipped: equipped ?? this.equipped,
      chestReward: chestReward,
    );
  }

  @override
  List<Object?> get props => [isLoading, isActionLoading, error, successMessage, items, inventory, equipped, chestReward];
}

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopDatasource _datasource;

  ShopBloc(this._datasource) : super(const ShopState()) {
    on<LoadShopEvent>(_onLoadShop);
    on<LoadInventoryEvent>(_onLoadInventory);
    on<BuyItemEvent>(_onBuyItem);
    on<OpenChestEvent>(_onOpenChest);
    on<EquipItemEvent>(_onEquipItem);
  }

  Future<void> _onLoadShop(LoadShopEvent event, Emitter<ShopState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await _datasource.getShopItems();
      emit(state.copyWith(isLoading: false, items: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadInventory(LoadInventoryEvent event, Emitter<ShopState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final inventory = await _datasource.getInventory();
      final equipped = await _datasource.getEquippedItem();
      emit(state.copyWith(isLoading: false, inventory: inventory, equipped: equipped));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onBuyItem(BuyItemEvent event, Emitter<ShopState> emit) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      final res = await _datasource.buyItem(event.itemId);
      emit(state.copyWith(isActionLoading: false, successMessage: res['message']));
      add(LoadInventoryEvent()); // refresh inventory
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      emit(state.copyWith(isActionLoading: false, error: 'Failed to buy: $errorMessage'));
    }
  }

  Future<void> _onOpenChest(OpenChestEvent event, Emitter<ShopState> emit) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      final res = await _datasource.openChest();
      emit(state.copyWith(
        isActionLoading: false, 
        successMessage: res['message'],
        chestReward: res['reward'],
      ));
      add(LoadInventoryEvent()); // refresh inventory
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      emit(state.copyWith(isActionLoading: false, error: errorMessage));
    }
  }

  Future<void> _onEquipItem(EquipItemEvent event, Emitter<ShopState> emit) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await _datasource.equipItem(event.itemId);
      emit(state.copyWith(isActionLoading: false, successMessage: 'Equipped successfully'));
      add(LoadInventoryEvent()); // refresh equipped
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      emit(state.copyWith(isActionLoading: false, error: 'Failed to equip: $errorMessage'));
    }
  }
}
