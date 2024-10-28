# %%
import concurrent
import glob
import logging
import os
import zipfile
import pickle
import re
import time
from collections import OrderedDict
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

import click
import numpy as np
import pandas as pd
import pyranges as pr
from tqdm import tqdm
import warnings

warnings.filterwarnings("ignore")

# %%
QTL_NAME_MAP = {'eQTL': 'eSMR', 'sQTL': 'sSMR', 'mQTL': 'mSMR', 'xQTL': 'xSMR',
                'pQTL': 'pSMR'
                }

SMR_Portal_qtl_name_list = [
    "eQTL_eQTLGen",
    "eQTL_BrainMeta",
    "eQTL_GTEx_Adipose_Subcutaneous",
    "eQTL_GTEx_Adipose_Visceral_Omentum",
    "eQTL_GTEx_Adrenal_Gland",
    "eQTL_GTEx_Artery_Aorta",
    "eQTL_GTEx_Artery_Coronary",
    "eQTL_GTEx_Artery_Tibial",
    "eQTL_GTEx_Brain_Amygdala",
    "eQTL_GTEx_Brain_Anterior_cingulate_cortex_BA24",
    "eQTL_GTEx_Brain_Caudate_basal_ganglia",
    "eQTL_GTEx_Brain_Cerebellar_Hemisphere",
    "eQTL_GTEx_Brain_Cerebellum",
    "eQTL_GTEx_Brain_Cortex",
    "eQTL_GTEx_Brain_Frontal_Cortex_BA9",
    "eQTL_GTEx_Brain_Hippocampus",
    "eQTL_GTEx_Brain_Hypothalamus",
    "eQTL_GTEx_Brain_Nucleus_accumbens_basal_ganglia",
    "eQTL_GTEx_Brain_Putamen_basal_ganglia",
    "eQTL_GTEx_Brain_Spinal_cord_cervical_c-1",
    "eQTL_GTEx_Brain_Substantia_nigra",
    "eQTL_GTEx_Breast_Mammary_Tissue",
    "eQTL_GTEx_Cells_Cultured_fibroblasts",
    "eQTL_GTEx_Cells_EBV-transformed_lymphocytes",
    "eQTL_GTEx_Colon_Sigmoid",
    "eQTL_GTEx_Colon_Transverse",
    "eQTL_GTEx_Esophagus_Gastroesophageal_Junction",
    "eQTL_GTEx_Esophagus_Mucosa",
    "eQTL_GTEx_Esophagus_Muscularis",
    "eQTL_GTEx_Heart_Atrial_Appendage",
    "eQTL_GTEx_Heart_Left_Ventricle",
    "eQTL_GTEx_Kidney_Cortex",
    "eQTL_GTEx_Liver",
    "eQTL_GTEx_Lung",
    "eQTL_GTEx_Minor_Salivary_Gland",
    "eQTL_GTEx_Muscle_Skeletal",
    "eQTL_GTEx_Nerve_Tibial",
    "eQTL_GTEx_Ovary",
    "eQTL_GTEx_Pancreas",
    "eQTL_GTEx_Pituitary",
    "eQTL_GTEx_Prostate",
    "eQTL_GTEx_Skin_Not_Sun_Exposed_Suprapubic",
    "eQTL_GTEx_Skin_Sun_Exposed_Lower_leg",
    "eQTL_GTEx_Small_Intestine_Terminal_Ileum",
    "eQTL_GTEx_Spleen",
    "eQTL_GTEx_Stomach",
    "eQTL_GTEx_Testis",
    "eQTL_GTEx_Thyroid",
    "eQTL_GTEx_Uterus",
    "eQTL_GTEx_Vagina",
    "eQTL_GTEx_Whole_Blood",
    "sQTL_BrainMeta",
    "sQTL_GTEx_Adipose_Subcutaneous",
    "sQTL_GTEx_Adipose_Visceral_Omentum",
    "sQTL_GTEx_Adrenal_Gland",
    "sQTL_GTEx_Artery_Aorta",
    "sQTL_GTEx_Artery_Coronary",
    "sQTL_GTEx_Artery_Tibial",
    "sQTL_GTEx_Brain_Amygdala",
    "sQTL_GTEx_Brain_Anterior_cingulate_cortex_BA24",
    "sQTL_GTEx_Brain_Caudate_basal_ganglia",
    "sQTL_GTEx_Brain_Cerebellar_Hemisphere",
    "sQTL_GTEx_Brain_Cerebellum",
    "sQTL_GTEx_Brain_Cortex",
    "sQTL_GTEx_Brain_Frontal_Cortex_BA9",
    "sQTL_GTEx_Brain_Hippocampus",
    "sQTL_GTEx_Brain_Hypothalamus",
    "sQTL_GTEx_Brain_Nucleus_accumbens_basal_ganglia",
    "sQTL_GTEx_Brain_Putamen_basal_ganglia",
    "sQTL_GTEx_Brain_Spinal_cord_cervical_c-1",
    "sQTL_GTEx_Brain_Substantia_nigra",
    "sQTL_GTEx_Breast_Mammary_Tissue",
    "sQTL_GTEx_Cells_Cultured_fibroblasts",
    "sQTL_GTEx_Cells_EBV-transformed_lymphocytes",
    "sQTL_GTEx_Colon_Sigmoid",
    "sQTL_GTEx_Colon_Transverse",
    "sQTL_GTEx_Esophagus_Gastroesophageal_Junction",
    "sQTL_GTEx_Esophagus_Mucosa",
    "sQTL_GTEx_Esophagus_Muscularis",
    "sQTL_GTEx_Heart_Atrial_Appendage",
    "sQTL_GTEx_Heart_Left_Ventricle",
    "sQTL_GTEx_Kidney_Cortex",
    "sQTL_GTEx_Liver",
    "sQTL_GTEx_Lung",
    "sQTL_GTEx_Minor_Salivary_Gland",
    "sQTL_GTEx_Muscle_Skeletal",
    "sQTL_GTEx_Nerve_Tibial",
    "sQTL_GTEx_Ovary",
    "sQTL_GTEx_Pancreas",
    "sQTL_GTEx_Pituitary",
    "sQTL_GTEx_Prostate",
    "sQTL_GTEx_Skin_Not_Sun_Exposed_Suprapubic",
    "sQTL_GTEx_Skin_Sun_Exposed_Lower_leg",
    "sQTL_GTEx_Small_Intestine_Terminal_Ileum",
    "sQTL_GTEx_Spleen",
    "sQTL_GTEx_Stomach",
    "sQTL_GTEx_Testis",
    "sQTL_GTEx_Thyroid",
    "sQTL_GTEx_Uterus",
    "sQTL_GTEx_Vagina",
    "sQTL_GTEx_Whole_Blood",
    "pQTL_INTERVAL",
    "pQTL_FENLAND",
    "pQTL_SCALLOP",
    "mQTL_BrainMeta",
    "mQTL_McRae"
]


