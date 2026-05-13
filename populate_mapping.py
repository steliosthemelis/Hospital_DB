import mysql.connector
from mysql.connector import Error

config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'mydb',
    'charset': 'utf8mb4'
}

split_file = r'C:\Users\ntoko\Hospital_DB\csv\DRUG_ACTIVE_split.txt'

def main():
    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor()
        
        with open(split_file, 'r', encoding='utf-8') as f:
            total_lines = sum(1 for _ in f)
        print(f"Σύνολο γραμμών: {total_lines}")
        
        inserted = 0
        skipped = 0
        
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
                
                # Βρες drug_id
                cursor.execute("SELECT drug_id FROM DRUG WHERE TRIM(LOWER(product_name)) = %s", (product_name.lower(),))
                row = cursor.fetchone()
                cursor.fetchall()  # consume any remaining results
                if not row:
                    skipped += 1
                    continue
                drug_id = row[0]
                
                # Βρες substance_id
                cursor.execute("SELECT substance_id FROM Active_Substance WHERE TRIM(LOWER(substance_name)) = %s", (substance_name.lower(),))
                row = cursor.fetchone()
                cursor.fetchall()
                if not row:
                    skipped += 1
                    continue
                substance_id = row[0]
                
                cursor.execute("INSERT IGNORE INTO DRUG_has_Active_Substance (DRUG_drug_id, Active_Substance_substance_id) VALUES (%s, %s)",
                               (drug_id, substance_id))
                conn.commit()  # commit every row (safe but slower) or batch commit
                inserted += 1
                
                if i % 10000 == 0:
                    print(f"Επεξεργάστηκαν {i}/{total_lines} γραμμές, εισαχθέντα: {inserted}")
        
        print(f"Ολοκλήρωση! Εισήχθησαν {inserted} εγγραφές. Παραλείφθηκαν {skipped} (χωρίς αντιστοίχηση).")
        
    except Error as e:
        print(f"Σφάλμα MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    main()