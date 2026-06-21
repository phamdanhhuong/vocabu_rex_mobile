import os

# 1. Fix alignment in PodcastMatchQuestionWidget & Add Animations
file_path = r"c:\TLCN\vocabu_rex_mobile\lib\exercise\ui\widgets\exercises\podcast_question_widgets.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import animate_do
if "import 'package:animate_do/animate_do.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:animate_do/animate_do.dart';")

# Fix row alignment in Match
old_row = """                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column"""

new_row = """                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column"""

content = content.replace(old_row, new_row)

# Add FadeInUp to PodcastMatchQuestionWidget
old_match_build = """  @override
  Widget build(BuildContext context) {
    return Container("""
new_match_build = """  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container("""
content = content.replace(old_match_build, new_match_build)
# Close FadeInUp
old_match_end = """        ],
      ),
    );
  }
}

/// True/False question widget"""
new_match_end = """        ],
      ),
    ),
    );
  }
}

/// True/False question widget"""
content = content.replace(old_match_end, new_match_end)

# Add FadeInUp to TrueFalse
old_tf_build = """  @override
  Widget build(BuildContext context) {
    return Container("""
new_tf_build = """  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container("""
content = content.replace(old_tf_build, new_tf_build)
# Close TrueFalse
old_tf_end = """        ],
      ),
    );
  }"""
new_tf_end = """        ],
      ),
    ),
    );
  }"""
content = content.replace(old_tf_end, new_tf_end)

# Add FadeInUp to ListenChoose
old_lc_build = """  @override
  Widget build(BuildContext context) {
    return Container("""
new_lc_build = """  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container("""
content = content.replace(old_lc_build, new_lc_build)
# Close ListenChoose
old_lc_end = """        ],
      ),
    );
  }"""
new_lc_end = """        ],
      ),
    ),
    );
  }"""
content = content.replace(old_lc_end, new_lc_end)

# Add FadeInUp to MultipleChoice
old_mc_build = """  @override
  Widget build(BuildContext context) {
    return Container("""
new_mc_build = """  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container("""
content = content.replace(old_mc_build, new_mc_build)
# Close MultipleChoice
old_mc_end = """        ],
      ),
    );
  }"""
new_mc_end = """        ],
      ),
    ),
    );
  }"""
content = content.replace(old_mc_end, new_mc_end)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)


# 2. Add animation to podcast_controls.dart
controls_path = r"c:\TLCN\vocabu_rex_mobile\lib\exercise\ui\widgets\exercises\enhanced_podcast\widgets\podcast_controls.dart"
with open(controls_path, 'r', encoding='utf-8') as f:
    c_content = f.read()

if "import 'package:animate_do/animate_do.dart';" not in c_content:
    c_content = c_content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:animate_do/animate_do.dart';")

old_controls_build = """  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;

    return Container("""

new_controls_build = """  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container("""

old_controls_end = """          ],
        ),
      ),
    );
  }"""

new_controls_end = """          ],
        ),
      ),
    ),
    );
  }"""

c_content = c_content.replace(old_controls_build, new_controls_build)
c_content = c_content.replace(old_controls_end, new_controls_end)

with open(controls_path, 'w', encoding='utf-8') as f:
    f.write(c_content)

print("Patch applied for animations and alignment.")
