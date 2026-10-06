# TESTING.md

Doğruluk kaynağı fiziksel iPad 1 / iOS 5.1.1'dir.

Durum sözlüğü:
- **COMPILE PASS**: yalnızca başarıyla derleniyor.
- **PHYSICAL PASS**: gerçek iPad 1'de doğrulandı.
- **FAIL**: fiziksel olarak yeniden üretilmiş hata.
- **PENDING**: henüz fiziksel olarak doğrulanmadı.

## Derleme
```bash
make clean
rm -rf .theos packages
make package FINALPACKAGE=1
```
Gerekenler: armv7, iOS 5.1 hedefi, eski iPhoneOS 6.1 SDK, MRC.

Güncel derleme durumu: **COMPILE PASS**.

## Açma / yönlendirme
- [x] bağımsız uygulama açılıyor — **PHYSICAL PASS**
- [x] `ipad1docx://open?path=...` uygulamaya ulaşıyor — **PHYSICAL PASS**
- [x] test edilen yüzde-kodlu boşluklar doğru çözülüyor — **PHYSICAL PASS**
- [ ] Türkçe/Unicode yol karakterleri — **PENDING**
- [ ] olmayan yol güvenle başarısız oluyor — **PENDING**
- [ ] DOCX olmayan yol reddediliyor — **PENDING**

## Ayrıştırıcı hattı
Test dosyası:
```text
/var/mobile/Media/iPad1Files/PDFs/Les Miresables.docx
```

Gözlenen fiziksel tanılamalar:
- sıkıştırılmış dosya boyutu: 97.844 bayt
- merkezi dizin bulundu
- `word/document.xml` bulundu
- sıkıştırma yöntemi: deflate
- açılmış XML boyutu: 1.498.378 bayt
- NSXMLParser sonucu: başarılı
- çıkarılan metin: 77.740 karakter
- stil aralıkları: 898

Durum:
- [x] ZIP merkezi dizin taraması — **PHYSICAL PASS**
- [x] document.xml çıkarma — **PHYSICAL PASS**
- [x] zlib ham açma — **PHYSICAL PASS**
- [x] NSXMLParser ayrıştırma — **PHYSICAL PASS**

## Görüntüleme
- [x] ayrıştırıcı sonucu görüntüleyiciye ulaşıyor — **PHYSICAL PASS**
- [x] tam belge yüksekliği hesaplanabiliyor — **PHYSICAL PASS**
- [ ] uzun DOCX açık ve görünür kalıyor — **FAIL**
- [ ] başında/ortasında/sonunda kaydırma — **PENDING**
- [ ] sanallaştırılmış 3–5 canlı sayfa penceresi — **PENDING PHYSICAL TEST**

Bilinen hata tanılamaları:
```text
content height observed: ~85k–90k px
```
İlk dev görünüm görüntüleyicisi ve tüm sayfaları baştan oluşturan ilk sayfalı görüntüleyici, fiziksel iPad 1'de yerleşim/görüntüleme kurulumundan sonra kapandı.

## İçerik kalitesi
- [ ] paragraflar okunabilir — **PENDING (bağımsız görüntüleme kararlılığı bekleniyor)**
- [ ] Türkçe karakterler okunabilir — **PENDING**
- [ ] kalın/italik görünüyor — **PENDING**
- [ ] başlıklar görsel olarak ayırt ediliyor — **PENDING**
- [ ] listeler okunabilir — **PENDING**
- [ ] tablo satırları mümkün olduğunca anlamlı alan/değer çiftlerini tek satırda tutuyor — **PENDING (bağımsız)**
- [ ] boş/yalnızca NBSP içeren hücreler tekrarlayan ayraç oluşturmuyor — **PENDING (bağımsız)**

## Kontroller
- [ ] A-/A+ sınırlı ve kararlı
- [ ] Bul / Sonraki / Önceki çalışıyor
- [ ] bulunamadı mesajı güvenli
- [ ] Bilgi dosya/yol/boyut gösteriyor
- [ ] döndürme/yeniden yerleşim çökmeye yol açmıyor

## Güvenlik sınırları
- [ ] 8 MiB'tan büyük sıkıştırılmış DOCX tam ayrıştırmadan önce reddediliyor
- [ ] 4 MiB'tan büyük `word/document.xml` reddediliyor
- [ ] şifreli DOCX reddediliyor
- [ ] desteklenmeyen sıkıştırma reddediliyor
- [ ] bozuk ZIP/XML çökmeden görünür şekilde başarısız oluyor

## Kararlılık
- [ ] aynı DOCX'i 20 kez aç/kapat
- [ ] birkaç DOCX dosyasını art arda aç
- [ ] A+/A- tekrar tekrar
- [ ] tekrarlı arama
- [ ] kademeli yavaşlama veya çökme yok
- [ ] okuyucu ekran dışındayken bellek uyarısı atılabilir durumu temizliyor

## Sınır
- [x] dosya yöneticisi davranışı yok
- [x] indirici yok
- [x] PDF motoru yok
- [x] Office/LibreOffice çalışma zamanı yok
- [x] OCR/AI/ML yok

Hiçbir bekleyen maddeyi fiziksel cihaz testi olmadan PASS'e çevirme.
