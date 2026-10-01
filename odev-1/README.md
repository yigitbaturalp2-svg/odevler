# 🏛️ Ödev 1: Demokrasi & Yönetişim Ontolojisi Platformu

Bu proje, doğrudan katılımcı demokrasi ilkelerini blokzincir güvenliği, karesel oylama ve yapay zeka destekli mevzuat ontolojisi ile birleştiren **yerel (native) Flutter mobil uygulamasıdır**.

---

## 🎯 Projenin Amacı ve Felsefi Problemin Çözümü

### Soru: *"Çoğunluk azınlığı tüketebilir mi? Nasıl çözeriz?"*
Geleneksel "1 Kişi = 1 Oy" sistemlerinde yüzeysel bir çoğunluk (%51), hayati haklarını savunan azınlığın (%49) haklarını gasp edebilir (*Tyranny of the Majority*). 

### Çözümümüz:
1. **Karesel Oylama (Quadratic Voting - $Maliyet = Oy^2$):** Seçmenler her konuya tek oy vermek zorunda değildir; kendileri için hayati derecede önemli konularda ses kredilerini katlayarak kullanabilirler (1 oy = 1 VC, 2 oy = 4 VC, 3 oy = 9 VC, 4 oy = 16 VC). Bu sayede 15 kişilik kararlı bir azınlık, 70 kişilik ilgisiz çoğunluğa karşı hakkını koruyabilir.
2. **%30 Azınlık Rıza Eşiği:** Temel hakları ilgilendiren yasalarda azınlığın en az %30'unun rızası olmadan yasa yürürlüğe giremez.
3. **Normlar Hiyerarşisi Filtresi:** Çoğunluk oyu çıksa dahi üst normlara (Anayasa Md. 43, Md. 56 vb.) aykırı teklifler yapay zeka ontolojisi ve bilirkişi vetosuyla otomatik olarak engellenir.

---

## 📜 Hocanın 8 Şartı ve Projedeki Karşılıkları

| Kural # | Hocanın Şartı | Uygulamadaki Karşılığı ve İşleyişi |
| :---: | :--- | :--- |
| **Kural 1** | **Konu Açma & Diff Önergesi** | Yurttaşlar yeni yasa teklifi açabilir (`+ Yeni Yasa`). Mevcut yasa metinleri üzerinde GitHub tarzı satır satır `Diff (Kırmızı/Yeşil)` düzenleme önergeleri sunulup oylanabilir. |
| **Kural 2** | **Salt Çoğunluk & Rıza** | Tekliflerin kabulü için en az %50+1 evet oyu ve ilgili etki alanındaki azınlık rızası aranır. |
| **Kural 3** | **Gerçek KYC + ZKP Rumuz** | Sistem veri tabanında gerçek T.C. kimlik, ad-soyad, doğum tarihi ve adres tutulur. Ancak defterde ve kamusal alanda **Sıfır Bilgi İspatı (ZKP)** ile üretilmiş anonim rumuzlar (`@AdaletSavunucusu`) görünür. |
| **Kural 4** | **Yürürlüğe Girme & Mühür** | Oylamayı geçen teklifler "OYLAMADA" statüsünden "KABUL EDİLDİ / YÜRÜRLÜKTE" statüsüne geçer ve yeni bir blok kazılarak zincire işlenir. |
| **Kural 5** | **Alt Konular (Sub-topics)** | Ana yasa tekliflerine bağlı bağımsız alt maddeler önerilebilir ve her biri kendi bağımsız oylama sürecine tabidir. |
| **Kural 6** | **Normlar Hiyerarşisi & Bilirkişi** | **Anayasa > Kanun > Yönetmelik** hiyerarşisi denetlenir. Üst norma aykırı teklifler ontoloji motoru tarafından tespit edilerek Bilirkişi Veto kararıyla düşürülür. Bilirkişilerin oy ağırlığı çarpanlıdır (örn. Prof. Dr. İlker Akman: `2.2x`). |
| **Kural 7** | **Silinemez Defter (SHA-256)** | Görüş ve müzakereler blokzincirde kriptografik hash'lerle mühürlenir; doğrudan fiziksel olarak silinemez. |
| **Kural 8** | **%66 Redaksiyon / Maskeleme** | KVKK ihlali veya nefret söylemi içeren silinemez yorumlar için topluluk sansür oylaması açılır; %66 "Silinsin" oyu çıkarsa metin maskelenir ancak kriptografik hash bütünlüğü korunur. |

---

