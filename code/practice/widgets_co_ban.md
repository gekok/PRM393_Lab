# Widget cơ bản trong Flutter — theo ảnh Newsfeed + slide Module 4

> Cách đọc file này:
> Ảnh của anh là khung Newsfeed.
> Slide Module 4 là danh sách viên gạch chuẩn.
> File này gộp cả hai lại.

Luồng dựng một màn hình đi thế này:

```
Khung Scaffold
↓
Bố cục Column / Row / Stack
↓
Nội dung Text / Image / List
↓
Nhập liệu / Nút bấm / Dữ liệu chờ
```

## Ảnh của anh chia ra sao?

```
Scaffold (khung ngoài)
↓
(1) AppBar: Newsfeed
↓
(2) SearchBar: avatar + ô nhập + icon ảnh
↓
(3) Stories: danh sách ngang
↓
(4) Post Card: bài viết
↓
(5) Reaction Bar: thích + bình luận + chia sẻ
↓
(6) BottomNavigationBar: thanh dưới
```

Cụm (1) dùng `Text` + `IconButton`.
Cụm (2) dùng `CircleAvatar` + `TextField` + `Icon`.
Cụm (3) dùng `ListView` ngang + `Container` + `Image` + `Text`.
Cụm (4) dùng `CircleAvatar` + `Text` + `IconButton` + `Image`.
Cụm (5) dùng `IconButton` + `Text` + `Divider`.
Cụm (6) dùng `BottomNavigationBar` + `IconButton` + `Text`.

---

## Không làm màn Newsfeed thì sao?

Anh hỏi đúng chỗ thiếu.
Ảnh Newsfeed chỉ phủ màn xem tin.
Các màn khác cần viên khác.

Trường hợp 1: anh làm màn form.
Dùng `Form` + `TextFormField` + `Checkbox`.
Thêm `DropdownButton` + `DatePicker`.
Nút gửi là `ElevatedButton`.
Báo xong bằng `SnackBar`.

```
Form
↓
TextFormField + validator
↓
Checkbox / Switch / Radio / Slider / Dropdown
↓
ElevatedButton
↓
SnackBar
```

Trường hợp 2: anh làm màn cài đặt.
Dùng `Switch` cho dark mode.
Dùng `Slider` cho âm lượng.
Dùng `RadioListTile` cho một lựa chọn.
Mỗi hàng là `ListTile` trong `ListView`.

```
ListView
↓
ListTile + Switch / Slider / Radio
↓
Divider chia cụm
```

Trường hợp 3: anh làm màn chi tiết.
Dùng `Stack` + `Positioned` cho banner.
Dùng `Card` + `ListTile` cho thông tin.
Dùng `GridView` cho lưới liên quan.
Dùng `FutureBuilder` để chờ API.

```
Stack banner
↓
Card + ListTile
↓
GridView / ListView.builder
↓
FutureBuilder bọc ngoài
```

Từ đây trở xuống em đánh dấu từng viên.
`[Trong ảnh]` là anh đã vẽ.
`[Ngoài ảnh - slide]` là slide vẫn tính cơ bản.

---

## Khung màn hình gồm gì?

Nhóm này giữ xương sống màn hình.
Mọi màn hình chính đều cần nó.

### Scaffold là gì? [Trong ảnh]

Chức năng là khung xương (backbone).
Nó giữ thanh trên.
Nó giữ thân giữa.
Nó giữ thanh dưới và nút tròn.

Thuộc tính hay dùng:

- `appBar`: thanh trên, thường là `AppBar`.
- `body`: thân giữa, chứa nội dung chính.
- `bottomNavigationBar`: thanh dưới, chuyển tab.
- `floatingActionButton`: nút tròn góc dưới.
- `backgroundColor`: màu nền toàn màn.
- `drawer`: ngăn kéo trượt từ cạnh.
- `resizeToAvoidBottomInset`: có đẩy UI khi bàn phím hiện không.

Hình ASCII:

```
+----------------------+
| AppBar               |
+----------------------+
|                      |
| Body                 |
|                      |
|                 (FAB)|
+----------------------+
| BottomNavigationBar  |
+----------------------+
```

### AppBar là gì? [Trong ảnh]

Chức năng là thanh tiêu đề trên cùng.
Nó hiện tên màn.
Nó giữ nút trái và cụm nút phải.

Thuộc tính hay dùng:

