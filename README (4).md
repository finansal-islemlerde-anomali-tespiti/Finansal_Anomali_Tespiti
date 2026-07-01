# 🔍 Finansal İşlemlerde Anomali ve Şüpheli İşlem Tespit Sistemi

> Bileşim Finansal Teknolojiler & Ödeme Sistemleri staj hazırlık projesi  
> Geliştiren: **Gurbet** & **Helin**

---

## 📌 Proje Hakkında

Bu proje, banka kartı ve ATM işlem verilerini analiz ederek **anormal ve şüpheli işlemleri otomatik olarak tespit eden** bir sistemdir. Bileşim Finansal Teknolojiler & Ödeme Sistemleri şirketinin İş Zekası ve Raporlama bölümünde staj yapmadan önce kendimizi geliştirmek amacıyla, şirkette kullanılan teknolojiler ve gerçek iş süreçleri göz önüne alınarak tasarlanmıştır.

**Projenin temel sorusu:**  
> *"Milyonlarca ATM ve kart işlemi arasında sahte, anormal veya riskli olanları nasıl tespit ederiz?"*

Örnek tespit senaryoları:
- Kısa süre içinde aynı kartla birden fazla yüksek tutarlı çekim
- Alışılmadık saatlerde gerçekleşen işlemler
- Kartın kayıtlı şehri dışında yapılan işlemler
- Günlük limit aşımına yakın art arda işlemler

Proje **3 katmandan** oluşmaktadır. Şu an **Katman 1** üzerinde çalışıyoruz:

| Katman | Konu | Durum |
|---|---|---|
| Katman 1 | SQL + Python + Veri Ambarı temelleri | 🔄 Devam ediyor |
| Katman 2 | BI & Raporlama (IBM Cognos, Power BI, ETL) | ⏳ Bekliyor |
| Katman 3 | Fintek & Ödeme Sistemleri bağlamı | ⏳ Bekliyor |

**Katman 1 kapsamında:**
- Banka kartı ve ATM işlemlerini modelleyen ilişkisel veritabanı tasarımı (T-SQL)
- 50.000+ sahte işlem kaydı üretimi (Python / Faker)
- Veri temizleme ve dönüştürme (pandas)
- Şüpheli işlem tespiti için SQL sorguları ve KPI hesaplamaları
- Anomali görselleştirme ve raporlama (matplotlib / seaborn)

---

## 🗂️ Proje Yapısı

```
finansal-islem-analiz/
│
├── README.md
│
├── database/
│   ├── schema.sql              # Tablo tanımları ve ilişkiler
│   ├── seed_data.sql           # Örnek sabit veriler (şehirler, ATM lokasyonları)
│   └── queries/
│       ├── kpi_reports.sql     # İş zekası sorguları
│       ├── anomaly_detect.sql  # Şüpheli işlem tespiti
│       └── monthly_summary.sql # Aylık özet raporlar
│
├── data_generation/
│   ├── generate_data.py        # Faker ile sahte veri üretimi
│   ├── requirements.txt
│   └── output/
│       └── transactions.csv    # Üretilen örnek veri
│
├── analysis/
│   ├── 01_data_cleaning.ipynb       # Veri temizleme
│   ├── 02_exploratory_analysis.ipynb # Keşifsel veri analizi
│   ├── 03_kpi_dashboard.ipynb       # KPI hesaplamaları
│   └── 04_anomaly_detection.ipynb   # Anormallik tespiti
│
└── reports/
    ├── monthly_report_sample.png
    └── transaction_heatmap.png
```

---

## 🛠️ Kullanılan Teknolojiler

| Katman | Teknoloji | Amaç |
|---|---|---|
| Veritabanı | Microsoft SQL Server | Veri depolama ve sorgulama |
| Veri üretimi | Python, Faker | Gerçekçi sahte veri üretimi |
| Veri işleme | pandas, numpy | Temizleme ve dönüştürme |
| Görselleştirme | matplotlib, seaborn | Grafik ve raporlar |
| Versiyon kontrol | Git, GitHub | İş birliği ve sürüm yönetimi |

---

## 🗄️ Veritabanı Şeması

Proje dört ana tablodan oluşmaktadır. Şirketin kullandığı **Microsoft SQL Server** söz dizimi baz alınarak tasarlanmıştır:

