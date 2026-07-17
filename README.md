# CRC Liquid-Biopsy Tutorial — for Indigo

This folder contains a complete, runnable tutorial that builds **two independent cancer classifiers** from real public data:

- **Part A** — gut microbiome (stool species) → CRC vs healthy, AUC ≈ 0.82
- **Part B** — cfDNA fragment lengths (blood plasma) → CRC vs healthy, AUC ≈ 0.97

Everything is real data downloaded from public databases. No simulations.

---

## How to run it

### 1. Install Python (one-time)

If you don't already have Python 3.10+ with Jupyter, the easiest option is **Anaconda** or **Miniforge** — both bundle Python, Jupyter, and most scientific packages. Download from https://www.anaconda.com/download or https://github.com/conda-forge/miniforge.

### 2. Open the notebook

```bash
cd /media/chew/Elements1/Chew/Rion/CRC_liquid_biopsy_Indigo
jupyter notebook CRC_RealData_Indigo.ipynb
```

(or open it in VS Code, JupyterLab, or any notebook environment of your choice)

### 3. Run cells top-to-bottom

The first code cell auto-installs anything missing (`pandas`, `numpy`, `matplotlib`, `seaborn`, `scikit-learn`, `requests`). Then it loads the microbiome CSVs from this folder and downloads the cfDNA files on demand.

**Good news**: the cfDNA files are already cached in `data/finaledb/` (344 samples). The notebook will skip downloads and run immediately.

---

## What's in this folder

### Main deliverables
- **`CRC_RealData_Indigo.ipynb`** — the student notebook (33 cells, runs end-to-end)
- **`CRC_RealData_Report.html`** — results summary with all figures embedded (open in any browser)
- **`prepare_microbiome_data.R`** — R script to regenerate the microbiome CSVs from scratch (only needed if you want fresh data)

### Data files the notebook reads
- `crc_species_abundance.csv` — microbiome relative-abundance matrix (4,771 species × 749 samples, 8.5 MB)
- `crc_sample_metadata.csv` — sample metadata for those 749 stool samples
- `data/finaledb/` — 344 Picard `insert_size_metrics.txt` files (cfDNA fragment-length histograms)

### Figures (also in the HTML report)
- `crc_microbiome_real_roc.png` — pooled + per-cohort ROC for microbiome classifier
- `crc_microbiome_real_features.png` — top 20 species driving classification
- `crc_microbiome_real_confusion.png` — confusion matrix + per-cohort AUC bars
- `cfdna_real_fragsize.png` — fragment-size distribution per group
- `cfdna_real_classifier.png` — ROC curves + short/long ratio boxplot
- `cfdna_real_batchcheck.png` — within-study sanity check (Cristiano-only AUC = 0.951)

### Supporting CSVs (for further analysis, not needed to run the notebook)
- `crc_microbiome_real_predictions.csv` — per-sample CV predictions (microbiome)
- `crc_microbiome_real_feature_importance.csv` — full feature-importance ranking (4,771 species)
- `cfdna_real_features.csv` — per-sample fragment statistics
- `cfdna_real_predictions.csv` — per-sample CV predictions (cfDNA)
- `finaledb_sample_manifest.csv` — FinaleDB sample listing with metadata

---

## Quick reference — key results

| Modality | n samples | Model | 10-fold CV AUC |
|---|---|---|---|
| Stool microbiome (7 published cohorts) | 648 (314 CRC, 334 control) | RandomForest | 0.818 |
| Plasma cfDNA fragment lengths | 128 (48 CRC, 80 healthy) | Logistic regression | 0.972 (0.951 within-study) |

The microbiome classifier rediscovers the canonical CRC "oral-translocation" signature (*Fusobacterium nucleatum*, *Parvimonas micra*, *Peptostreptococcus stomatis*, *Gemella morbillorum*, ...). The cfDNA classifier confirms the canonical 12-bp mean-length shortening (155.6 bp in CRC vs 167.4 bp in healthy) — exactly what Cristiano et al. 2019 *Nature* reported.

---

## Troubleshooting

- **`FileNotFoundError: crc_species_abundance.csv`** → make sure Jupyter is launched from this folder, not from your home directory
- **`ModuleNotFoundError`** → the first code cell installs everything; if it failed, run `pip install pandas numpy matplotlib seaborn scikit-learn requests` in your terminal
- **`URLError` during cfDNA download** → cached files are in `data/finaledb/` so this section should not need internet; if you wiped that folder, you do need internet for the live download

---

## Data sources & citations

- **curatedMetagenomicData** — Pasolli E, Schiffer L, Manghi P, et al. *Nature Methods* 14, 1023–1024 (2017). Bioconductor package; we fetched the 7 CRC cohort `.rda` files directly from `https://mghp.osn.xsede.org/bir190004-bucket01/ExperimentHub/curatedMetagenomicData/`.
- **CRC meta-analysis benchmark** — Thomas AM, Manghi P, Asnicar F, et al. *Nature Medicine* 25, 667–678 (2019). Reports avg cross-validation AUC ≈ 0.84 on this same data.
- **FinaleDB** — Zheng H, Zhu MS, Liu Y. *Bioinformatics* 37, 2502–2503 (2021). cfDNA fragment data at `http://finaledb.research.cchmc.org/`.
- **cfDNA fragmentomics canonical paper** — Cristiano S, Leal A, Phallen J, et al. *Nature* 570, 385–389 (2019).
