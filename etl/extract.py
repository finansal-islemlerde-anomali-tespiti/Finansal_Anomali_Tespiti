import pyodbc
import pandas as pd
import os

# 1. VERİTABANI BAĞLANTI AYARLARI (Windows Authentication)
SERVER = 'GURBET\\SQLEXPRESS'  # Veya kendi MSSQL Server sunucu adınız
DATABASE = 'AnomaliTespiti'

print("=== ETL PIPELINE BAŞLATILDI ===")

try:
    # SQL Server'a Windows Kimlik Doğrulaması ile bağlanıyoruz
    conn_str = f'DRIVER={{SQL Server}};SERVER={SERVER};DATABASE={DATABASE};Trusted_Connection=yes;'
    conn = pyodbc.connect(conn_str)
    print("1. SQL Server bağlantısı başarıyla sağlandı.")

    # 2. EXTRACT & TRANSFORM: SQL Views Üzerinden Veri Çekme
    print("2. Raporlama görünümlerinden (Views) veriler çekiliyor...")
    
    # KPI Verisini Çekme
    df_daily_kpi = pd.read_sql("SELECT * FROM dbo.vw_daily_kpi", conn)
    
    # Anomali Özet Verisini Çekme
    df_anomaly_summary = pd.read_sql("SELECT * FROM dbo.vw_anomaly_summary", conn)

    # 3. VERİ DOĞRULAMA (Validation - Helin ile ortak kontrol adımı)
    print("\n--- ETL Veri Doğrulama Kontrolleri ---")
    print(f"vw_daily_kpi Satır Sayısı: {len(df_daily_kpi)}")
    print(f"vw_anomaly_summary Satır Sayısı: {len(df_anomaly_summary)}")
    print(f"Eksik Değer (Null) Sayısı (KPI): {df_daily_kpi.isnull().sum().sum()}")

    # 4. LOAD: Çıktıları BI Araçlarının Okuyacağı Hedef Klasöre Yazma
    output_dir = "etl/load_targets"
    os.makedirs(output_dir, exist_ok=True)

    kpi_output_path = os.path.join(output_dir, "daily_kpi_report.csv")
    anomaly_output_path = os.path.join(output_dir, "anomaly_summary_report.csv")

    df_daily_kpi.to_csv(kpi_output_path, index=False)
    df_anomaly_summary.to_csv(anomaly_output_path, index=False)

    print(f"\n3. Veriler başarıyla çıkartıldı ve yüklendi:")
    print(f" - {kpi_output_path}")
    print(f" - {anomaly_output_path}")
    print("\n=== ETL PIPELINE BAŞARIYLA TAMAMLANDI ===")

except Exception as e:
    print(f"\n[HATA] ETL Pipeline çalışırken bir sorun oluştu: {e}")
finally:
    if 'conn' in locals():
        conn.close()