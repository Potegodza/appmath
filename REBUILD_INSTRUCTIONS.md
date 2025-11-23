# 🔄 คำแนะนำการ Rebuild App

## ✅ ขั้นตอนที่ 1: Clean Project
```bash
cd d:\projectyeen\appmath
flutter clean
```

## ✅ ขั้นตอนที่ 2: Get Dependencies
```bash
flutter pub get
```

## ✅ ขั้นตอนที่ 3: ตรวจสอบ Devices
```bash
flutter devices
```

## ✅ ขั้นตอนที่ 4: Run App

### สำหรับ Android (แนะนำ):
```bash
flutter run -d android
```
หรือ
```bash
flutter run -d emulator-5554
```

### สำหรับ Chrome (ทดสอบ):
```bash
flutter run -d chrome
```

### สำหรับ Windows (ต้องมี Visual Studio):
```bash
flutter run -d windows
```

## 📋 สิ่งที่แก้ไขแล้ว:
- ✅ แก้ไข `pubspec.yaml`: เปลี่ยน `sounds/background_music.mp3` → `sounds/`
- ✅ แก้ไขชื่อไฟล์: `background_music.mp3.mp3` → `background_music.mp3`
- ✅ แก้ไข await errors ใน `sound_service.dart`

## ⚠️ หมายเหตุ:
- หลังจาก rebuild แล้ว เพลงพื้นหลังควรเล่นได้
- ไฟล์เสียงประกอบ (success.mp3, wrong.mp3, button_click.mp3) ยังไม่มี แต่แอปจะทำงานได้ปกติ
- ถ้ามีปัญหา symlink ให้เปิด Developer Mode (ดู `FIX_SYMLINK_WINDOWS.md`)

## 🔍 ตรวจสอบว่า Build สำเร็จ:
- ดู console log ว่ามี error หรือไม่
- ตรวจสอบว่าแอปเปิดได้
- ตรวจสอบว่าเพลงเล่นได้ (ถ้าเปิดเพลงในหน้าตั้งค่า)










