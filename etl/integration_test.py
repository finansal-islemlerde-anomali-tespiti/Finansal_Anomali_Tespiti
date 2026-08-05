import pandas as pd
import pyodbc

print("=== KATMAN 2 ENTEGRASYON VE ÇAPRAZ KONTROL TESTİ ===")

try:
    # 1. SQL Server'daki Ham Veri Toplamını Alma
    conn_str = "DRIVER={SQL Server};SERVER=localhost;DATABASE=AnomaliTespiti;Trusted_Connection=yes;"
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    cursor.execute("SELECT COUNT(*), SUM(amount) FROM dbo.transactions")
    sql_raw_count, sql_raw_sum = cursor.fetchone()

    # 2. ETL Tarafında Çıkarılan CSV Raporunu Okuma
    kpi_df = pd.read_csv('etl/load_targets/daily_kpi_report.csv')
    etl_kpi_count = kpi_df['toplam_islem_adedi'].sum()
    etl_kpi_sum = kpi_df['toplam_islem_hacmi_tl'].sum()

    # Tip Dönüşümü (Decimal -> Float)
    sql_raw_sum = float(sql_raw_sum) if sql_raw_sum is not None else 0.0

    # 3. Çapraz Kontrol (Reconciliation)
    print(f"\n1. Ham SQL İşlem Adedi  : {sql_raw_count} | ETL Rapor Adedi : {etl_kpi_count}")
    print(f"2. Ham SQL Toplam Hacim  : {sql_raw_sum:,.2f} TL | ETL Rapor Hacmi: {etl_kpi_sum:,.2f} TL")

    if sql_raw_count == etl_kpi_count and abs(sql_raw_sum - etl_kpi_sum) < 0.01:
        print("\n[SONUÇ] BAŞARILI! Veri ambarı ile ETL rapor katmanı %100 mutabık.")
    else:
        print("\n[SONUÇ] UYARI! Veri tutarsızlığı tespit edildi.")

except Exception as e:
    print(f"\n[HATA] Test çalışırken sorun oluştu: {e}")

finally:
    if 'conn' in locals():
        conn.close()