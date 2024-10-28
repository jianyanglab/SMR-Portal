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
mr_enable=`yq .mr.enable "${CONFIG}"`

# ------------------------------------------------------------------------
#  post SMR analysis
# ------------------------------------------------------------------------
gencode=`yq .gene.gencode "${CONFIG}"`
reference_all_bim_file=`yq .reference.reference_all_bim "${CONFIG}"`

env=`yq .environment.post_smr "${CONFIG}"`
source activate ${env}

cmd="python ${SCRIPT_DIR}/L2G/post_SMR.py ${trait_name} 
    --gencode_file ${gencode} 
    --bim_file ${reference_all_bim_file} 
    -q eQTL -q sQTL -q mQTL -q pQTL -q xQTL 
    --save_dir ${OUTPUT}/SMR/SMR_Portal 
    --running_data_dir ${OUTPUT}/SMR 
    --gwas_file ${GWAS_DATA} 
    --max_workers 10 
    --convert_to_hg38"  

if [ "$mr_enable" = "True" ]; then
    cmd="${cmd} --other_mr_result_dir_path ${OUTPUT}/MR/summary"
fi

echo "Executing command:"
echo "$cmd"
$cmd

