# AGENTS.md

## Değiştirilemez platform
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- eski iPhoneOS 6.1 SDK

Kolaylık için dağıtım hedefini yükseltme veya yalnızca yeni iOS'ta olan API'ler ekleme.

## Kapsam
Bu repo, iPad1 uygulama ailesinin DOCX okuma uzmanıdır.

İzin verilenler:
- okuma için gereken formata özgü DOCX ZIP/XML ayrıştırma
- hafif, salt okunur tipografi/yerleşim
- arama ve yazı boyutu kontrolleri
- sınırlı görsel desteği, yalnızca fiziksel profil çıkarıldıktan sonra

İzin verilmeyenler:
- genel dosya yönetimi
- genel ZIP/arşiv arayüzü
- indirme yöneticisi
- PDF okuyucu özellikleri
- medya oynatma
- Office/LibreOffice motoru
- düzenleme/kaydetme
- OCR/AI/ML

## Uygulama ailesi sahiplik kuralı
Her uygulama uzman kalır. Bir yetenek ailedeki başka bir uygulamaya aitse, o alt sistemi burada yeniden yazmak yerine URL devri/geri çağrısı kullan.

Güncel yönlendirme sözleşmesi:
```text
ipad1docx://open?path=<percent-encoded absolute path>
```

## Fiziksel doğrulama kuralı
Başarılı derleme çalışma zamanında GEÇTİ demek değildir. Bir özelliği yalnızca fiziksel iPad 1 **PHYSICAL PASS** olarak işaretleyebilir.

Bu terimleri tutarlı kullan:
- COMPILE PASS (derleme geçti)
- PHYSICAL PASS (fiziksel cihazda geçti)
- FAIL (başarısız)
- PENDING (bekliyor)

Bir özelliği asla yalnızca simülatör varsayımlarından, kod incelemesinden veya başarılı derlemeden PASS olarak işaretleme.

## Bellek kuralı
256 MB cihaz sınırı mimari kararlara hükmeder.

Gereken davranış:
- akışlı/sınırlı işlemeyi tercih et;
- atılabilir nesneleri agresif şekilde serbest bırak;
- belge genelinde ağır önbellekler asla tutma;
- asla belgenin tam yüksekliğinde bir arka depo (backing store) oluşturma;
- uzun belgenin tüm sayfa görünümlerini asla aynı anda oluşturma;
- pahalı görüntüleme görünümlerini sanallaştır/yeniden kullan;
- canlı CoreText sayfa görünümlerini küçük, görünür bir pencerede tut; mümkünse yaklaşık 3–5;
- bellek uyarılarını kenar durum değil, birinci sınıf davranış olarak ele al.

## Değişiklik disiplini
Düzenlemeden önce:
1. `SESSION.md`'yi oku;
2. `ARCHITECTURE.md`'yi oku;
3. `TASKS.md`'yi oku;
4. `TESTING.md`'yi oku;
5. yerel cihaz hata ayıklama değişikliklerinin üzerine yazılmasın diye `git status -sb` kontrol et.

Fiziksel test bilinen bir gerçeği değiştirdiğinde, aynı çalışma oturumunda `SESSION.md` ve `TESTING.md`'yi güncelle.

## Hata ayıklama kuralı
Cihaza ağır çalışma zamanı araçları eklemek yerine hafif dosya günlüğünü tercih et. Güncel geçici hata ayıklama yolu:
```text
/var/mobile/Media/iPad1Files/ipad1docx-debug.log
```
Sürümden önce ayrıntılı tanılamaları kaldır veya derleme dışı bırak.
