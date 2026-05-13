import mysql.connector
from mysql.connector import Error

# Ρυθμίσεις σύνδεσης (προσάρμοσε αν χρειαστεί)
config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',          # άφησε κενό αν δεν έχεις
    'database': 'mydb',
    'charset': 'utf8mb4'
}

split_file = 'csv/DRUG_ACTIVE_split.txt'

def main():
    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor()
        
        # Απενεργοποίηση ελέγχων για ταχύτητα
        cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
        cursor.execute("SET UNIQUE_CHECKS = 0")
        cursor.execute("SET AUTOCOMMIT = 0")
        
        # Μέτρηση γραμμών
        with open(split_file, 'r', encoding='utf-8') as f:
            total_lines = sum(1 for _ in f)
        print(f"Σύνολο γραμμών: {total_lines}")
        
        # Προετοιμασία ερωτήματος
        insert_query = """
            INSERT IGNORE INTO DRUG_has_Active_Substance (DRUG_drug_id, Active_Substance_substance_id)
            VALUES (%s, %s)
        """
        
        # Διάβασμα των γραμμών και αποθήκευση σε batches
        batch_size = 10000   # γραμμές ανά batch
        batch = []
        inserted_total = 0
        skipped = 0
        
        # Cache για να αποφύγουμε επαναλαμβανόμενες SELECT (προαιρετικό)
        drug_cache = {}
        substance_cache = {}
        
        with open(split_file, 'r', encoding='utf-8') as f:
            for i, line in enumerate(f, 1):
                line = line.strip()
                if not line:
                    continue
                parts = line.split('\t')
                if len(parts) < 2:
                    continue
                product_name = parts[0].strip()
                substance_name = parts[1].strip()
                
                # Βρες drug_id από cache ή από DB
                if product_name in drug_cache:
                    drug_id = drug_cache[product_name]
                else:
                    cursor.execute("SELECT drug_id FROM DRUG WHERE TRIM(LOWER(product_name)) = %s", (product_name.lower(),))
                    row = cursor.fetchone()
                    if row:
                        drug_id = row[0]
                        drug_cache[product_name] = drug_id
                    else:
                        skipped += 1
                        continue
                
                # Βρες substance_id από cache ή από DB
                cache_key = substance_name.lower()
                if cache_key in substance_cache:
                    substance_id = substance_cache[cache_key]
                else:
                    cursor.execute("SELECT substance_id FROM Active_Substance WHERE TRIM(LOWER(substance_name)) = %s", (substance_name.lower(),))
                    row = cursor.fetchone()
                    if row:
                        substance_id = row[0]
                        substance_cache[cache_key] = substance_id
                    else:
                        skipped += 1
                        continue
                
                batch.append((drug_id, substance_id))
                
                # Όταν γεμίσει το batch, εκτέλεσε bulk insert
                if len(batch) >= batch_size:
                    cursor.executemany(insert_query, batch)
                    conn.commit()
                    inserted_total += len(batch)
                    print(f"Επεξεργάστηκαν {i}/{total_lines} γραμμές, εισαχθέντα: {inserted_total}")
                    batch = []
        
        # Υπόλοιπες γραμμές
        if batch:
            cursor.executemany(insert_query, batch)
            conn.commit()
            inserted_total += len(batch)
        
        # Ενεργοποίηση ελέγχων ξανά
        cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
        cursor.execute("SET UNIQUE_CHECKS = 1")
        
        print(f"Ολοκλήρωση! Εισήχθησαν {inserted_total} εγγραφές. Παραλείφθηκαν {skipped} (χωρίς αντιστοίχηση).")
        
    except Error as e:
        print(f"Σφάλμα MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    main()