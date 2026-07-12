-- Bileþim Finansal Teknolojiler - Finansal Ýþlemlerde Anomali Tespiti Projesi
-- Ýþ Zekasý ve KPI Raporlama Sorgularý (T-SQL / MSSQL)

USE AnomaliTespiti;
GO

-- ============================================================================
-- KPI 1: ÞEHÝR BAZLI TOPLAM ÝÞLEM HACMÝ VE MÝKTARI
-- Yönetim için hangi þehrin ne kadar finansal hacim yarattýðýný gösterir.
-- ============================================================================
SELECT 
    atm.city AS sehir,
    COUNT(t.transaction_id) AS toplam_islem_sayisi,
    SUM(t.amount) AS toplam_islem_hacmi_tl,
    AVG(t.amount) AS ortalama_islem_tutari_tl
FROM transactions t
JOIN atm_locations atm ON t.atm_id = atm.atm_id
GROUP BY atm.city
ORDER BY toplam_islem_hacmi_tl DESC;
GO

-- ============================================================================
-- KPI 2: ÝÞLEM TÝPÝ BAZLI SAATLÝK DAÐILIM VE ANOMALÝ ORANLARI
-- Çekme, Yatýrma ve Ödeme iþlemlerinin saatlik yoðunluðunu analiz eder.
-- ============================================================================
SELECT 
    DATEPART(HOUR, created_at) AS islem_saati,
    transaction_type AS islem_tipi,
    COUNT(transaction_id) AS islem_adet,
    SUM(amount) AS toplam_tutar
FROM transactions
GROUP BY DATEPART(HOUR, created_at), transaction_type
ORDER BY islem_saati ASC, islem_tipi;
GO

-- ============================================================================
-- KPI 3: EN YÜKSEK HACÝMLÝ ÝÞLEM YAPAN ÝLK 10 MÜÞTERÝ / HESAP
-- Yüksek riskli veya yüksek hacimli müþterilerin takibi için kullanýlýr.
-- ============================================================================
SELECT TOP 10
    acc.account_id,
    acc.customer_name,
    acc.city,
    COUNT(t.transaction_id) AS toplam_islem_adedi,
    SUM(t.amount) AS toplam_harcama_tutari
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
JOIN accounts acc ON c.account_id = acc.account_id
GROUP BY acc.account_id, acc.customer_name, acc.city
ORDER BY toplam_harcama_tutari DESC;
GO

-- ============================================================================
-- KPI 4: ATM BAZLI YOÐUNLUK VE AKTÝFLÝK RAPORU
-- En çok kullanýlan ve bakým/nakit ikmali gerekebilecek ATM'leri listeler.
-- ============================================================================
SELECT 
    atm.atm_id,
    atm.bank_name,
    atm.city,
    atm.district,
    COUNT(t.transaction_id) AS atm_kullanim_sayisi,
    SUM(t.amount) AS atm_toplam_islem_tutari
FROM atm_locations atm
LEFT JOIN transactions t ON atm.atm_id = t.atm_id
GROUP BY atm.atm_id, atm.bank_name, atm.city, atm.district
ORDER BY atm_kullanim_sayisi DESC;
GO