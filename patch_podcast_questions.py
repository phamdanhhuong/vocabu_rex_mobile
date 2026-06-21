import os

file_path = r"c:\TLCN\vocabu_rex_mobile\lib\exercise\ui\widgets\exercises\podcast_question_widgets.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace general container decorations for questions
old_container_dec = """      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppPreferences().isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),"""

new_container_dec = """      decoration: BoxDecoration(
        color: AppPreferences().isDarkMode ? AppColors.eel : AppColors.snow,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppPreferences().isDarkMode ? AppColors.swan : AppColors.polar, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppPreferences().isDarkMode ? Colors.black.withOpacity(0.2) : AppColors.hare.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),"""

content = content.replace(old_container_dec, new_container_dec)

# Fix True/False Statement box
old_tf_statement = """            decoration: BoxDecoration(
              color: AppColors.polar,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.swan, width: 1.w),
            ),
            child: Text(
              _question.statement,
              style: AppTypography.defaultTextTheme().bodyLarge?.copyWith(
                color: AppColors.eel,"""

new_tf_statement = """            decoration: BoxDecoration(
              color: AppPreferences().isDarkMode ? AppColors.swan : AppColors.polar,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppPreferences().isDarkMode ? AppColors.hare.withOpacity(0.3) : AppColors.swan, width: 1.w),
            ),
            child: Text(
              _question.statement,
              style: AppTypography.defaultTextTheme().bodyLarge?.copyWith(
                color: AppColors.bodyText,"""

content = content.replace(old_tf_statement, new_tf_statement)

# Fix True/False buttons
old_tf_btn = """        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2.w),
          borderRadius: BorderRadius.circular(12.r),
        ),"""

new_tf_btn = """        decoration: BoxDecoration(
          color: color.withOpacity(AppPreferences().isDarkMode ? 0.2 : 0.1),
          border: Border.all(color: color, width: 2.w),
          borderRadius: BorderRadius.circular(16.r),
        ),"""

content = content.replace(old_tf_btn, new_tf_btn)

# Fix Multiple Choice Option Button
old_mc_btn = """        decoration: BoxDecoration(
          color: AppColors.polar,
          border: Border.all(color: AppColors.macaw, width: 2.w),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          option,
          style: AppTypography.defaultTextTheme().bodyMedium?.copyWith(
            color: AppColors.eel,"""

new_mc_btn = """        decoration: BoxDecoration(
          color: AppPreferences().isDarkMode ? AppColors.swan : AppColors.polar,
          border: Border.all(color: AppColors.macaw.withOpacity(0.5), width: 2.w),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          option,
          style: AppTypography.defaultTextTheme().bodyMedium?.copyWith(
            color: AppColors.bodyText,"""

content = content.replace(old_mc_btn, new_mc_btn)

# Fix Listen Choose Word Chip
old_chip = """        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.macaw.withOpacity(0.2)
              : AppColors.polar,
          border: Border.all(
            color: isSelected ? AppColors.macaw : AppColors.swan,
            width: 2.w,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          word,
          style: AppTypography.defaultTextTheme().bodyMedium?.copyWith(
            color: isSelected ? AppColors.macaw : AppColors.eel,"""

new_chip = """        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.macaw.withOpacity(AppPreferences().isDarkMode ? 0.3 : 0.2)
              : (AppPreferences().isDarkMode ? AppColors.swan : AppColors.polar),
          border: Border.all(
            color: isSelected ? AppColors.macaw : (AppPreferences().isDarkMode ? AppColors.hare.withOpacity(0.3) : AppColors.swan),
            width: 2.w,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          word,
          style: AppTypography.defaultTextTheme().bodyMedium?.copyWith(
            color: isSelected ? AppColors.macaw : AppColors.bodyText,"""

content = content.replace(old_chip, new_chip)

# Fix Question Text colors (replace AppColors.eel with AppColors.bodyText)
content = content.replace("color: AppColors.eel,", "color: AppColors.bodyText,")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Podcast questions UI patched.")
