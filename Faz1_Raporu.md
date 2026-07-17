*ATM İşlem Analizi ve Anomali Tespit Sistemi — Faz 1 Raporu*

# PROJE RAPORU

## ATM İşlem Analizi ve Anomali Tespit Sistemi

*Faz 1: Veri Altyapısı, Keşifçi Veri Analizi ve Anomali Tespiti*

**Dokümantasyon Sürümü:** 1.0

**Tarih:** 16 Temmuz 2026

**Veritabanı Mimarisi:** Microsoft SQL Server (T-SQL)

---

# İçindekiler

1. Yönetici Özeti
2. Proje Altyapısı ve Veri Mimarisi
   - 2.1. Veritabanı Yönetimi
   - 2.2. Veri Seti Üretimi
3. Keşifçi Veri Analizi (EDA) Bulguları
   - 3.1. Zamansal Dağılım Analizi
   - 3.2. İşlem Hacmi Analizi
4. Anomali Tespit Başarı Kriterleri
   - 4.1. İstatistiksel Sınır Belirleme (Boxplot Analizi)
   - 4.2. Yakalanan Anomaliler
5. Sonuç ve Sonraki Adımlar

---

# 1. Yönetici Özeti

Bu doküman, ATM İşlem Analizi ve Anomali Tespit Sistemi projesinin birinci fazına ait çalışmaları özetlemektedir. Faz 1 kapsamında; ilişkisel veritabanı altyapısının kurulması, gerçekçi sentetik veri setinin üretilmesi, keşifçi veri analizinin (EDA) gerçekleştirilmesi ve istatistiksel yöntemlerle tutar bazlı anomali tespitinin yapılması hedeflenmiştir. Bu hedeflere ilişkin tüm teknik adımlar başarıyla tamamlanmış ve sonuçlar aşağıda detaylandırılmıştır.

Proje, finansal işlem verileri üzerinden dolandırıcılık şüphesi taşıyan anormal işlemlerin istatistiksel yöntemlerle otomatik olarak filtrelenmesini amaçlamaktadır. Bu doğrultuda kurgulanan veri mimarisi ve analiz süreçleri, ilerleyen fazlarda geliştirilecek makine öğrenmesi tabanlı tespit modelleri için sağlam bir temel oluşturmaktadır.

# 2. Proje Altyapısı ve Veri Mimarisi

## 2.1. Veritabanı Yönetimi

Sistemin veri katmanı, Microsoft SQL Server (T-SQL) mimarisi üzerine inşa edilmiştir. Veritabanı şeması, finansal işlem süreçlerini bütüncül biçimde temsil edecek şekilde dört temel tablo etrafında tasarlanmıştır:

- **accounts** — Müşteri hesap bilgilerinin tutulduğu ana tablo
- **cards** — Hesaplara bağlı banka/kredi kartı bilgileri
- **atm_locations** — İşlemlerin gerçekleştiği ATM lokasyon verileri
- **transactions** — Tüm finansal işlem kayıtlarının tutulduğu merkezi tablo

Bu tablolar arasında Primary Key / Foreign Key ilişkileri üzerinden tam ilişkisel bir model başarıyla kurgulanmıştır. Bu sayede işlem verileri; ilgili hesap, kart ve ATM lokasyon bilgileriyle tutarlı ve bütünlük içinde ilişkilendirilebilmektedir.

## 2.2. Veri Seti Üretimi

Analiz ve test süreçlerinde kullanılmak üzere, Python programlama dili ile Faker ve pandas kütüphaneleri kullanılarak sentetik bir veri seti oluşturulmuştur. Veri seti, Türkçe lokalizasyona uygun (isim, adres, şehir vb. alanlar dahil) gerçekçi finansal işlem kayıtlarından oluşmaktadır.

**Toplam Kayıt Sayısı:** 50.400 satır

**Üretim Araçları:** Python — Faker, pandas

**Lokalizasyon:** Türkçe (TR)

# 3. Keşifçi Veri Analizi (EDA) Bulguları

## 3.1. Zamansal Dağılım Analizi

İşlemlerin gün içindeki saatlik dağılımı incelendiğinde, işlemlerin günün 24 saatine genel olarak dengeli (uniform) biçimde yayıldığı gözlemlenmiştir. Bununla birlikte, anomali tespit algoritmalarının test edilebilmesi amacıyla gece saatlerine (özellikle yüksek riskli zaman dilimlerine) bilinçli olarak ek işlem yoğunluğu enjekte edilmiştir. Bu tasarım, geliştirilecek tespit mekanizmalarının zaman bazlı risk senaryolarına duyarlılığının test edilmesini sağlamaktadır.