class GeneListError(Exception):
    """Exception raised for errors in the gene list processing."""

    def __init__(self, message):
        self.message = message
        super().__init__(self.message)


def merge_cojo_files(trait_name, cojo_dir, cojo_merge_dir):
    cojo_merge_dir.mkdir(exist_ok=True, parents=True)
    cojo_merged_file = cojo_merge_dir / f"{trait_name}.jma.cojo"
    if not cojo_merged_file.exists():
        cojo_files = glob.glob(f"{cojo_dir}/{trait_name}_chr*.jma.cojo")
        merged_cojo = pd.concat([pd.read_csv(f, sep='\t') for f in cojo_files])
        merged_cojo.to_csv(cojo_merged_file, sep='\t', index=False)
    return cojo_merged_file


def process_smr_files(subcategory, files, qtl_name, ):
    """
    Process SMR files for a given subcategory.
    This function is intended to be executed in a separate process.
    """
    # for f in files:
    #     print(f"=================={f}\n")
    
    
    logging.info(f"Reading {qtl_name}...")
    df_list = [
        pd.read_csv(f, sep='\t',
                    # usecols=['Gene', 'probeID', 'Probe_bp', 'p_SMR', 'p_HEIDI', 'topSNP_bp', 'topSNP'],
                    dtype={'Gene': str, 'probeID': str, 'Probe_bp': int, 'p_SMR': float,
                           'p_HEIDI': float, 'topSNP_bp': int, 'topSNP': str
                           })
        for f in files]
    SMR_results = pd.concat(df_list, ignore_index=True)

    nan_rows = SMR_results.p_SMR.isnull()
    SMR_results = SMR_results[~nan_rows]

    SMR_results = SMR_results.groupby('Gene').apply(lambda x: x.loc[x['p_SMR'].idxmin()])

    SMR_results.drop(columns=['Gene'], inplace=True)

    # SMR_results = SMR_results[['probeID', 'Probe_bp', 'p_SMR', 'p_HEIDI', 'topSNP_bp', 'topSNP']]

    # SMR_results.columns = [f"{col}_{qtl_name}" for col in SMR_results.columns]

    if bim_lookup_dict is not None:
        # print(f"--Converting the {qtl_name} snp bp to hg38")
        # use bim lookup dict
        SMR_results['topSNP_bp'] = SMR_results['topSNP'].map(bim_lookup_dict)
        SMR_results.dropna(subset=['topSNP_bp'], inplace=True)

    return SMR_results


def read_and_preprocess_gene_annotation(gencode_file):
    gencode = pd.read_csv(gencode_file, sep="\t", header=0)
    gencode['V1'] = gencode['V1'].str.replace("^chr", "", regex=True)
    gencode['gene_id'] = gencode['gene_id'].str.replace("\\..*", "", regex=True)
    gencode = gencode[gencode['gene_type'] == "protein_coding"]
    gencode = gencode[~gencode['V1'].isin(['M', 'X', 'Y'])]
    gencode = gencode.drop_duplicates(subset=['gene_name'])
    result = gencode[['gene_id', 'gene_name', 'V1', 'V4', 'V5', 'V7']].copy()
    result.columns = ['gene_id', 'gene_name', 'chr', 'start', 'end', 'strand']
    # result['GWAS_LOCUS'] = None
    # result['Lead_SNP'] = None
    # result['Lead_SNP_BP'] = None
    return result


