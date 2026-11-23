# Étude de Cas 02 : DataCo Industrial Hydraulics Distribution
## Fiabilité des livraisons (OTIF), blocages en entrepôt et marge nette réelle

**Cours :** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Atelier :** Atelier #1 — Charte de projet et cadrage des objectifs  
**Langue :** Français (`FR`)

---

## 1. Contexte de l'entreprise et du secteur

### 1.1 Le marché européen de l'hydraulique industrielle (B2B)
Les usines, les mines et les fabricants de machines lourdes ont besoin chaque jour de pompes hydrauliques haute pression, de vannes de contrôle, de vérins, de filtres et de tuyaux (flexibles) haute pression. Si un tuyau éclate ou si une vanne tombe en panne, toute une machine d'usine s'arrête en quelques secondes.

Pour éviter ces arrêts coûteux, les clients signent des contrats stricts (**SLA — Service Level Agreement**) : la norme exige au moins **92,0 % de livraisons à l'heure et complètes (OTIF >= 92,0 %)**. En cas de retard ou de quantité manquante, l'entreprise paie automatiquement une **pénalité financière**.

### 1.2 Profil de l'entreprise : DataCo Industrial Hydraulics Distribution
**DataCo Industrial Hydraulics Distribution Sp. z o.o.** gère un réseau européen de 4 entrepôts. Elle livre **12 produits (SKU)** à **16 grands clients B2B**, classés en 4 segments :
* **`VIP Heavy OEM` :** Grandes usines avec de gros volumes et de fortes remises contractuelles.
* **`Mining & Tunneling` :** Entreprises minières ayant besoin de pièces robustes et de livraisons urgentes.
* **`Press Builder OEM` :** Constructeurs de machines achetant des pompes et vannes de précision.
* **`Regional MRO` :** Équipes locales de maintenance commandant des filtres et pièces de rechange.

---

## 2. Réseau logistique et catalogue de produits

### 2.1 Quatre entrepôts (Hubs) et transporteurs (`Warehouses` & `Carrier_SLA_Policies`)

| Entrepôt (Hub) | Zone desservie | Activité spéciale / Risque de retard |
| :--- | :--- | :--- |
| **`HUB-Central-Frankfurt`** | Allemagne, Autriche, Suisse & Europe de l'Ouest | Préparation rapide et exportation de pompes et vannes |
| **`HUB-Poland-Wroclaw`** | Usines automobiles de Basse-Silésie | Envoi de palettes mixtes et pièces de rechange |
| **`HUB-South-Katowice`** | Industrie lourde de Haute-Silésie | Contient le **banc d'essai haute pression obligatoire** pour tester les tuyaux avant l'envoi ! |
| **`HUB-North-Gdansk`** | Corridor portuaire Baltique & Nordique | Plateforme régionale pour vérins, vannes et maintenance (MRO) |

Chaque entrepôt travaille avec quatre transporteurs externes (3PL : **`DHL_EXPRESS`**, **`DB_SCHENKER`**, **`UPS_FREIGHT`**, **`RABEN_LOGISTICS`**) selon 4 niveaux de rapidité :
* **`Same Day` (SLA `1j`)** et **`First Class` (SLA `2j`)** — livraisons urgentes très chères avec fortes pénalités en cas de retard.
* **`Second Class` (SLA `4j`)** et **`Standard Class` (SLA `6j`)** — réapprovisionnement normal planifié.

