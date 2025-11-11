import 'package:flutter_bloc/flutter_bloc.dart';

class ShowcaseState {
  final bool hasSeenHomeShowcase;
  final bool hasSeenAppBarShowcase;
  final bool hasSeenNavBarShowcase;

  const ShowcaseState({
    this.hasSeenHomeShowcase = true,
    this.hasSeenAppBarShowcase = true,
    this.hasSeenNavBarShowcase = true,
  });

  ShowcaseState copyWith({
    bool? hasSeenHomeShowcase,
    bool? hasSeenAppBarShowcase,
    bool? hasSeenNavBarShowcase,
  }) {
    return ShowcaseState(
      hasSeenHomeShowcase: hasSeenHomeShowcase ?? this.hasSeenHomeShowcase,
      hasSeenAppBarShowcase:
          hasSeenAppBarShowcase ?? this.hasSeenAppBarShowcase,
      hasSeenNavBarShowcase:
          hasSeenNavBarShowcase ?? this.hasSeenNavBarShowcase,
    );
  }
}

class ShowCaseCubit extends Cubit<ShowcaseState> {
  ShowCaseCubit() : super(const ShowcaseState());
  void markHomeShowcaseSeen() {
    emit(state.copyWith(hasSeenHomeShowcase: true));
  }

  void markAppBarShowcaseSeen() {
    emit(state.copyWith(hasSeenAppBarShowcase: true));
  }

  void markNavBarShowcaseSeen() {
    emit(state.copyWith(hasSeenNavBarShowcase: true));
  }

  void reset() {
    emit(
      state.copyWith(
        hasSeenAppBarShowcase: false,
        hasSeenHomeShowcase: false,
        hasSeenNavBarShowcase: false,
      ),
    );
  }
}