- `title`: tên màn, thường là `Text`.
- `leading`: nút trái, thường là quay lại.
- `actions`: danh sách nút phải, thường là `IconButton`.
- `backgroundColor`: màu nền thanh.
- `foregroundColor`: màu chữ và icon.
- `elevation`: độ đổ bóng.
- `centerTitle`: có căn giữa tiêu đề không.
- `bottom`: thanh phụ dưới, ví dụ `TabBar`.

Hình ASCII:

```
+--------------------------------+
| < | Newsfeed         | Q |  *  |
+--------------------------------+
```

Ví dụ trong ảnh (1):

```
AppBar(
  title: Text('Newsfeed'),
  actions: [
    IconButton(icon: Icon(Icons.search)),
  ],
)
```

### BottomNavigationBar là gì? [Trong ảnh]

Chức năng là thanh tab dưới cùng.
Nó chuyển nhanh giữa các màn.
Slide ghi giữ từ 2 tới 5 tab.

Thuộc tính hay dùng:

- `items`: danh sách tab, mỗi tab là `BottomNavigationBarItem`.
- `currentIndex`: tab đang chọn.
- `onTap`: hàm chạy khi nhấn tab.
- `type`: cố định hay trượt.
- `selectedItemColor`: màu tab đang chọn.
- `unselectedItemColor`: màu tab chưa chọn.
- `iconSize`: cỡ icon, mặc định là `24`.

Hình ASCII:

```
+--------+--------+--------+
|  Home  | Search | Profile|
|   *    |   o    |   o    |
+--------+--------+--------+
```

### FloatingActionButton là gì? [Ngoài ảnh - slide]

Chức năng là nút tròn nổi góc dưới.
Nó giữ hành động chính màn đó.
Ví dụ thêm bài, thêm tin.

Thuộc tính hay dùng:

- `child`: icon trong nút, thường là `Icon`.
- `onPressed`: hàm chạy khi nhấn, null thì nút mờ.
- `tooltip`: chữ gợi ý khi nhấn giữ.
- `backgroundColor`: màu nền nút.
- `heroTag`: tên hiệu ứng chuyển màn.
- `mini`: bản nhỏ hay không.
- `shape`: hình nút, tròn hay bo góc.
- `elevation`: độ nổi bóng.

Hình ASCII:

```
+------+
| Body |
|      |
|    +--+
|    |+ ||
|    +--+
+------+
```

### SafeArea là gì? [Ngoài ảnh - slide]

Chức năng là tránh tai thỏ (notch).
Nó tránh thanh trạng thái.
Nó tránh tai động (Dynamic Island).

Thuộc tính hay dùng:

- `child`: nội dung bên trong.
- `left`: có né cạnh trái không.
- `top`: có né cạnh trên không.
- `right`: có né cạnh phải không.
- `bottom`: có né cạnh dưới không.
- `minimum`: khoảng đệm tối thiểu.

Hình ASCII:

```
+------------+
| tai thỏ    |
+------------+
| SafeArea   |
|  nội dung  |
|            |
+------------+
```

---

## Xếp hình bằng gì?

Nhóm này xếp viên gạch dọc ngang.
Ảnh của anh gọi là `Layout Layer`.

### Column là gì? [Trong ảnh]

Chức năng là xếp dọc từ trên xuống.
Dùng cho thân màn.
Dùng cho thẻ bài viết.

Thuộc tính hay dùng:

- `children`: danh sách con xếp dọc.
- `mainAxisAlignment`: căn theo trục dọc.
- `crossAxisAlignment`: căn theo trục ngang.
- `mainAxisSize`: ôm sát hay giãn hết.
- `spacing`: khoảng cách giữa các con (bản mới).

Hình ASCII:

```
+------+
|  A   |
+------+
|  B   |
+------+
|  C   |
+------+
```

### Row là gì? [Trong ảnh]

Chức năng là xếp ngang từ trái sang.
Dùng cho hàng nút.
Dùng cho đầu thẻ bài viết.

Thuộc tính hay dùng:

- `children`: danh sách con xếp ngang.
- `mainAxisAlignment`: căn theo trục ngang.
- `crossAxisAlignment`: căn theo trục dọc.
- `mainAxisSize`: ôm sát hay giãn hết.
- `spacing`: khoảng cách giữa các con.

Hình ASCII:

```
+---+---+---+
| A | B | C |
+---+---+---+
```

Ví dụ cụm (5) Reaction Bar:

```
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    IconButton(icon: Icon(Icons.thumb_up)),
    IconButton(icon: Icon(Icons.comment)),
    IconButton(icon: Icon(Icons.share)),
  ],
)
```

