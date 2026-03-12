class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'StepSphere';
  static const String appTagline = 'Walk. Explore. Conquer.';

  // Auth
  static const String login = 'Giriş Yap';
  static const String register = 'Kayıt Ol';
  static const String logout = 'Çıkış Yap';
  static const String email = 'E-posta';
  static const String password = 'Şifre';
  static const String confirmPassword = 'Şifreyi Onayla';
  static const String fullName = 'Ad Soyad';
  static const String forgotPassword = 'Şifremi Unuttum';
  static const String dontHaveAccount = 'Hesabın yok mu? ';
  static const String alreadyHaveAccount = 'Zaten hesabın var mı? ';
  static const String signUp = 'Kayıt Ol';
  static const String signIn = 'Giriş Yap';
  static const String orContinueWith = 'veya şununla devam et';
  static const String continueWithGoogle = 'Google ile Devam Et';

  // Onboarding
  static const String onboarding1Title = 'Yürüyüşünü Takip Et';
  static const String onboarding1Desc =
      'GPS ile her adımını kaydet, rotanı haritada gör.';
  static const String onboarding2Title = 'Alanını İşaretle';
  static const String onboarding2Desc =
      'Yürüdüğün bölgeleri işaretle ve kendi sphere\'ini oluştur.';
  static const String onboarding3Title = 'Arkadaşlarınla Yarış';
  static const String onboarding3Desc =
      'Keşfettiğin alanları arkadaşlarınla kıyasla ve liderlik tablosunda yüksel.';
  static const String getStarted = 'Başlayalım';
  static const String next = 'İleri';
  static const String skip = 'Atla';

  // Home
  static const String goodMorning = 'Günaydın';
  static const String goodAfternoon = 'İyi öğlenler';
  static const String goodEvening = 'İyi akşamlar';
  static const String todayStats = 'Bugünkü İstatistikler';
  static const String weeklyStats = 'Haftalık Özet';
  static const String recentWalks = 'Son Yürüyüşler';
  static const String startWalk = 'Yürüyüşe Başla';
  static const String noWalksYet = 'Henüz yürüyüş yok';
  static const String noWalksDesc = 'İlk yürüyüşünü başlatmak için butona dokun!';

  // Walk
  static const String activeWalk = 'Aktif Yürüyüş';
  static const String walkHistory = 'Yürüyüş Geçmişi';
  static const String soloWalk = 'Tek Başıma';
  static const String groupWalk = 'Arkadaşlarımla';
  static const String steps = 'Adım';
  static const String distance = 'Mesafe';
  static const String calories = 'Kalori';
  static const String duration = 'Süre';
  static const String pace = 'Tempo';
  static const String startTime = 'Başlangıç';
  static const String endTime = 'Bitiş';
  static const String pauseWalk = 'Duraklat';
  static const String resumeWalk = 'Devam Et';
  static const String stopWalk = 'Bitir';
  static const String walkCompleted = 'Yürüyüş Tamamlandı!';
  static const String saveWalk = 'Kaydet';
  static const String discardWalk = 'Vazgeç';

  // Map & Zones
  static const String myZones = 'Spherem';
  static const String friendZones = 'Arkadaş Sphereleri';
  static const String totalAreaExplored = 'Keşfedilen Alan';
  static const String zoneOverlap = 'Çakışan Alan';
  static const String newZoneAdded = 'Yeni bölge eklendi!';

  // Friends
  static const String friends = 'Arkadaşlar';
  static const String addFriend = 'Arkadaş Ekle';
  static const String friendRequests = 'Arkadaşlık İstekleri';
  static const String searchFriends = 'Arkadaş Ara';
  static const String noFriends = 'Henüz arkadaş yok';
  static const String noFriendsDesc = 'Arkadaşlarını bul ve birlikte keşfet!';
  static const String accept = 'Kabul Et';
  static const String decline = 'Reddet';
  static const String pending = 'Bekliyor';
  static const String remove = 'Kaldır';

  // Comparison
  static const String compare = 'Karşılaştır';
  static const String vsLastWeek = 'Geçen Haftayla';
  static const String vsFriends = 'Arkadaşlarla';
  static const String vsMyself = 'Kendimle';
  static const String improved = 'Geliştin!';
  static const String keepGoing = 'Devam et!';
  static const String areaComparison = 'Alan Karşılaştırması';
  static const String currentArea = 'Bu Sefer';
  static const String previousArea = 'Önceki Sefer';
  static const String newAreaAdded = 'Yeni Alan';

  // Profile
  static const String profile = 'Profil';
  static const String editProfile = 'Profili Düzenle';
  static const String settings = 'Ayarlar';
  static const String totalWalks = 'Toplam Yürüyüş';
  static const String totalSteps = 'Toplam Adım';
  static const String totalDistance = 'Toplam Mesafe';
  static const String totalCalories = 'Yakılan Kalori';
  static const String achievements = 'Başarımlar';
  static const String weight = 'Kilo (kg)';
  static const String height = 'Boy (cm)';
  static const String unitMetric = 'Metrik (km)';
  static const String unitImperial = 'İmperial (mil)';

  // Leaderboard
  static const String leaderboard = 'Lider Tablosu';
  static const String weekly = 'Haftalık';
  static const String monthly = 'Aylık';
  static const String allTime = 'Tüm Zamanlar';

  // Errors
  static const String errorGeneric = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String errorNoInternet = 'İnternet bağlantısı yok.';
  static const String errorLocationPermission =
      'Konum izni gerekiyor. Lütfen ayarlardan izin verin.';
  static const String errorEmailInvalid = 'Geçerli bir e-posta adresi girin.';
  static const String errorPasswordShort = 'Şifre en az 6 karakter olmalıdır.';
  static const String errorPasswordMismatch = 'Şifreler eşleşmiyor.';
  static const String errorNameRequired = 'Ad soyad gereklidir.';

  // Units
  static const String km = 'km';
  static const String m = 'm';
  static const String mi = 'mil';
  static const String kcal = 'kcal';
  static const String minPerKm = 'dk/km';
  static const String step = 'adım';
}
