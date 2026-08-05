# Katman 3: Fintek & Ödeme Sistemleri Bağlamı — Final Raporu

**Proje:** Finansal İşlemlerde Anomali ve Şüpheli İşlem Tespit Sistemi  
**Geliştiriciler:** Gurbet & Helin  
**Kurum / Kapsam:** Bileşim Finansal Teknolojiler & Ödeme Sistemleri — Staj Hazırlık Projesi (2026)  
**Tarih:** Ağustos 2026  

---

## 1. Genel Mimari ve Yönetici Özeti
Katman 1 (Veri Ambarı ve SQL Anomali Tespiti) ve Katman 2 (BI & ETL Pipeline) üzerine inşa edilen Katman 3 kapsamında, gerçek fintek ve kartlı ödeme sistemleri iş süreçleri simüle edilmiş; veri güvenliği, KVKK uyumluluğu ve sektörel KPI karşılaştırma katmanları projeye entegre edilmiştir.

---

## 2. Adım Adım Yapılan Çalışmalar ve Teknik Detaylar

### 2.1 Faz 1 & 2B — ATM/POS İşlem Simülasyonu (Helin Önderliğinde)
- **Simülasyon Modülü:** `layer3/simulation/pos_atm_simulator.py`[cite: 1]
- **Teknik Detaylar:** Statik veriye ek olarak zaman içinde gelişen durum tabanlı (state-based) oturum simülasyonu kurgulanmıştır (`kart_takıldı` ➔ `PIN_girildi` ➔ `onay/red` ➔ `kart_çıkarıldı`)[cite: 1]. Yetersiz bakiye, yanlış PIN ve zaman aşımı gibi gerçekçi hata senaryoları sisteme dahil edilmiştir[cite: 1].

### 2.2 Faz 2A — Finansal KPI Sektörel Eşleştirme (Gurbet Önderliğinde)
- **SQL Görünümü:** `layer3/kpi_benchmark/industry_kpi_compare.sql` (`vw_industry_kpi_benchmark`)[cite: 1]
- **Teknik Detaylar:** Projede hesaplanan metrikler fintek sektör standartlarıyla karşılaştırılmıştır[cite: 1]:
  - **İşlem Onay Oranı (Approval Rate):** Sektörel minimum %95 eşiği ile sistem değerleri kıyaslanmıştır[cite: 1].
  - **Gece İşlem Yoğunluğu:** Sektörel maksimum %15 eşiği üzerinden gece yarısı risk oranı izlenmiştir[cite: 1].

### 2.3 Faz 3 — KVKK Uyumlu Veri Maskeleme (Gurbet Önderliğinde)
- **SQL / Maskeleme Dosyası:** `layer3/masking/masking_views.sql` (`vw_transactions_masked`)[cite: 1]
- **Teknik Detaylar:** 
  - **Dynamic Data Masking (DDM):** SQL Server seviyesinde `accounts.customer_name` sütununa `partial` maskeleme uygulanmıştır[cite: 1].
  - **Masked View:** Yetkisiz kullanıcılar ve dış rapor aktarımları için PII (Kişisel Tanımlanabilir Bilgi) içeren müşteri isimleri `G****** Y*****` formatında otomatik anonimleştirilmiştir[cite: 1].

---

## 3. Katman 3 Görev Dağılımı ve Katkı Özeti

| Görev Alanı | Önder / Sorumlu | Çıktı / Dosya | Durum |
| :--- | :--- | :--- | :--- |
| ATM/POS Durum Simülasyonu | **Helin** | `layer3/simulation/pos_atm_simulator.py`[cite: 1] | Tamamlandı |
| KVKK Maskeleme (DDM & Views) | **Gurbet** | `layer3/masking/masking_views.sql`[cite: 1] | Tamamlandı |
| Sektörel KPI Benchmarking | **Gurbet** | `layer3/kpi_benchmark/industry_kpi_compare.sql`[cite: 1] | Tamamlandı |
| Canlı Demo & Sunum Akışı | **Ortak** | `layer3/demo/demo_script.md`[cite: 1] | Tamamlandı |
| Katman 3 Final Raporu | **Ortak** | `Katman3_Final_Raporu.md`[cite: 1] | Tamamlandı |

---

## 4. Genel Proje Kapanışı ve Kazanımlar
Bu proje ile **Bileşim Finansal Teknolojiler & Ödeme Sistemleri** stajı öncesinde[cite: 1]:
1. 50.400+ satırlık ilişkisel finansal veri modeli (MSSQL / T-SQL) kurgulanmıştır[cite: 1].
2. 6 farklı kural bazlı anomali tespit algoritması yazılmıştır[cite: 1].
3. Uçtan uca veri taşıma (ETL Pipeline), Power BI ve IBM Cognos BI altyapısı tamamlanmıştır[cite: 1].
4. KVKK/BDDK mevzuatlarına uygun veri maskeleme ve canlı simülasyon katmanı devreye alınmıştır[cite: 1].

*Gurbet & Helin — Bileşim Finansal Teknolojiler Staj Hazırlık Projesi (2026)*[cite: 1]