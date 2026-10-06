# CHANGELOG.md

## Yayımlanmadı

### Eklendi
- iPad 1 / iOS 5.1.1 için bağımsız `iPad1DOCXReader` uygulaması
- `ipad1docx://open?path=...` URL devri
- sınırlı DOCX ZIP okuyucu
- zlib ile ham deflate desteği
- `word/document.xml` çıkarma
- NSXMLParser tabanlı metin/stil çıkarma
- temel kalın, italik, başlık, liste ve tablo satırı anlamları
- salt okunur arama kontrolleri
- yazı boyutu kontrolleri
- dosya/yol/boyut bilgi görünümü
- geçici cihaz tarafı hata ayıklama günlüğü

### Fiziksel iPad 1'de doğrulandı
- bağımsız uygulamanın açılması
- URL scheme devri
- test edilen yolda yüzde-kodlu boşluk çözme
- dosya yolu çözümleme
- ZIP merkezi dizin taraması
- `word/document.xml` bulma
- deflate açma
- uzun bir DOCX'te NSXMLParser ayrıştırması

### Devam ediyor
- bellek güvenli uzun belge görüntüleme
- sanallaştırılmış/yeniden kullanılan CoreText sayfa görünümleri

### Bilinen sorun
Uzun DOCX belgeleri şu an fiziksel iPad 1'de yerleşim/görüntüleme kurulumundan sonra uygulamayı kapatıyor. Ayrıştırma aşamaları başarıyla tamamlanıyor; aktif inceleme görüntüleyicinin bellek kullanımı.

## 0.1.0
İlk bağımsız paket kimliği ve Theos uygulama iskeleti.