def read_cojo_and_bim(cojo_file, bim):
    cojo = pd.read_table(cojo_file)
    cojo = cojo.merge(bim[['SNP', 'POS_hg38']], on='SNP', how='left')
    cojo['LOCUS_START'] = cojo['POS_hg38'] - 1_000_000
    cojo['LOCUS_START'] = cojo['LOCUS_START'].clip(lower=0)
    cojo['LOCUS_END'] = cojo['POS_hg38'] + 1_000_000
    return cojo


def create_pyranges_and_merge(cojo):
    gr_cojo = pr.PyRanges(chromosomes=cojo['Chr'].apply(lambda x: f"chr{x}"), starts=cojo['LOCUS_START'],
                          ends=cojo['LOCUS_END'])
    merged_regions = gr_cojo.merge()
    return merged_regions.df


def annotate_results_with_lead_snp(merged_df, cojo, result):
    for index, row in merged_df.iterrows():
        chr_no_prefix = row.Chromosome.lstrip("chr")
        start, end = row.Start, row.End
        overlapping_cojo = cojo[
            (cojo['Chr'].astype(str) == chr_no_prefix) & (cojo['LOCUS_START'] <= end) & (cojo['LOCUS_END'] >= start)]
        if not overlapping_cojo.empty:
            min_p_index = overlapping_cojo['p'].idxmin()
            lead_snp = overlapping_cojo.loc[min_p_index, 'SNP']
            lead_snp_bp = overlapping_cojo.loc[min_p_index, 'POS_hg38']
            mask = (result['chr'] == chr_no_prefix) & (result['start'] <= end) & (result['end'] >= start)
            result.loc[mask, 'GWAS_LOCUS'] = f"chr{chr_no_prefix}:{start}:{end}"
            result.loc[mask, 'Lead_SNP'] = lead_snp
            result.loc[mask, 'Lead_SNP_BP'] = lead_snp_bp
    return result


def rm_mhc_hg38(smr, mhcStart=28510120, mhcEnd=33480577):
    # mask_snp = (smr['chr'].astype(int) == 6) & (smr['Lead_SNP_BP'] <= mhcEnd) & (smr['Lead_SNP_BP'] >= mhcStart)
    mask_gene = (smr['chr'].astype(int) == 6) & (((smr['start'] <= mhcEnd) & (smr['start'] >= mhcStart)) |
                                                 ((smr['end'] <= mhcEnd) & (smr['end'] >= mhcStart)))
    # mask = mask_snp | mask_gene
    mask = mask_gene
    print(f"Removing {mask.sum()} rows in MHC region")
    return smr[~mask]


# %% SMR

