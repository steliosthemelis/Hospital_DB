from faker import Faker
import random
from datetime import datetime, timedelta, time
import shlex

fake = Faker('el_GR')


def can_assign(amka, shift_type, shift_date, person_schedule, person_monthly, monthly_cap):
    result = True
    if shift_type == 'Morning':
        date_to_check = shift_date - timedelta(days=1)
        if person_schedule[amka].get(date_to_check) == 'Night':
            result = False
    if shift_type == 'Afternoon':
        if person_schedule[amka].get(shift_date) == 'Morning':
            result = False
    if shift_type == 'Night':
        if person_schedule[amka].get(shift_date) == 'Afternoon':
            result = False
        night_shifts = True
        for i in range(1, 4):
            date_to_check = shift_date - timedelta(days=i)
            night_shifts = night_shifts and (person_schedule[amka].get(date_to_check) == 'Night')
        if night_shifts:
            result = False
    if person_monthly[amka].get((shift_date.year, shift_date.month), 0) + 1 > monthly_cap:
        result = False
    return result


def can_assign_intern(amka, shift_type, shift_date, dept_id, shift_doctors, doctor_grade):
    if doctor_grade[amka] != 'Intern':
        return True
    for i in shift_doctors.get((shift_type, shift_date, dept_id), []):
        if doctor_grade[i] == 'Supervisor A' or doctor_grade[i] == 'Director':
            return True
    return False


def cannot_assign_room_or_doc(schedule, key, start, end):
    for s, e in schedule.get(key, []):
        if start < e and end > s:
            return True
    return False


icd10_codes = [
    'C50.9', 'C61',   'D50.9', 'E04.9', 'E78.5',
    'F32.9', 'F41.9', 'G40.9', 'G43.9', 'H25.9', 'I10',   'I20.9',
    'I21.9', 'I50.9', 'I63.9', 'J01.9', 'J06.9', 'J18.9',
    'J44.9', 'J45.9', 'K21.9', 'K29.7', 'K80.2', 'L03.9',
    'M15.9', 'M54.5', 'N20.1', 'N39.0', 'O80.9', 'R07.4', 'S02.9',
    'S72.0', 'T07'
]

ken_codes = [
    'Ε01Α', 'Ν26Μ', 'Ο16Α', 'Α20Μ', 'Κ06Χ',
    'Κ42Χ', 'Π12Μβ', 'Η41Μ', 'Μ27Χ', 'Δ01Χ',
    'Θ09Μ', 'Υ25Μ', 'Λ04Μ', 'Σ02Χβ', 'Ι24Α'
]

# Build substance_name -> substance_id matching what load.sql inserts
# (Active_Substance_split.txt loaded via TRUNCATE + AUTO_INCREMENT)
substance_to_id = {}
with open('csv/Active_Substance_split.txt', 'r', encoding='utf-8') as f:
    for idx, line in enumerate(f, start=1):
        name = line.rstrip('\r\n').strip().strip('"').lower()
        if name:
            substance_to_id[name] = idx

all_substance_ids = list(substance_to_id.values())

# Build drug_code -> drug_id from DRUG_utf8.txt (no header; col0=drug_code, AUTO_INCREMENT from 1)
drug_id_by_name = {}
with open('csv/DRUG_utf8.txt', 'r', encoding='utf-8-sig') as f:
    for idx, line in enumerate(f, start=1):
        parts = line.rstrip('\r\n').split('\t')
        if len(parts) >= 1:
            product_name = parts[0].strip().strip('"').lower()
            if product_name and product_name not in drug_id_by_name:
                drug_id_by_name[product_name] = idx
        if idx >= 12235:
            break

# Build drug_id -> set of substance_ids from DRUG_ACTIVE_split.txt
drug_substances = {}
with open('csv/DRUG_ACTIVE_split.txt', 'r', encoding='utf-8-sig') as f:
    for line in f:
        parts = line.rstrip('\r\n').split('\t')
        if len(parts) >= 2:
            product_name = parts[0].strip().strip('"').lower()
            substance    = parts[1].strip().strip('"').lower()
            drug_id = drug_id_by_name.get(product_name)
            sub_id  = substance_to_id.get(substance)
            if drug_id is not None and sub_id is not None:
                drug_substances.setdefault(drug_id, set()).add(sub_id)


