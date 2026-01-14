import csv
import os
from collections import defaultdict

# --- BASE DIR (dossier du script) ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

ALIMENTS_FILE = os.path.join(BASE_DIR, "aliments.csv")
RECETTE_ALIMENT_FILE = os.path.join(BASE_DIR, "recetteAliment.csv")
OUTPUT_FILE = os.path.join(BASE_DIR, "aliments_updated.csv")


# --- UNIT GROUPS ---
POIDS = {"g", "kg", "mg", "gramme", "grammes"}
VOLUME = {"ml", "cl", "l", "litre", "litres"}
UNITAIRE = {"pcs", "pc", "piece", "pieces"}
MENAGER = {"gousse", "gousses", "tranche", "tranches", "pincée"}

def normalize(unit):
    return unit.strip().lower()

# --- 1. collect units per aliment ---
units_by_aliment = defaultdict(set)

with open(RECETTE_ALIMENT_FILE, newline='', encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        id_aliment = row["id_aliment"]
        unit = normalize(row["unite"])
        if unit:
            units_by_aliment[id_aliment].add(unit)

# --- 2. infer type ---
def infer_type(units):
    u = set(units)

    if u & VOLUME and not u & (POIDS | UNITAIRE):
        return "VOLUME"

    if u & UNITAIRE and u & POIDS:
        return "MIXTE"

    if u & UNITAIRE:
        return "UNITAIRE"

    if u & (POIDS | MENAGER):
        return "POIDS"

    return "INCONNU"

# --- 3. update aliments.csv ---
with open(ALIMENTS_FILE, newline='', encoding="utf-8") as f:
    aliments = list(csv.DictReader(f))

for aliment in aliments:
    aid = aliment["id_aliment"]
    units = units_by_aliment.get(aid, [])
    aliment["type_mesure"] = infer_type(units)

# --- 4. write output ---
with open(OUTPUT_FILE, "w", newline='', encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=aliments[0].keys())
    writer.writeheader()
    writer.writerows(aliments)

print("✅ aliments_updated.csv généré")
