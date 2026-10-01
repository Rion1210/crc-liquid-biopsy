#!/usr/bin/env Rscript
# prepare_microbiome_data.R
# ----------------------------------------------------------------------------
# Builds crc_species_abundance.csv + crc_sample_metadata.csv from public
# curatedMetagenomicData ExperimentHub .rda files.
#
# Does NOT require the curatedMetagenomicData R package — those .rda files are
# vanilla Biobase::ExpressionSet objects, so base R can load them. This avoids
# the heavy install / rbiom dyn-load issues.
#
# Requires: Biobase (Bioconductor), which most R users already have.
#   BiocManager::install("Biobase")
# ----------------------------------------------------------------------------

suppressPackageStartupMessages(library(Biobase))

BASE <- "https://mghp.osn.xsede.org/bir190004-bucket01/ExperimentHub/curatedMetagenomicData"
out_dir <- "cmd_data"
dir.create(out_dir, showWarnings = FALSE)

# Map: friendly study name -> remote .rda path
files <- list(
  ZellerG_2014    = "ZellerG_2014.metaphlan_bugs_list.stool.rda",
  FengQ_2015      = "20170526.FengQ_2015.metaphlan_bugs_list.stool.rda",
  YuJ_2015        = "20170526.YuJ_2015.metaphlan_bugs_list.stool.rda",
  VogtmannE_2016  = "20170526.VogtmannE_2016.metaphlan_bugs_list.stool.rda",
  HanniganGD_2017 = "20171006.HanniganGD_2017.metaphlan_bugs_list.stool.rda",
  ThomasAM_2018a  = "20181025/20181025.ThomasAM_2018a.metaphlan_bugs_list.stool.rda",
  ThomasAM_2018b  = "20190422/20190422.ThomasAM_2018b.metaphlan_bugs_list.stool.rda"
)

# Download
for(study in names(files)){
  local <- file.path(out_dir, basename(files[[study]]))
  if(!file.exists(local) || file.info(local)$size < 1000){
    cat("Downloading", study, "...\n")
    download.file(paste0(BASE, "/", files[[study]]), local, mode = "wb", quiet = TRUE)
  }
}

# Load + extract
load_eset <- function(local, study){
  e <- new.env(); load(local, envir = e)
  eset <- get(ls(envir = e)[1], envir = e)
  list(study = study, ab = exprs(eset), pd = pData(eset))
}

# Harmonize phenotype across cohorts (older format = ZellerG; newer = study_condition)
harmonize <- function(d){
  pd <- d$pd; n <- nrow(pd)
  bmi <- if("BMI" %in% colnames(pd)) pd$BMI else if("bmi" %in% colnames(pd)) pd$bmi else rep(NA_real_, n)
  if(d$study == "ZellerG_2014"){
    sc <- ifelse(pd$group == "control", "control",
          ifelse(pd$disease %in% c("large_adenoma","small_adenoma"), "adenoma",
          ifelse(pd$disease == "cancer", "CRC", NA_character_)))
  } else {
    sc <- pd$study_condition
  }
  out <- data.frame(
    sample_id = rownames(pd), study_name = d$study,
    study_condition = sc,
    age = if("age" %in% colnames(pd)) pd$age else NA,
    gender = if("gender" %in% colnames(pd)) pd$gender else NA,
    country = if("country" %in% colnames(pd)) pd$country else NA,
    bmi = bmi, stringsAsFactors = FALSE)
  out[!is.na(out$study_condition) & out$study_condition %in% c("control","adenoma","CRC"), ]
}

# species rows only (have |s__ but not |t__)
filter_species <- function(ab){
  rn <- rownames(ab)
  ab[grepl("\\|s__", rn) & !grepl("\\|t__", rn), , drop = FALSE]
}

harm <- lapply(names(files), function(s){
  d <- load_eset(file.path(out_dir, basename(files[[s]])), s)
  pd <- harmonize(d); ab <- filter_species(d$ab)
  keep <- intersect(colnames(ab), pd$sample_id)
  ab <- ab[, keep, drop = FALSE]
  pd <- pd[match(colnames(ab), pd$sample_id), ]
  list(study = s, ab = ab, pd = pd)
})

# Union species, samples; fill zeros
all_species <- unique(unlist(lapply(harm, function(h) rownames(h$ab))))
all_samples <- unlist(lapply(harm, function(h) colnames(h$ab)))
M <- matrix(0, nrow = length(all_species), ncol = length(all_samples),
            dimnames = list(all_species, all_samples))
for(h in harm) M[rownames(h$ab), colnames(h$ab)] <- as.matrix(h$ab)
# Shorten species names to s__<species>
rownames(M) <- sub(".*\\|s__", "s__", rownames(M))

all_meta <- do.call(rbind, lapply(harm, function(h) h$pd))

write.csv(M, "crc_species_abundance.csv", row.names = TRUE)
write.csv(all_meta, "crc_sample_metadata.csv", row.names = FALSE)

cat("\nWrote:\n")
cat("  crc_species_abundance.csv  (", nrow(M), "species x", ncol(M), "samples)\n")
cat("  crc_sample_metadata.csv    (", nrow(all_meta), "samples )\n")
print(table(all_meta$study_condition))
