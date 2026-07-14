<<<<<<< HEAD
-- Bileşim Finansal Teknolojiler - Finansal İşlemlerde Anomali Tespiti Projesi
-- Doğrulanmış ve Veri Seti ile Tam Uyumlu Veritabanı Şeması

USE AnomaliTespiti;
GO

-- Eski tabloları temizleme sırası
IF OBJECT_ID('dbo.transactions', 'U') IS NOT NULL DROP TABLE dbo.transactions;
IF OBJECT_ID('dbo.cards', 'U') IS NOT NULL DROP TABLE dbo.cards;
IF OBJECT_ID('dbo.accounts', 'U') IS NOT NULL DROP TABLE dbo.accounts;
IF OBJECT_ID('dbo.atm_locations', 'U') IS NOT NULL DROP TABLE dbo.atm_locations;
GO

-- 1. Hesaplar Tablosu
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_name NVARCHAR(100) NOT NULL,
    account_status VARCHAR(20) NOT NULL,
    daily_limit DECIMAL(18,2) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);

-- 2. ATM Lokasyonları Tablosu (Seed data metin içerdiği için VARCHAR)
CREATE TABLE atm_locations (
    atm_id VARCHAR(50) PRIMARY KEY,
    atm_name NVARCHAR(100) NOT NULL,
    city NVARCHAR(50) NOT NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL
);

-- 3. Kartlar Tablosu
CREATE TABLE cards (
    card_id INT PRIMARY KEY,
    account_id INT NOT NULL,
    card_type VARCHAR(20) NOT NULL,
    expiry_date DATE NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_cards_accounts FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 4. Finansal İşlemler Tablosu
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    card_id INT NOT NULL,
    atm_id VARCHAR(50) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT FK_transactions_cards FOREIGN KEY (card_id) REFERENCES cards(card_id),
    CONSTRAINT FK_transactions_atms FOREIGN KEY (atm_id) REFERENCES atm_locations(atm_id)
);
GO
=======
CREATE DATABASE AnomaliTespiti;
GO
USE AnomaliTespiti;
GO

--müşteri hesapları tablosu
CREATE TABLE accounts(
account_id VARCHAR(50) PRIMARY KEY,
custumer_name NVARCHAR(100) NOT NULL,
account_status VARCHAR(20) NOT NULL,
daily_limit DECIMAL(18,2) NOT NULL,
created_aat DATETIME DEFAULT GETDATE()
);


--banka ve kredi kartları tablosu
CREATE TABLE cards(
card_number VARCHAR(19) PRIMARY KEY,
account_id VARCHAR(50) NOT NULL,
card_type VARCHAR(20) NOT NULL,
car_status VARCHAR(20) NOT NULL,
expiry_date DATE NOT NULL,
CONSTRAINT FK_cards_accounts FOREIGN KEY (account_id) REFERENCES accounts(account_id)
); 

--atm lokasyonları tablosu
 CREATE TABLE atm_locations(
 atm_id VARCHAR(50) PRIMARY KEY,
 atm_name NVARCHAR(100) NOT NULL,
 city NVARCHAR(50) NOT NULL,
 latitude DECIMAL(9,6) NOT NULL,
 longitude DECIMAL(9,6) NOT NULL,
 );



 --finansal işlemler (transaction) tablosu
 CREATE TABLE transactions(
 transaction_id VARCHAR (50) PRIMARY KEY,
 card_number VARCHAR(19) NOT NULL,
 atm_id VARCHAR(50) NOT NULL,
 transaction_date DATETIME NOT NULL,
 amount DECIMAL(18,2) NOT NULL,
 transaction_type VARCHAR(30) NOT NULL,
 merchant_type NVARCHAR(50) NULL,
 is_anomaly INT DEFAULT 0,
 anomaly_type NVARCHAR(100) NULL,
 CONSTRAINT FK_transactions_cards FOREIGN KEY (card_number) REFERENCES cards(card_number),
 CONSTRAINT FK_transactions_atms FOREIGN KEY (atm_id) REFERENCES atm_locations(atm_id)
 );
>>>>>>> 8c7a3d128b3c875ed212b3c619a0671436216e7a
