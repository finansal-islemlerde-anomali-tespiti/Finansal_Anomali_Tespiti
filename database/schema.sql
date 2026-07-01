CREATE DATABASE AnomaliTespiti;
GO
USE AnomaliTespiti;
GO

--müþteri hesaplarý tablosu
CREATE TABLE accounts(
account_id VARCHAR(50) PRIMARY KEY,
custumer_name NVARCHAR(100) NOT NULL,
account_status VARCHAR(20) NOT NULL,
daily_limit DECIMAL(18,2) NOT NULL,
created_aat DATETIME DEFAULT GETDATE()
);


--banka ve kredi kartlarý tablosu
CREATE TABLE cards(
card_number VARCHAR(19) PRIMARY KEY,
account_id VARCHAR(50) NOT NULL,
card_type VARCHAR(20) NOT NULL,
car_status VARCHAR(20) NOT NULL,
expiry_date DATE NOT NULL,
CONSTRAINT FK_cards_accounts FOREIGN KEY (account_id) REFERENCES accounts(account_id)
); 

--atm lokasyonlarý tablosu
 CREATE TABLE atm_locations(
 atm_id VARCHAR(50) PRIMARY KEY,
 atm_name NVARCHAR(100) NOT NULL,
 city NVARCHAR(50) NOT NULL,
 latitude DECIMAL(9,6) NOT NULL,
 longitude DECIMAL(9,6) NOT NULL,
 );



 --finansal iþlemler (transaction) tablosu
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