## 🎭 Canlı Sunum Senaryoları (Hızlı Geçiş)

Uygulamanın sağ üst köşesindeki **Ayarlar (Ayar Çarkı)** ikonuna dokunarak hocaya derste gösterilecek 5 farklı senaryo arasında anında geçiş yapabilirsiniz:

1. **Senaryo 1: Kentsel Dönüşüm & Karesel Oylama**
   - Azınlık hakları koruması, yağmur suyu göletleri diff önergesi, bisiklet yolları alt konusu.
2. **Senaryo 2: Anayasaya Aykırı Teklif & Normlar Hiyerarşisi Reddi**
   - Kıyıların özelleştirilmesi teklifi. T.C. Anayasası Madde 43 ihlali nedeniyle AI ontoloji uyumu %18'e düşer ve Bilirkişi Prof. Dr. İlker Akman tarafından VETO edilir.
3. **Senaryo 3: KVKK İhlali & Defterde Sansür Oylaması**
   - Deftere yazılan şahsi adres/TC ifşası. Kural 7 gereği silinemez; Kural 8 gereği %66 topluluk oylaması ile maskelenir.
4. **Senaryo 4: Kabul Edilmiş Resmi Kanun**
   - Yenilenebilir enerji teşvik kanunu. Salt çoğunlukla kabul edilmiş ve Blok #1050'ye mühürlenmiş yürürlükteki mevzuat.
5. **Senaryo 5: Sıfırdan Canlı Sunum Modu**
   - Hocanın o an derste söyleyeceği yasa teklifini canlı olarak girip test etmek için boş taslak modu.

---

## 🛠️ Canlı Manuel Kontroller

Sunum sırasında hocanın *"Şu teklifin oylarını değiştirirsen ne olur?"* veya *"Ontoloji puanını düşürürsen ne olur?"* soruları için Ayarlar altındaki **Manuel Kontroller** sekmesinden:
- Evet/Hayır oyları tek tıkla (+20 / -20) manipüle edilebilir.
- Teklif statüsü anlık olarak *Oylamada / Kabul / Veto* yapılabilir.
- Ontoloji uyum slider'ı (0 - 100) canlı kaydırılabilir.
- Ses kredisi (+50 VC) eklenebilir veya sıfırlanabilir.
- Aktif yurttaş rolü (Yiğit, Prof. Dr. İlker Akman [2.2x], Zeynep [1.5x]) değiştirilebilir.

---

## 📱 Ekran Görüntüleri ve UI Tasarımı

- **0 Piksel Taşma (Zero-Overflow):** En dar telefon ekranlarında (`360x640`) dahi tüm kartlar, alt menü ve modallar responsive olarak test edilmiş; 0 taşma garantisi sağlanmıştır.
- **Modern Koyu Acrylic Arayüz:** `#090D16` derin uzay teması, `#38BDF8` neon cam göbeği vurguları ve özel 5 sekmeli alt menü:
  1. 🗳️ **Konular:** Yasa teklifleri, karesel oy kontrolleri, diff görüntüleyici, filtreler.
  2. 🕸️ **İnsan Grafı:** Canvas üzerinde çizilen interaktif güven grafı (Web of Trust).
  3. ⚖️ **Bilirkişi:** Normlar hiyerarşisi katmanları, AI denetim motoru ve bilirkişi görüşleri.
  4. ⛓️ **Defter:** Blokzincir gezgini (Blok hash, önceki hash, merkle kökü, canlı blok kazma).
  5. 🪪 **Kimlik:** KYC gerçek kimlik paneli, ZKP kamusal rumuz ve rol yönetimi.

---

## 💻 macOS Üzerinde Kurulum ve Çalıştırma

Projeyi Mac cihazınızda çalıştırmak için:

### 1. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 2. Taşma ve Birim Testlerini Çalıştırın
```bash
flutter test
```
*(Tüm testlerin `All tests passed!` verdiğini doğrulayın).*

### 3. macOS Masaüstü veya iOS / Android Olarak Başlatın
```bash
# macOS yerel masaüstü penceresi olarak çalıştırmak için:
flutter run -d macos

# Bağlı iPhone / Android veya simülatörde çalıştırmak için:
flutter run
```

---

## 📦 Android APK
Doğrudan Android cihaza yüklemek için derlenmiş hazır paket:
- **`Demokrasi.apk`** (Masaüstünde ve release dizininde mevcuttur).
- Yükleme komutu:
  ```bash
  adb install -r Demokrasi.apk
  ```
