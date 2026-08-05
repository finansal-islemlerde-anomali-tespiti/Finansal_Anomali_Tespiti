USE AnomaliTespiti;
GO

-- ============================================================================
-- 1. SQL SERVER DYNAMIC DATA MASKING (DDM) TANIMLARI (Doküman 10.3.1 - Faz 3)
-- Müþteri isimlerini 'partial' fonksiyonu ile otomatik maskeler
-- ============================================================================
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.accounts') AND name = 'customer_name')
BEGIN
    ALTER TABLE dbo.accounts
    ALTER COLUMN customer_name ADD MASKED WITH (FUNCTION = 'partial(1, "XXX***", 0)');
END
GO

-- ============================================================================
-- 2. KVKK UYUMLU RAPORLAMA GÖRÜNÜMÜ (vw_transactions_masked)
-- DDM desteklemeyen veya raporlama servisleri için PII gizlenmiþ View
-- ============================================================================
CREATE OR ALTER VIEW dbo.vw_transactions_masked AS
SELECT 
    t.transaction_id,
    t.card_id,
    -- Ýsim Maskeleme: 'Gurbet Yýlmaz' -> 'G****** Y*****'
    CASE 
        WHEN CHARINDEX(' ', acc.customer_name) > 0 THEN
            LEFT(acc.customer_name, 1) + REPLICATE('*', CHARINDEX(' ', acc.customer_name) - 1) + ' ' +
            SUBSTRING(acc.customer_name, CHARINDEX(' ', acc.customer_name) + 1, 1) + REPLICATE('*', LEN(acc.customer_name) - CHARINDEX(' ', acc.customer_name))
        ELSE 
            LEFT(acc.customer_name, 1) + REPLICATE('*', LEN(acc.customer_name) - 1)
    END AS masked_customer_name,
    atm.city AS atm_sehri,
    t.amount,
    t.transaction_type,
    t.status,
    t.created_at
FROM dbo.transactions t
JOIN dbo.cards c ON t.card_id = c.card_id
JOIN dbo.accounts acc ON c.account_id = acc.account_id
JOIN dbo.atm_locations atm ON t.atm_id = atm.atm_id;
GO

PRINT 'KVKK Uyumlu Veri Maskeleme (DDM ve Masked Views) basariyla yuklendi.';