# SMR results processing function
def fetch_SMR_result_xQTL(trait_name, QTL_type, gene_annotation_from_gtf, running_data_dir, max_workers=1):
    """
        Returns:
        - tuple: Contains two elements:
            1. df (DataFrame): A DataFrame containing all SMR results for the given QTL type.
            2. result_most_significant (DataFrame): A DataFrame containing the most significant SMR results for the given QTL type.
    """

    def find_most_significant_smr_df(df, SMR_type):
        if df is None:
            print(f"Skipping due to empty result")
            return pd.DataFrame(
                columns=[f'{SMR_type}_HEIDI', f'{SMR_type}_min_QTL', f'{SMR_type}_min_probe',
                         f'{SMR_type}_min_probe_bp',
                         SMR_type])

        def find_most_significant_qtl(row):
            pvalue_cols = [col for col in row.index if col.startswith('p_SMR')]
            min_pvalue_col = row[pvalue_cols].astype(float).idxmin()
            qtl_name = min_pvalue_col.split('_', 2)[-1]  # Extract QTL name from the column name
            min_pvalue = row[min_pvalue_col]
            log_pvalue = -np.log10(min_pvalue)
            probe_col = f'probe_{qtl_name}'
            probe_bp_col = f'probe_bp_{qtl_name}'
            top_snp_col = f'topSNP_{qtl_name}'
            top_snp_bp_col = f'topSNP_bp_{qtl_name}'

            gene_name = row['gene_name']

            return pd.Series({f'{SMR_type}_HEIDI': row[f'p_HEIDI_{qtl_name}'], f'{SMR_type}_min_QTL': qtl_name,
                              f'{SMR_type}_min_probe': row[probe_col],
                              f'{SMR_type}_min_probe_bp': row[probe_bp_col], SMR_type: log_pvalue,
                              f'{SMR_type}_min_top_snp': row[top_snp_col],
                              f'{SMR_type}_min_top_snp_bp': row[top_snp_bp_col],
                              'gene_name': gene_name,

                              })

        p_threshold = 0.05 / total_gene_number
        p_threshold_log = -np.log10(p_threshold)
        df_most_significant = df.apply(find_most_significant_qtl, axis=1).set_index('gene_name')
        df_most_significant[f'{SMR_type}_sig'] = df_most_significant[SMR_type] > p_threshold_log
        return df_most_significant

    pattern = re.compile(rf"^{trait_name}_({QTL_type}.*)_chr(ALL|\d+)\.msmr$")
    smr_dir = Path(running_data_dir) / 'summary'
    # Find all SMR files that match the QTL type
    smr_files = list(smr_dir.glob(f"{trait_name}_{QTL_type}*_chr*.msmr"))

    # Group files by their extracted subcategory
    files_by_subcategory = OrderedDict()
    for file in smr_files:
        match = pattern.match(file.name)
        if match:
            subcategory = match.group(1)
            if subcategory not in files_by_subcategory:
                files_by_subcategory[subcategory] = []
            files_by_subcategory[subcategory].append(file)
    
    
    print("Filter qtl results files of SMR Portal website list")
    # print(files_by_subcategory)
    files_by_subcategory = OrderedDict(
        (subcategory, files)
        for subcategory, files in files_by_subcategory.items()
        if subcategory in SMR_Portal_qtl_name_list
    )
    # print("--------------------------")
    # print(files_by_subcategory)
    
            
    SMR_results_list = []
    SMR_database_list = []
    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        futures = []
        for subcategory, files in files_by_subcategory.items():
            qtl_name = subcategory
            # print(f'--------------------subcategory:{subcategory}')
            # print(f'--------------------files:{files}')
            future = executor.submit(process_smr_files, subcategory, files, qtl_name, )
            futures.append(future)
        
        for future, qtl_name in tqdm(zip(futures, files_by_subcategory.keys()), total=len(futures),
                                     desc=f"Processing qtl_name {QTL_type}"):
            try:
                result_all_column = future.result()
            except Exception as e:
                print(f"Warning: no results for QTL {qtl_name}")
                continue

            SMR_results = result_all_column[['probeID', 'Probe_bp', 'p_SMR', 'p_HEIDI', 'topSNP_bp', 'topSNP']].copy()
            SMR_results.rename(
                columns={'probeID': 'probe', 'Probe_bp': 'probe_bp', 'p_SMR': 'p_SMR', 'p_HEIDI': 'p_HEIDI'},
                inplace=True)
            SMR_results.columns = [f"{col}_{qtl_name}" for col in SMR_results.columns]

            SMR_results_list.append(SMR_results)

            result_all_column.insert(0, 'qtl_name', qtl_name)
            SMR_database_list.append(result_all_column.reset_index())

    if len(SMR_results_list) == 0:
        print(f"No {QTL_type} SMR results found for {trait_name}")
        return None
    SMR_results_all = pd.concat(SMR_results_list, axis=1)

    gene_needed = gene_annotation_from_gtf.index.intersection(SMR_results_all.index)
    total_gene_number = len(gene_needed)

    if QTL_type == 'xQTL' and total_gene_number == 0:
        # check the SMR_results_all.index is all NaN
        if SMR_results_all.index.isnull().all():
            # raise GeneListError("The Uploaded xQTL epi Gene Name column is empty. Please check the input file.")
            warnings.warn("The Uploaded xQTL epi Gene Name column is empty. Please check the input file.")
        else:
            # raise GeneListError("The Uploaded xQTL epi Gene Name column has no overlap with the gene list in the annotation GTF file. Please check the input file.")
            warnings.warn(
                "The Uploaded xQTL epi Gene Name column has no overlap with the gene list in the annotation GTF file. Please check the input file.")
        return None

    # genes_within_locus = cojo_gene_df[cojo_gene_df['GWAS_LOCUS'].notnull()].index.intersection(gene_needed)
    df = SMR_results_all.loc[gene_needed]
    print(f"Total {QTL_type} probe number: {total_gene_number}")
    df.index.name = 'gene_name'
    # df = rm_mhc_hg38(df).reset_index()
    result_most_significant = find_most_significant_smr_df(df.reset_index(), QTL_NAME_MAP[QTL_type])

    # filter to save the database result
    p_threshold = 0.05 / total_gene_number
    SMR_Merged_raw = pd.concat(SMR_database_list, axis=0, ignore_index=True)
    SMR_Merged_raw = SMR_Merged_raw[SMR_Merged_raw.Gene.isin(gene_needed)]

    SMR_database_df = SMR_Merged_raw.copy()
    SMR_database_df = SMR_database_df[SMR_database_df['p_SMR'] < p_threshold]

    # append the gene annotation to the merged raw result
    SMR_Merged_raw = SMR_Merged_raw.merge(gene_annotation_from_gtf, left_on='Gene', right_index=True, how='left')

    return df, result_most_significant, SMR_database_df, SMR_Merged_raw


@click.command()
@click.argument('trait_name')
@click.option('--gencode_file',
              default="/storage/yangjianLab/qiting/data/annotation/gencode/gencode.v40.GRCh38.gene.annotation.bed",
              help='Path to the GENCODE file.')
