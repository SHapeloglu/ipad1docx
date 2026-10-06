# ARCHITECTURE.md

## Hedef
Masaüstü Word sadakatine çalışmadan iPad 1 / iOS 5.1.1 için pratikteki en hafif DOCX okuma deneyimini sağlamak.

## Bileşenler
```text
AppDelegate
  -> receives ipad1docx://open?path=...
  -> validates path/extension
  -> pushes DocumentReaderViewController

DocumentReaderViewController
  -> file guards / controls / search
  -> owns UIScrollView and toolbar
  -> DOCXReader
  -> DocumentRichTextView

DOCXReader
  -> bounded ZIP central-directory scan
  -> reads only word/document.xml
  -> zlib store/deflate support
  -> NSXMLParser streaming extraction
  -> plain text + bounded style ranges

DocumentRichTextView
  -> CoreText attributed-string framesetter
  -> page-range calculation
  -> virtualized small page-view window
  -> no WebView / HTML / JavaScript
```

Özetle: `AppDelegate` adresi alıp yolu/uzantıyı doğrular; `DocumentReaderViewController` dosya korumaları, kontroller ve aramayı yönetir; `DOCXReader` sınırlı ZIP taraması yapıp yalnızca `word/document.xml`'i akışla ayrıştırır; `DocumentRichTextView` CoreText ile küçük, sanallaştırılmış bir sayfa penceresi görüntüler (WebView/HTML/JavaScript yok).

## URL sözleşmesi
Birincil açma sözleşmesi:
```text
ipad1docx://open?path=<percent-encoded absolute path>
```

Okuyucu orijinal dosyayı yerinde açar. Dosyayı kopyalamaz, taşımaz veya yaşam döngüsünü sahiplenmez.

## Ortak depolama sınırı
Standart ortak depolama şurada kalır:
```text
/var/mobile/Media/iPad1Files
```

Gezinme, kopyala/taşı/yeniden adlandır/sil ve dosya yönlendirme `iPad1Files`'a aittir. `iPad1DOCXReader` yalnızca bir yol alır ve DOCX'i okur.

## Bellek mimarisi
iPad 1'de yalnızca 256 MB RAM var. Bu yüzden görüntüleyici belge yüksekliğinde arka depolardan ve belge genelinde canlı sayfa görünümlerinden kaçınmalıdır.

Zorunlu kurallar:
- sıkıştırılmış DOCX <= 8 MiB
- `word/document.xml` <= 4 MiB
- stil aralıkları <= 4096
- paketin tamamı çıkarılmaz
- v1'de görsel önbelleği yok
- arka plan dizini yok
- uzak ilişki getirme yok
- tam belge yüksekliğinde tek dev görüntüleme görünümü yok
- sayfa geometrisi önceden hesaplanabilir, ancak yalnızca küçük, görünür bir sayfa penceresi canlı `UIView` örneklerine sahip olmalı
- hedef canlı görüntüleme penceresi: yaklaşık 3–5 sayfa görünümü
- ekran dışı sayfa görünümlerini agresif şekilde serbest bırak

## Görüntüleme akışı
```text
DOCXReader
  -> plainText + styles
  -> DocumentRichTextView builds one CTFramesetter
  -> calculate page character ranges with CTFrameGetVisibleStringRange
  -> keep lightweight range metadata for the full document
  -> instantiate only visible/near-visible IP1DOCXPageView objects
  -> recycle/remove page views as scrolling changes
```

Bu mimari bilinçli olarak şunları ayırır:
- belge metadata'sı/aralıkları: ucuz ve kalıcı;
- CoreText framesetter: tek ortak nesne;
- sayfa görünümleri/arka depolar: pahalı ve sanallaştırılmış.

## Desteklenen v1 anlamları
- paragraflar / satır sonları
- kalın / italik
- temel başlıklar
- basit liste göstergesi
- okunabilir satırlara düzleştirilmiş basit tablolar
- boş/yalnızca NBSP içeren hücreler görsel ayraçlardan çıkarılır
- salt okunur arama ve yazı boyutu kontrolleri

## Açıkça hedef dışı
- düzenleme/kaydetme
- izlenen değişiklikler/yorum düzenleyici
- piksel piksel Word sayfalaması
- tam Word stil/tema motoru
- makrolar
- Office/LibreOffice SDK/çalışma zamanı
- genel ZIP gezgini
- OCR / AI / ML

## Uygulama ailesi sahiplik kuralı
Her uygulama uzman kalır. Ailedeki başka bir yetenek gerekiyorsa, o alt sistemi bu uygulamaya kopyalamak yerine URL devri/geri çağrısı kullan.
