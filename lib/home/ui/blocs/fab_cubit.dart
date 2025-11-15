import 'package:flutter_bloc/flutter_bloc.dart';

class FabCubit extends Cubit<bool> {
  FabCubit() : super(true); // Mặc định hiện FAB

  void show() => emit(true);
  void hide() => emit(false);
}
