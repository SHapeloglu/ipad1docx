# CLAUDE.md — iPad1DOCXReader (ipad1docx)

Orijinal **iPad 1 (A4, 256 MB RAM, iOS 5.1.1, armv7)** için hafif, **salt okunur DOCX okuyucu** — Objective-C, **MRC/non-ARC**, Theos + eski iPhoneOS 6.1 SDK. Amaç Word yerleşim sadakati değil, okunabilir içerik: sınırlı ZIP okuyucu (yalnızca `word/document.xml`) → NSXMLParser ile metin/stil çıkarma (paragraflar, satır sonları, kalın/italik/başlıklar, basit listeler, hafif tablolar) → CoreText görüntüleme, A-/A+, Bul/Sonraki/Önceki, dosya bilgisi. Paket `com.olap.ipad1docxreader` **0.1.0** (`control`).

- GitHub: https://github.com/SHapeloglu/ipad1docx
- Önce oku: `AGENTS.md` (platform + kapsam, belirleyici) → `ARCHITECTURE.md` → `TASKS.md` → `SESSION.md` → `TESTING.md` → `BACKLOG.md` / `CHANGELOG.md`.
- Açma sözleşmesi: `ipad1docx://open?path=<percent-encoded-absolute-path>` (iPad1Files çağırır).

## Güncel öncelik (TASKS.md)

Ö0 — uzun DOCX görüntülemeyi kararlı yap: kaydırmaya bağlı sanallaştırılmış sayfa penceresi, yalnızca ~3–5 canlı sayfa görünümü, uzun bir belgeyle fiziksel yeniden test (başı/ortası/sonu çökmeden). Ardından Ö1 sanallaştırılmış sayfalarda okuyucu kontrolleri → Ö2 yönlendirme geçişi (iPad1Files `.docx` → `ipad1pdf` yerine `ipad1docx`; iPad1PDFReader'daki gömülü DOCX kodu yalnızca fiziksel PASS'ten sonra kaldırılır) → Ö3 kalite.

## Derleme

```bash
make clean && make package FINALPACKAGE=1      # ARCHS=armv7, TARGET=iphone:clang:6.1:5.1, -fno-objc-arc
```

Diğer iPad1 uygulamaları gibi eski `ssh-rsa` seçenekleriyle SSH üzerinden kurulur.

## Kurallar (AGENTS.md)

- Dağıtım hedefini yükseltme veya yalnızca yeni iOS'ta olan API'ler ekleme.
- Kapsam içi: formata özgü DOCX ZIP/XML ayrıştırma, hafif salt okunur tipografi, arama, yazı boyutu kontrolleri; görseller yalnızca fiziksel profil sonrası.
- **İzin verilmeyenler:** genel dosya yönetimi, genel ZIP/arşiv arayüzü, indirme yöneticisi, PDF özellikleri, medya oynatma, Office/LibreOffice motoru, düzenleme/kaydetme.
- Bellek/dosya boyutu sınırlarını sıkı tut; asla tüm belgeyi kapsayan bitmap oluşturma.
- "Bitti" tanımı fiziksel cihazda PASS'tir; sonuçları `SESSION.md` ve `TESTING.md`'ye yaz.
- Tüm `.md` dokümanları Türkçe yazılır.
