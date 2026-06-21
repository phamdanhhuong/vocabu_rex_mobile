import os

file_select = r"c:\TLCN\vocabu_rex_mobile\lib\exercise\ui\widgets\exercises\listen_choose_select.dart"

with open(file_select, 'r', encoding='utf-8') as f:
    content = f.read()

old_wrap_children = """              children: availableWords.map((word) {
                int drawn = drawnCounts[word] ?? 0;
                drawnCounts[word] = drawn + 1;
                
                int selected = selectedCounts[word] ?? 0;
                bool isUsed = drawn < selected;

                return _NeumorphicWordTile(
                  word: word,
                  isPlaceholder: isUsed,
                  onTap: () {
                    if (!isUsed && !isSubmitted && !revealed) {
                      HapticFeedback.lightImpact();
                      onSelectWord(word);
                    }
                  },
                );
              }).toList(),"""

new_wrap_children = """              children: availableWords.asMap().entries.map((entry) {
                int index = entry.key;
                String word = entry.value;

                int drawn = drawnCounts[word] ?? 0;
                drawnCounts[word] = drawn + 1;
                
                int selected = selectedCounts[word] ?? 0;
                bool isUsed = drawn < selected;

                return FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 100 * index),
                  child: _NeumorphicWordTile(
                    word: word,
                    isPlaceholder: isUsed,
                    onTap: () {
                      if (!isUsed && !isSubmitted && !revealed) {
                        HapticFeedback.lightImpact();
                        onSelectWord(word);
                      }
                    },
                  ),
                );
              }).toList(),"""

content = content.replace(old_wrap_children, new_wrap_children)

with open(file_select, 'w', encoding='utf-8') as f:
    f.write(content)

print("Staggered animation applied.")
