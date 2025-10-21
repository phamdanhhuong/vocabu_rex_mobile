import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
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
              Icon(Icons.bolt, color: AppColors.primaryYellow, size: 20.sp),
              SizedBox(width: 6.w),
              Text(
                '${energy.currentEnergy}/${energy.maxEnergy}',
                style: TextStyle(color: AppColors.textBlue, fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          );
        }
        // Loading or error: show a placeholder
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, color: Colors.grey, size: 20.sp),
            SizedBox(width: 6.w),
            Text('--', style: TextStyle(color: AppColors.textBlue, fontSize: 14.sp, fontWeight: FontWeight.w600)),
          ],
        );
      },
    );
  }
}