### Stack là gì? [Ngoài ảnh - slide]

Chức năng là chồng lớp lên nhau.
Lớp sau đè lớp trước.
Dùng cho ảnh poster đè gradient.

Thuộc tính hay dùng:

- `children`: danh sách lớp, lớp sau đè lớp trước.
- `alignment`: căn mặc định cho con không ghim.
- `fit`: con giãn hay ôm.
- `clipBehavior`: có cắt phần tràn không.

Hình ASCII:

```
+-----------+
| ảnh nền   |
|           |
|  +-----+  |
|  | chữ |  |
|  +-----+  |
+-----------+
```

Ví dụ slide Module 5:

```
Stack(
  children: [
    Image.network(posterUrl),
    Positioned(bottom: 0, child: Container()),
  ],
)
```

### Positioned là gì? [Ngoài ảnh - slide]

Chức năng là ghim con trong `Stack`.
Nó đặt con theo cạnh.
Chỉ dùng trong `Stack`.

Thuộc tính hay dùng:

- `left`: cách cạnh trái bao nhiêu.
- `top`: cách cạnh trên bao nhiêu.
- `right`: cách cạnh phải bao nhiêu.
- `bottom`: cách cạnh dưới bao nhiêu.
- `width`: rộng cố định.
- `height`: cao cố định.
- `child`: viên con được ghim.

Hình ASCII:

```
+---------------+
| Stack         |
|      +---+    |
|      | P |<-bottom: 0
|      +---+    |
+---------------+
```

### Container là gì? [Trong ảnh]

Chức năng là hộp đa năng.
Nó bọc một con.
Nó thêm màu, đệm, viền.

Thuộc tính hay dùng:

- `child`: viên con bên trong.
- `padding`: đệm trong, dùng `EdgeInsets`.
- `margin`: lề ngoài, dùng `EdgeInsets`.
- `color`: màu nền, không dùng chung với `decoration`.
- `decoration`: trang trí `BoxDecoration`.
- `width`: rộng cố định.
- `height`: cao cố định.
- `alignment`: căn con bên trong.
- `constraints`: giới hạn rộng cao.

Hình ASCII:

```
+------------------+
| margin           |
| +--------------+ |
| | padding      | |
| | +----------+ | |
| | | child    | | |
| | +----------+ | |
| +--------------+ |
+------------------+
```

Trong ảnh, `Container` là từng thẻ story.
Trong ảnh, `Container` là khung thẻ bài.

### Padding là gì? [Trong ảnh]

Chức năng là tạo khoảng thở quanh con.
Nó chỉ bọc một con.
Dùng cho giãn cách chuẩn.

Thuộc tính hay dùng:

- `padding`: khoảng đệm, dùng `EdgeInsets`.
- `child`: viên con được bọc.

Hình ASCII:

```
+--------------+
| padding      |
|  +--------+  |
|  | child  |  |
|  +--------+  |
+--------------+
```

### Center là gì? [Ngoài ảnh - slide]

Chức năng là gom con vào giữa.
Căn cả dọc và ngang.
Dùng cho chữ chờ, ảnh trống.

Thuộc tính hay dùng:

- `child`: viên con cần căn giữa.
- `widthFactor`: rộng bằng mấy lần con.
- `heightFactor`: cao bằng mấy lần con.

Hình ASCII:

```
+-----------+
|           |
|   child   |
|           |
+-----------+
```

### SizedBox là gì? [Ngoài ảnh - slide]

Chức năng là tạo khoảng cứng.
Nó giữ chỗ rộng cao cố định.
Dùng để cách hai viên ra.

Thuộc tính hay dùng:

- `width`: rộng giữ chỗ.
- `height`: cao giữ chỗ.
- `child`: con bên trong, có thể không có.

Hình ASCII:

```
+---+  +---+
|A  |16|B  |
+---+  +---+
  SizedBox(width: 16)
```

### Expanded là gì? [Trong ảnh]

Chức năng là giãn con lấp chỗ trống.
Nó chống tràn trong `Column`.
Slide bắt bọc `ListView` bằng nó.

Thuộc tính hay dùng:

- `child`: viên con được giãn.
- `flex`: tỉ lệ chia chỗ, mặc định là `1`.

Hình ASCII:

```
+------------+
| A (cố định)|
+------------+
| B Expanded |
| giãn hết   |
+------------+
```

### Flexible là gì? [Trong ảnh]

