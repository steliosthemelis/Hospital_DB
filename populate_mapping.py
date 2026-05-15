import mysql.connector
from mysql.connector import Error

config = {
    'host': 'localhost',
    'user': 'root',
    'password': '12345',
    'database': 'mydb',
    'charset': 'utf8mb4'
}

split_file = 'csv/DRUG_ACTIVE_split.txt'
batch_size = 50000

def main():
    conn = None
    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor()
        
        cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
        cursor.execute("SET UNIQUE_CHECKS = 0")
        cursor.execute("SET AUTOCOMMIT = 0")
        
        pairs = []
        with open(split_file, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                parts = line.split('\t')
                if len(parts) < 2:
                    continue
                product_name = parts[0].strip()
                substance_name = parts[1].strip()
                pairs.append((product_name, substance_name))
        
        total = len(pairs)
        print(f"Σύνολο γραμμών: {total}")
        
        cursor.execute("SELECT drug_id, TRIM(LOWER(product_name)) FROM DRUG")
        drug_map = {row[1].lower(): row[0] for row in cursor.fetchall()}
        print(f"DRUG entries loaded: {len(drug_map)}")
        
        cursor.execute("SELECT substance_id, TRIM(LOWER(substance_name)) FROM Active_Substance")
        sub_map = {row[1].lower(): row[0] for row in cursor.fetchall()}
        print(f"Active_Substance entries loaded: {len(sub_map)}")
        
        insert_pairs = []
        skipped = 0
        for product_name, substance_name in pairs:
            drug_id = drug_map.get(product_name.lower())
            sub_id = sub_map.get(substance_name.lower())
            if drug_id and sub_id:
                insert_pairs.append((drug_id, sub_id))
            else:
                skipped += 1
        
        print(f"Έγκυρα ζεύγη: {len(insert_pairs)}, Παραλείφθηκαν: {skipped}")
        
        inserted = 0
        for i in range(0, len(insert_pairs), batch_size):
            batch = insert_pairs[i:i+batch_size]
            cursor.executemany("INSERT IGNORE INTO DRUG_has_Active_Substance (DRUG_drug_id, Active_Substance_substance_id) VALUES (%s, %s)", batch)
            conn.commit()
            inserted += len(batch)
            print(f"Εισήχθησαν {inserted}/{len(insert_pairs)}")
        
        cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
        cursor.execute("SET UNIQUE_CHECKS = 1")
        conn.commit()
        
        print(f"Ολοκλήρωση! Εισήχθησαν {inserted} εγγραφές.")
        
    except KeyboardInterrupt:
        print("\nΔιακόπηκε από τον χρήστη.")
    except Error as e:
        print(f"Σφάλμα MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    main()