## 3.2. İşlem Hacmi Analizi

Sistem genelinde işlem türlerine göre dağılım incelendiğinde, Sorgu, Para Yatırma ve Para Çekme işlemlerinin adet bazında birbirine eşit olduğu tespit edilmiştir.

| İşlem Türü | İşlem Adedi | Nakit Akışına Etkisi |
| --- | --- | --- |
| Sorgu (Bakiye Sorgulama) | 16.000 | Yok |
| Para Yatırma | 16.000 | Var (Pozitif Akış) |
| Para Çekme | 16.000 | Var (Negatif Akış) |

İşlem adetleri eşit dağılmış olmasına rağmen, beklenildiği üzere nakit akış hacmi (parasal tutar bazında) Para Yatırma ve Para Çekme işlemlerinde yoğunlaşmıştır; zira Sorgu işlemleri parasal bir hareket içermemektedir.

![İşlem Tipleri Adet ve Hacim Dashboard](../reports/kpi_dashboard_output.png)
*Şekil 1: İşlem Türlerine Göre Adet ve Toplam Finansal Hacim Dağılımı (KPI Dashboard)*

# 4. Anomali Tespit Başarı Kriterleri

## 4.1. İstatistiksel Sınır Belirleme (Boxplot Analizi)

Tutar bazlı anomali tespiti için Boxplot (kutu grafiği) yöntemi kullanılarak IQR (Çeyrekler Arası Aralık) tabanlı istatistiksel eşik değerleri hesaplanmıştır. Buna göre üçüncü çeyrek (Q3) değeri ve üst aykırı değer (upper outlier) eşiği aşağıdaki gibi belirlenmiştir:

| Metrik | Değer |
| --- | --- |
| Üçüncü Çeyrek (Q3) | 3.744,48 TL |
| Üst Aykırı Değer Eşiği | 7.479,11 TL |

![İşlem Tutarları Boxplot Grafiği](../reports/transaction_heatmap.png) 
*Şekil 2: İşlem Tutarları Dağılımı ve Tutar Anomalisi Aykırı Değer Sınırları (Boxplot)*

## 4.2. Yakalanan Anomaliler

Hesaplanan üst istatistiksel sınırın (7.479,11 TL) üzerinde kalan ve doğrudan dolandırıcılık (Fraud) şüphesi taşıyan işlemler sistematik olarak filtrelenmiştir. Bu kapsamda toplam 993 adet "Tutar Anomalisi" başarıyla tespit edilmiş ve listelenmiştir.

| Kriter | Sonuç |
| --- | --- |
| Toplam İşlem Sayısı | 50.400 |
| Üst Aykırı Değer Eşiği | 7.479,11 TL |
| Tespit Edilen Anomali Sayısı | 993 |
| Anomali Tespit Yöntemi | IQR / Boxplot Tabanlı İstatistiksel Analiz |

Elde edilen bu sonuçlar, kurulan veri mimarisinin ve istatistiksel analiz metodolojisinin, tutar bazlı anormal işlemleri tutarlı ve tekrarlanabilir biçimde tespit edebildiğini göstermektedir.

# 5. Sonuç ve Sonraki Adımlar

Faz 1 kapsamında hedeflenen tüm çıktılar başarıyla tamamlanmıştır: ilişkisel veritabanı mimarisi kurulmuş, Türkçe lokalizasyonlu sentetik veri seti üretilmiş, keşifçi veri analizi gerçekleştirilmiş ve istatistiksel yöntemlerle tutar anomalileri tespit edilmiştir.

Bir sonraki fazda ele alınması önerilen başlıca çalışma alanları şunlardır:

- Tespit edilen 993 anomalinin manuel/otomatik doğrulama süreçleriyle etiketlenmesi
- Zaman, lokasyon ve işlem türü gibi çok boyutlu değişkenleri birlikte değerlendiren makine öğrenmesi tabanlı anomali tespit modellerinin geliştirilmesi
- Gerçek zamanlı (real-time) işlem izleme ve uyarı (alert) mekanizmasının tasarlanması
- Model performansının Precision, Recall ve F1-Score metrikleri ile değerlendirilmesi
