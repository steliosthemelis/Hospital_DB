import csv
import os

def detect_encoding(file_path):
    encodings = ['utf-8', 'utf-16-le', 'windows-1252']
    for enc in encodings:
        try:
            with open(file_path, 'r', encoding=enc) as f:
                f.read()
            return enc
        except UnicodeDecodeError:
            continue
    return 'utf-8'

# Διαδρομές αρχείων
input_drug_active = 'csv/DRUG_ACTIVE_utf8.txt'
output_drug_active_split = 'csv/DRUG_ACTIVE_split.txt'

input_active_substance = 'csv/Active_Substance.txt'
output_active_substance_split = 'csv/Active_Substance_split.txt'

# 1. Split DRUG_ACTIVE
print("Processing DRUG_ACTIVE...")
enc_drug = detect_encoding(input_drug_active)
print(f"Encoding for DRUG_ACTIVE: {enc_drug}")
with open(input_drug_active, 'r', encoding=enc_drug) as infile, \
     open(output_drug_active_split, 'w', encoding='utf-8', newline='') as outfile:
    for line in infile:
        line = line.rstrip('\n\r')
        if not line.strip():
            continue
        parts = line.split('\t')
        if len(parts) < 2:
            print(f"Warning: line without tab: {line[:50]}...")
            continue
        product = parts[0].strip()
        substances = parts[1].strip()
        if not product or not substances:
            continue
        for s in substances.split('|'):
            s = s.strip()
            if s:
                outfile.write(f"{product}\t{s}\n")

print(f"Split DRUG_ACTIVE done. Output: {output_drug_active_split}")
# 2. Split Active_Substance
print("Processing Active_Substance...")
enc_sub = detect_encoding(input_active_substance)
print(f"Encoding for Active_Substance: {enc_sub}")
with open(input_active_substance, 'r', encoding=enc_sub) as infile, \
     open(output_active_substance_split, 'w', encoding='utf-8', newline='') as outfile:
    reader = csv.reader(infile, delimiter='\t')
    writer = csv.writer(outfile, delimiter='\t')
    for row in reader:
        if not row:
            continue
        substance = row[0].strip()
        if not substance:
            continue
        for s in substance.split('|'):
            s = s.strip()
            if s:
                writer.writerow([s])

print(f"Split Active_Substance done. Output: {output_active_substance_split}") 