-- Bileþim Finansal Teknolojiler - Finansal Ýþlemlerde Anomali Tespiti Projesi
-- Veritabaný Þemasý (Doküman Madde 4.1 Uyumlu)

USE AnomaliTespiti;
GO

-- Varsa eski hatalý tablolarý silip temizleyelim
IF OBJECT_ID('dbo.transactions', 'U') IS NOT NULL DROP TABLE dbo.transactions;
IF OBJECT_ID('dbo.cards', 'U') IS NOT NULL DROP TABLE dbo.cards;
IF OBJECT_ID('dbo.accounts', 'U') IS NOT NULL DROP TABLE dbo.accounts;
IF OBJECT_ID('dbo.atm_locations', 'U') IS NOT NULL DROP TABLE dbo.atm_locations;
GO

-- 1. accounts (Hesap Tablosu) - Doküman 4.1.1
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_name NVARCHAR(100) NOT NULL,
    city NVARCHAR(50) NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(15,2) NOT NULL,
    created_at DATETIME NOT NULL
);

-- 2. cards (Kart Tablosu) - Doküman 4.1.2
CREATE TABLE cards (
    card_id INT PRIMARY KEY,
    account_id INT NOT NULL,
    card_type VARCHAR(20) NOT NULL,
    expiry_date DATE NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    credit_limit DECIMAL(15,2) NULL,
    CONSTRAINT FK_cards_accounts FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 3. atm_locations (ATM Konum Tablosu) - Doküman 4.1.4
CREATE TABLE atm_locations (
    atm_id INT PRIMARY KEY,
    city NVARCHAR(50) NOT NULL,
    district NVARCHAR(50) NOT NULL,
    bank_name NVARCHAR(100) NOT NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL
);

-- 4. transactions (Ýþlem Tablosu) - Doküman 4.1.3
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    card_id INT NOT NULL,
    atm_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT FK_transactions_cards FOREIGN KEY (card_id) REFERENCES cards(card_id),
    CONSTRAINT FK_transactions_atms FOREIGN KEY (atm_id) REFERENCES atm_locations(atm_id)
);
GO

PRINT 'Veritabaný þemasý dokümantasyona %100 uyumlu þekilde güncellendi.';