```
accounts          cards              transactions        atm_locations
─────────────     ─────────────      ─────────────────   ─────────────────
account_id (PK)   card_id (PK)       transaction_id (PK) atm_id (PK)
customer_name     account_id (FK)    card_id (FK)        city
city              card_type          atm_id (FK)         district
account_type      expiry_date        amount              bank_name
balance           is_active          transaction_type    latitude
created_at        credit_limit       status              longitude
                                     created_at
```

---

## 🚀 Kurulum ve Çalıştırma

### 1. Repoyu klonla

```bash
git clone https://github.com/gurbet-helin/finansal-islem-analiz.git
cd finansal-islem-analiz
```

### 2. Python bağımlılıklarını yükle

```bash
pip install -r data_generation/requirements.txt
```

### 3. Veritabanını oluştur

```bash
# SQL Server Management Studio (SSMS) ile bağlan
# ya da sqlcmd kullanarak:
sqlcmd -S localhost -U sa -P sifren -i database/schema.sql
```

### 4. Sahte veri üret

```bash
python data_generation/generate_data.py
```

### 5. Jupyter Notebook'ları çalıştır

```bash
jupyter notebook analysis/
```

---

## 📊 Tespit Senaryoları

Bu projede aşağıdaki anomali ve şüpheli işlem durumları analiz edilmektedir:

- **Hız anomalisi:** Aynı kart ile 10 dakika içinde 3'ten fazla işlem yapılması
- **Coğrafi anomali:** Kartın kayıtlı olduğu şehir dışında gerçekleşen işlemler
- **Saat anomalisi:** Gece 00:00–05:00 arasında gerçekleşen yüksek tutarlı çekimler
- **Limit anomalisi:** Günlük limitin %90'ına ulaşan art arda işlemler
- **Tutar anomalisi:** Kartın ortalama işlem tutarının 5 katını aşan tek işlemler
- **Sıklık trendi:** Aylık işlem hacminde ani artış/düşüş tespiti

---

## 👩‍💻 İş Bölümü

| Konu | Sorumlu |
|---|---|
| Veritabanı tasarımı ve SQL şeması | Gurbet (önder) + Helin |
| SQL KPI sorguları | Gurbet (önder) + Helin |
| Python veri üretimi (Faker) | Helin (önder) + Gurbet |
| pandas analiz ve temizleme | Helin (önder) + Gurbet |
| Görselleştirme (matplotlib / seaborn) | Ortak |
| GitHub yönetimi ve README | Ortak |

---

## 🎯 Öğrenme Hedefleri

Bu projeyi tamamladığımızda şu konularda deneyim kazanmış olacağız:

- **SQL:** İlişkisel tablo tasarımı, JOIN, GROUP BY, HAVING, Window Functions
- **Veri ambarı:** Star schema mantığı, fact/dimension tablo ayrımı
- **Python:** pandas ile veri işleme, Faker ile sentetik veri üretimi
- **İş zekası:** KPI tanımlama, anormallik tespiti, özet raporlama
- **Git:** Branch, commit, pull request iş akışı

---

## 📅 Yol Haritası

### 🔵 Katman 1 — SQL + Python + Veri Ambarı
- [x] Proje fikri ve mimari tasarım
- [x] GitHub repo kurulumu ve README
- [ ] Veritabanı şeması (schema.sql)
- [ ] Sahte veri üretim scripti (generate_data.py)
- [ ] Temel SQL sorguları (JOIN, GROUP BY, Window Functions)
- [ ] Jupyter analiz notebook'ları
- [ ] Görselleştirmeler (matplotlib / seaborn)
- [ ] Katman 1 final raporu

### 🟣 Katman 2 — BI & Raporlama _(henüz başlanmadı)_
- [ ] IBM Cognos ile rapor tasarımı
- [ ] Power BI dashboard
- [ ] ETL pipeline tasarımı
- [ ] Katman 2 final raporu

### 🟢 Katman 3 — Fintek & Ödeme Sistemleri _(henüz başlanmadı)_
- [ ] ATM / POS işlem simülasyonu
- [ ] Finansal KPI tanımlama
- [ ] KVKK uyumlu veri maskeleme
- [ ] Kapsamlı sunum ve demo

---

## 📝 Notlar

Bu proje tamamen eğitim amaçlıdır. Kullanılan tüm veriler Python Faker kütüphanesi ile üretilmiş sentetik verilerdir; gerçek kişi veya kurumlara ait herhangi bir bilgi içermemektedir.

---

*Bileşim Finansal Teknolojiler & Ödeme Sistemleri — Staj Hazırlık Projesi, 2026*
