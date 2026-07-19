# CRC Liquid-Biopsy Pipeline

This folder contains a complete, runnable tutorial that builds **two independent cancer classifiers** from real public data:

- **Part A** — gut microbiome (stool species) → CRC vs healthy, AUC ≈ 0.82
- **Part B** — cfDNA fragment lengths (blood plasma) → CRC vs healthy, AUC ≈ 0.97

All analyses are conducted on real-world, publicly available datasets; no simulations were used in this pipeline.

### Repository Contents

- **`notebooks/CRC_RealData.ipynb`** — The primary analysis pipeline for data processing, model training, and performance evaluation.
- **`prepare_microbiome_data.R`** — R script utilized to generate the microbiome abundance matrices from raw curatedMetagenomicData sources.

- **`data/`** Directory containing the necessary inputs, including processed microbiome matrices and cached cfDNA fragment metrics.
- **`data/finaledb//`** Directory containing the cached cfDNA fragment-length histograms (344 samples).
---

### Technical SetUp & Reproducibility

## 1. Dependencies

Ensure a Python 3.10+ environment is active. Install required packages via the first cell of the main notebook, or execute: 
pip install pandas numpy matplotlib seaborn scikit-learn requests

## 2. Execution: 

Launch Jupyter from the project root directory: 
jupyter notebook notebooks/CRC_RealData.ipynb

---

## Data sources & citations

- **curatedMetagenomicData** — Pasolli E, Schiffer L, Manghi P, et al. *Nature Methods* 14, 1023–1024 (2017). Bioconductor package; we fetched the 7 CRC cohort `.rda` files directly from `https://mghp.osn.xsede.org/bir190004-bucket01/ExperimentHub/curatedMetagenomicData/`.
- **CRC meta-analysis benchmark** — Thomas AM, Manghi P, Asnicar F, et al. *Nature Medicine* 25, 667–678 (2019). Reports avg cross-validation AUC ≈ 0.84 on this same data.
- **FinaleDB** — Zheng H, Zhu MS, Liu Y. *Bioinformatics* 37, 2502–2503 (2021). cfDNA fragment data at `http://finaledb.research.cchmc.org/`.
- **cfDNA fragmentomics canonical paper** — Cristiano S, Leal A, Phallen J, et al. *Nature* 570, 385–389 (2019).