Chức năng giống `Expanded` nhưng mềm hơn.
Con được co khi thiếu chỗ.
Dùng khi màn nhỏ hay tràn.

Thuộc tính hay dùng:

- `child`: viên con được co giãn.
- `flex`: tỉ lệ chia chỗ.
- `fit`: ôm (`loose`) hay ép (`tight`).

Hình ASCII:

```
+------------+
| A Flexible |
| co được    |
+------------+
| B          |
+------------+
```

### Wrap là gì? [Ngoài ảnh - slide]

Chức năng là tự xuống dòng khi hết chỗ.
Slide khuyên dùng cho chip dài.
Không cần tính toán điều kiện.

Thuộc tính hay dùng:

- `children`: danh sách chip.
- `spacing`: cách ngang giữa các con.
- `runSpacing`: cách dọc giữa các hàng.
- `alignment`: căn hàng.
- `direction`: hướng xếp, ngang hay dọc.

Hình ASCII:

```
+---+---+---+
| A | B | C |
+---+---+---+
| D | E     |
+---+-------+
```

### SingleChildScrollView là gì? [Trong ảnh]

Chức năng là cho một cột cuộn được.
Dùng cho form dài.
Tránh bàn phím che nút gửi.

Thuộc tính hay dùng:

- `child`: cột dài bên trong.
- `scrollDirection`: cuộn dọc hay ngang.
- `padding`: đệm quanh vùng cuộn.
- `physics`: cảm giác cuộn.
- `reverse`: đảo đầu cuộn hay không.

Hình ASCII:

```
+------+
| A    |
| B    |
| C  ^ |
| D  | |
| E  v |
+------+
```

---

## Hiện chữ ảnh ra sao?

Nhóm này hiện nội dung mắt thấy.
Không nhận nhập liệu.

### Text là gì? [Trong ảnh]

Chức năng là hiện một dòng chữ.
Mọi tên, tiêu đề đều dùng nó.
Trong ảnh, `Newsfeed` là `Text`.

Thuộc tính hay dùng:

- `data`: chuỗi cần hiện, tham số đầu tiên.
- `style`: kiểu chữ `TextStyle`.
- `textAlign`: căn trái, phải, giữa.
- `overflow`: tràn thì cắt kiểu gì.
- `maxLines`: tối đa mấy dòng.
- `softWrap`: có tự xuống dòng không.

`TextStyle` gồm:

- `fontSize`: cỡ chữ.
- `fontWeight`: đậm nhạt.
- `color`: màu chữ.
- `letterSpacing`: giãn chữ.
- `height`: giãn dòng.
- `decoration`: gạch chân, gạch ngang.

Hình ASCII:

```
+----------------+
| Newsfeed       |
+----------------+
```

### Image là gì? [Trong ảnh]

Chức năng là hiện ảnh.
Ảnh mạng dùng `Image.network`.
Ảnh local dùng `Image.asset`.

Thuộc tính hay dùng:

- `src`: đường dẫn, mạng hay asset.
- `width`: rộng ảnh.
- `height`: cao ảnh.
- `fit`: co ảnh kiểu gì (`BoxFit.cover`).
- `loadingBuilder`: hiện gì khi đang tải.
- `errorBuilder`: hiện gì khi lỗi.

Hình ASCII:

```
+-----------+
| /\/\/\/\  |
| \/\/\/\/  |
|  ảnh      |
+-----------+
```

Trong ảnh, `Image` nằm trong story.
Trong ảnh, `Image` là ảnh bài viết.

### Icon là gì? [Trong ảnh]

Chức năng là hiện một biểu tượng.
Lấy từ bộ Material.
Dùng cho nút, trạng thái.

Thuộc tính hay dùng:

- `icon`: tên icon, ví dụ `Icons.favorite`.
- `size`: cỡ icon.
- `color`: màu icon.
- `semanticLabel`: mô tả cho trợ năng.

Hình ASCII:

```
+---+
| ♥ |
+---+
```

### Card là gì? [Ngoài ảnh - slide]

Chức năng là tấm thẻ nổi.
Nó gom thông tin ngắn.
Đi chung với `ListTile` rất hợp.

Thuộc tính hay dùng:

- `child`: nội dung trong thẻ.
- `elevation`: độ nổi bóng.
- `margin`: lề ngoài thẻ.
- `shape`: viền bo góc.
- `color`: màu nền thẻ.
- `clipBehavior`: cắt tràn hay không.

Hình ASCII:

