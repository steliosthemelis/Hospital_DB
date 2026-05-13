# clean_drug.py
# Διαβάζει το DRUG_utf8.txt, αφαιρεί την πρώτη στήλη (αν υπάρχει αριθμός) και γράφει ένα καθαρό DRUG_clean.txt

input_file = r'C:\Users\ntoko\Hospital_DB\csv\DRUG_utf8.txt'
output_file = r'C:\Users\ntoko\Hospital_DB\csv\DRUG_clean.txt'

print("Καθαρισμός του DRUG_utf8.txt...")

with open(input_file, 'r', encoding='utf-8') as infile, \
     open(output_file, 'w', encoding='utf-8', newline='') as outfile:
    
    for line_num, line in enumerate(infile, 1):
        line = line.rstrip('\n\r')
        if not line.strip():
            continue
        
        # Χωρίζει με tab
        parts = line.split('\t')
        
        # Αν η πρώτη στήλη είναι αριθμός (πιθανός σειριακός), αγνόησέ την
        if len(parts) > 1 and parts[0].strip().isdigit():
            # Κράτα όλες τις υπόλοιπες στήλες
            cleaned_parts = parts[1:]
        else:
            # Αλλιώς κράτα όλες
            cleaned_parts = parts
        
        # Γράφει την καθαρή γραμμή (ενώνει με tab)
        outfile.write('\t'.join(cleaned_parts) + '\n')

print(f"Ολοκληρώθηκε! Το καθαρό αρχείο αποθηκεύτηκε ως: {output_file}")