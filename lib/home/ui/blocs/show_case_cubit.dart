import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShowcaseState {
  final bool hasSeenLessonShowcase;
  final bool hasSeenAppBarShowcase;
  final bool hasSeenNavBarShowcase;

  const ShowcaseState({
    this.hasSeenLessonShowcase = true,
    this.hasSeenAppBarShowcase = true,
    this.hasSeenNavBarShowcase = true,
  });

  ShowcaseState copyWith({
    bool? hasSeenLessonShowcase,
    bool? hasSeenAppBarShowcase,
    bool? hasSeenNavBarShowcase,
  }) {
    return ShowcaseState(
      hasSeenLessonShowcase:
          hasSeenLessonShowcase ?? this.hasSeenLessonShowcase,
      hasSeenAppBarShowcase:
          hasSeenAppBarShowcase ?? this.hasSeenAppBarShowcase,
      hasSeenNavBarShowcase:
          hasSeenNavBarShowcase ?? this.hasSeenNavBarShowcase,
    );
  }
}

class ShowCaseCubit extends Cubit<ShowcaseState> {
  final Map<String, GlobalKey> showcaseKeys = {};

  ShowCaseCubit() : super(const ShowcaseState());

  void registerKey(String name, GlobalKey key) {
    showcaseKeys[name] = key;
  }

  GlobalKey? getKey(String name) => showcaseKeys[name];

  void markLessonShowcaseSeen() {
    emit(state.copyWith(hasSeenLessonShowcase: true));
  }

  void markAppBarShowcaseSeen() {
    emit(state.copyWith(hasSeenAppBarShowcase: true));
  }

  void markNavBarShowcaseSeen() {
    emit(state.copyWith(hasSeenNavBarShowcase: true));
  }

  void resetNavShowCase() {
    emit(
      state.copyWith(
        hasSeenAppBarShowcase: false,
        hasSeenNavBarShowcase: false,
      ),
    );
  }

  void resetLessonShowCase() {
    emit(state.copyWith(hasSeenLessonShowcase: false));
  }
}