```
  ___________
 /           \
|  nội dung   |
|  trong thẻ  |
 \___________/
```

### ListTile là gì? [Ngoài ảnh - slide]

Chức năng là một hàng chuẩn.
Một hàng có đầu giữa cuối.
Dùng cho danh bạ, phim, sản phẩm.

Thuộc tính hay dùng:

- `leading`: đầu hàng, thường là `CircleAvatar`.
- `title`: tiêu đề giữa, thường là `Text`.
- `subtitle`: dòng phụ dưới tiêu đề.
- `trailing`: cuối hàng, thường là `Icon`.
- `onTap`: nhấn thì làm gì.
- `onLongPress`: nhấn giữ thì làm gì.
- `dense`: hàng gọn hay không.
- `contentPadding`: đệm trong hàng.

Hình ASCII:

```
+------------------------+
| (o) | Tiêu đề      | > |
|     | Dòng phụ     |   |
+------------------------+
```

### CircleAvatar là gì? [Trong ảnh]

Chức năng là ảnh tròn đầu hàng.
Hiện đại hơn ảnh vuông.
Trong ảnh dùng cho avatar.

Thuộc tính hay dùng:

- `radius`: bán kính vòng tròn.
- `backgroundImage`: ảnh nền, dùng `NetworkImage`.
- `backgroundColor`: màu nền khi chưa có ảnh.
- `child`: chữ trong vòng, ví dụ chữ cái đầu.

Hình ASCII:

```
   ___
  /   \
 | (o) |
  \___/
```

### Chip là gì? [Ngoài ảnh - slide]

Chức năng là nhãn nhỏ gắn thể loại.
Dùng cho genre phim.
Nằm trong `Wrap` thì tự xuống dòng.

Thuộc tính hay dùng:

- `label`: chữ trong chip, thường là `Text`.
- `avatar`: icon hoặc ảnh đầu chip.
- `deleteIcon`: icon xóa.
- `onDeleted`: nhấn xóa thì làm gì.
- `backgroundColor`: màu nền chip.
- `shape`: viền chip.

Hình ASCII:

```
+-----------+
| (o) Hành động |
+-----------+
```

### Divider là gì? [Trong ảnh]

Chức năng là gạch ngang chia cụm.
Dùng trong cụm (5).
Tách cảm xúc và hành động.

Thuộc tính hay dùng:

- `height`: cao vùng chứa gạch.
- `thickness`: dày nét gạch.
- `color`: màu gạch.
- `indent`: thụt đầu trái.
- `endIndent`: thụt đầu phải.

Hình ASCII:

```
 Thích   Bình luận   Chia sẻ
----------------------------
 123      10 bình luận
```

---

## Nhập liệu dùng gì?

Nhóm này nhận tay người dùng.
Slide Module 7 gom đủ nhất.

### TextField là gì? [Trong ảnh]

Chức năng là ô nhập đơn giản một lần.
Không kiểm lỗi đi kèm.
Trong ảnh (2) ô tìm kiếm dùng nó.

Thuộc tính hay dùng:

- `controller`: giữ chữ đã nhập.
- `decoration`: trang trí `InputDecoration`.
- `obscureText`: có ẩn chữ mật khẩu không.
- `keyboardType`: kiểu bàn phím.
- `onChanged`: chữ đổi thì làm gì.
- `onSubmitted`: nhấn xong thì làm gì.
- `maxLines`: mấy dòng, `1` là một dòng.

Hình ASCII:

```
+----------------------+
| Tìm kiếm...        |X||
+----------------------+
```

### TextFormField là gì? [Ngoài ảnh - slide]

Chức năng là ô nhập có kiểm lỗi.
Nằm trong `Form` mới phát huy.
Dùng cho đăng nhập, đăng ký.

Thuộc tính hay dùng:

- `validator`: hàm kiểm, đúng trả `null`.
- `onSaved`: lưu giá trị khi form lưu.
- `autovalidateMode`: khi nào hiện lỗi.
- `decoration`: trang trí `InputDecoration`.
- `obscureText`: ẩn mật khẩu hay không.
- `controller`: giữ chữ đã nhập.

`InputDecoration` gồm:

- `labelText`: nhãn trên ô.
- `hintText`: chữ mờ gợi ý.
- `prefixIcon`: icon đầu ô.
- `suffixIcon`: icon cuối ô.
- `border`: viền ô.
- `errorText`: chữ lỗi hiện tay.

Hình ASCII:

