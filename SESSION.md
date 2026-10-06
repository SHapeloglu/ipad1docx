# SESSION.md

## Proje
`iPad1DOCXReader` — orijinal iPad 1 için özel, hafif, salt okunur DOCX okuyucu.

Repo: `SHapeloglu/ipad1docx`
Dal: `main`

## Değiştirilemez hedef
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- eski iPhoneOS 6.1 SDK

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

## Sahiplik
Bu uygulama yalnızca DOCX okumadan sorumludur. Genel dosya yöneticisine, arşiv yöneticisine, indiriciye, medya oynatıcıya, terminale veya PDF okuyucuya dönüşmemelidir.

Uygulama ailesi yönlendirmesi:
```text
.docx -> iPad1Files -> ipad1docx://open?path=<encoded absolute path> -> iPad1DOCXReader
```

Standart ortak depolama:
```text
/var/mobile/Media/iPad1Files
```

## Güncel fiziksel durum
- Bağımsız uygulamanın açılması: **PHYSICAL PASS**
- `ipad1docx://open?path=...` URL devri: **PHYSICAL PASS**
- Test edilen yolda yüzde-kodlu boşluklar: **PHYSICAL PASS**
- Dosya varlığı/yol doğrulaması: **PHYSICAL PASS**
- DOCX ZIP merkezi dizin taraması: **PHYSICAL PASS**
- `word/document.xml` bulma: **PHYSICAL PASS**
- zlib ile ham deflate açma: **PHYSICAL PASS**
- uzun test DOCX'inde NSXMLParser ayrıştırması: **PHYSICAL PASS**
- test dosyasında ayrıştırıcı çıktısı: 77.740 metin karakteri / 898 stil aralığı
- uzun belge görüntüleme: **FAIL — uygulama yerleşim/görüntüleme kurulumundan sonra kapanıyor**

Bilinen test dosyası:
```text
/var/mobile/Media/iPad1Files/PDFs/Les Miresables.docx
```
Cihazda gözlenen test dosyası boyutu: 97.844 bayt.
Açılmış `word/document.xml`: 1.498.378 bayt.

## Güncel görüntüleyici teşhisi
Orijinal görüntüleyici tek bir çok uzun CoreText görünümü oluşturuyordu. Fiziksel günlükler yaklaşık 85–90 bin piksellik bir içerik yüksekliği gösterdi; bu, 256 MB'lık iPad 1 bellek bütçesine uygun değil.

İlk sayfalı görüntüleyici içeriği yaklaşık 900 piksellik sayfa görünümlerine böldü, ama hâlâ tüm sayfa görünümlerini baştan oluşturuyordu. Ardından üst görünüm görüntü alanı yüksekliğiyle sınırlandı, yine de uygulama yerleşimden sonra kapandı. Bu yüzden güncel yön gerçek sanallaştırma/yeniden kullanma: tüm sayfa aralıklarını hesapla, ama yalnızca küçük, görünür bir sayfa görünümü penceresini canlı tut.

## Repo ve yerel çalışma ağacı
Repo `main` dalı artık devam eden sanallaştırılmış `DocumentRichTextView` çalışmasını içeriyor.

Geliştirici bilgisayarında şu dosyada yerel bir değişiklik var:
```text
DocumentReaderViewController.m
```
Bu yerel değişiklik görüntü alanı/yerleşim tanılamalarını içeriyor ve yanlışlıkla üzerine yazılmamalı.

Devam etmeden önce çalıştır:
```bash
git status -sb
```
ve çekerken veya sanallaştırılmış görüntüleyiciyi bağlarken bu yerel değişikliği koru.

## Hemen yapılacak sonraki adım
1. Yerel `DocumentReaderViewController.m` değişikliklerini koruyarak en son `main`'i çek.
2. Controller'ı/scroll view'ı sanallaştırılmış görüntüleyicinin güncelleme metoduna bağla.
3. Yalnızca küçük, görünür bir sayfa penceresini canlı tut (hedef: yaklaşık 3–5 görünüm).
4. Temiz derle.
5. Fiziksel iPad 1'e kur.
6. `Les Miresables.docx`'i yeniden test et.
7. Ancak uzun belge görüntüleme fiziksel olarak kararlı olduktan sonra A-/A+, arama, döndürme ve tekrarlı aç/kapat'ı test et.
8. Ancak bağımsız yönlendirme/görüntüleme PASS olduktan sonra iPad1Files'ın `.docx` yönlendirmesini PDFReader'dan DOCXReader'a çevir.
9. Ancak iPad1Files geçişi PASS olduktan sonra iPad1PDFReader'daki gömülü DOCX yedek kodunu kaldır.

## Derleme
```bash
make clean
rm -rf .theos packages
make package FINALPACKAGE=1
```

Beklenen paket:
```text
packages/com.olap.ipad1docxreader_0.1.0_iphoneos-arm.deb
```

## Hata ayıklama günlüğü
Geçici tanılamalar şu an şuraya yazıyor:
```text
/var/mobile/Media/iPad1Files/ipad1docx-debug.log
```
Sürüm derlemesinden önce ayrıntılı günlüğü kaldır veya derleme dışı bırak.
