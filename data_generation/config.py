# config.py

# Gurbet'in SQL Server'da oluşturduğu kesin tablo ve sütun isimleri[cite: 3]
# İleride Gurbet tablo veya sütun adlarını değiştirirse sadece burayı güncellemen yetecek![cite: 3]
DB_MAPPING = {
    "tables": {
        "accounts": "accounts",
        "cards": "cards",
        "transactions": "transactions",
        "atm_locations": "atm_locations"
    },
    "columns": {
        # accounts tablosu sütunları[cite: 3]
        "account_id": "account_id",
        "customer_name": "customer_name",
        "city": "city",
        "account_type": "account_type",
        "balance": "balance",
        "created_at": "created_at",
        
        # cards tablosu sütunları[cite: 3]
        "card_id": "card_id",
        "card_type": "card_type",
        "expiry_date": "expiry_date",
        "is_active": "is_active",
        "credit_limit": "credit_limit",
        
        # transactions tablosu sütunları[cite: 3]
        "transaction_id": "transaction_id",
        "atm_id": "atm_id",
        "amount": "amount",
        "transaction_type": "transaction_type",
        "status": "status"
    }
}

# Faker ve genel veri üretimi ayarların[cite: 3]
DATA_GEN_SETTINGS = {
    "total_records": 50000,  # Üretilecek toplam sahte işlem sayısı[cite: 3]
    "locale": "tr_TR",       # Türkçe isimler ve şehirler üretmek için[cite: 3]
    "seed": 42               # Her çalışmada aynı verilerin üretilmesi için (tutarlılık)
}