```
+------------------+
| Email            |
| abc@fpt.edu.vn   |
| Nhập email đúng  |
+------------------+
```

### Form là gì? [Ngoài ảnh - slide]

Chức năng là gom nhiều ô lại.
Kiểm một lượt bằng khóa.
Lưu và xóa một lượt.

Thuộc tính hay dùng:

- `key`: khóa `GlobalKey<FormState>`.
- `child`: cột ô nhập bên trong.
- `autovalidateMode`: khi nào tự kiểm.
- `onChanged`: form đổi thì làm gì.

Ba hàm hay gọi:

```
validate()
save()
reset()
```

Hình ASCII:

```
+ Form -------------+
| [Tên]            |
| [Email]          |
| [Mật khẩu]       |
| [ Nút Gửi ]      |
+------------------+
```

### Checkbox là gì? [Ngoài ảnh - slide]

Chức năng là chọn đúng sai.
Nhấn thì đổi trạng thái.
Dùng cho đồng ý điều khoản.

Thuộc tính hay dùng:

- `value`: đang chọn hay không.
- `onChanged`: nhấn thì đổi gì.
- `activeColor`: màu khi chọn.
- `checkColor`: màu dấu tích.

Hình ASCII:

```
+---+
| X | Đồng ý điều khoản
+---+
```

### Switch là gì? [Ngoài ảnh - slide]

Chức năng là công tắc bật tắt.
Bật là đúng, tắt là sai.
Dùng cho dark mode, thông báo.

Thuộc tính hay dùng:

- `value`: đang bật hay không.
- `onChanged`: gạt thì đổi gì.
- `activeColor`: màu khi bật.

Hình ASCII:

```
Dark mode   [----|O]
```

### Radio là gì? [Ngoài ảnh - slide]

Chức năng là chọn một trong nhóm.
Một nhóm chỉ một đáp án.
`RadioListTile` là bản cả hàng.

Thuộc tính hay dùng:

- `value`: giá trị của nút này.
- `groupValue`: giá trị đang chọn cả nhóm.
- `onChanged`: chọn thì đổi gì.
- `title`: chữ của hàng (bản `RadioListTile`).
- `secondary`: icon phụ cuối hàng.

Hình ASCII:

```
(o) Nam
( ) Nữ
( ) Khác
```

### Slider là gì? [Ngoài ảnh - slide]

Chức năng là kéo giá trị liên tục.
Kéo trong một khoảng.
Dùng cho âm lượng, đánh giá.

Thuộc tính hay dùng:

- `value`: giá trị hiện tại.
- `min`: giá trị nhỏ nhất.
- `max`: giá trị lớn nhất.
- `divisions`: chia mấy nấc.
- `label`: nhãn hiện khi kéo.
- `onChanged`: kéo thì đổi gì.
- `activeColor`: màu đoạn đã kéo.

Hình ASCII:

```
0 ----O---------- 100
```

### DropdownButton là gì? [Ngoài ảnh - slide]

Chức năng là sổ xuống chọn một.
Tiết kiệm chỗ màn hình.
Slide dùng cho sắp xếp A-Z.

Thuộc tính hay dùng:

- `value`: đang chọn gì.
- `items`: danh sách lựa chọn.
- `onChanged`: chọn thì đổi gì.
- `hint`: chữ gợi ý khi chưa chọn.
- `isExpanded`: có giãn hết rộng không.

Hình ASCII:

```
+--------------+
| A-Z        v |
+--------------+
| A-Z          |
| Z-A          |
| Rating       |
+--------------+
```

### DatePicker và TimePicker là gì? [Ngoài ảnh - slide]

Chức năng là chọn ngày giờ lịch.
Mở dạng hộp thoại (dialog).
Dùng cho đặt vé, hẹn giờ.

Thuộc tính hay gọi:

- `context`: màn nào mở lịch.
- `initialDate`: ngày mở đầu.
- `firstDate`: ngày nhỏ nhất được chọn.
- `lastDate`: ngày lớn nhất được chọn.
- `initialTime`: giờ mở đầu (bản giờ).

Hình ASCII:

```
+---------------+
|  Tháng 12     |
| Mo Tu We Th   |
|        1  2   |
| [OK]  [Cancel]|
+---------------+
```

---

## Nút bấm và phản hồi ở đâu?

Nhóm này cho tay nhấn vào.
Nhấn xong thì báo lại.

### IconButton là gì? [Trong ảnh]

Chức năng là nút icon không chữ.
Nhấn nhanh một hành động.
Trong ảnh dùng khắp nơi.

