#!/bin/bash

# **********
# input ----
# **********

# 1. GWAS data: ../../data/demo/GWAS.tar.gz
# 2. xQTL data: ../../data/demo/xQTL_archive.tar.gz
# 3. Gene annotation: ../../data/demo/gene_annotation.txt
# 4. SMR results: ../../data/demo/SMR_results.msmr

# **********
# output ----
# **********

# 5. plot data (left): ../../data/demo/SMR_plot.txt

Rscript ./SMR_results_locus.R  \
	../../data/demo/SMR_results.msmr \
	../../data/demo/SMR_plot.txt



