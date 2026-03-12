# 🌐 StepSphere

> **Walk. Explore. Conquer.**

StepSphere, yürüyüş takip uygulamasıdır. GPS ile rotanızı kaydedin, adımlarınızı sayın, kalori yakımınızı hesaplayın ve keşfettiğiniz alanları haritada işaretleyin. Arkadaşlarınızla yarışın ve kendi "sphere"inizin büyüklüğünü gösterin.

## ✨ Özellikler

- 🗺️ **GPS Rota Takibi** — Başlangıçtan bitiş noktasına gerçek zamanlı rota
- 👣 **Adım Sayacı** — Cihazın pedometre sensörü ile adım takibi
- 🔥 **Kalori Hesaplama** — MET formülü ile kişiselleştirilmiş kalori hesabı
- 🌐 **Sphere Haritası** — Yürüdüğünüz alanlar haritada polygon olarak işaretlenir
- 👥 **Grup Yürüyüşü** — Arkadaşlarınızla birlikte yürüyüş modu
- 📊 **Alan Karşılaştırması** — Mevcut yürüyüşü önceki yürüyüşlerle kıyasla
- 🏆 **Sosyal Özellikler** — Arkadaş ekle, sphere alanlarını kıyasla
- 📈 **Haftalık Grafikler** — Bu hafta vs geçen hafta bar grafiği

## 🏗️ Mimari

```
lib/
├── core/
│   ├── constants/        # Renkler, sabitler, metinler
│   ├── theme/            # Uygulama teması
│   └── utils/            # Kalori hesaplama, mesafe/format yardımcıları
├── data/
│   ├── models/           # UserModel, WalkModel, ZoneModel, FriendRequestModel
│   ├── repositories/     # Firestore CRUD operasyonları
│   └── services/         # GPS, Pedometer servisleri
├── presentation/
│   ├── providers/        # AuthProvider, WalkProvider, UserProvider
│   ├── screens/          # Tüm ekranlar
│   └── widgets/          # Yeniden kullanılabilir widget'lar
└── routes/               # AppRouter
```

## 🔧 Kurulum

### 1. Gereksinimler

- Flutter 3.19+ SDK
- Dart 3.0+
- Firebase hesabı
- Google Maps API Key

### 2. Firebase Kurulumu

1. [Firebase Console](https://console.firebase.google.com)'a git
2. "StepSphere" adında yeni proje oluştur
3. **Authentication** → E-posta/Şifre oturum açmayı etkinleştir
4. **Firestore Database** → Production mode'da oluştur
5. **Storage** → Etkinleştir
6. **Android uygulama** ekle: `com.stepsphere.app`
7. `google-services.json` indir → `android/app/` klasörüne koy
8. **iOS uygulama** ekle: `com.stepsphere.app`
9. `GoogleService-Info.plist` indir → `ios/Runner/` klasörüne koy

### 3. FlutterFire Configure

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Bu komut `lib/firebase_options.dart` dosyasını otomatik oluşturur.

### 4. `main.dart` Güncelleme

`lib/main.dart` içindeki yorum satırlarını kaldır:

```dart
import 'firebase_options.dart';  // uncomment

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,  // uncomment
);
```

### 5. Google Maps API Key

1. [Google Cloud Console](https://console.cloud.google.com)'da Maps SDK for Android/iOS etkinleştir
2. `android/app/src/main/AndroidManifest.xml` → `YOUR_GOOGLE_MAPS_API_KEY` yerine gerçek anahtarı koy
3. `ios/Runner/Info.plist` → `YOUR_IOS_MAPS_API_KEY` yerine gerçek anahtarı koy

### 6. Firestore Index & Rules Deploy

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only storage
```

### 7. Bağımlılıkları Yükle & Çalıştır

```bash
flutter pub get
flutter run
```

## 📱 Ekranlar

| Ekran | Açıklama |
|-------|----------|
| Splash | Otomatik yönlendirme |
| Onboarding | 3 sayfalı tanıtım |
| Login / Register | Firebase Auth |
| Ana Sayfa | Bugünkü istatistikler, son yürüyüşler |
| Aktif Yürüyüş | Gerçek zamanlı harita + istatistikler |
| Yürüyüş Özeti | Tamamlanan yürüyüşün detayları |
| Sphere Haritası | Tüm keşfedilen alanlar, arkadaş karşılaştırması |
| Karşılaştırma | Bu hafta vs geçen hafta + arkadaşla karşılaştırma |
| Arkadaşlar | Arkadaş listesi, istek yönetimi, arama |
| Profil | Kullanıcı istatistikleri, ayarlar |

## 🔗 Firestore Koleksiyonlar

| Koleksiyon | Açıklama |
|-----------|----------|
| `users` | Kullanıcı profili + toplam istatistikler |
| `walks` | Her yürüyüş (rota, adım, kalori, alan) |
| `zones` | Polygon verisi (haritada işaretlenen alanlar) |
| `friend_requests` | Arkadaşlık istekleri |

## 📦 Bağımlılıklar

- **firebase_core / auth / firestore / storage** — Backend
- **provider** — State management
- **google_maps_flutter** — Harita
- **geolocator** — GPS konumu
- **pedometer** — Adım sayacı
- **fl_chart** — Grafikler
- **image_picker** — Profil fotoğrafı
- **shared_preferences** — Yerel depolama