@click.option('--bim_file',
              default="/storage/yangjianLab/sharedata/LD_reference/UKB/genotype_10K/BED_ukbEUR_imp_v3_INFO0.8_maf0.01_mind0.05_geno0.05_hwe1e6_10K_hg38_chrALL.bim",
              help='Path to the BIM file.')
@click.option('--qtl_categories', '-q', multiple=True, type=click.Choice(['eQTL', 'sQTL', 'mQTL', 'xQTL', 'pQTL']),
              help='QTL categories to process.')
@click.option('--save_dir',
              required=False,
              help='Directory to save results.')
@click.option('--running_data_dir',
              required=True,
              help='Directory to save results.')
@click.option('--gwas_file',
              required=True,
              help='The GWAS summary statistics file.')
# indicate whether to use the bim lookup dict
@click.option('--max_workers', default=1, help='Number of workers for parallel processing.')
@click.option('--convert_to_hg38', default=False, is_flag=True,
              help='Whether to use the bim lookup dict, to convert the snp bp to hg38.')
@click.option('--bim_lookup_dict_path', default=None, help='Path to the bim lookup dict pickle file.')
@click.option('--other_mr_result_dir_path', default=None, help='Path to the other MR result file, such as GSMR, etc.')
def cli(*args, **kwargs):
    # print('args:', args)
    # print('kwargs:', kwargs)
    main(*args, **kwargs)


