USE AnomaliTespiti;
GO

-- ============================================================================
-- FINANSAL KPI SEKTÖREL EÞLEÞTÝRME VE KARÞILAÞTIRMA GÖRÜNÜMÜ
-- Doküman Madde 10.3.1 (Faz 2A) Uyumlu
-- ============================================================================
CREATE OR ALTER VIEW dbo.vw_industry_kpi_benchmark AS
WITH SystemMetrics AS (
    SELECT 
        COUNT(*) AS ToplamIslem,
        SUM(CASE WHEN status = 'basarili' THEN 1 ELSE 0 END) AS BasariliIslem,
        SUM(CASE WHEN status = 'reddedildi' THEN 1 ELSE 0 END) AS RedIslem,
        SUM(CASE WHEN DATEPART(HOUR, created_at) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS GeceIslem
    FROM dbo.transactions
)
SELECT 
    'Ýþlem Onay Oraný (Approval Rate)' AS Metric_Name,
    ROUND((CAST(BasariliIslem AS FLOAT) / ToplamIslem) * 100, 2) AS System_Value,
    95.00 AS Industry_Benchmark_Min,
    CASE 
        WHEN (CAST(BasariliIslem AS FLOAT) / ToplamIslem) * 100 >= 95.00 THEN 'SEKTÖR STANDARDINDA'
        ELSE 'RÝSKLÝ / ÝNCELEME GEREKÝYOR'
    END AS Benchmark_Status
FROM SystemMetrics

UNION ALL

SELECT 
    'Gece Ýþlem Yoðunluk Yüzdesi' AS Metric_Name,
    ROUND((CAST(GeceIslem AS FLOAT) / ToplamIslem) * 100, 2) AS System_Value,
    15.00 AS Industry_Benchmark_Max,
    CASE 
        WHEN (CAST(GeceIslem AS FLOAT) / ToplamIslem) * 100 <= 15.00 THEN 'SEKTÖR STANDARDINDA'
        ELSE 'YÜKSEK GECE YOÐUNLUÐU'
    END AS Benchmark_Status
FROM SystemMetrics;
GO

PRINT 'Sektorel KPI Karsilastirma Gorunumu (vw_industry_kpi_benchmark) olusturuldu.';