import os
import random
from datetime import datetime, timedelta
import pandas as pd

class POSATMSimulator:
    """
    ATM ve POS durum makinesi (State Machine) simülatörü.
    Oturum Akışı: Kart Takıldı -> PIN Girildi -> İşlem Seçildi -> Onay/Red -> Kart Çıkarıldı
    """
    def __init__(self):
        self.states = ["KART_TAKILDI", "PIN_GIRILDI", "ISLEM_SECILDI", "ONAYLANDI", "REDDEDILDI", "KART_CIKARILDI"]
        self.transaction_types = ["çekim", "yatırma", "sorgu", "transfer"]
        self.cities = ["İstanbul", "Ankara", "İzmir", "Bursa", "Antalya"]
        
    def _generate_timestamp_with_peak_hours(self):
        """Gerçekçi zaman dağılımı: Gece %15, Yoğun saatler (12:00-18:00) %60, Diğer %25"""
        now = datetime.now()
        days_back = random.randint(0, 30)
        base_date = now - timedelta(days=days_back)
        
        time_slot = random.choices(["gece", "yogun", "normal"], weights=[0.15, 0.60, 0.25])[0]
        
        if time_slot == "gece":
            hour = random.randint(0, 5)
        elif time_slot == "yogun":
            hour = random.randint(12, 18)
        else:
            hour = random.choice([6, 7, 8, 9, 10, 11, 19, 20, 21, 22, 23])
            
        minute = random.randint(0, 59)
        second = random.randint(0, 59)
        return base_date.replace(hour=hour, minute=minute, second=second)

    def generate_session(self, card_id, account_balance):
        """Tek bir ATM/POS oturumunu ve durum geçişlerini simüle eder."""
        timestamp = self._generate_timestamp_with_peak_hours()
        
        # 1. PIN Kontrolü (Hata Senaryosu: Yanlış PIN)
        pin_success = random.choices([True, False], weights=[0.93, 0.07])[0]
        if not pin_success:
            return {
                "card_id": card_id,
                "atm_id": random.randint(1, 50),
                "transaction_type": random.choice(self.transaction_types),
                "amount": 0.0,
                "status": "reddedildi",
                "failure_reason": "Hatalı PIN",
                "created_at": timestamp
            }
            
        tx_type = random.choice(self.transaction_types)
        
        # 2. Tutar ve Bakiye Kontrolü (Hata Senaryosu: Yetersiz Bakiye)
        amount = round(random.uniform(50.0, 4000.0), 2) if tx_type in ["çekim", "transfer"] else round(random.uniform(100.0, 10000.0), 2)
        
        if tx_type in ["çekim", "transfer"] and amount > account_balance:
            return {
                "card_id": card_id,
                "atm_id": random.randint(1, 50),
                "transaction_type": tx_type,
                "amount": amount,
                "status": "reddedildi",
                "failure_reason": "Yetersiz Bakiye",
                "created_at": timestamp
            }
            
        return {
            "card_id": card_id,
            "atm_id": random.randint(1, 50),
            "transaction_type": tx_type,
            "amount": amount,
            "status": "başarılı",
            "failure_reason": None,
            "created_at": timestamp
        }

    def run_bulk_simulation(self, session_count=5000, output_path="layer3/simulation/output/simulated_transactions.csv"):
        """Belirtilen sayıda oturum üretip CSV dosyasına kaydeder."""
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        print(f"=== {session_count} Adet ATM/POS Oturumu Simüle Ediliyor ===")
        
        sessions = []
        for _ in range(session_count):
            card_id = random.randint(1000, 9999)
            balance = round(random.uniform(100.0, 15000.0), 2)
            sessions.append(self.generate_session(card_id, balance))
            
        df = pd.DataFrame(sessions)
        df.sort_values(by="created_at", inplace=True)
        df.to_csv(output_path, index=False, encoding="utf-8-sig")
        print(f"✅ Simülasyon Verisi Başarıyla Kaydedildi: {output_path}")
        print(df.head())

if __name__ == "__main__":
    simulator = POSATMSimulator()
    simulator.run_bulk_simulation(session_count=5000)