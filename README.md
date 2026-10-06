# iPad1DOCXReader

Orijinal iPad 1 için hafif, salt okunur DOCX okuyucu.

Hedef platform:
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C / MRC
- Theos / eski iPhoneOS 6.1 SDK

Açma sözleşmesi:

```text
ipad1docx://open?path=<percent-encoded-absolute-path>
```

Kapsam: Microsoft Word yerleşim sadakati değil, okunabilir DOCX içeriği. Uygulama yalnızca okuma için gereken DOCX parçalarını ayrıştırır ve sıkı bellek/dosya boyutu sınırları uygular.

Taşınmış güncel çekirdek:
- sınırlı DOCX ZIP okuyucu (yalnızca `word/document.xml`)
- NSXMLParser ile metin/stil çıkarma
- paragraflar ve satır sonları
- temel kalın / italik / başlık stilleri
- basit listeler
- boş hücreleri gizleyen hafif tablo satırları
- CoreText ile görüntüleme
- A- / A+
- Bul / Sonraki / Önceki
- dosya bilgisi

Kapsam dışı: düzenleme, kaydetme, makrolar, uzak ilişkiler (remote relationships), Office/LibreOffice motoru, OCR, AI/ML, genel ZIP/dosya yöneticisi özellikleri.
