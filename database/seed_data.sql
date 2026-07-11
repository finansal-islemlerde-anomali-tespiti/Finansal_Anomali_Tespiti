-- Sabit Referans Verileri (Seed Data)
USE AnomaliTespiti;
GO

INSERT INTO atm_locations (atm_id, atm_name, city, latitude, longitude)
VALUES 
('ATM1000', N'Bilesim Bank Kadikoy ATM', N'Istanbul', 40.9818, 29.0326),
('ATM1001', N'Bilesim Bank Cankaya ATM', N'Ankara', 39.9208, 32.8541),
('ATM1002', N'Bilesim Bank Konak ATM', N'Izmir', 38.4189, 27.1287),
('ATM1003', N'Bilesim Bank Nilufer ATM', N'Bursa', 40.2216, 28.9614),
('ATM1004', N'Bilesim Bank Muratpasa ATM', N'Antalya', 36.8848, 30.7040),
('ATM1005', N'Bilesim Bank Seyhan ATM', N'Adana', 36.9914, 35.3213),
('ATM1006', N'Bilesim Bank Merkez ATM', N'Elazig', 38.6748, 39.2225);
GO

PRINT 'Sabit referans verileri (Seed Data) basariyla yuklendi.';