Thuộc tính hay dùng:

- `icon`: icon trong nút.
- `onPressed`: nhấn thì làm gì.
- `tooltip`: chữ gợi ý nhấn giữ.
- `iconSize`: cỡ icon.
- `color`: màu icon.

Hình ASCII:

```
+---+
| Q | tìm kiếm
+---+
```

### ElevatedButton là gì? [Ngoài ảnh - slide]

Chức năng là nút nổi có chữ.
Dùng cho gửi, đăng nhập.
Nhấn xong thường báo `SnackBar`.

Thuộc tính hay dùng:

- `child`: chữ trong nút, thường là `Text`.
- `onPressed`: nhấn thì làm gì, null thì mờ.
- `style`: màu, bo góc, đệm.

Hình ASCII:

```
+---------------+
|  Đăng nhập    |
+---------------+
```

### SnackBar là gì? [Ngoài ảnh - slide]

Chức năng là thanh báo dưới màn.
Hiện sau hành động.
Tự mất sau vài giây.

Thuộc tính hay dùng:

- `content`: chữ báo, thường là `Text`.
- `action`: nút trong thanh, ví dụ Thử lại.
- `duration`: hiện mấy giây.
- `behavior`: nổi hay dính đáy.

Cách hiện:

```
ScaffoldMessenger.of(context).showSnackBar(...)
```

Hình ASCII:

```
+----------------------+
| Thân màn             |
+----------------------+
| Đăng nhập thành công |
+----------------------+
```

### CircularProgressIndicator là gì? [Ngoài ảnh - slide]

Chức năng là vòng quay chờ.
Hiện khi đang tải.
Đi chung với `FutureBuilder`.

Thuộc tính hay dùng:

- `value`: tiến độ, null là quay mãi.
- `strokeWidth`: dày vòng.
- `color`: màu vòng.
- `backgroundColor`: màu nền vòng.

Hình ASCII:

```
   ___
  /   \
 |  ~  | đang tải
  \___/
```

---

## Danh sách cuộn thế nào?

Nhóm này vẽ nhiều hàng giống nhau.
Chỉ vẽ hàng đang thấy.
Nên danh sách dài vẫn mượt.

### ListView là gì? [Trong ảnh]

Chức năng là cột cuộn được.
Danh sách ngắn thì dùng thường.
Trong ảnh (3) và (4) dùng nó.

Thuộc tính hay dùng:

- `children`: danh sách con cố định.
- `scrollDirection`: cuộn dọc hay ngang.
- `padding`: đệm quanh danh sách.
- `physics`: cảm giác cuộn.

Hình ASCII:

```
+------+
| A    |
| B  ^ |
| C  | |
| D  v |
+------+
```

### ListView.builder là gì? [Ngoài ảnh - slide]

Chức năng là vẽ lười theo vị trí.
Có 1000 hàng cũng mượt.
Bài tập Module 4 bắt dùng nó.

Thuộc tính hay dùng:

- `itemCount`: tổng mấy hàng.
- `itemBuilder`: hàm vẽ hàng thứ `i`.
- `scrollDirection`: cuộn dọc hay ngang.
- `padding`: đệm quanh danh sách.

Hình ASCII:

```
ListView.builder(
  itemCount: 1000,
  itemBuilder: (_, i) => ListTile(...),
)
```

```
+------+
| 0    |
| 1    | chỉ vẽ
| 2    | vùng thấy
+------+
```

### ListView.separated là gì? [Ngoài ảnh - slide]

Chức năng giống `builder` nhưng có gạch chia.
Gạch vẽ bằng `separatorBuilder`.
Hợp cho danh sách phim, tin.

Thuộc tính hay dùng:

- `itemCount`: tổng mấy hàng.
- `itemBuilder`: vẽ hàng.
- `separatorBuilder`: vẽ gạch giữa hai hàng.

Hình ASCII:

```
+------+
| A    |
|------|
| B    |
|------|
| C    |
+------+
```

### GridView là gì? [Ngoài ảnh - slide]

Chức năng là lưới cuộn được.
Tự đổi số cột theo rộng.
Slide dùng cho màn thể loại.

Thuộc tính hay dùng:

- `crossAxisCount`: mấy cột.
- `crossAxisSpacing`: cách ngang.
- `mainAxisSpacing`: cách dọc.
- `children`: danh sách con (bản `count`).
- `gridDelegate`: cách chia lưới (bản `builder`).
- `itemCount`: tổng mấy ô (bản `builder`).
- `itemBuilder`: vẽ ô thứ `i` (bản `builder`).

