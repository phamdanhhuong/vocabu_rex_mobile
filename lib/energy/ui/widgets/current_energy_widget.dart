import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/energy_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'energy_dropdown_overlay.dart';

class CurrentEnergyWidget extends StatefulWidget {
  final VoidCallback? onTapEnergy;

  const CurrentEnergyWidget({
    Key? key,
    this.onTapEnergy,
  }) : super(key: key);

  @override
  State<CurrentEnergyWidget> createState() => _CurrentEnergyWidgetState();
}

class _CurrentEnergyWidgetState extends State<CurrentEnergyWidget> {
  final GlobalKey _energyKey = GlobalKey();
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    // Listen to BLoC states for buy success/error
    context.read<EnergyBloc>().stream.listen((state) {
      if (state is EnergyBuySuccess) {
        _hideOverlay();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mua năng lượng thành công! +${state.purchase.energyPurchased}'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (state is EnergyBuyError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${state.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnergyBloc, EnergyState>(
      builder: (context, state) {
        if (state is EnergyLoaded) {
          final energy = state.response.currentEnergy;
          final maxEnergy = state.response.maxEnergy;
          return CompositedTransformTarget(
            link: _link,
            child: GestureDetector(
              key: _energyKey,
              onTap: () {
                if (_isOverlayVisible) {
                  _hideOverlay();
                } else {
                  _showOverlay(context);
                }
                widget.onTapEnergy?.call();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: Colors.yellow, size: 24),
                  const SizedBox(width: 4),
                  Text('$energy/$maxEnergy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow)),
                ],
              ),
            ),
          );
        } else if (state is EnergyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is EnergyError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showOverlay(BuildContext context) {
    if (_isOverlayVisible) return;

    final energyState = context.read<EnergyBloc>().state;
    final currencyState = context.read<CurrencyBloc>().state;

    if (energyState is! EnergyLoaded || currencyState is! CurrencyLoaded) {
      return;
    }

    final RenderBox renderBox = _energyKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: offset.dy + size.height,
        child: Material(
          color: Colors.transparent,
          child: EnergyDropdownOverlay(
            onClose: _hideOverlay,
            currentEnergy: energyState.response.currentEnergy,
            maxEnergy: energyState.response.maxEnergy,
            timeUntilNextRecharge: energyState.response.rechargeInfo.timeUntilNextRecharge,
            gemCost: energyState.response.pricing.gemCost,
            coinCost: energyState.response.pricing.coinCost,
            gemsBalance: currencyState.balance.gems,
            coinsBalance: currencyState.balance.coins,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOverlayVisible = true;
    });
  }

  void _hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() {
        _isOverlayVisible = false;
      });
    }
  }
}
