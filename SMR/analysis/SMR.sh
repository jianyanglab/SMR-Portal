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
mkdir -p ${OUTPUT}/SMR/SMR_Portal

# ------------------------------------------------------------------------
#  SMR analysis
# ------------------------------------------------------------------------

SMR=`yq .software.smr "${CONFIG}"`
REFERENCE_bld=`yq .reference.reference_bld "${CONFIG}"`
QTL_list=`yq .magic.QTL_list "${CONFIG}"`

maf=`yq .smr.maf "${CONFIG}"`
peqtl_smr=`yq .smr.peqtl_smr "${CONFIG}"`
peqtl_heidi=`yq .smr.peqtl_heidi "${CONFIG}"`
batch_num=`yq .smr.batch_num "${CONFIG}"`
smr_multi_index=`yq .smr.smr_multi_index "${CONFIG}"`
smr_heidi_index=`yq .smr.heidi_index "${CONFIG}"`
magic_smr_multi_index=`yq .magic.smr_multi_index "${CONFIG}"`
magic_smr_heidi_index=`yq .magic.heidi_index "${CONFIG}"`

default_maf=0.01
default_peqtl_smr=5e-8
default_peqtl_heidi=1.57e-3
default_smr_multi_index=TRUE
default_smr_heidi_index=TRUE



if [[ -z "$maf" || "$maf" == "null" ]]; then
    maf=$default_maf
fi
if [[ -z "$peqtl_smr" || "$peqtl_smr" == "null" ]]; then
    peqtl_smr=$default_peqtl_smr
fi
if [[ -z "$peqtl_heidi" || "$peqtl_heidi" == "null" ]]; then
    peqtl_heidi=$default_peqtl_heidi
fi

# ------------------------------------------------------------------------
# run MAGIC Portal or SMR Portal analysis
run_magic_index=`yq .magic.run_magic_index "${CONFIG}"`
if [ "$run_magic_index" = "TRUE" ]; then
    echo "--------------------------- Running MAGIC Portal ---------------------------"
    smr_multi_index=$magic_smr_multi_index
    smr_heidi_index=$magic_smr_heidi_index
else
    echo "--------------------------- Running SMR Portal ---------------------------"
fi


if [[ -z "$smr_multi_index" || "$smr_multi_index" == "null" ]]; then
    smr_multi_index=$default_smr_multi_index
fi
if [[ -z "$smr_heidi_index" || "$smr_heidi_index" == "null" ]]; then
    smr_heidi_index=$default_smr_heidi_index
fi



# **** Here we take qtl as a unit. In total 230 xQTL datasets.
# 1-149: eQTL
# 150-200: sQTL
# 201-206: pQTL
# 207-217: mQTL
# 218-224: hQTL
# 225-229: caQTL

# ----
# old QTL list:
# **** Here we take qtl as a unit.
# QTL_list=`yq .smr.QTL_list "${CONFIG}"`
# 1-78: eQTL
# 79-129: sQTL
# 130-131: mQTL
# 132-136: pQTL

qtl_i=${SLURM_ARRAY_TASK_ID}

qtl_name=`awk -F "\t" -v row=$qtl_i 'NR==row {print $1}' $QTL_list`
qtl_data=`awk -F "\t" -v row=$qtl_i 'NR==row {print $2}' $QTL_list`
qtl_chr=`awk -F "\t" -v row=$qtl_i 'NR==row {print $3}' $QTL_list`


if [ -z "$qtl_name" ]; then
    echo "no QTL in line $qtl_i, skip"
    exit 0
fi

if [ ! -f "${OUTPUT}/SMR/summary/${trait_name}_${qtl_name}_chrALL.msmr" ]; then

for i in $(seq 1 22); do

    if [ "$qtl_chr" = "TRUE" ]; then
        QTL_data="${qtl_data}${i}"
    else
        QTL_data="${qtl_data}"
    fi

    
    cmd="${SMR} --bld ${REFERENCE_bld}_chr${i} \
        --gwas-summary ${GWAS_DATA} \
        --beqtl-summary ${QTL_data} \
        --probe-chr ${i} \
        --maf ${maf} \
        --peqtl-smr ${peqtl_smr} \
        --peqtl-heidi ${peqtl_heidi} \
        --thread-num 4 \
        --probe-chr ${i} \
        --out ${OUTPUT}/SMR/detail/${trait_name}_${qtl_name}_chr${i}"

    if [ "$smr_multi_index" = "TRUE" ]; then
        cmd="${cmd} --smr-multi"
    fi

    if [ "$smr_heidi_index" = "FALSE" ]; then
        cmd="${cmd} --heidi-off"
    fi
    
    echo "Executing command:"
    echo "$cmd"
    $cmd &

    pids+=($!)
    if (( i % ${batch_num} == 0 )); then
        for pid in "${pids[@]}"; do
            wait $pid || [ $? -eq 99 ] && true || exit $?
        done
        pids=()
    fi

done

# wait for all jobs to finish
for pid in "${pids[@]}"; do
    wait $pid || [ $? -eq 99 ] && true || exit $?
done


# No matter smr or smr-multi, we will final output the "_chrALL.msmr" file 
awk 'NR==1 || FNR>1' ${OUTPUT}/SMR/detail/${trait_name}_${qtl_name}_chr*smr > ${OUTPUT}/SMR/summary/${trait_name}_${qtl_name}_chrALL.msmr
rm ${OUTPUT}/SMR/detail/${trait_name}_${qtl_name}_chr*

else
    echo "File already exists."
fi
