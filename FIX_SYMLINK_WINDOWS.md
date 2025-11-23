# 🔧 วิธีแก้ปัญหา Symlink Support บน Windows

## ❌ ปัญหา:
```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

## ✅ วิธีแก้ไข (เลือกวิธีใดวิธีหนึ่ง):

### วิธีที่ 1: เปิด Developer Mode (แนะนำ) ⭐

1. **เปิด Settings:**
   - กด `Windows + I` หรือ
   - คลิกขวาที่ Start Menu → Settings

2. **ไปที่ Developer Mode:**
   - ไปที่ **Update & Security** → **For developers**
   - หรือพิมพ์ใน Search: `Developer Mode`

3. **เปิด Developer Mode:**
   - เลือก **Developer Mode** (ไม่ใช่ "Developer settings")
   - Windows จะถามให้ restart คอมพิวเตอร์ → กด **Yes**

4. **Restart คอมพิวเตอร์**

5. **ลอง build อีกครั้ง:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### วิธีที่ 2: ใช้ Command Prompt (Admin)

ถ้าไม่สามารถเปิด Developer Mode ได้:

1. **เปิด Command Prompt as Administrator:**
   - คลิกขวาที่ Start Menu
   - เลือก **Windows PowerShell (Admin)** หรือ **Command Prompt (Admin)**

2. **รันคำสั่ง:**
   ```cmd
   reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /d 1
   ```

3. **Restart คอมพิวเตอร์**

4. **ลอง build อีกครั้ง**

### วิธีที่ 3: ใช้ PowerShell (Admin)

1. **เปิด PowerShell as Administrator**

2. **รันคำสั่ง:**
   ```powershell
   Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1
   ```

3. **Restart คอมพิวเตอร์**

## 🔍 ตรวจสอบว่าเปิด Developer Mode แล้ว:

1. ไปที่ Settings → Update & Security → For developers
2. ตรวจสอบว่า **Developer Mode** เปิดอยู่ (Switch เป็นสีเขียว)

## ⚠️ หมายเหตุ:

- **Developer Mode** ปลอดภัยสำหรับการพัฒนาแอป
- ไม่มีผลกระทบต่อความปลอดภัยของระบบ
- สามารถปิดได้เมื่อไม่ใช้งานแล้ว
- จำเป็นสำหรับ Flutter development บน Windows

## 🚀 หลังจากแก้ไขแล้ว:

```bash
cd d:\projectyeen\appmath
flutter clean
flutter pub get
flutter run
```

## 💡 ถ้ายังมีปัญหา:

1. **ตรวจสอบสิทธิ์ Admin:**
   - ต้องรัน Command Prompt/PowerShell as Administrator

2. **ตรวจสอบ Windows Version:**
   - Developer Mode ใช้ได้กับ Windows 10 version 1507 ขึ้นไป
   - Windows 11 รองรับแน่นอน

3. **ลองวิธีอื่น:**
   - Build สำหรับ Android/iOS แทน Windows
   - ใช้ WSL2 (Windows Subsystem for Linux)










