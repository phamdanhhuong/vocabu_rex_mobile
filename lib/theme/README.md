Theme system (Duolingo-inspired)

Files
- `colors.dart` — color tokens and semantic colors.
- `typography.dart` — TextTheme and font family.
- `light_theme.dart`, `dark_theme.dart` — ThemeData for light/dark.
- `app_theme.dart` — simple exporter and helper.
- `components/button_theme.dart` — button styles.

How to use
1. In `main.dart`, import `package:your_app/theme/app_theme.dart` and set:

   MaterialApp(
     theme: AppTheme.light(),
     darkTheme: AppTheme.dark(),
     themeMode: ThemeMode.system,
   )

Fonts
- If you want a custom font (e.g., Inter or a playful rounded font), add it to `pubspec.yaml` under `fonts:` and reference the family name in `typography.dart`.

Extending
- Add more component theming under `components/` (inputs, cards, chips).
- Use `ThemeExtension` when you need custom, mode-aware tokens (gradients, illustrations colors).
