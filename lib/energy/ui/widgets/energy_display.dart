import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';

class EnergyDisplay extends StatefulWidget {
  const EnergyDisplay({Key? key}) : super(key: key);

  @override
  _EnergyDisplayState createState() => _EnergyDisplayState();
}

class _EnergyDisplayState extends State<EnergyDisplay> {
  @override
  void initState() {
    super.initState();
    // Request initial energy status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnergyBloc>().add(GetEnergyStatusEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnergyBloc, EnergyState>(
      builder: (context, state) {
        if (state is EnergyLoaded) {
          final energy = state.response;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, color: AppColors.cardinal, size: 24.sp),
              SizedBox(width: 4.w),
              Text(
                '${energy.currentEnergy}',
                style: TextStyle(color: AppColors.macaw, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          );
        }
        // Loading or error: show a placeholder
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Colors.grey, size: 24.sp),
            SizedBox(width: 4.w),
            Text('--', style: TextStyle(color: AppColors.macaw, fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ],
        );
      },
    );
  }
}
