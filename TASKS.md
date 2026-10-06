# TASKS.md

## Öncelik 0 — uzun DOCX görüntülemeyi kararlı yap
- [x] özel repo oluştur
- [x] sınırlı DOCX ayrıştırıcıyı taşı
- [x] salt okunur okuyucu arayüzünü taşı
- [x] `ipad1docx://open?path=...` alıcısını ekle
- [x] eski toolchain ile temiz derle
- [x] fiziksel iPad 1'e kur ve aç
- [x] URL devrini fiziksel olarak doğrula
- [x] ZIP bulma / açma / XML ayrıştırmayı fiziksel olarak doğrula
- [x] tam belge boyutundaki dev görüntüleme yüzeyini bellek riski olarak tespit et
- [x] tek dev görüntüleme yüzeyini sayfalı CoreText tasarımıyla değiştir
- [x] üst görüntüleyici kabını yerelde görüntü alanı yüksekliğiyle sınırla
- [ ] sanallaştırılmış sayfa penceresi güncellemelerini kaydırmaya bağla
- [ ] yalnızca yaklaşık 3–5 canlı sayfa görünümü tut
- [ ] uzun DOCX'i fiziksel olarak yeniden test et (`Les Miresables.docx`)
- [ ] uygulamanın açık kaldığını ve belge metninin göründüğünü doğrula
- [ ] başında / ortasında / sonunda çökmeden kaydırmayı doğrula

## Öncelik 1 — görüntüleme kararlı olduktan sonra okuyucu kontrolleri
- [ ] A-/A+ sanallaştırılmış sayfaları güvenle yeniden akıtıyor
- [ ] Bul / Sonraki / Önceki doğru sanal sayfaya kaydırıyor
- [ ] Bilgi dosya/yol/boyut gösteriyor
- [ ] döndürmede yeniden yerleşim kararlı
- [ ] tekrarlı aç/kapat kademeli yavaşlama yapmıyor

## Öncelik 2 — yönlendirme geçişi
- [ ] iPad1Files `.docx` kaydını `ipad1pdf`'den `ipad1docx`'e çevir
- [ ] iPad1Files üzerinden yüzde-kodlu boşlukları doğrula
- [ ] Türkçe/Unicode yolları doğrula
- [ ] olmayan/desteklenmeyen yolların güvenle başarısız olduğunu doğrula
- [ ] yalnızca fiziksel PASS'ten sonra iPad1PDFReader'daki gömülü DOCX kodunu/yönlendirmesini kaldır

## Öncelik 3 — DOCX v1 kalitesi
- [ ] tam Word yerleşimi olmadan tablo okunabilirliğini iyileştir
- [ ] daha iyi numaralı liste anlamları
- [ ] daha güvenilir başlıklar için `styles.xml`'i değerlendir
- [ ] köprüleri okunabilir metin olarak göster
- [ ] üst bilgi/alt bilgi fizibilitesi

## Sürüm hijyeni
- [ ] ayrıntılı `/var/mobile/Media/iPad1Files/ipad1docx-debug.log` tanılamalarını kaldır veya derleme dışı bırak
- [ ] README'yi doğrulanmış özellik listesiyle güncelle
- [ ] ilk kararlı beta için CHANGELOG'u güncelle

## Asla ekleme
- Office/LibreOffice motoru
- düzenleme/kaydetme
- makrolar
- uzak ilişki getirme
- genel ZIP/dosya yöneticisi özellikleri
- OCR/AI/ML