### 2.2 Catalogue produits (onglet `Products`, 5 catégories / 12 SKU)
1. **Hydraulic Pumps** *(Pompes hydrauliques : prix élevé, bonne marge brute)*
2. **Control Valves** *(Vannes de contrôle de précision)*
3. **Actuators & Cylinders** *(Vérins et équipements lourds)*
4. **High-Pressure Hoses** *(Tuyaux haute pression : prix plus bas, doivent passer un test de pression obligatoire avant la sortie d'entrepôt)*
5. **Filtration & Conditioning** *(Cartouches de filtres pour la maintenance)*

---

## 3. Problèmes principaux de l'entreprise

Sur la période de **60 jours**, la direction fait face à trois grands problèmes :
1. **Crise OTIF face à l'objectif de 92,0 % :** Le taux OTIF du réseau est bien en dessous de **92,0 %**, ce qui coûte environ **100 000 €** de pénalités de retard en deux mois. Les moyennes mensuelles cachent *où* naît le retard : est-ce sur la route pendant le transport, ou en attente à l'intérieur de l'entrepôt (**`warehouse_dwell_hours`**) avant le départ du camion ?
2. **De grosses ventes qui cachent des pertes :** Les commerciaux voient un grand chiffre d'affaires sur les comptes VIP. Mais l'ERP calcule la marge **avant** d'enlever les vrais coûts de transport urgent et les pénalités de retard. De grosses remises (**15–23 %**) + un transport urgent sur des articles moins chers peuvent donner une **marge nette négative** !
3. **Piège du double comptage (Fan-Out) :** Chaque commande contient en moyenne **~1,8 ligne de produit** (`~8 450+` lignes propres pour `~4 770+` commandes). Le coût de transport (`freight_cost_eur`) et les pénalités (`sla_penalty_eur`) sont donnés pour toute la commande, pas par produit. Si vous copiez ces coûts sur chaque ligne sans les partager selon la part de chaque ligne dans le chiffre d'affaires de la commande (**répartition proportionnelle / pro-rata**), vous comptez les frais logistiques presque deux fois !

---

## 4. Deux points de vue différents (Track A vs. Track B)

### 🅰️ Perspective A : VP Commercial & Contrôle des prix
* **Objectif principal :** Protéger le vrai bénéfice net (`Chiffre d'affaires net - Coût produit (COGS) - Transport partagé - Pénalités partagées`), limiter les remises trop élevées et trouver les couples **`Segment × Catégorie`** qui perdent de l'argent.
* **Hors périmètre (Ne veut PAS voir) :** Les journaux d'attente du banc d'essai ou les heures de scan des camions.

### 🅱️ Perspective B : Directeur Supply Chain & Logistique
* **Objectif principal :** Remonter l'**OTIF >= 92,0 %**, séparer les problèmes de délai (*On-Time*) des quantités manquantes (*In-Full*), mesurer le temps d'attente en entrepôt (`warehouse_dwell_hours` = `DISPATCHED_FROM_HUB - ORDER_CONFIRMED`), comparer les hubs et transporteurs 3PL, et réduire les pénalités SLA.
* **Hors périmètre (Ne veut PAS voir) :** Les commissions des vendeurs ou les grilles de remises commerciales.

---

## 5. Données disponibles sur 60 jours (`data/bronze/`)

La simulation couvre **60 jours d'activité** (`2026-10-01` – `2026-11-29`) dans trois fichiers :

1. **`order_items_trans.csv` (Lignes de commandes ERP, 8 623 lignes) :** `order_id`, `order_date`, `customer_id`, `product_id`, `ordered_qty`, `delivered_qty`, `unit_price_eur`, `discount_rate`. *(Note : les données logistiques viennent de `shipment_events.json` au niveau commande ; partager les frais et pénalités entre les lignes peut créer de petits écarts d'arrondi d'environ ~0,05 €).*
   * *Erreurs à nettoyer :* `~85` lignes en double, dates mélangées entre format ISO (`YYYY-MM-DD`) et européen (`%d/%m/%Y %H:%M` — attention à ne pas inverser le jour et le mois !), remises négatives (`-0.05`), remises écrites en pourcentage (`15.0` au lieu de `0.15`), faux produit (`SKU-GHOST-99`), livraisons impossibles (`delivered_qty > ordered_qty`), et prix `unit_price_eur` manquants (`NaN` — à calculer via le catalogue `standard_cost_eur * list_markup`, sans supprimer les lignes !).
2. **`shipment_events.json` (Étapes entrepôt et transporteurs, 22 746 événements) :** `event_id`, `timestamp`, `event_type` (`ORDER_CONFIRMED`, `PICKING_COMPLETED`, `DISPATCHED_FROM_HUB`, `IN_TRANSIT_HUB_SCAN`, `DELIVERED_AT_GATE`, `DELIVERY_EXCEPTION`), `order_id`, `warehouse_hub`, `shipping_mode`, `carrier_code`, `scheduled_shipping_days`, `freight_cost_eur`, `sla_penalty_eur`.
   * *Erreurs à nettoyer :* Espaces en trop (`"Standard Class  "`) qui cassent les catégories, et fausses anomalies `DELIVERY_EXCEPTION` de `145 jours` qui faussent les moyennes.
3. **`master_catalog.xlsx` (Fichier de référence MDM, 4 onglets) :** `Products`, `Customers`, `Warehouses`, et `Carrier_SLA_Policies`.

---

## 6. Travail demandé pour l'Atelier #1
Complétez [`project_charter_template.md`](project_charter_template.md) avec :
1. Votre rôle (**Perspective A** ou **B**) ;
2. Votre plan de qualité des données (`Data Quality Gate 1` / `Proces DQ Gate 1` : suppression des doublons, lecture des dates mixtes, correction des remises, quarantaine, répartition pro-rata) ;
3. Votre évaluation **Gartner ITScore** (`As-Is` vs `To-Be`) ;
4. **3 questions SMART-BI mesurables**.
