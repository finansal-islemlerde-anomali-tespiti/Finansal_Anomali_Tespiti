-- Bileþim Finansal Teknolojiler - Finansal Ýþlemlerde Anomali Tespiti Projesi
-- Kural Bazlý SQL Anomali Tespit Sorgularý (Doküman Madde 6 Uyumlu)

USE AnomaliTespiti;
GO
-- 1. HIZ ANOMALÝSÝ (Doküman Madde 6.1)
-- Kural: Ayný kart ile son iþlemle arasýnda 10 dakikadan az süre olan ardýþýk iþlemler
WITH OrderedTx AS (
    SELECT 
        transaction_id,
        card_id,
        created_at,
        amount,
        LAG(created_at) OVER (PARTITION BY card_id ORDER BY created_at) AS prev_tx_date
    FROM transactions
)
SELECT 
    transaction_id,
    card_id,
    created_at,
    prev_tx_date,
    DATEDIFF(MINUTE, prev_tx_date, created_at) AS diff_minutes,
    amount
FROM OrderedTx
WHERE prev_tx_date IS NOT NULL 
  AND DATEDIFF(MINUTE, prev_tx_date, created_at) <= 10;
GO

-- 2. COÐRAFÝ ANOMALÝ (Doküman Madde 6)
-- Kural: Kartýn baðlý olduðu hesabýn þehri dýþýndaki ATM'lerde yapýlan iþlemler
SELECT 
    t.transaction_id,
    t.card_id,
    acc.customer_name,
    acc.city AS account_city,
    atm.city AS atm_city,
    t.amount,
    t.created_at
FROM transactions t
JOIN cards c ON t.card_id = c.card_id
JOIN accounts acc ON c.account_id = acc.account_id
JOIN atm_locations atm ON t.atm_id = atm.atm_id
WHERE acc.city <> atm.city;
GO

-- 3. SAAT ANOMALÝSÝ (Doküman Madde 6)
-- Kural: Gece 00:00 - 05:00 arasýnda gerçekleþen yüksek tutarlý çekimler
SELECT 
    transaction_id,
    card_id,
    amount,
    created_at
FROM transactions
WHERE DATEPART(HOUR, created_at) BETWEEN 0 AND 5
  AND amount > 5000;
GO

-- 4. TUTAR ANOMALÝSÝ (Doküman Madde 6.2)
-- Kural: Kartýn ortalama iþlem tutarýnýn 5 katýný aþan iþlemler
WITH CardStats AS (
    SELECT 
        card_id,
        AVG(amount) AS avg_amount
    FROM transactions
    GROUP BY card_id
)
SELECT 
    t.transaction_id,
    t.card_id,
    t.amount,
    cs.avg_amount,
    (t.amount / cs.avg_amount) AS amount_ratio
FROM transactions t
JOIN CardStats cs ON t.card_id = cs.card_id
WHERE t.amount > (cs.avg_amount * 5);
GO