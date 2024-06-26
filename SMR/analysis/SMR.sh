#!/bin/bash
set -e

# ------------------------------------------------------------------------
#  Input
# ------------------------------------------------------------------------
CONFIG=$1
SCRIPT_DIR=`yq .script.path "${CONFIG}"`
GWAS_DATA=`yq .input.gwas "${CONFIG}"`
trait_name=`yq .input.trait "${CONFIG}"`
OUTPUT=`yq .input.output "${CONFIG}"`

mkdir -p ${OUTPUT}/SMR/detail
mkdir -p ${OUTPUT}/SMR/summary
mkdir -p ${OUTPUT}/SMR/smr

# ------------------------------------------------------------------------
#  SMR analysis
# ------------------------------------------------------------------------

SMR=`yq .software.smr "${CONFIG}"`
REFERENCE_bld=`yq .reference.reference_bld "${CONFIG}"`
QTL_list=`yq .smr.QTL_list "${CONFIG}"`

# ----
qtl_i=${SLURM_ARRAY_TASK_ID}
# **** Here we take qtl as a unit.
# 1-78: eQTL
# 79-129: sQTL
# 130-131: mQTL
# 132-136: pQTL

qtl_name=`head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $1}'`
qtl_data=`head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $2}'`
qtl_chr=`head -n ${qtl_i} ${QTL_list} | tail -n1 | awk -F "\t" '{print $3}'`



for i in $(seq 1 22); do

    if [ "$qtl_chr" = "TRUE" ]; then
        QTL_data="${qtl_data}${i}"
    else
        QTL_data="${qtl_data}"
    fi

    "${SMR}" --bld "${REFERENCE_bld}_chr${i}" \
        --gwas-summary "${GWAS_DATA}" \
        --beqtl-summary "${QTL_data}" \
        --maf 0.01 \
        --smr-multi \
        --thread-num 4 \
        --out "${OUTPUT}/SMR/detail/${trait_name}_${qtl_name}_chr${i}"

done


awk 'NR==1 || FNR>1' ${OUTPUT}/SMR/detail/${trait_name}_${qtl_name}_chr*.msmr > ${OUTPUT}/SMR/summary/${trait_name}_${qtl_name}_chrALL.msmr

# rm ${OUTPUT}/SMR/detail/${trait_name}_${qtl_name}_chr*.

