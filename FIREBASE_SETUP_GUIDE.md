# 🔥 Hướng dẫn cấu hình Firebase cho RunVix

## ❌ Vấn đề hiện tại
Firebase không hoạt động vì **thiếu file google-services.json** trong Android project.

---

## ✅ Giải pháp: Tải google-services.json từ Firebase Console

### Bước 1: Truy cập Firebase Console
1. Mở https://console.firebase.google.com/
2. Chọn project **RunVix** của bạn

### Bước 2: Tải google-services.json cho Android
1. Vào **Project Settings** (⚙️ icon ở góc trái)
2. Chọn tab **Your apps** (hoặc **Apps**)
3. Chọn app Android (nếu có - nếu chưa có thì click **"Add app"** → chọn **Android**)
4. Nhấn **"Download google-services.json"** button
5. **File sẽ được tải về máy**

### Bước 3: Đặt file vào đúng vị trí
```
Đặt file google-services.json vào:
D:\DoAn\Project\RunVix\android\app\src\main\google-services.json
```

**Lưu ý:** Thư mục phải là `src/main/` chứ không phải thư mục khác!

### Bước 4: Kiểm tra cấu hình Android
File `android/app/build.gradle.kts` đã có cấu hình Firebase:
```
plugins {
    id("com.google.gms.google-services")
}
```
✅ Cấu hình này **đã chính xác**

---

## 🎯 Cấu hình iOS (nếu cần)

Nếu chạy trên iOS, bạn cũng cần:
1. Download **GoogleService-Info.plist** từ Firebase Console
2. Đặt vào `ios/Runner/GoogleService-Info.plist`

---

## 🧪 Kiểm tra sau khi cấu hình

Sau khi đặt file, chạy:
```bash
flutter clean
flutter pub get
flutter run
```

Kiểm tra console log để xem:
```
✅ Firebase đã được khởi tạo thành công!
✅ AuthenticationRepository đã sẵn sàng!
```

---

## 📋 Danh sách kiểm tra
- [ ] google-services.json đã được tải từ Firebase Console
- [ ] File được đặt trong `android/app/src/main/`
- [ ] Chạy `flutter clean && flutter pub get`
- [ ] Chạy `flutter run` và kiểm tra logs
- [ ] Thử đăng nhập với email/password

---

## 💡 Các vấn đề phổ biến

### "Network Request Failed" khi đăng nhập
- Kiểm tra kết nối Internet
- Chắc chắn Firebase Console không có lỗi
- Kiểm tra xem tài khoản email có tồn tại trong Firebase không

### "Operation not allowed"
- Vào Firebase Console → Authentication → Sign-in method
- Bật **Email/Password** provider
  
### "google-services.json not found"
- Kiểm tra xem file có trong `android/app/src/main/` không
- Tên file phải **chính xác** là `google-services.json`

---

## 🛠️ Hỗ trợ
Nếu vẫn gặp lỗi, kiểm tra:
1. Flutter version: `flutter --version`
2. Firebase Core version trong pubspec.yaml (hiện tại: 3.10.1 ✅)
3. Xem chi tiết lỗi trong console output

