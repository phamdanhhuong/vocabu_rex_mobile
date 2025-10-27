## Hướng dẫn nhanh cho illustration (phiên bản rút gọn)

Mục tiêu: dễ đọc, giữ nguyên ý chính, áp dụng trực tiếp khi thiết kế hoặc tạo SVG.

---

## Nguyên tắc cơ bản

- Hình cơ bản: chỉ dùng 3 loại hình: hình chữ nhật bo góc (rounded rectangle), vòng tròn (circle), và tam giác bo góc (rounded triangle). Luôn bo cạnh — tránh góc nhọn.
- Phong cách: phẳng (flat), tối giản, ưu tiên nhịp điệu hình khối hơn chi tiết nhỏ.
- Nhịp điệu: thay đổi kích thước và hình dạng giữa các shape để tạo sự thú vị; tránh lặp lại các khối có cùng visual weight.
- Đơn giản: dùng ít shapes nhất có thể mà vẫn truyền tải được ý — mục tiêu khoảng 6–15 shapes cho một illustration; icon nên 1–6 shapes.

## Không gian & bóng đổ

- Thiết kế phẳng: giữ mọi thứ trên cùng trục nhìn; nếu cần cảm giác độ sâu thì rất tinh tế, không đổi trục.
- Bóng: luôn là pill (hình viên thuốc) nằm dưới nhân vật/đối tượng — không dùng oval (oval gợi perspective). Chỉ đặt shadow khi màu bóng tối hơn màu nền ngay bên dưới.

## Màu sắc

- Dùng bảng màu pastel tươi, rực rỡ; tránh dùng xám làm màu chính (xám trông lạnh, thiếu sức sống).
- Giới hạn số màu: 2–4 màu chính + 1 accent; giữ readability khi scale nhỏ.

## Khuôn mặt & chi tiết

- Mắt: 5 kiểu chính (round, glasses, almond, linear, dots cho scale nhỏ). Mắt phải hình học (no ovals). Tránh kính quá nhỏ che biểu cảm.
- Mũi: 1–2 rounded rectangles; khi nhìn nghiêng, mũi nhận tone màu da.
- Miệng: biểu cảm, thường hơi lệch; có thể vượt ra ngoài khung mặt để tăng cảm xúc; răng/lưỡi luôn nằm gọn trong miệng.
- Tóc: đơn giản — 1–2 shapes lớn; có phần tóc/sideburn trên/qua tai để tránh cảm giác cắt cụt.

## Tay, chân, tạo dáng

- Tay & bàn tay: ưu tiên shapes đơn giản (vòng tròn cho bàn tay); nếu vẽ ngón, chỉ dùng số tối thiểu (≤4 nếu cần).
- Ổ cánh tay (arm socket) nên ẩn sau thân để silhouette sạch.
- Tạo dáng: chọn pose phù hợp tính cách — tránh trạng thái thẳng đứng, expressionless.

## Điểm nhấn & chi tiết nổi

- Floating accents: các chi tiết nhỏ có thể nổi quanh nhân vật nếu phục vụ pose/ý nghĩa (ví dụ: vật nhỏ lơ lửng). Đừng thêm nếu không cần.

## Sản xuất & export

- Khi export SVG: giữ mỗi phần là shape riêng (không rasterize). Dùng fills (không strokes) khi có thể để dễ animate.
- Kích thước viewBox đề xuất: icon 48×48 (hoặc 24×24), illustration 512×512.
- Đặt tên layers/components rõ ràng: head, body, eye_L, eye_R, mouth, arm_L, arm_R, shadow, accent.

## Tuyệt đối tránh

- Góc nhọn và pointy shapes.
- Dùng xám làm màu chính.
- Bóng dạng ellipse/oval dưới đối tượng.
- Quá nhiều shapes nhỏ hoặc nhiều màu khiến mất readability.
- Đặt pupils chính giữa theo chiều dọc (trông dễ gây khó chịu), kính nhỏ che mất biểu cảm, quá nhiều ngón tay.

---

## Checklist nhanh khi thiết kế/sinh SVG

