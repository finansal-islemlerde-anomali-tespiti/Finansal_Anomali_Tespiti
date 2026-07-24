USE AnomaliTespiti;
GO

-- ============================================================================
-- 1. VIEW: GÜNLÜK VE ÞEHÝR BAZLI KPI ÖZETÝ (vw_daily_kpi)
-- Hem Cognos hem Power BI'ýn doðrudan grafik besleyeceði ana ETL çýktýsý
-- ============================================================================
CREATE OR ALTER VIEW dbo.vw_daily_kpi AS
SELECT 
    CAST(t.created_at AS DATE) AS islem_tarihi,
    atm.city AS atm_sehri,
    t.transaction_type AS islem_tipi,
    COUNT(t.transaction_id) AS toplam_islem_adedi,
    SUM(t.amount) AS toplam_islem_hacmi_tl,
    AVG(t.amount) AS ortalama_islem_tutari_tl,
    SUM(CASE WHEN t.status = 'reddedildi' THEN 1 ELSE 0 END) AS reddedilen_islem_adedi
FROM dbo.transactions t
JOIN dbo.atm_locations atm ON t.atm_id = atm.atm_id
GROUP BY CAST(t.created_at AS DATE), atm.city, t.transaction_type;
GO

-- ============================================================================
-- 2. VIEW: ANOMALÝ ÖZET RAPORU (vw_anomaly_summary)
-- Katman 1'deki tespit sorgularýný Cognos'a hazýr beslemek için
-- ============================================================================
CREATE OR ALTER VIEW dbo.vw_anomaly_summary AS
WITH CardStats AS (
    SELECT card_id, AVG(amount) AS avg_amount
    FROM dbo.transactions
    GROUP BY card_id
)
SELECT 
    t.transaction_id,
    t.card_id,
    atm.city AS atm_sehri,
    t.amount,
    cs.avg_amount AS kart_ortalamasi,
    t.created_at AS islem_zamani,
    -- Katman 1'de kurguladýðýmýz kural bazlý anomali kontrolü
    CASE 
        WHEN t.amount > (cs.avg_amount * 5) THEN 'Tutar Anomalisi'
        WHEN DATEPART(HOUR, t.created_at) BETWEEN 0 AND 5 AND t.amount > 5000 THEN 'Saat Anomalisi'
        ELSE 'Normal'
    END AS anomali_durumu
FROM dbo.transactions t
JOIN CardStats cs ON t.card_id = cs.card_id
JOIN dbo.atm_locations atm ON t.atm_id = atm.atm_id;
GO

PRINT 'Katman 2 raporlama gorunumleri (Views) basariyla olusturuldu.';