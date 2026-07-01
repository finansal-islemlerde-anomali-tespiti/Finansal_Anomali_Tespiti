import os
import random
import pandas as pd
from faker import Faker
# config.py dosyasındaki esnek haritalama yapısını içeri aktarıyoruz
from config import DB_MAPPING, DATA_GEN_SETTINGS

# Faker ve random motorunu config'deki seed ile sabitleyelim (Tutarlılık için)
fake = Faker(DATA_GEN_SETTINGS["locale"])
Faker.seed(DATA_GEN_SETTINGS["seed"])
random.seed(DATA_GEN_SETTINGS["seed"])

def generate_accounts(num_records=1000):
    """accounts (Hesaplar) tablosu için gerçekçi Türkçe veri üretir"""
    accounts = []
    account_types = ['vadesiz', 'vadeli', 'ticari']
    cities = ['İstanbul', 'Ankara', 'İzmir', 'Elazığ', 'Bursa', 'Antalya']
    
    c_cols = DB_MAPPING["columns"]
    for i in range(1, num_records + 1):
        accounts.append({
            c_cols["account_id"]: i,
            c_cols["customer_name"]: fake.name(),
            c_cols["city"]: random.choice(cities),
            c_cols["account_type"]: random.choice(account_types),
            c_cols["balance"]: round(random.uniform(500, 250000), 2),
            c_cols["created_at"]: fake.date_time_between(start_date='-3y', end_date='now').strftime('%Y-%m-%d %H:%M:%S')
        })
    return pd.DataFrame(accounts)

def generate_cards(accounts_df, num_records=1200):
    """cards (Kartlar) tablosu için hesaplara bağlı veri üretir"""
    cards = []
    card_types = ['debit', 'credit']
    c_cols = DB_MAPPING["columns"]
    
    # Her kartın geçerli bir hesaba bağlanması için mevcut account_id listesini alıyoruz
    account_ids = accounts_df[c_cols["account_id"]].tolist()
    
    for i in range(1, num_records + 1):
        # Her hesabın en az 1 kartı olmasını garanti edelim
        acc_id = account_ids[i-1] if i <= len(account_ids) else random.choice(account_ids)
        
        cards.append({
            c_cols["card_id"]: i,
            c_cols["account_id"]: acc_id,
            c_cols["card_type"]: random.choice(card_types),
            # Hatalı olan metod credit_card_expire olarak düzeltildi:
            c_cols["expiry_date"]: fake.credit_card_expire(start="now", end="+5y", date_format="%Y-%m-%d"),
            "is_active": random.choices([1, 0], weights=[90, 10])[0], # %90 aktif, %10 pasif kart
            c_cols["credit_limit"]: round(random.uniform(5000, 100000), 2) if random.choice(card_types) == 'credit' else 0.00
        })
    return pd.DataFrame(cards)

def generate_transactions(cards_df, num_records=50000):
    """Normal ve dökümandaki anomali türlerini içeren işlem verilerini üretir"""
    transactions = []
    tx_types = ['çekim', 'yatırma', 'sorgu']
    statuses = ['başarılı', 'başarılı', 'başarılı', 'reddedildi', 'askıda']
    
    c_cols = DB_MAPPING["columns"]
    card_ids = cards_df[c_cols["card_id"]].tolist()
    
    # Gurbet'in seed_data dökümanındaki ATM ID'leri için 1-20 arası havuz
    atm_ids = list(range(1, 21))
    
    print("⏳ 50.000+ İşlem ve anomali senaryoları enjekte ediliyor...")
    
    # --- 1. NORMAL İŞLEMLERİN ÜRETİMİ ---
    for i in range(1, num_records + 1):
        transactions.append({
            c_cols["transaction_id"]: i,
            c_cols["card_id"]: random.choice(card_ids),
            c_cols["atm_id"]: random.choice(atm_ids),
            c_cols["amount"]: round(random.uniform(10, 4900), 2),
            c_cols["transaction_type"]: random.choice(tx_types),
            c_cols["status"]: random.choice(statuses),
            "created_at": fake.date_time_between(start_date='-30d', end_date='now').strftime('%Y-%m-%d %H:%M:%S')
        })
    
    df_tx = pd.DataFrame(transactions)
    
    # --- 2. ANOMALİ ENJEKSİYONLARI ---
    # Senaryo 3: Saat Anomalisi (Gece 00:00 - 05:00 arası çok yüksek tutarlı işlemler)
    print("  -> Saat anomalileri ekleniyor...")
    for j in range(500):
        idx = random.randint(0, num_records - 1)
        df_tx.loc[idx, 'amount'] = round(random.uniform(45000, 95000), 2)
        random_night_time = f" 0{random.randint(0,4)}:{random.randint(10,59)}:{random.randint(10,59)}"
        df_tx.loc[idx, 'created_at'] = df_tx.loc[idx, 'created_at'].split()[0] + random_night_time
    
    # Senaryo 5: Tutar Anomalisi (Normal saatte ama ortalamanın çok üstünde tekil işlemler)
    print("  -> Tutar anomalileri ekleniyor...")
    for j in range(500):
        idx = random.randint(0, num_records - 1)
        df_tx.loc[idx, 'amount'] = round(random.uniform(75000, 150000), 2)
        df_tx.loc[idx, 'status'] = 'başarılı'

    # Senaryo 1: Hız Anomalisi (Aynı kartla 10 dakika içinde 4 ardışık işlem)
    print("  -> Hız anomalileri ekleniyor...")
    for j in range(100):
        target_card = random.choice(card_ids)
        base_time = fake.date_time_between(start_date='-15d', end_date='now')
        for k in range(4):
            new_id = len(df_tx) + 1
            time_offset = base_time + pd.Timedelta(minutes=k*2)
            new_row = {
                c_cols["transaction_id"]: new_id,
                c_cols["card_id"]: target_card,
                c_cols["atm_id"]: random.choice(atm_ids),
                c_cols["amount"]: round(random.uniform(1000, 3000), 2),
                c_cols["transaction_type"]: 'çekim',
                c_cols["status"]: 'başarılı',
                'created_at': time_offset.strftime('%Y-%m-%d %H:%M:%S')
            }
            df_tx = pd.concat([df_tx, pd.DataFrame([new_row])], ignore_index=True)

    return df_tx

if __name__ == "__main__":
    print("🚀 Sahte veri üretimi başlatılıyor...")
    
    # Çıktı klasörü yoksa otomatik oluşturalım
    os.makedirs("data_generation/output", exist_ok=True)
    
    # 1. Hesapları ve Kartları üret
    df_accounts = generate_accounts(1000)
    df_cards = generate_cards(df_accounts, 1200)
    
    # 2. İşlemleri ve Anomalileri üret
    df_transactions = generate_transactions(df_cards, DATA_GEN_SETTINGS["total_records"])
    
    # 3. CSV dökümanı olarak kaydet (Dökümandaki klasör yapısına göre)
    df_transactions.to_csv("data_generation/output/transactions.csv", index=False)
    
    print("\n" + "="*40)
    print(f"✅ Başarıyla {len(df_accounts)} adet Hesap üretildi.")
    print(f"✅ Başarıyla {len(df_cards)} adet Kart üretildi.")
    print(f"🔥 TOPLAM {len(df_transactions)} ADET İŞLEM (TRANSACTION) VERİSİ ANOMALİLERLE BİRLİKTE ÜRETİLDİ VE KAYDEDİLDİ!")
    print("📁 Dosya Yolu: data_generation/output/transactions.csv")
    print("="*40)