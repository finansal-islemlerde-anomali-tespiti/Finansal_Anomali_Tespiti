-- Bileþim Finansal Teknolojiler - IBM Cognos Anomali Raporu Sorgu Þablonu
-- Bu sorgu, IBM Cognos Analytics Report Studio üzerinde 'Query Subject' olarak kullanýlýr.

USE AnomaliTespiti;
GO

SELECT 
    t.transaction_id AS [Ýþlem No],
    t.card_id AS [Kart No],
    c.card_type AS [Kart Türü],
    acc.customer_name AS [Müþteri Ad Soyad],
    acc.city AS [Hesap Þehri],
    atm.atm_id AS [ATM Kodu],
    atm.city AS [ATM Þehri],
    t.amount AS [Ýþlem Tutarý (TL)],
    t.transaction_type AS [Ýþlem Türü],
    t.status AS [Ýþlem Durumu],
    t.created_at AS [Ýþlem Zamaný],
    
    -- Cognos Raporunda Kýrmýzý/Sarý Renklendirme Ýçin Risk Seviyesi Etiketi
    CASE 
        WHEN t.amount > 10000 THEN 'YÜKSEK RÝSK'
        WHEN DATEPART(HOUR, t.created_at) BETWEEN 0 AND 5 THEN 'ORTA RÝSK (GECE)'
        ELSE 'DÜÞÜK RÝSK'
    END AS [Risk Grubu]

FROM dbo.transactions t
JOIN dbo.cards c ON t.card_id = c.card_id
JOIN dbo.accounts acc ON c.account_id = acc.account_id
JOIN dbo.atm_locations atm ON t.atm_id = atm.atm_id

-- Cognos Parametre Filtreleri (Rapor ekranýndan seçilecek parametreler)
WHERE t.amount > 1000 -- Þüpheli eþik altý iþlemleri rapora dahil etmiyoruz
ORDER BY t.created_at DESC;
GO