- [ ] Chỉ dùng rounded rect / circle / rounded triangle.
- [ ] Các shape phải bo cạnh.
- [ ] Palette: pastel/bright, tránh gray.
- [ ] Shadow = pill dưới đối tượng, màu tối hơn nền.
- [ ] Shapes: icon 1–6, illustration 6–15.
- [ ] Mắt geometric, miệng expressive, tay đơn giản.
- [ ] Output: SVG sạch, fills-only, separate named layers.

---

## Prompt mẫu để sinh icon/illustration SVG

Hướng dẫn chung cho prompt:
- Yêu cầu rõ: "output: SVG" hoặc "generate vector SVG".
- Nói rõ phong cách: flat, geometric, rounded corners.
- Giới hạn shapes: ví dụ "6–12 shapes" cho illustration, "1–3 shapes" cho icon.
- Bảng màu: pastel, avoid gray; hoặc liệt kê các hex cụ thể.
- Bóng: "pill-shaped shadow under object".
- Negative constraints: "no sharp corners, no gray, no gradients, no textures, no tiny decorative shapes".

Ví dụ prompt (Icon — Tiếng Việt):
"Flat SVG icon, viewBox 48x48. Use 1–3 shapes (rounded rect/circle/rounded triangle); all corners rounded. Pastel palette (max 3 colors), no gray. Fills only, no strokes. Add pill-shaped shadow under object. No gradients or textures. Separate named layers (body, eye, accent, shadow). Editable SVG output."

Ví dụ prompt (Icon — English):
"Generate a flat SVG icon (48x48 viewBox). Use only 1–3 geometric shapes: rounded rectangle, circle, rounded triangle. All corners rounded. Pastel palette (max 3 colors, avoid gray). Fills only, add a pill-shaped shadow beneath. No gradients, no textures, separate named layers, editable SVG."

Ví dụ prompt (Character illustration — Tiếng Việt):
"Flat vector character SVG, viewBox 512x512. Compose with 6–12 shapes (rounded rect/circle/rounded triangle). All edges rounded. Palette: pastel, 2–4 main colors + 1 accent, avoid gray. Eyes geometric, mouth expressive (slightly asymmetric). Hands simplified (circles), max 4 fingers. Pill-shaped shadow under character, optional single floating accent. Provide separate named layers for animation. No gradients or textures."

Ví dụ prompt (Character illustration — English):
"Create a flat vector character illustration in SVG (512x512 viewBox). Use only rounded rectangles, circles, and rounded triangles (6–15 shapes). All edges rounded. Vibrant pastel palette (2–4 main colors + 1 accent); avoid gray. Keep style flat and geometric. Eyes: round/almond/linear; mouth: expressive and slightly asymmetric. Hands: simple shapes, max 4 fingers. Include a pill-shaped shadow and optionally one floating accent. Provide named layers for animation. No gradients, no textures. Output editable SVG."

Negative constraints (copyable):
- "No sharp corners, no pointy shapes."
- "No gray as a primary color."
- "No gradients or textures; fills only."
- "No perspective ovals for shadows."
- "No tiny decorative shapes that break legibility at small sizes."

---

## Prompt mẫu cho icon Bottom Navigation (Duolingo style)

Dưới đây là các prompt cụ thể để sinh bộ icon cho thanh điều hướng dưới, dựa trên guideline đã có.

### 1. Icon "Learn" (Học) - Biểu tượng cuốn sách

**Tiếng Việt:**
"Flat SVG icon, viewBox 24x24, chủ đề học tập. Biểu diễn một cuốn sách mở đơn giản. Dùng 2-3 shape (chữ nhật bo góc). Mọi góc bo tròn. Palette: 2 màu pastel (#84D8FF và #1CB0F6), không xám. Chỉ dùng fill, không stroke. Thêm bóng pill nhỏ dưới sách. SVG output, các layer đặt tên (book_cover, book_pages, shadow)."

**English:**
"Generate a flat SVG icon, 24x24 viewBox, for a 'Learn' tab. Depict a simple open book using 2-3 rounded rectangle shapes. All corners must be rounded. Use a 2-color pastel palette (#84D8FF and #1CB0F6), no gray. Fills only, no strokes. Add a small pill-shaped shadow underneath. Output an editable SVG with named layers (book_cover, book_pages, shadow)."

