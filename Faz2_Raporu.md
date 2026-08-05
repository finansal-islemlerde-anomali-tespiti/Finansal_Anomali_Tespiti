# Katman 2: BI & Raporlama (ETL, Power BI & IBM Cognos) — Final Raporu
**Proje:** Finansal İşlemlerde Anomali ve Şüpheli İşlem Tespit Sistemi  
**Geliştiriciler:** Gurbet (SQL & ETL & Cognos Önderi) & Helin (Python & Power BI Önderi)  
**Kurum / Kapsam:** Bileşim Finansal Teknolojiler & Ödeme Sistemleri — Staj Hazırlık Projesi (2026)  
**Tarih:** Ağustos 2026  

---

## 1. Genel Mimari ve Amaç
Katman 1'de ilişkisel veritabanı şeması kurulan ve Python (Faker) ile 50.400 satırlık gerçekçi finansal işlem verisi yüklenen sistemin üzerine, Katman 2 kapsamında **Kurumsal İş Zekası (Business Intelligence - BI) ve ETL (Extract-Transform-Load) Boru Hattı** inşa edilmiştir.

**Temel Problem ve Çözüm:**  
Canlı bankacılık/fintek sistemlerinde milyonlarca verinin döndüğü ham tablolara doğrudan BI araçlarını (Power BI, Cognos vb.) bağlamak veritabanını kilitler ve yavaşlatır. Bu sorunu çözmek amacıyla:
1. Veritabanı üzerinde yükü hafifleten **Raporlama Görünümleri (Views)** oluşturulmuştur.
2. Bu verileri periyodik olarak çekip temizleyen **Python ETL Pipeline** kurgulanmıştır.
3. Çıkarılan temiz ara veriler (staging CSV) üzerinden **Power BI İnteraktif Dashboard** ve **IBM Cognos Resmi Rapor Şablonları** geliştirilmiştir.

---

## 2. Adım Adım Yapılan Çalışmalar ve Teknik Detaylar

### 2.1 Faz 1 — Veritabanı Raporlama Katmanı (Views) & ETL Pipeline (Gurbet Önderliğinde)
- **SQL Görünümleri (Views):**
  - `vw_daily_kpi`: Günlük ve şehir bazlı işlem adetlerini, dönen toplam/ortalama TL hacimlerini ve reddedilen işlem sayılarını özetler.
  - `vw_anomaly_summary`: Tutar ve saat anomalisi içeren şüpheli işlemleri kurallara göre etiketleyerek BI katmanına hazır sunar.
- **Python ETL Script'i (`etl/extract.py`):**
  - Dokümantasyon standartlarına tam uyumlu olarak `pyodbc` ve `MS SQL Server` sürücüsü kullanılmıştır.
  - SQL Server'daki `AnomaliTespiti` veritabanından veriler otomatik çekilerek `etl/load_targets/` klasörüne `daily_kpi_report.csv` (93 özet satırı) ve `anomaly_summary_report.csv` (50.400 detay satırı) olarak aktarılmıştır.

---

### 2.2 Faz 2A — IBM Cognos Analytics Rapor Şablonu (Gurbet Önderliğinde)
- **Rapor Şablon Dosyası:** `bi/cognos/reports/anomaly_cognos_report.sql`
- **Kurumsal Kullanım Mantığı:**  
  IBM Cognos sunucu tabanlı, BDDK ve resmi denetim kurumlarına verilecek resmi PDF/Excel dökümlerini üreten ağır siklet bir platformdur.
- **Teknik Özellikler:**
  - Cognos Report Studio üzerinde *Query Subject* olarak doğrudan kullanılacak T-SQL sorgusu geliştirilmiştir.
  - Sütunlar köşeli parantezler ile kurumsal Türkçe başlıklara çevrilmiştir (`[Müşteri Ad Soyad]`, `[İşlem Tutarı (TL)]`).
  - `CASE WHEN` mantığı ile tutarı 10.000 TL üzeri olan işlemlere `'YÜKSEK RİSK'`, gece yapılanlara `'ORTA RİSK (GECE)'` etiketi basılarak Cognos üzerindeki **Koşullu Renklendirme (Conditional Formatting)** altyapısı (kırmızı/sarı vurgulama) hazırlanmıştır.

