# CLAUDE.md

Bu dosya, bu proje üzerinde çalışırken Claude'un (Claude Code dahil) izlemesi gereken bağlamı ve kuralları içerir.

## Proje

**iPad1DOCXReader** — Lightweight read-only DOCX reader for the original iPad 1. Target platform: - iPad 1 / Apple A4 / 256 MB RAM - iOS 5.1.1 - armv7 - Objective-C / MRC - Theos / legacy iPhoneOS 6.1 SDK

- GitHub: https://github.com/SHapeloglu/ipad1docx

## Teknoloji Yığını

- Objective-C / UIKit (iOS, Theos ile derleniyor)

## Önemli Dosyalar

- `AppDelegate.m`
- `Makefile`
- `Resources/Info.plist`
- `main.m`

Mimari ayrıntılar için bkz. `ARCHITECTURE.md`.

## Sık Kullanılan Komutlar

```bash
# Henüz belgelenmiş komut yok — kurulum/çalıştırma adımlarını buraya ekleyin.
```

## Kurallar

- Proje eski iOS sürümlerini (iPad 1 / iOS 5.1.1 dahil) hedefliyor olabilir — yeni API kullanmadan önce deployment target'ı kontrol et.
- Derleme ortamını (Xcode veya Theos `Makefile`) değiştirmeden önce mevcut yapı dosyalarını incele; yeni kaynak dosyalarını derleme listesine (`project.pbxproj` / Makefile `*_FILES`) eklemeyi unutma.
- `.env`, parola, token ve API anahtarlarını asla commit etme.
- Her çalışma oturumunun sonunda `session.md`ye kısa kayıt düş; görev durumunu `task.md`de güncelle.
- Önceliklendirilmemiş fikirleri `backlog.md`ye yaz; somutlaşınca `task.md`ye taşı.

## Çalışma Dosyaları

| Dosya | Amaç |
|---|---|
| `ARCHITECTURE.md` | Mimari ve dizin yapısı referansı |
| `TASKS.md` | Aktif / devam eden / tamamlanan görevler |
| `BACKLOG.md` | Önceliklendirilmemiş fikir ve teknik borç havuzu |
| `SESSION.md` | Oturum günlüğü — her oturum sonunda güncellenir |