def main(trait_name, gencode_file, bim_file, qtl_categories, save_dir, running_data_dir, gwas_file, max_workers,
         convert_to_hg38=False, bim_lookup_dict_path=None, other_mr_result_dir_path=None):
    # Create directories
    start_time = time.time()

    running_data_dir = Path(running_data_dir)
    if save_dir is None:
        save_dir = running_data_dir / 'plot'
    save_dir = Path(save_dir)
    save_dir.mkdir(exist_ok=True, parents=True)

    gene_annotation_from_gtf = read_and_preprocess_gene_annotation(gencode_file).set_index('gene_name')
    gene_annotation_from_gtf = rm_mhc_hg38(gene_annotation_from_gtf)
    global bim_lookup_dict
    bim_lookup_dict = None

    if bim_lookup_dict_path is not None:
        print(f'loading bim from the bim_lookup_dict_path')
        # load from pickle
        with open(bim_lookup_dict_path, 'rb') as f:
            bim, bim_lookup_dict = pickle.load(f)

        if not convert_to_hg38:
            bim_lookup_dict = None

    else:
        bim = pd.read_csv(bim_file, sep="\t", header=None, usecols=[0, 1, 3], names=["Chr", "SNP", "POS_hg38"],
                          dtype={'Chr': np.int32, 'SNP': str, 'POS_hg38': np.int32})
        if convert_to_hg38:
            print("Creating bim lookup dict for hg38 conversion")
            bim_lookup_dict = bim.set_index('SNP').POS_hg38.to_dict()

    result_qtls = []
    result_all_probe_qtls = []
    result_database_qtls = []
    result_merged_raw_qtls = []
    valid_qtl_categories = []

    for qtl_category in qtl_categories:
        # Assuming fetch_SMR_result_xQTL is a function that processes each QTL type
        fetch_result = fetch_SMR_result_xQTL(trait_name, qtl_category, gene_annotation_from_gtf, running_data_dir,
                                             max_workers=max_workers)
        if fetch_result is not None:
            qtl_all_probe_df, qtl_result_most_significant, SMR_database_df, SMR_Merged_raw = fetch_result
            result_qtls.append(qtl_result_most_significant)
            result_all_probe_qtls.append(qtl_all_probe_df)
            valid_qtl_categories.append(qtl_category)
            result_database_qtls.append(SMR_database_df)
            result_merged_raw_qtls.append(SMR_Merged_raw)

    result_most_significant = pd.DataFrame()
    if len(result_qtls) > 0:
        result_most_significant = pd.concat(
            result_qtls, axis=1)

    # keep at least one QTL is significant
    qtl_sig_names = [f'{QTL_NAME_MAP[qtl_category]}_sig' for qtl_category in valid_qtl_categories]
    any_sig = result_most_significant[qtl_sig_names].any(axis=1)
    result_most_significant_sig = result_most_significant[any_sig]
    
    # if no significant QTL, skip the rest
    if result_most_significant_sig.empty:
        print("!!!!!!!!!!No significant QTL found.")
        print("!!!!!!!!!!You should insure the GWAS input has some significant loci.")
        print("!!!!!!!!!!!Skipping the rest of the analysis.")

        # write the empty result
        result_most_significant_sig.to_csv(save_dir / f'{trait_name}_SMR_plot.summary', sep='\t')

        # touch a file to indicate no significant QTL
        (save_dir / f'{trait_name}_no_sig.warning').touch()
        for i, qtl_category in enumerate(valid_qtl_categories):
            (save_dir / f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.summary').touch()
            (save_dir / f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.database').touch()

            # To ensure the merged raw result has the same columns when no significant QTL
            append_nan_cols = ['GWAS_LOCUS', 'Lead_SNP', 'Lead_SNP_BP']
            result_merged_raw_df = result_merged_raw_qtls[i]
            result_merged_raw_df[append_nan_cols] = np.nan
            # save the merged raw result
            result_merged_raw_df.to_csv(Path(save_dir) / f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.merged.tsv',
                                        sep='\t',
                                        index=False)

            # compress the merged raw result to a zip file
        with zipfile.ZipFile(save_dir / f'{trait_name}_merged_raw.zip', 'w') as zipf:
            for i, qtl_category in enumerate(valid_qtl_categories):
                zipf.write(save_dir / f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.merged.tsv',
                           arcname=f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.merged.tsv')
            # os.remove(save_dir / f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.merged.tsv')

        return
    # ## find the top SNP for each gene
    # result['GWAS_LOCUS'] = None
    # result['Lead_SNP'] = None
    # result['Lead_SNP_BP'] = None

    _QTL_SMR_logp = result_most_significant_sig[
        [f'{QTL_NAME_MAP[qtl_category]}' for qtl_category in valid_qtl_categories]]

    _QTL_SMR_top_snp_bp = result_most_significant_sig[
        [f'{QTL_NAME_MAP[qtl_category]}_min_top_snp_bp' for qtl_category in valid_qtl_categories]]
    _QTL_SMR_top_snp_bp.columns = [f'{QTL_NAME_MAP[qtl_category]}' for qtl_category in valid_qtl_categories]

    _QTL_SMR_top_snp = result_most_significant_sig[
        [f'{QTL_NAME_MAP[qtl_category]}_min_top_snp' for qtl_category in valid_qtl_categories]]
    _QTL_SMR_top_snp.columns = [f'{QTL_NAME_MAP[qtl_category]}' for qtl_category in valid_qtl_categories]

    # _QTL_SMR_logp_max = _QTL_SMR_logp.idxmax(axis=1)
    # _QTL_SMR_top_snp_max = _QTL_SMR_top_snp.lookup(_QTL_SMR_logp_max.index, _QTL_SMR_logp_max)
    # _QTL_SMR_top_snp_bp_max = _QTL_SMR_top_snp_bp.lookup(_QTL_SMR_logp_max.index, _QTL_SMR_logp_max)
    _QTL_SMR_logp_max = _QTL_SMR_logp.idxmax(axis=1)
    idx = pd.MultiIndex.from_arrays([_QTL_SMR_logp_max.index, _QTL_SMR_logp_max])
    _QTL_SMR_top_snp_max = _QTL_SMR_top_snp.stack()[idx].values
    _QTL_SMR_top_snp_bp_max = _QTL_SMR_top_snp_bp.stack()[idx].values

    _QTL_SMR_df = pd.DataFrame({'top_snp': _QTL_SMR_top_snp_max, 'top_snp_bp': _QTL_SMR_top_snp_bp_max, },
                               index=result_most_significant_sig.index)
    _QTL_SMR_df = gene_annotation_from_gtf.join(_QTL_SMR_df, how='inner')
    # _QTL_SMR_df.drop(columns=['GWAS_LOCUS', 'Lead_SNP', 'Lead_SNP_BP'], inplace=True)
    _QTL_SMR_df['Chromosome'] = _QTL_SMR_df['chr']
    _QTL_SMR_df['Start'] = _QTL_SMR_df['top_snp_bp'] - 500_000
    _QTL_SMR_df['Start'] = _QTL_SMR_df['Start'].clip(lower=0)
    _QTL_SMR_df['End'] = _QTL_SMR_df['top_snp_bp'] + 500_000

    # gr_cojo = pr.PyRanges(chromosomes=_QTL_SMR_df['Chr'], starts=_QTL_SMR_df['LOCUS_START'],
    #                       ends=_QTL_SMR_df['LOCUS_END'])
    gr_cojo = pr.PyRanges(_QTL_SMR_df.reset_index())
    merged_regions = gr_cojo.merge()
    merged_regions_with_lead_snp = merged_regions.df.copy()
    merged_regions_with_lead_snp['Lead_SNP'] = None
    merged_regions_with_lead_snp['Lead_SNP_BP'] = None
    # ## save the gwas result by locus
    # gwas conversion
    print("Processing GWAS file...")
    # gwas = pd.read_csv(gwas_file, sep="\t", usecols=['SNP', 'P', ])
    gwas = pd.read_csv(gwas_file, sep="\t").rename(columns=str.upper)[['SNP', 'P']]

    gwas.columns = [x.upper() for x in gwas.columns]
    gwas['P'] = pd.to_numeric(gwas['P'], errors='coerce')
    gwas.set_index('SNP', inplace=True)
    gwas = gwas.join(bim.set_index('SNP'), how='inner')
    gwas.rename(columns={'POS_hg38': 'POS', 'Chr': 'CHR'}, inplace=True)
    gwas.reset_index(inplace=True)
    gwas = gwas[['CHR', 'POS', 'P', 'SNP']]
    gwas.sort_values(by=['CHR', 'POS'], inplace=True)
    gwas_save_dir = save_dir / 'gwas'
    gwas_save_dir.mkdir(exist_ok=True, parents=True)
    # ##
    # for i, row in gr_cojo.df.copy().iterrows():
    #     chrom, start, end = int(row.Chromosome), int(row.Start), int(row.End),
    #     sub_gwas = gwas[(gwas['CHR'] == chrom) & (gwas['POS'] >= start) & (gwas['POS'] <= end)]
    #     Lead_SNP_index = sub_gwas['P'].idxmin()
    #     Lead_SNP = sub_gwas.loc[Lead_SNP_index, 'SNP']
    #     Lead_SNP_BP = sub_gwas.loc[Lead_SNP_index, 'POS']
    #
    #     merged_regions_with_lead_snp.loc[i, 'Lead_SNP'] = Lead_SNP
    #     merged_regions_with_lead_snp.loc[i, 'Lead_SNP_BP'] = Lead_SNP_BP
    #
    #     sub_gwas.to_csv(gwas_save_dir / f'{trait_name}_chr{chrom}:{start}:{end}.txt', sep='\t', index=False)

    for i, row in merged_regions_with_lead_snp.copy().iterrows():
        chrom, start, end = int(row.Chromosome), int(row.Start), int(row.End),
        sub_gwas = gwas[(gwas['CHR'] == chrom) & (gwas['POS'] >= start) & (gwas['POS'] <= end)]
        Lead_SNP_index = sub_gwas['P'].idxmin()
        Lead_SNP = sub_gwas.loc[Lead_SNP_index, 'SNP']
        Lead_SNP_BP = sub_gwas.loc[Lead_SNP_index, 'POS']

        merged_regions_with_lead_snp.loc[i, 'Lead_SNP'] = Lead_SNP
        merged_regions_with_lead_snp.loc[i, 'Lead_SNP_BP'] = Lead_SNP_BP

        sub_gwas.to_csv(gwas_save_dir / f'{trait_name}_chr{chrom}:{start}:{end}.txt', sep='\t', index=False)

    print("Annotating SMR results with lead SNP...")
    # ##
    gr_cojo_with_locus = gr_cojo.join(pr.PyRanges(merged_regions_with_lead_snp), ).df
    gr_cojo_with_locus['GWAS_LOCUS'] = 'chr' + gr_cojo_with_locus['Chromosome'].astype(str) + ':' + gr_cojo_with_locus[
        'Start_b'].astype(str) + ':' + gr_cojo_with_locus['End_b'].astype(str)
    gr_cojo_with_locus.set_index('gene_name', inplace=True)
    ' gene_id chr     start       end strand'
    # gr_cojo_with_locus=gr_cojo_with_locus[['gene_id','chr','start','end','strand', 'top_snp',  'top_snp_bp','locus']]
    # gr_cojo_with_locus['top_snp_bp']=gr_cojo_with_locus['top_snp_bp'].astype(int)
    result_locus = gr_cojo_with_locus[
        ['gene_id', 'chr', 'start', 'end', 'strand', 'GWAS_LOCUS', 'Lead_SNP', 'Lead_SNP_BP']]

    # ##
    result_most_significant_sig = result_locus.join(result_most_significant_sig, how='inner')

    # ##
    print("Saving results...")
    result_most_significant_sig.to_csv(save_dir / f'{trait_name}_SMR_plot.summary', sep='\t')

    for i, qtl_category in enumerate(valid_qtl_categories):
        result_qtl_sig = result_all_probe_qtls[i].reindex(result_most_significant_sig.index, axis=0)
        result_qtl_sig = result_locus.join(result_qtl_sig, how='inner')
        # save
        result_qtl_sig.to_csv(Path(save_dir) / f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.summary', sep='\t')

        # save the database result
        result_database_df = result_database_qtls[i].set_index('Gene')

        result_database_df = result_database_df.join(result_locus, ).reset_index()
        result_database_df.to_csv(Path(save_dir) / f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.database',
                                  sep='\t',
                                  index=False
                                  )

        # add locus information to merged raw, only append ['GWAS_LOCUS', 'Lead_SNP', 'Lead_SNP_BP']
        result_merged_raw_df = result_merged_raw_qtls[i].set_index('Gene')
        result_merged_raw_df = result_merged_raw_df.join(result_locus[['GWAS_LOCUS', 'Lead_SNP', 'Lead_SNP_BP']],
                                                         how='left').reset_index()

        # save the merged raw result
        result_merged_raw_df.to_csv(Path(save_dir) / f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.merged.tsv',
                                    sep='\t',
                                    index=False)

    # compress the merged raw result to a zip file
    with zipfile.ZipFile(save_dir / f'{trait_name}_merged_raw.zip', 'w') as zipf:
        for i, qtl_category in enumerate(valid_qtl_categories):
            zipf.write(save_dir / f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.merged.tsv',
                       arcname=f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.merged.tsv')
            # os.remove(save_dir / f'{trait_name}_{QTL_NAME_MAP[qtl_category]}.merged.tsv')

    # combine other MR results
    if other_mr_result_dir_path is not None:
        other_mr_result_dir_path = Path(other_mr_result_dir_path)
        assert other_mr_result_dir_path.is_dir()
        # example file name: 'T2D_eQTL_GTEx_Prostate_MR_comparison.txt'
        other_MR_files = list(other_mr_result_dir_path.glob(f'{trait_name}_*_MR_comparison.txt'))
        other_MR_files.sort()
        # MR_result_df = pd.concat([pd.read_csv(f, sep='\t') for f in other_MR_files])
        MR_result_df_list = [pd.read_csv(f, sep='\t') for f in other_MR_files if os.path.getsize(f) > 0]

        if MR_result_df_list:
            MR_result_df = pd.concat(MR_result_df_list)
        else:
            # If all files are empty, return an empty DataFrame
            MR_result_df = pd.DataFrame()

        if MR_result_df.empty:
            open(save_dir / f'{trait_name}_other_MR_results.txt', 'w').close()
        else:
            MR_result_df.to_csv(save_dir / f'{trait_name}_other_MR_results.txt', sep='\t', index=False)

    total_time = time.time() - start_time
    print(f"Total time: {total_time:.2f} seconds")

# %% 
class TEST_POST_SMR:
    def __init__(self, trait_name, gencode_file, bim_file, qtl_categories, save_dir, running_data_dir, gwas_file,
                 max_workers,
                 convert_to_hg38=False,
                 bim_lookup_dict_path=None,
                 other_MR_result_dir_path=None
                 ):
        self.trait_name = trait_name
        self.gencode_file = gencode_file
        self.bim_file = bim_file
        self.qtl_categories = qtl_categories
        self.save_dir = save_dir
        self.running_data_dir = running_data_dir
        self.gwas_file = gwas_file
        self.max_workers = max_workers
        self.convert_to_hg38 = convert_to_hg38
        self.bim_lookup_dict_path = bim_lookup_dict_path
        self.other_MR_result_dir_path = other_MR_result_dir_path

    def call_cli(self):
        args = [
            self.trait_name,
            '--gencode_file', self.gencode_file,
            '--bim_file', self.bim_file,
            *[f'-q' if i % 2 == 0 else self.qtl_categories[i // 2] for i in range(len(self.qtl_categories) * 2)],
            '--save_dir', self.save_dir,
            '--running_data_dir', self.running_data_dir,
            '--gwas_file', self.gwas_file,
            '--max_workers', str(self.max_workers),
            '--convert_to_hg38' if self.convert_to_hg38 else None,
            '--bim_lookup_dict_path' if self.bim_lookup_dict_path else None,
            self.bim_lookup_dict_path,
            '--other_mr_result_dir_path' if self.other_MR_result_dir_path else None,
            self.other_MR_result_dir_path
        ]
        args = [arg for arg in args if arg is not None]
        cli(args=args)

    def call_main(self):
        main(self.trait_name, self.gencode_file, self.bim_file, self.qtl_categories, self.save_dir,
             self.running_data_dir, self.gwas_file, self.max_workers, convert_to_hg38=self.convert_to_hg38,
             bim_lookup_dict_path=self.bim_lookup_dict_path, other_mr_result_dir_path=self.other_MR_result_dir_path)

    def __call__(self):
        self.call_main()





# %%
class TEST_POST_SMR_T2D(TEST_POST_SMR):
    def __init__(self):
        super().__init__(
            trait_name='T2D',
            gwas_file="/storage/yangjianLab/sharedata/GWAS_summary/01_Public/01_cojo/DIAMANTE_EUR_T2D_2022_NG.txt",
            
            gencode_file="/storage/yangjianLab/qiting/data/annotation/gencode/gencode.v40.GRCh38.gene.annotation.bed",
            bim_file="/storage/yangjianLab/sharedata/LD_reference/UKB/genotype_10K/BED_ukbEUR_imp_v3_INFO0.8_maf0.01_mind0.05_geno0.05_hwe1e6_10K_hg38_chrALL.bim",
            qtl_categories=['eQTL', 'sQTL', 'mQTL', 'pQTL'],
            # qtl_categories=['eQTL'],
            save_dir="/storage/yangjianLab/guoyazhou/GAMMA_git_data/SMR/debug_tmp",
            running_data_dir="/storage/yangjianLab/guoyazhou/GAMMA_git_data/SMR",
            max_workers=10,
            convert_to_hg38=True
        )

# %%
if __name__ == '__main__':
    cli()
    # test = TEST_POST_SMR_SCZ()
    # test = TEST_POST_SMR_WBC()
    # test = TEST_DEBUG_20240801()
    # test = TEST_DEBUG_20240729()
    # test = TEST_POST_SMR_DEMO()
    # test = TEST_POST_SMR_DEMO_convert_to38()
    # test = TEST_POST_SMR_DEMO_convert_to38_by_bim_lookup_dict()
    # test = TEST_pQTL()
    # test = TEST_Yazhou_Batch_Run3()
    # test = TEST_Yazhou_Batch_Run()
    # test = TEST_Yazhou_Batch_Run2()
    # test = TEST_POST_SMR_T2D()
    # test()
    # test.call_cli()