### 2. Icon "Leaderboard" (Bảng xếp hạng) - Biểu tượng khiên

**Tiếng Việt:**
"Flat SVG icon, viewBox 24x24, chủ đề bảng xếp hạng. Biểu diễn một chiếc khiên (shield) tối giản. Dùng 1-2 shape (tam giác bo góc và chữ nhật bo góc). Mọi góc bo tròn. Palette: 2 màu pastel (#FFC800 và #FF9600), không xám. Chỉ dùng fill. Thêm bóng pill nhỏ dưới khiên. SVG output, các layer đặt tên (shield_body, shield_accent, shadow)."

**English:**
"Generate a flat SVG icon, 24x24 viewBox, for a 'Leaderboard' tab. Depict a minimalist shield. Use 1-2 shapes (rounded triangle and rounded rectangle). All corners must be rounded. Use a 2-color pastel palette (#FFC800 and #FF9600), no gray. Fills only. Add a small pill-shaped shadow underneath. Output an editable SVG with named layers (shield_body, shield_accent, shadow)."

### 3. Icon "Profile" (Hồ sơ) - Biểu tượng người dùng

**Tiếng Việt:**
"Flat SVG icon, viewBox 24x24, chủ đề hồ sơ người dùng. Biểu diễn một hình bán thân (bust) đơn giản. Dùng 2 shape (vòng tròn cho đầu, chữ nhật bo góc cho thân). Mọi góc bo tròn. Palette: 2 màu pastel (#A5ED6E và #58A700), không xám. Chỉ dùng fill. Thêm bóng pill nhỏ dưới thân. SVG output, các layer đặt tên (head, body, shadow)."

**English:**
"Generate a flat SVG icon, 24x24 viewBox, for a 'Profile' tab. Depict a simple user bust silhouette. Use 2 shapes (a circle for the head, a rounded rectangle for the body). All corners must be rounded. Use a 2-color pastel palette (#A5ED6E and #58A700), no gray. Fills only. Add a small pill-shaped shadow underneath. Output an editable SVG with named layers (head, body, shadow)."

### 4. Icon "Shop" (Cửa hàng) - Biểu tượng viên kim cương

**Tiếng Việt:**
"Flat SVG icon, viewBox 24x24, chủ đề cửa hàng. Biểu diễn một viên kim cương (gem) đơn giản. Dùng 2-3 shape (tam giác bo góc). Mọi góc bo tròn. Palette: 2 màu pastel (#CE82FF và #9069CD), không xám. Chỉ dùng fill. Thêm bóng pill nhỏ dưới kim cương. SVG output, các layer đặt tên (gem_top, gem_bottom, shadow)."

**English:**
"Generate a flat SVG icon, 24x24 viewBox, for a 'Shop' tab. Depict a simple gem. Use 2-3 rounded triangle shapes. All corners must be rounded. Use a 2-color pastel palette (#CE82FF and #9069CD), no gray. Fills only. Add a small pill-shaped shadow underneath. Output an editable SVG with named layers (gem_top, gem_bottom, shadow)."

### 5. Icon "Practice" (Luyện tập) - Biểu tượng tạ tay

**Tiếng Việt:**
"Flat SVG icon, viewBox 24x24, chủ đề luyện tập. Biểu diễn một chiếc tạ tay (dumbbell) tối giản. Dùng 3 shape (chữ nhật bo góc). Mọi góc bo tròn. Palette: 2 màu pastel (#FF7878 và #FF4B4B), không xám. Chỉ dùng fill. Thêm bóng pill nhỏ dưới tạ. SVG output, các layer đặt tên (bar, weight_left, weight_right, shadow)."

**English:**
"Generate a flat SVG icon, 24x24 viewBox, for a 'Practice' tab. Depict a minimalist dumbbell. Use 3 rounded rectangle shapes. All corners must be rounded. Use a 2-color pastel palette (#FF7878 and #FF4B4B), no gray. Fills only. Add a small pill-shaped shadow underneath. Output an editable SVG with named layers (bar, weight_left, weight_right, shadow)."