with open('02_load_hospital_data.sql', 'w', encoding='utf-8') as f:
    f.write("-- Αρχείο Φόρτωσης Δεδομένων Λειτουργίας\n")
    f.write("USE `mydb`;\n\n")

    # personnel

    f.write("INSERT INTO `PERSONNEL` (`AMKA`, `name`, `surname`, `age`, `email`, `phone`, `hire_date`, `personnel_type`) VALUES\n")

    doctor_amkas = []
    nurse_amkas = []
    administrative_staff_amkas = []

    for i in range(80):
        amka = fake.numerify('###########')
        doctor_amkas.append(amka)
        name = fake.first_name()
        surname = fake.last_name()
        age = fake.random_int(min=18, max=65)
        email = fake.ascii_free_email()
        phone = fake.numerify('69########')
        hire_date = fake.date_between(start_date='-10y', end_date='today')
        line = f"('{amka}', '{name}', '{surname}', '{age}', '{email}', '{phone}', '{hire_date}', 'Doctor')"
        if i == 79:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    f.write("INSERT INTO `PERSONNEL` (`AMKA`, `name`, `surname`, `age`, `email`, `phone`, `hire_date`, `personnel_type`) VALUES\n")
    for i in range(250):
        amka = fake.numerify('###########')
        nurse_amkas.append(amka)
        name = fake.first_name()
        surname = fake.last_name()
        age = fake.random_int(min=18, max=65)
        email = fake.ascii_free_email()
        phone = fake.numerify('69########')
        hire_date = fake.date_between(start_date='-10y', end_date='today')
        line = f"('{amka}', '{name}', '{surname}', '{age}', '{email}', '{phone}', '{hire_date}', 'Nurse')"
        if i == 249:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    f.write("INSERT INTO `PERSONNEL` (`AMKA`, `name`, `surname`, `age`, `email`, `phone`, `hire_date`, `personnel_type`) VALUES\n")
    for i in range(40):
        amka = fake.numerify('###########')
        administrative_staff_amkas.append(amka)
        name = fake.first_name()
        surname = fake.last_name()
        age = fake.random_int(min=18, max=65)
        email = fake.ascii_free_email()
        phone = fake.numerify('69########')
        hire_date = fake.date_between(start_date='-10y', end_date='today')
        line = f"('{amka}', '{name}', '{surname}', '{age}', '{email}', '{phone}', '{hire_date}', 'Administrative_Staff')"
        if i == 39:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    # doctor

    f.write("INSERT INTO `DOCTOR` (`license_number`, `specialty`, `Grade`, `PERSONNEL_AMKA`, `Supervisor_AMKA`) VALUES\n")

    directors    = doctor_amkas[0:15]
    supervisor_a = doctor_amkas[15:30]
    supervisor_b = doctor_amkas[30:50]
    intern       = doctor_amkas[50:80]
    doctor_speciality = []

    specialities = [
        "Cardiology", "Neurology", "Orthopedics", "Pediatrics", "General Surgery",
        "Internal Medicine", "Emergency", "Psychiatry", "Radiology", "Anesthesiology",
        "Obstetrics & Gynecology", "Ophthalmology", "Gastroenterology", "Urology", "Oncology"
    ]

    for i in range(15):
        doctor_speciality.append(specialities[i])
        licence_number = fake.numerify('########')
        line = f"('{licence_number}', '{specialities[i]}', 'Director', '{directors[i]}', NULL)"
        f.write(line + ",\n")

    for i in range(15):
        licence_number = fake.numerify('########')
        speciality = random.choice(specialities)
        doctor_speciality.append(speciality)
        supervisor = random.choice(directors)
        line = f"('{licence_number}', '{speciality}', 'Supervisor A', '{supervisor_a[i]}', '{supervisor}')"
        f.write(line + ",\n")

    for i in range(20):
        licence_number = fake.numerify('########')
        speciality = random.choice(specialities)
        doctor_speciality.append(speciality)
        supervisor = random.choice(supervisor_a)
        line = f"('{licence_number}', '{speciality}', 'Supervisor B', '{supervisor_b[i]}', '{supervisor}')"
        f.write(line + ",\n")

    for i in range(30):
        licence_number = fake.numerify('########')
        speciality = random.choice(specialities)
        doctor_speciality.append(speciality)
        supervisor = random.choice(supervisor_b)
        line = f"('{licence_number}', '{speciality}', 'Intern', '{intern[i]}', '{supervisor}')"
        if i == 29:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    # department

    f.write("INSERT INTO `Department` (`num_of_beds`, `building`, `level`, `dept_id`, `Director_AMKA`) VALUES\n")

    number_of_beds = []
    for i in range(15):
        num_of_beds = fake.random_int(min=15, max=45)
        number_of_beds.append(num_of_beds)
        building = fake.random_int(min=1, max=4)
        level = fake.random_int(min=0, max=4)
        dept_id = specialities[i]
        Director_AMKA = directors[i]
        line = f"('{num_of_beds}', '{building}', '{level}', '{dept_id}', '{Director_AMKA}')"
        if i == 14:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    # beds

    f.write("INSERT INTO `BEDS` (`bed_id`, `type`, `status`, `Department_dept_id`) VALUES\n")

    bed_types = ['Single', 'Double', 'Ward', 'ICU']
    availabilities = ['Available', 'Occupied', 'Maintenance']
    beds_available = []

    for i in range(15):
        for j in range(number_of_beds[i]):
            bed_id = j + 1
            bed_type = random.choice(bed_types)
            status = random.choices(availabilities, weights=[98, 0, 2], k=1)[0]
            Department_dept_id = specialities[i]
            if status == 'Available':
                beds_available.append((bed_id, Department_dept_id))
            line = f"('{bed_id}', '{bed_type}', '{status}', '{Department_dept_id}')"
            if i == 14 and j == number_of_beds[14] - 1:
                f.write(line + ";\n\n")
            else:
                f.write(line + ",\n")

    # nurse

    f.write("INSERT INTO `Nurse` (`Grade`, `PERSONNEL_AMKA`, `Department_dept_id`) VALUES\n")

    nurse_grades = ['Nurse Assistant', 'Nurse', 'Supervisor Nurse']
    emergency_nurses = []

    for i in range(250):
        grade = random.choice(nurse_grades)
        amka = nurse_amkas[i]
        dept_id = random.choice(specialities)
        if dept_id == 'Emergency':
            emergency_nurses.append(amka)
        line = f"('{grade}', '{amka}', '{dept_id}')"
        if i == 249:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    if not emergency_nurses:
        emergency_nurses = nurse_amkas[:]

    # administrative staff

    f.write("INSERT INTO `Administrative_Staff` (`duties`, `PERSONNEL_AMKA`, `Department_dept_id`) VALUES\n")

    admin_roles = [
        'Γραμματέας Κλινικής',
        'Λογιστής',
        'Υπάλληλος Υποδοχής',
        'Υπάλληλος Τιμολόγησης',
        'Υπεύθυνος Προμηθειών',
        'Διοικητικός Υπάλληλος',
        'Γραμματέας Εξωτερικών Ιατρείων'
    ]

    for i in range(40):
        duties = random.choice(admin_roles)
        amka = administrative_staff_amkas[i]
        dep_id = random.choice(specialities)
        line = f"('{duties}', '{amka}', '{dep_id}')"
        if i == 39:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    # room

    f.write("INSERT INTO `ROOM` (`room_id`, `room_type`) VALUES\n")

    for i in range(10):
        room_id = i
        room_type = random.choice(['Operating Room', 'Procedure Room'])
        line = f"('{room_id}', '{room_type}')"
        if i == 9:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    # patient

    f.write("INSERT INTO `Patient` (`AMKA`, `first_name`, `last_name`, `father_name`, `age`, `gender`, `weight`, `height`, `address`, `phone`, `email`, `profession`, `nationality`, `insurance_type`) VALUES\n")

    patient_amkas = []

    for i in range(200):
        amka = fake.numerify("###########")
        patient_amkas.append(amka)
        is_child = random.choices([True, False], weights=[20, 80], k=1)[0]
        if is_child:
            age = random.randint(1, 14)
        else:
            age = random.randint(15, 90)
        gender = random.choice(['Male', 'Female'])
        if gender == 'Male':
            first_name = fake.first_name_male()
            last_name = fake.last_name_male()
        else:
            first_name = fake.first_name_female()
            last_name = fake.last_name_female()
        father_name = fake.first_name_male()
        if age < 15:
            weight = random.randint(75 + (age * 5), 85 + (age * 6))
            height = round((random.randint(10 + (age * 2), 12 + (age * 3))) / 100, 2)
        else:
            if gender == 'Male':
                height = round(random.randint(165, 195) / 100, 2)
                weight = random.randint(65, 115)
            else:
                height = round(random.randint(150, 180) / 100, 2)
                weight = random.randint(50, 95)
        address = fake.address()
        phone = fake.numerify("69########")
        email = fake.ascii_email()
        job = fake.job()[:45]
        nationalities = ['Ελληνική', 'Αλβανική', 'Βρετανική', 'Γερμανική', 'Συριακή']
        nat_weights = [85, 5, 4, 3, 3]
        nationality = random.choices(nationalities, weights=nat_weights, k=1)[0]
        insurance = random.choice(['EFKA', 'Private', 'None'])
        line = f"('{amka}', '{first_name}', '{last_name}', '{father_name}', '{age}', '{gender}', '{weight}', '{height}', '{address}', '{phone}', '{email}', '{job}', '{nationality}', '{insurance}')"
        if i == 199:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    # emergency contact

    f.write("INSERT INTO `Emergency_Contact` (`first_name`, `last_name`, `phone`, `relationship`, `Patient_AMKA`) VALUES\n")

    relationships = ['Σύζυγος', 'Γονέας', 'Τέκνο', 'Αδελφός/η', 'Φίλος/η']

    for i in range(200):
        k = random.randint(1, 2)
        for j in range(k):
            first_name = fake.first_name()
            last_name = fake.last_name()
            phone = fake.numerify("69########")
            relationship = random.choice(relationships)
            amka = patient_amkas[i]
            line = f"('{first_name}', '{last_name}', '{phone}', '{relationship}', '{amka}')"
            if i == 199 and j == k - 1:
                f.write(line + ";\n\n")
            else:
                f.write(line + ",\n")

    # patient allergy

    f.write("INSERT INTO `Patient_Allergy` (`Patient_AMKA`, `Active_Substance_substance_id`) VALUES\n")

    patient_allergies = {amka: set() for amka in patient_amkas}
    allergy_lines = []

    for i in range(200):
        k = random.randint(0, 3)
        if k > 0:
            amka = patient_amkas[i]
            sub_ids = random.sample(all_substance_ids, min(k, len(all_substance_ids)))
            for sub_id in sub_ids:
                patient_allergies[amka].add(sub_id)
                allergy_lines.append(f"('{amka}', {sub_id})")

    f.write(",\n".join(allergy_lines) + ";\n\n")

    # doctor_has_department

    f.write("INSERT INTO `DOCTOR_has_Department` (`DOCTOR_PERSONNEL_AMKA`, `Department_dept_id`) VALUES\n")

    for i in range(80):
        amka = doctor_amkas[i]
        dep_id = doctor_speciality[i]
        doc_deps = {dep_id}
        line = f"('{amka}', '{dep_id}')"
        k = random.randint(0, 2)
        if i == 79 and k == 0:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")
        for j in range(k):
            extra_dep = random.choice(specialities)
            while extra_dep in doc_deps:
                extra_dep = random.choice(specialities)
            doc_deps.add(extra_dep)
            line = f"('{amka}', '{extra_dep}')"
            if i == 79 and j == k - 1:
                f.write(line + ";\n\n")
            else:
                f.write(line + ",\n")

    # hospitalization

    f.write("INSERT INTO `Hospitalization` (`entry_date`, `exit_date`, `total_cost`, `BEDS_bed_id`, `BEDS_Department_dept_id`, `Patient_AMKA`, `ICD-10_in`, `ICD-10_out`, `KEN_ken_code`) VALUES\n")

    all_hospitalizations = []
    bed_schedules = {pair: [] for pair in beds_available}

    for i in range(500):
        amka = random.choice(patient_amkas)
        valid_slot_found = False
        while not valid_slot_found:
            bed_pair = random.choice(beds_available)
            b_id, d_id = bed_pair
            start_date = fake.date_between(start_date='-5y', end_date='today')
            is_active = random.choices([True, False], weights=[10, 90], k=1)[0]
            if is_active:
                end_date = start_date + timedelta(days=365)
            else:
                days_in_hospital = random.randint(1, 15)
                end_date = start_date + timedelta(days=days_in_hospital)
            overlap = False
            for existing_start, existing_end in bed_schedules[bed_pair]:
                if start_date <= existing_end and end_date >= existing_start:
                    overlap = True
                    break
            if not overlap:
                valid_slot_found = True
                bed_schedules[bed_pair].append((start_date, end_date))
                final_end_date = None if is_active else end_date
                icd_in = random.choice(icd10_codes)
                icd_out = random.choice(icd10_codes) if not is_active else None
                ken = random.choice(ken_codes)
                all_hospitalizations.append({
                    'amka': amka,
                    'bed_id': b_id,
                    'dept_id': d_id,
                    'entry': start_date,
                    'exit': final_end_date,
                    'icd_in': icd_in,
                    'icd_out': icd_out,
                    'ken': ken
                })

    all_hospitalizations.sort(key=lambda x: x['entry'])

    for i, h in enumerate(all_hospitalizations):
        h['hosp_id'] = i + 1
        entry_str = h['entry'].strftime('%Y-%m-%d')
        exit_str = f"'{h['exit'].strftime('%Y-%m-%d')}'" if h['exit'] else "NULL"
        icd_out_val = f"'{h['icd_out']}'" if h['icd_out'] else "NULL"
        line = f"('{entry_str}', {exit_str}, 0.00, {h['bed_id']}, '{h['dept_id']}', '{h['amka']}', '{h['icd_in']}', {icd_out_val}, '{h['ken']}')"
        if i == len(all_hospitalizations) - 1:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    # triage

    f.write("INSERT INTO `Triage` (`arrival_time`, `symptoms`, `urgency_level`, `Nurse_PERSONNEL_AMKA`, `Hospitalization_hosp_id`, `Patient_AMKA`) VALUES\n")

    triages = []
    symptoms_list = [
        "Πυρετός", "Βήχας", "Πονοκέφαλος", "Δύσπνοια", "Πόνος στο στήθος",
        "Κοιλιακός πόνος", "Ναυτία", "Έμετος", "Ζάλη", "Αδυναμία / Κόπωση",
        "Διάρροια", "Ρίγος", "Πόνος στη μέση", "Δερματικό Εξάνθημα",
        "Αιμορραγία", "Λιποθυμικό Επεισόδιο", "Μούδιασμα άκρων",
        "Ταχυκαρδία", "Δυσουρία", "Οίδημα (Πρήξιμο)"
    ]

    for i in range(400):
        hosp = all_hospitalizations[i]
        nurse_amka = random.choice(emergency_nurses)
        num_of_symptoms = random.randint(1, 3)
        chosen_symptoms = random.sample(symptoms_list, num_of_symptoms)
        symptoms_string = ", ".join(chosen_symptoms)
        if len(symptoms_string) > 45:
            symptoms_string = symptoms_string[:45]
        level = random.randint(1, 5)
        random_time = time(random.randint(0, 23), random.randint(0, 59), random.randint(0, 59))
        eval_datetime = datetime.combine(hosp['entry'], random_time)
        triages.append({
            'arrival': eval_datetime,
            'symptoms': symptoms_string,
            'level': level,
            'nurse_amka': nurse_amka,
            'hosp_id': hosp['hosp_id'],
            'patient_amka': hosp['amka']
        })

    for i in range(600):
        arrival_time = fake.date_time_between(start_date='-10y', end_date='now')
        num_of_symptoms = random.randint(1, 3)
        chosen_symptoms = random.sample(symptoms_list, num_of_symptoms)
        symptoms_string = ", ".join(chosen_symptoms)
        if len(symptoms_string) > 45:
            symptoms_string = symptoms_string[:45]
        level = random.randint(1, 5)
        nurse_amka = random.choice(emergency_nurses)
        p_amka = random.choice(patient_amkas)
        triages.append({
            'arrival': arrival_time,
            'symptoms': symptoms_string,
            'level': level,
            'nurse_amka': nurse_amka,
            'hosp_id': None,
            'patient_amka': p_amka
        })

    triages.sort(key=lambda x: x['arrival'])

    for i, h in enumerate(triages):
        h['triage_id'] = i + 1
        entry_str = h['arrival'].strftime('%Y-%m-%d %H:%M:%S')
        hosp_id_val = h['hosp_id'] if h['hosp_id'] else "NULL"
        line = f"('{entry_str}', '{h['symptoms']}', {h['level']}, '{h['nurse_amka']}', {hosp_id_val}, '{h['patient_amka']}')"
        if i == len(triages) - 1:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    # shifts

    f.write("INSERT INTO `Shift` (`shift_type`, `date`, `Department_dept_id`) VALUES\n")

    shift_types_list = ['Morning', 'Afternoon', 'Night']
    today = datetime.today().date()

    for i in range(7):
        for j in range(15):
            for k in range(3):
                shift_type = shift_types_list[k]
                shift_date = today - timedelta(days=i)
                dep_id = specialities[j]
                line = f"('{shift_type}', '{shift_date}', '{dep_id}')"
                if i == 6 and j == 14 and k == 2:
                    f.write(line + ";\n\n")
                else:
                    f.write(line + ",\n")

    # doctor_has_shift

    all_personnel = doctor_amkas + nurse_amkas + administrative_staff_amkas
    person_schedule = {amka: {} for amka in all_personnel}
    monthly_shifts  = {amka: {} for amka in all_personnel}
    shift_doctors   = {}

    doctor_grade = {}
    for amka in directors:    doctor_grade[amka] = 'Director'
    for amka in supervisor_a: doctor_grade[amka] = 'Supervisor A'
    for amka in supervisor_b: doctor_grade[amka] = 'Supervisor B'
    for amka in intern:       doctor_grade[amka] = 'Intern'

    f.write("INSERT INTO `DOCTOR_has_Shift` (`DOCTOR_PERSONNEL_AMKA`, `Shift_shift_type`, `Shift_date`, `Shift_Department_dept_id`) VALUES\n")

    for i in range(7):
        for j in range(15):
            for k in range(3):
                for l in range(3):
                    shift_date = today - timedelta(days=i)
                    dep_id = specialities[j]
                    amka = random.choice(doctor_amkas)
                    attempts = 0
                    while not (can_assign(amka, shift_types_list[k], shift_date, person_schedule, monthly_shifts, 15)
                               and can_assign_intern(amka, shift_types_list[k], shift_date, dep_id, shift_doctors, doctor_grade)):
                        amka = random.choice(doctor_amkas)
                        attempts += 1
                        if attempts > 300:
                            break
                    monthly_shifts[amka][(shift_date.year, shift_date.month)] = monthly_shifts[amka].get((shift_date.year, shift_date.month), 0) + 1
                    person_schedule[amka][shift_date] = shift_types_list[k]
                    shift_doctors.setdefault((shift_types_list[k], shift_date, dep_id), []).append(amka)
                    line = f"('{amka}', '{shift_types_list[k]}', '{shift_date}', '{dep_id}')"
                    if i == 6 and j == 14 and k == 2 and l == 2:
                        f.write(line + ";\n\n")
                    else:
                        f.write(line + ",\n")

    # nurse_has_shift

    f.write("INSERT INTO `Nurse_has_Shift` (`Nurse_PERSONNEL_AMKA`, `Shift_shift_type`, `Shift_date`, `Shift_Department_dept_id`) VALUES\n")

    for i in range(7):
        for j in range(15):
            for k in range(3):
                for l in range(6):
                    shift_date = today - timedelta(days=i)
                    dep_id = specialities[j]
                    amka = random.choice(nurse_amkas)
                    attempts = 0
                    while not can_assign(amka, shift_types_list[k], shift_date, person_schedule, monthly_shifts, 20):
                        amka = random.choice(nurse_amkas)
                        attempts += 1
                        if attempts > 300:
                            break
                    monthly_shifts[amka][(shift_date.year, shift_date.month)] = monthly_shifts[amka].get((shift_date.year, shift_date.month), 0) + 1
                    person_schedule[amka][shift_date] = shift_types_list[k]
                    line = f"('{amka}', '{shift_types_list[k]}', '{shift_date}', '{dep_id}')"
                    if i == 6 and j == 14 and k == 2 and l == 5:
                        f.write(line + ";\n\n")
                    else:
                        f.write(line + ",\n")

    # administrative_staff_has_shift

    f.write("INSERT INTO `Administrative_Staff_has_Shift` (`Administrative_Staff_PERSONNEL_AMKA`, `Shift_shift_type`, `Shift_date`, `Shift_Department_dept_id`) VALUES\n")

    for i in range(7):
        for j in range(15):
            for k in range(3):
                for l in range(2):
                    shift_date = today - timedelta(days=i)
                    dep_id = specialities[j]
                    amka = random.choice(administrative_staff_amkas)
                    attempts = 0
                    while not can_assign(amka, shift_types_list[k], shift_date, person_schedule, monthly_shifts, 25):
                        amka = random.choice(administrative_staff_amkas)
                        attempts += 1
                        if attempts > 300:
                            break
                    monthly_shifts[amka][(shift_date.year, shift_date.month)] = monthly_shifts[amka].get((shift_date.year, shift_date.month), 0) + 1
                    person_schedule[amka][shift_date] = shift_types_list[k]
                    line = f"('{amka}', '{shift_types_list[k]}', '{shift_date}', '{dep_id}')"
                    if i == 6 and j == 14 and k == 2 and l == 1:
                        f.write(line + ";\n\n")
                    else:
                        f.write(line + ",\n")

    # lab exams

    f.write("INSERT INTO `LAB_EXAMS` (`type`, `date`, `result`, `unit`, `cost`, `Hospitalization_hosp_id`, `DOCTOR_PERSONNEL_AMKA`) VALUES \n")

    lab_exams_dict = {
        'Γενική Αίματος (Αιματοκρίτης)':   ('numeric', '%',    (35.0, 52.0)),
        'Αιμοσφαιρίνη (Hb)':               ('numeric', 'g/dL', (11.0, 17.5)),
        'Σάκχαρο Ορού':                     ('numeric', 'mg/dL',(70.0, 180.0)),
        'Ουρία':                            ('numeric', 'mg/dL',(15.0, 60.0)),
        'Κρεατινίνη':                       ('numeric', 'mg/dL',(0.6, 1.5)),
        'Χοληστερίνη':                      ('numeric', 'mg/dL',(120.0, 280.0)),
        'Τρανσαμινάσες (SGOT)':             ('numeric', 'U/L',  (10.0, 50.0)),
        'CRP (C-Αντιδρώσα Πρωτεΐνη)':      ('numeric', 'mg/L', (0.1, 20.0)),
        'Ακτινογραφία Θώρακος':             ('text', '-', ['Φυσιολογική', 'Ύποπτο Εύρημα', 'Σκίαση', 'Χωρίς Παθολογία']),
        'Μαγνητική Τομογραφία (MRI)':       ('text', '-', ['Χωρίς παθολογικά ευρήματα', 'Αλλοίωση ιστών', 'Φυσιολογική']),
        'Αξονική Τομογραφία (CT)':          ('text', '-', ['Φυσιολογική', 'Ανεύρεση όγκου', 'Καθαρή']),
        'Υπέρηχος Κοιλίας':                 ('text', '-', ['Φυσιολογικός', 'Λιπώδης διήθηση ήπατος', 'Χολολιθίαση']),
        'Γενική Ούρων':                     ('text', '-', ['Αρνητική', 'Παρουσία βακτηρίων', 'Ίχνη αίματος']),
        'PCR SARS-CoV-2':                   ('text', '-', ['Αρνητικό', 'Θετικό'])
    }

    all_lab_exams = []

    for i, hosp in enumerate(all_hospitalizations):
        num_of_exams = random.randint(1, 6)
        chosen_exams = random.choices(list(lab_exams_dict.keys()), k=num_of_exams)
        for exam_name in chosen_exams:
            exam_info = lab_exams_dict[exam_name]
            result_format = exam_info[0]
            unit = exam_info[1]
            if result_format == 'numeric':
                min_val, max_val = exam_info[2]
                res_val = round(random.uniform(min_val, max_val), 1)
                result_str = str(res_val)
            else:
                result_str = random.choice(exam_info[2])
            if hosp['exit'] is not None:
                date = hosp['entry'] + timedelta(days=random.randint(0, (hosp['exit'] - hosp['entry']).days))
            else:
                date = hosp['entry'] + timedelta(days=random.randint(0, (today - hosp['entry']).days))
            hosp_id = hosp['hosp_id']
            doc_amka = random.choice(doctor_amkas)
            cost = random.randint(15, 100)
            date_str = date.strftime('%Y-%m-%d')
            all_lab_exams.append({
                'type': exam_name,
                'date': date_str,
                'result': result_str,
                'unit': unit,
                'cost': cost,
                'hosp_id': hosp_id,
                'doc_amka': doc_amka
            })

    all_lab_exams.sort(key=lambda x: x['date'])

    for i, h in enumerate(all_lab_exams):
        h['lab_id'] = i + 1
        line = f"('{h['type']}', '{h['date']}', '{h['result']}', '{h['unit']}', {h['cost']}, {h['hosp_id']}, '{h['doc_amka']}')"
        if i == len(all_lab_exams) - 1:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    # evaluation

    f.write("INSERT INTO `Evaluation` (`nursing_care`, `Clean`, `Food`, `TotalExperience`, `Hospitalization_hosp_id`) VALUES\n")

    eval_lines = []
    hosp_to_eval = {}
    eval_counter = 1

    for i, hosp in enumerate(all_hospitalizations):
        if hosp['exit'] is None:
            continue
        hosp_to_eval[hosp['hosp_id']] = eval_counter
        eval_counter += 1
        nursing = random.randint(1, 5)
        clean = random.randint(1, 5)
        food = random.randint(1, 5)
        total = random.randint(1, 5)
        eval_lines.append(f"({nursing}, {clean}, {food}, {total}, {hosp['hosp_id']})")

    f.write(",\n".join(eval_lines) + ";\n\n")

    # medical procedures

    f.write("INSERT INTO `Medical_Procedures` (`name`, `category`, `duration`, `cost`, `start_time`, `end_time`, `ROOM_room_id`, `DocInCharge_id`, `Hospitalization_hosp_id`) VALUES\n")

    procedures_catalog = [
        ('Σκωληκοειδεκτομή',                      'Surgery',  60,  800.00),
        ('Λαπαροσκοπική Χολοκυστεκτομή',           'Surgery',  90, 1200.00),
        ('Καισαρική Τομή',                          'Surgery',  50, 1000.00),
        ('Αρθροπλαστική Γόνατος',                   'Surgery', 150, 3500.00),
        ('Αρθροπλαστική Ισχίου',                    'Surgery', 180, 4000.00),
        ('Εγχείρηση Καταρράκτη',                    'Surgery',  40,  600.00),
        ('Θυρεοειδεκτομή',                          'Surgery', 120, 1500.00),
        ('Μαστεκτομή',                              'Surgery', 150, 2000.00),
        ('Κήλη (Πλαστική Αποκατάσταση)',             'Surgery',  75,  900.00),
        ('Αορτοστεφανιαία Παράκαμψη (Bypass)',       'Surgery', 240, 8000.00),
        ('Γαστροσκόπηση',                           'Diagnostic',  30,  150.00),
        ('Κολονοσκόπηση',                           'Diagnostic',  45,  200.00),
        ('Βρογχοσκόπηση',                           'Diagnostic',  40,  250.00),
        ('Βιοψία Ήπατος',                           'Diagnostic',  45,  300.00),
        ('Οσφυονωτιαία Παρακέντηση',                'Diagnostic',  30,  180.00),
        ('Στεφανιογραφία',                          'Diagnostic',  60,  600.00),
        ('Βιοψία Μυελού των Οστών',                 'Diagnostic',  40,  350.00),
        ('Αγγειοπλαστική (Μπαλονάκι/Stent)',         'Therapy',  90, 2500.00),
        ('Αιμοκάθαρση',                             'Therapy', 240,  150.00),
        ('Χημειοθεραπεία (Συνεδρία)',               'Therapy', 120,  400.00),
        ('Ακτινοθεραπεία (Συνεδρία)',               'Therapy',  20,  100.00),
        ('Μετάγγιση Αίματος',                       'Therapy',  90,  120.00),
        ('Εξωσωματική Λιθοτριψία',                  'Therapy',  60,  500.00),
        ('Καθαρισμός / Συρραφή Τραύματος',          'Therapy',  30,   80.00),
    ]

    room_schedule = {}
    doc_schedule  = {}
    proc_teams = []
    proc_lines = []
    med_id = 0

    for i, hosp in enumerate(all_hospitalizations):
        is_there_proc = random.choices([True, False], weights=[25, 75], k=1)[0]
        if not is_there_proc:
            continue
        number_of_proc = random.randint(1, 2)
        for j in range(number_of_proc):
            med_id += 1
            chosen_procedure = random.choice(procedures_catalog)
            proc_name     = chosen_procedure[0]
            proc_category = chosen_procedure[1]
            proc_duration = chosen_procedure[2]
            proc_cost     = chosen_procedure[3]
            hosp_id = hosp['hosp_id']
            if hosp['exit'] is not None:
                date = hosp['entry'] + timedelta(days=random.randint(0, (hosp['exit'] - hosp['entry']).days))
            else:
                date = hosp['entry'] + timedelta(days=random.randint(0, (today - hosp['entry']).days))
            random_time = time(random.randint(0, 23), random.randint(0, 59), random.randint(0, 59))
            date = datetime.combine(date, random_time)
            end_time = date + timedelta(minutes=proc_duration)
            doc_in_charge = random.choice(doctor_amkas)
            while cannot_assign_room_or_doc(doc_schedule, doc_in_charge, date, end_time):
                doc_in_charge = random.choice(doctor_amkas)
            doc_schedule.setdefault(doc_in_charge, []).append((date, end_time))
            room_id = random.randint(1, 10)
            while cannot_assign_room_or_doc(room_schedule, room_id, date, end_time):
                room_id = random.randint(1, 10)
            room_schedule.setdefault(room_id, []).append((date, end_time))
            for k in range(random.randint(1, 2)):
                doc_amka = random.choice(doctor_amkas)
                while cannot_assign_room_or_doc(doc_schedule, doc_amka, date, end_time):
                    doc_amka = random.choice(doctor_amkas)
                doc_schedule.setdefault(doc_amka, []).append((date, end_time))
                proc_teams.append({'amka': doc_amka, 'proc': med_id})
            for k in range(random.randint(2, 3)):
                nurse_amka = random.choice(nurse_amkas)
                proc_teams.append({'amka': nurse_amka, 'proc': med_id})
            start_str = date.strftime('%Y-%m-%d %H:%M:%S')
            end_str   = end_time.strftime('%Y-%m-%d %H:%M:%S')
            proc_lines.append(f"('{proc_name}', '{proc_category}', {proc_duration}, {proc_cost}, '{start_str}', '{end_str}', {room_id}, '{doc_in_charge}', {hosp_id})")

    f.write(",\n".join(proc_lines) + ";\n\n")

    # procedure team

    f.write("INSERT INTO `Procedure_Team` (`Medical_Procedures_procedure_id`, `PERSONNEL_AMKA`) VALUES\n")

    for i, h in enumerate(proc_teams):
        line = f"({h['proc']}, '{h['amka']}')"
        if i == len(proc_teams) - 1:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")

    # prescription

    f.write("INSERT INTO `Perscription` (`PERSONNEL_AMKA`, `Patient_AMKA`, `DRUG_drug_id`, `start_date`, `end_date`, `dosage`, `frequency`, `Hospitalization_hosp_id`) VALUES\n")

    dosages = [
        "500 mg", "1000 mg", "250 mg", "20 mg", "40 mg", "100 mg",
        "1 χάπι", "2 χάπια", "1 κάψουλα", "1/2 χάπι",
        "5 ml", "10 ml", "15 ml",
        "1 αμπούλα", "1 flacon",
        "1 φακελάκι", "2 ψεκασμοί", "1 σταγόνα"
    ]

    frequencies = [
        "1x / ημέρα",
        "2x / ημέρα (Πρωί - Βράδυ)",
        "3x / ημέρα (Ανά 8 ώρες)",
        "4x / ημέρα (Ανά 6 ώρες)",
        "Ανά 12 ώρες",
        "Εφάπαξ",
        "PRN (Επί πόνου)",
        "Πριν τον ύπνο",
        "Μετά το φαγητό",
        "Ανά 24 ώρες"
    ]

    hosp_to_doctor = {}
    line_presc = []

    for i, hosp in enumerate(all_hospitalizations):
        hosp_id = hosp['hosp_id']
        number_of_presc = random.randint(1, 3)
        for j in range(number_of_presc):
            doc_amka = random.choice(doctor_amkas)
            pat_amka = hosp['amka']
            safe_drugs = [
                drug_id for drug_id, subs in drug_substances.items()
                if not subs & patient_allergies[pat_amka]
            ]
            drug_id = random.choice(safe_drugs)
            if hosp['exit'] is not None:
                start_date = hosp['entry'] + timedelta(days=random.randint(0, (hosp['exit'] - hosp['entry']).days))
                end_date = start_date + timedelta(days=max(1, random.randint(0, (hosp['exit'] - start_date).days)))
                hosp_to_doctor.setdefault(hosp_id, []).append(doc_amka)
            else:
                start_date = hosp['entry'] + timedelta(days=random.randint(0, (today - hosp['entry']).days))
                end_date = start_date + timedelta(days=max(1, random.randint(0, (today - start_date).days)))
            dosage = random.choice(dosages)
            frequency = random.choice(frequencies)
            line_presc.append(f"('{doc_amka}', '{pat_amka}', {drug_id}, '{start_date}', '{end_date}', '{dosage}', '{frequency}', {hosp_id})")

    f.write(",\n".join(line_presc) + ";\n\n")

    # doctor evaluation

    f.write("INSERT INTO `DoctorEvaluation` (`MedCareQuality`, `eval_id`, `DOCTOR_PERSONNEL_AMKA`) VALUES\n")

    eval_doc_lines = []

    for hosp_id, eval_id in hosp_to_eval.items():
        doctors_for_hosp = hosp_to_doctor.get(hosp_id, doctor_amkas)
        doc_amka = random.choice(doctors_for_hosp)
        quality = random.randint(1, 5)
        eval_doc_lines.append(f"({quality}, {eval_id}, '{doc_amka}')")

    f.write(",\n".join(eval_doc_lines) + ";\n\n")
