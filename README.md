# CRC Liquid-Biopsy Worked Examples

Code and data for the two worked examples in:

> Nakata R. *Multi-Modal Liquid Biopsy for Early Cancer Detection: Integrating Tumor Microbiome with Circulating Cell-Free DNA.*

The repository builds two separate colorectal cancer (CRC) vs. control classifiers from public data. One uses stool microbiome profiles and the other uses plasma cfDNA fragment lengths. The two models use different patients, so their AUCs should not be compared directly. Both are discrimination examples (CRC vs. control) and do not measure early-stage sensitivity.

| | Part A: stool microbiome | Part B: plasma cfDNA fragmentomics |
|---|---|---|
| Data | curatedMetagenomicData, 7 cohorts | FinaleDB, 3 studies |
| Samples | 648 (314 CRC, 334 control); adenomas excluded | 128 (48 CRC, 80 healthy) |
| Features | 4,771 species, log10(rel. abundance + 1e-6) | 8 fragment-length summary statistics (80–400 bp) |
| Model | Random forest (500 trees, min leaf 5, balanced) | Logistic regression; random forest for comparison |
| Validation | Stratified 10-fold CV, out-of-fold predictions | Stratified 10-fold CV, out-of-fold predictions |
| Result | AUC 0.819 (95% CI 0.788–0.848); per-cohort 0.614–0.889 | Pooled LR AUC 0.973 (0.946–0.993); single-lab (Cristiano 2019) AUC 0.952 (0.907–0.986) |

Confidence intervals come from 1,000 bootstrap resamples of the out-of-fold predictions. Random seeds are fixed (42) throughout.

### Note on the cfDNA comparison

All 80 healthy controls come from Cristiano et al. 2019. Of the 48 CRC cases, 27 are from Cristiano 2019, 18 from Sun et al. 2019 and 3 from Snyder et al. 2016. The pooled AUC therefore mixes disease differences with lab and processing differences. The Cristiano-only result (27 CRC vs. 80 healthy, one lab) is the cleaner estimate. Section B.8 of the notebook breaks the fragment features down by study.

## Repository contents

```
notebooks/CRC_RealData.ipynb                 main analysis (Parts A and B)
data/crc_species_abundance.csv               species x sample relative abundances (Part A)
data/crc_sample_metadata.csv                 sample metadata for Part A
data/finaledb/*.insert_size_metrics.txt      cached FinaleDB fragment-length histograms
data/finaledb/finaledb_sample_manifest.csv   metadata for all cached histograms
data/finaledb/paper_sample_selection_128.csv the exact 128 samples used in Part B
figures/                                     every figure panel, 300-dpi PNG
prepare_microbiome_data.R                    rebuilds the Part A CSVs from curatedMetagenomicData
requirements.txt                             pinned Python package versions
```

### How the 128 cfDNA samples were chosen

All 48 FinaleDB CRC plasma samples were used, plus 80 healthy plasma samples drawn at random from the 262 Cristiano 2019 controls, using `np.random.seed(42)`. The exact list is saved in `paper_sample_selection_128.csv`, so the analysis does not depend on the live FinaleDB website. The FinaleDB cache also holds samples that this analysis does not use, such as Jiang et al. 2015 healthy controls.

## Reproducing the results

```bash
conda create -n crc python=3.12
conda activate crc
pip install -r requirements.txt notebook nbconvert
jupyter nbconvert --to notebook --execute --inplace notebooks/CRC_RealData.ipynb
```

Run this from the repository root. The run takes a few minutes and writes every figure to `figures/`. Random-forest results can differ in the third decimal place across scikit-learn versions and operating systems. The values above were produced on macOS with the versions pinned in `requirements.txt` (scikit-learn 1.8.0).

## Versions

- `v1.0-submitted`: the code as it was when the manuscript was first submitted.
- `v1.1-revision`: the version that matches the revised manuscript.

## Data sources

- **curatedMetagenomicData.** Pasolli E, Schiffer L, Manghi P, et al. *Nature Methods* 14, 1023–1024 (2017).
- **Microbiome cohorts.** Zeller et al. 2014; Feng et al. 2015; Yu et al. 2017; Vogtmann et al. 2016; Hannigan et al. 2018; Thomas et al. 2019 (ThomasAM_2018a/b).
- **FinaleDB.** Zheng H, Zhu MS, Liu Y. *Bioinformatics* 37, 2502–2503 (2021).
- **Cristiano S, Leal A, Phallen J, et al.** *Nature* 570, 385–389 (2019). doi:10.1038/s41586-019-1272-6
- **Sun K, Jiang P, Cheng SH, et al.** *Genome Research* 29, 418–427 (2019). doi:10.1101/gr.242719.118
- **Snyder MW, Kircher M, Hill AJ, Daza RM, Shendure J.** *Cell* 164, 57–68 (2016). doi:10.1016/j.cell.2015.11.050
- **Benchmark.** Thomas AM, Manghi P, Asnicar F, et al. *Nature Medicine* 25, 667–678 (2019) reports a mean cross-validation AUC of about 0.84 on largely overlapping microbiome data.

## Acknowledgement of tools

Parts of the code and repository were organized with assistance from an AI tool, with the approval of the author's research mentor. All code was reviewed and run by the author.
