import random
import time
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
        
    def generate_session(self, card_id, account_balance):
        """Tek bir ATM/POS oturumunu ve durum geçişlerini simüle eder."""
        current_state = "KART_TAKILDI"
        timestamp = datetime.now() - timedelta(minutes=random.randint(1, 10000))
        
        # 1. PIN Kontrolü (Hata Senaryosu: Yanlış PIN)
        pin_success = random.choices([True, False], weights=[0.92, 0.08])[0]
        if not pin_success:
            current_state = "REDDEDILDI"
            return {
                "card_id": card_id,
                "transaction_type": random.choice(self.transaction_types),
                "amount": 0.0,
                "status": "reddedildi",
                "failure_reason": "Hatalı PIN",
                "created_at": timestamp
            }
            
        current_state = "PIN_GIRILDI"
        tx_type = random.choice(self.transaction_types)
        current_state = "ISLEM_SECILDI"
        
        # 2. Tutar ve Bakiye Kontrolü (Hata Senaryosu: Yetersiz Bakiye)
        amount = round(random.uniform(20.0, 5000.0), 2) if tx_type in ["çekim", "transfer"] else round(random.uniform(50.0, 10000.0), 2)
        
        if tx_type == "çekim" and amount > account_balance:
            current_state = "REDDEDILDI"
            return {
                "card_id": card_id,
                "transaction_type": tx_type,
                "amount": amount,
                "status": "reddedildi",
                "failure_reason": "Yetersiz Bakiye",
                "created_at": timestamp
            }
            
        current_state = "ONAYLANDI"
        current_state = "KART_CIKARILDI"
        
        return {
            "card_id": card_id,
            "transaction_type": tx_type,
            "amount": amount,
            "status": "başarılı",
            "failure_reason": None,
            "created_at": timestamp
        }

if __name__ == "__main__":
    simulator = POSATMSimulator()
    print("=== ATM / POS İşlem Simülasyonu Çalıştırılıyor ===")
    
    # Test amaçlı 10 oturum üretimi
    sample_sessions = [simulator.generate_session(card_id=random.randint(100, 999), account_balance=3000.0) for _ in range(10)]
    df = pd.DataFrame(sample_sessions)
    print(df.to_string())