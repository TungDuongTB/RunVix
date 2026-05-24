# 🌐 Hướng dẫn cấu hình Firebase cho WEB

## ❌ Vấn đề hiện tại
Firebase không hoạt động trên Web vì **thiếu Firebase Config** trong `web/index.html`

---

## ✅ Giải pháp: Lấy Firebase Config từ Firebase Console

### Bước 1️⃣: Truy cập Firebase Console
1. Mở https://console.firebase.google.com/
2. Chọn project **RunVix** của bạn

### Bước 2️⃣: Lấy Web Config
1. Vào **Project Settings** (⚙️ icon ở góc trái)
2. Chọn tab **Your apps** (hoặc **Apps**)
3. Tìm app **Web** (nếu chưa có thì click **"+ Add app"** → chọn **Web** → input tên app)
4. **Sẽ hiện code setup như này:**

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyDxxx...",
  authDomain: "yourproject.firebaseapp.com",
  projectId: "yourproject",
  storageBucket: "yourproject.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123xyz"
};
```

### Bước 3️⃣: Thay config vào web/index.html
1. Mở file **web/index.html** trong project
2. Tìm phần `firebaseConfig` (tìm từ Google Console)
3. **Thay toàn bộ giá trị** bằng config của bạn:

```html
const firebaseConfig = {
  apiKey: "AIzaSyDxxx...",           // ← COPY từ Console
  authDomain: "yourproject.firebaseapp.com",  // ← COPY từ Console
  projectId: "yourproject",          // ← COPY từ Console
  storageBucket: "yourproject.appspot.com",   // ← COPY từ Console
  messagingSenderId: "123456789",    // ← COPY từ Console
  appId: "1:123456789:web:abc123xyz" // ← COPY từ Console
};
```

⚠️ **QUAN TRỌNG:** Mỗi giá trị phải chính xác 100%!

---

## 🧪 Kiểm tra sau khi cấu hình

Sau khi thay config, chạy:
```bash
flutter clean
flutter pub get
flutter run -d chrome  # Hoặc -d firefox, -d edge, etc.
```

Kiểm tra console log:
```
🌐 Platform: WEB
✅ Firebase đã được khởi tạo thành công!
✅ AuthenticationRepository đã sẵn sàng!
```

---

## 📋 Danh sách kiểm tra
- [ ] Lấy Firebase Config từ Console
- [ ] Copy toàn bộ 6 giá trị vào web/index.html
- [ ] Kiểm tra không có dấu ngoặc kép thừa hoặc thiếu
- [ ] Chạy `flutter clean && flutter pub get`
- [ ] Chạy `flutter run -d chrome`
- [ ] Kiểm tra console logs
- [ ] Thử đăng nhập/đăng ký

---

## 🎯 Tương tương hỗ trợ nhiều platform
Bộ code mới đã hỗ trợ:
- ✅ **WEB** (sử dụng Firebase SDK từ CDN)
- ✅ **ANDROID** (sử dụng google-services.json)
- ✅ **iOS** (sử dụng GoogleService-Info.plist)
- ✅ **WINDOWS, LINUX, macOS** (nếu cần)

---

## 💡 Các vấn đề phổ biến

### ❌ "FirebaseOptions cannot be null"
- ✅ Đã sửa trong main.dart - không cần lo

### ❌ "Config không hợp lệ" hoặc lỗi CORS
- Kiểm tra lại các giá trị config
- Chắc chắn không có space thừa
- Kiểm tra dấu ngoặc kép

### ❌ Email/Password không hoạt động
Vào Firebase Console → **Authentication** → **Sign-in method**
- Bật **Email/Password** provider

### ❌ "Network error" khi đăng nhập
- Kiểm tra kết nối Internet
- Kiểm tra Firebase project status
- Thử F12 → Console (browser) để xem chi tiết lỗi

---

## 📝 Ví dụ config hoàn chỉnh

```html
<script>
  const firebaseConfig = {
    apiKey: "AIzaSyDxxx123xyz",
    authDomain: "runvix-project.firebaseapp.com",
    projectId: "runvix-project",
    storageBucket: "runvix-project.appspot.com",
    messagingSenderId: "123456789123",
    appId: "1:123456789123:web:abc123def456ghi"
  };

  firebase.initializeApp(firebaseConfig);
</script>
```

---

## 🛠️ File đã sửa
- ✅ `web/index.html` - Thêm Firebase SDK & placeholder for config
- ✅ `lib/main.dart` - Hỗ trợ khởi tạo Firebase cho Web
- ✅ `lib/Data/Repository/authentication_repository.dart` - Xử lý lỗi tốt hơn

---

## 🚀 Tiếp theo
1. **Copy Firebase Config từ Console**
2. **Paste vào web/index.html**
3. **Chạy app trên web**
4. **Thử đăng nhập để test**

Nếu vẫn gặp lỗi, kiểm tra browser console (F12) để xem thông báo lỗi chi tiết!