Hình ASCII:

```
+---+ +---+
| A | | B |
+---+ +---+
+---+ +---+
| C | | D |
+---+ +---+
```

---

## Dữ liệu chờ hiện gì?

Nhóm này nối async vào cây widget.
Không cần tự ghi `setState` nhiều.

### FutureBuilder là gì? [Ngoài ảnh - slide]

Chức năng là nghe một giá trị tương lai.
Tự chia 4 trạng thái.
Module 8 dùng với `ListView`.

Thuộc tính hay dùng:

- `future`: future cần nghe.
- `initialData`: dữ liệu tạm lúc chờ.
- `builder`: hàm vẽ theo `snapshot`.

`snapshot` gồm:

- `connectionState`: đang chờ hay xong.
- `hasData`: có dữ liệu chưa.
- `hasError`: có lỗi không.
- `data`: dữ liệu trả về.

Bốn nhánh vẽ:

```
waiting -> vòng quay
↓
error -> chữ lỗi + nút Thử lại
↓
no data -> chữ trống
↓
data -> ListView
```

Hình ASCII:

```
+--------------+
| FutureBuilder|
|  +--------+  |
|  | List / |  |
|  | Lỗi /  |  |
|  | Quay   |  |
|  +--------+  |
+--------------+
```

### StreamBuilder là gì? [Ngoài ảnh - slide]

Chức năng là nghe nhiều giá trị theo thời gian.
Dữ liệu mới thì vẽ lại.
Module 3 gắn sau Repo.

Thuộc tính hay dùng:

- `stream`: stream cần nghe.
- `initialData`: dữ liệu tạm lúc chờ.
- `builder`: hàm vẽ theo `snapshot`.

Luồng chuẩn:

```
Model
↓
Repo
↓
Stream
↓
StreamBuilder rebuild
```

Hình ASCII:

```
stream: 1 -> 2 -> 3
         ↓   ↓   ↓
UI:     A1  A2  A3
```

---

## Màn to nhỏ xử sao?

Nhóm này chống tràn màn.
Slide Module 6 dạy riêng.

### MediaQuery là gì? [Ngoài ảnh - slide]

Chức năng là đọc thông tin màn.
Rộng, cao, hướng, tai thỏ.
Dùng để rẽ nhánh Mobile / Tablet.

Thuộc tính hay đọc:

- `size.width`: rộng màn.
- `size.height`: cao màn.
- `orientation`: dọc hay ngang.
- `padding`: vùng tai thỏ.
- `devicePixelRatio`: mật độ điểm ảnh.

Cách đọc:

```
MediaQuery.of(context).size.width
```

Hình ASCII:

```
w < 600 -> Mobile
w >= 600 -> Tablet
```

### LayoutBuilder là gì? [Ngoài ảnh - slide]

Chức năng là đọc ràng buộc của cha.
Không phải cả màn.
Dùng cho thẻ co theo chỗ.

Thuộc tính hay dùng:

- `builder`: hàm nhận `(context, constraints)`.
- `constraints.maxWidth`: rộng nhất được dùng.
- `constraints.maxHeight`: cao nhất được dùng.

Hình ASCII:

```
Cha: maxWidth = 500
↓
con > 500 -> WideCard
con <= 500 -> NarrowCard
```

### OrientationBuilder là gì? [Ngoài ảnh - slide]

Chức năng là bắt xoay dọc ngang.
Dọc thì một cột.
Ngang thì hai cột.

Thuộc tính hay dùng:

- `builder`: hàm nhận `(context, orientation)`.
- `orientation`: `portrait` hay `landscape`.

Hình ASCII:

```
portrait: [ A ]
          [ B ]

landscape: [A | B]
```

---

## Ôn nhanh theo ảnh ra sao?

Trường hợp 1: anh vẽ khung.
Nhớ `Scaffold` giữ ba phần.
`AppBar` trên, `Body` giữa, `BottomNavigationBar` dưới.

Trường hợp 2: anh xếp hình.
Nhớ `Column` xếp dọc.
`Row` xếp ngang.
Tràn thì bọc `Expanded`.
Chip dài thì dùng `Wrap`.

Trường hợp 3: anh hiện tin.
Nhớ `ListView.builder` vẽ lười.
Mỗi hàng là `ListTile`.
Đầu hàng là `CircleAvatar`.
Chia cụm bằng `Divider`.