---

### 2.3 Faz 2B — Power BI İnteraktif Dashboard (Helin Önderliğinde)
- **Dashboard Dosyası:** `bi/powerbi/dashboard.pbix`
- **Kurumsal Kullanım Mantığı:**  
  Yöneticilerin ve Fraud analistlerinin toplantılarda veya günlük takiplerde tıklayarak filtreleme yapabileceği dinamik görselleştirme platformudur.
- **Teknik Özellikler:**
  - `etl/load_targets/` klasöründeki verileri doğrudan besleme kaynağı olarak kullanır.
  - Gün ve saat matrisinde **İşlem Yoğunluk Isı Haritası (Heatmap)**, şehir bazlı risk haritası ve anomali türü dağılım grafiklerini barındırır.

---

### 2.4 Faz 3 — Veri Mutabakatı ve Çapraz Kontrol Testi (Ortak)
- **Test Script'i:** `etl/integration_test.py`
- **Şirket Karşılığı (Data Reconciliation):**  
  BI panellerinde ve resmi raporlarda görünen sayılar ile veritabanında yatan ham verilerin %100 uyuştuğunu doğrulama işlemidir.
- **Test Sonuçları:**
  - **Ham SQL İşlem Adedi:** 50.400 | **ETL Rapor Adedi:** 50.400 (Tam uyum!)
  - **Ham SQL Toplam Finansal Hacim:** 211.791.228,40 TL | **ETL Rapor Hacmi:** 211.791.228,40 TL (Kuruşu kuruşuna mutabık!)
  - **Sonuç:** Test çalıştırılmış ve `[SONUÇ] BAŞARILI! Veri ambarı ile ETL rapor katmanı %100 mutabık.` onay kodu alınmıştır.

---

## 3. Ekip İçi Görev Dağılımı ve Katkı Özeti

| Görev Alanı | Önder / Sorumlu | Çıktı / Dosya | Durum |
| :--- | :--- | :--- | :--- |
| SQL Views & ETL Pipeline | **Gurbet** | `database/schema.sql`, `etl/extract.py` | Tamamlandı |
| IBM Cognos SQL Şablonu | **Gurbet** | `bi/cognos/reports/anomaly_cognos_report.sql` | Tamamlandı |
| Power BI Dashboard | **Helin** | `bi/powerbi/dashboard.pbix` | Tamamlandı |
| Veri Doğrulama & Notebook | **Helin** | `analysis/03_kpi_dashboard.ipynb` | Tamamlandı |
| Entegrasyon & Mutabakat Testi | **Ortak** | `etl/integration_test.py` | Tamamlandı |
| Katman 2 Final Raporu | **Ortak** | `Katman2_Final_Raporu.md` | Tamamlandı |

---

## 4. Katman 3'e Geçiş ve Sonraki Adımlar
Katman 2 başarıyla tamamlanmış, veri ambarından BI katmanına kadar olan tüm boru hattı uçtan uca doğrulanmıştır. 

Dokümantasyon yol haritasındaki sıradaki aşama **Katman 3 — Fintek & Ödeme Sistemleri Bağlamı** olacaktır:
1. ATM / POS canlı işlem simülasyonu script'leri.
2. Finansal KPI'ların sektörel standartlarla eşleştirilmesi.
3. KVKK uyumlu veri maskeleme teknikleri (Müşteri PII verilerini gizleme).
4. Kapsamlı sunum ve canlı demo hazırlığı.

*Gurbet & Helin — Bileşim Finansal Teknolojiler & Ödeme Sistemleri Staj Hazırlık Projesi, 2026*