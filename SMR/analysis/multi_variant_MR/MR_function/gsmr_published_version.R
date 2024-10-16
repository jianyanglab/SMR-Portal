# gsmr: A tool for GSMR and HEIDI analysis
# The gsmr package Perform Generalized Summary-data-based Mendelian Randomization analysis (GSMR)
#  and HEterogeneity In Dependent Instruments analysis to remove pleiotropic outliers (HEIDI-outlier).
# @author Zhihong Zhu <z.zhu1@uq.edu.au>
# @author Zhili Zheng <zhili.zheng@uq.edu.au>
# @author Futao Zhang <f.zhang5@uq.edu.au>
# @author Jian Yang <jian.yang@uq.edu.au>

eps = 1e-6;

# ************************************************** #
#         check data is missing or not               #
# ************************************************** #
check_element <- function(vals, argue) {
    vals = vals[which(is.finite(vals))]
    if(length(vals)==0) {
        stop("None of the ", argue, " is found. Please check.")
    }
}

# ************************************************** #
#       variance-covariane matrix of bXY             #
# ************************************************** #
cov_bXY <- function(bzx, bzx_se, bzy, bzy_se, ldrho) {
    bXY = bzy / bzx
    zscoreZX = bzx / bzx_se
    nsnp = dim(ldrho)[1]
    covbXY = diag(nsnp)
    if(nsnp>1) {
        zszxij = zscoreZX%*%t(zscoreZX)
        bxyij = bXY%*%t(bXY)
        sezyij = bzy_se%*%t(bzy_se)
        bzxij = bzx%*%t(bzx)
        covbXY = ldrho*sezyij/bzxij + ldrho*bxyij/zszxij 
    }
    return(covbXY)
}

# ************************************************** #
#                 HEIDI test                         #
# ************************************************** #
#' @importFrom survey pchisqsum
heidi <- function(bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, 
                 heidi_thresh = pchisq(10, 1, lower.tail=F),
                 nSNPs_thresh=10, maxid=integer(0) ) {

    remain_index = seq(1, length(bzx))
    m = length(remain_index)

    # recaculate the zscore_ZX for vector has been changed
    zscore_ZX = bzx / bzx_se
    bXY = bzy / bzx
    seSMR = sqrt( (bzy_se^2*bzx^2 + bzx_se^2*bzy^2) / bzx^4 )
    # remap the maxid according to filtered data
    maxid = which(remain_index==maxid)
    if(length(maxid) != 1) {
        stop("The top SNP for the HEIDI analysis is missing.")
    }
    # diff = bXY_top - bXY_-i
    dev = bXY[maxid] - bXY[-maxid]
    # v matrix
    covbXY = cov_bXY(bzx, bzx_se, bzy, bzy_se, ldrho)
    tmp1 = diag(covbXY)[maxid]
    tmp2 = covbXY[-maxid, -maxid]
    tmp3 = covbXY[maxid, -maxid]
    vdev = tmp1 + tmp2 - tmp3
    vdev = t(t(vdev) - tmp3)
    diag(vdev) = diag(vdev) + eps
    # variance of diff
    vardev = diag(covbXY)[-maxid] + tmp1 - 2*tmp3
    vardev = vardev + eps
    chisq_dev = dev^2 / vardev
    if(m>2) {
        # correlation matrix of diff
        corr_dev = diag(m-1)
        # more than 2 instruments
        for( i in 1 : (m-2) ) {
            for( j in (i+1) : (m-1) ) {
                corr_dev[i,j] = corr_dev[j,i] =
                       vdev[i,j] / sqrt(vdev[i,i]*vdev[j,j])
            }
        }

        # estimate the p value
        lambda = eigen(corr_dev, symmetric=TRUE, only.values=TRUE)$values
        t = length(lambda)
        pHet = pchisqsum(sum(chisq_dev)+eps, df=rep(1,t), a=lambda, method="sadd", lower.tail=F)

    } else {
        pHet = pchisq(chisq_dev, 1, lower.tail=F)
    }

    return(list(pheidi=pHet, nsnps=m, used_index=remain_index))
}

# ************************************************** #
#          Iterations for HEIDI-ouliter              #
# ************************************************** #

heidi_outlier_iter <- function(bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, gwas_thresh, heidi_thresh, remain_index) {
    # remove pleiotropic instruments
    m = length(remain_index)
    # grab reference instrument
    bxy = bzy/bzx
    bxy_q = quantile(bxy, probs = seq(0, 1, 0.2))
    min_bxy = as.numeric(bxy_q[3]); max_bxy = as.numeric(bxy_q[4]);
    slctindx = which(bxy <= max_bxy & bxy >= min_bxy)
    if(length(slctindx)==0) {
        message("The top SNP for the HEIDI-outlier analysis is missing. None SNPs are in the third quintile of the distribution of bxy.");
        stop("The top SNP for the HEIDI-outlier analysis is missing. None SNPs are in the third quintile of the distribution of bxy.");
    }
    refid = slctindx[which.min(bzx_pval[slctindx])]
    pheidi = as.numeric()
    for( i in 1 : m ) {
      if( i==refid ) next
      heidi_result = heidi(bzx[c(refid,i)], bzx_se[c(refid,i)], bzx_pval[c(refid,i)],
                          bzy[c(refid,i)], bzy_se[c(refid,i)],
                          ldrho[c(refid,i), c(refid,i)],
                          gwas_thresh, 2, 1)
      pheidi[i] = as.numeric(heidi_result$pheidi)
    }
    remain_index = remain_index[sort(c(refid,which(pheidi>=heidi_thresh)))]
    return(remain_index)
}


# ************************************************** #
#              Test identical elements               #
# ************************************************** #
check_vec_elements_eq <- function(dim_vec){
    return(all(dim_vec == dim_vec[1]))
}


# ************************************************** #
#                     LD pruning                     #
# ************************************************** #
# LD pruning, removing pairs of SNPs that LD r2 > threshold
# return index: the index be used for further analysis
snp_ld_prune = function(ldrho, ld_r2_thresh) {
    # initialization
    nsnp = dim(ldrho)[1]
    diag(ldrho) = 0
    ldrho[upper.tri(ldrho)]=0
    include_id = c(1:nsnp)

    # save the index which have ld r^2 > threshold
    indx = which(ldrho^2>ld_r2_thresh, arr.ind=T)
    if(length(indx)==0) return(NULL);
    indx1 = as.numeric(indx[,2])
    indx2 = as.numeric(indx[,1])
    slct_indx = c(indx1, indx2)
    indxbuf = unique(sort(slct_indx))

    # count how many SNPs in high LD
    nproc = length(indxbuf)
    n_slct_snp = as.numeric()
    for( i in 1 : nproc) {
        n_slct_snp[i] = length(which(slct_indx==indxbuf[i]))
    }  

    # decide the index to remove
    nproc = length(indx1)
    if(nproc==0) return(NULL);
    for( i in 1 : nproc ) {
        n1 = n_slct_snp[which(indxbuf==indx1[i])]
        n2 = n_slct_snp[which(indxbuf==indx2[i])]
        if(n1 < n2) {
            t = indx1[i]; indx1[i] = indx2[i]; indx2[i] = t
        }
    }
    indx1 = unique(sort(indx1))
    return(indx1)
}


# ************************************************** #
#              Filter the summary data               #
# ************************************************** #
# filter the input to se and zscore
# parameters see HEIDI or SMR_Multi functions
# return index: the index be used for further analysis
# NOTICE: the parameters will be revised in place after run!!!!! TAKE CARE
filter_summdat <- function(snp_id, bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, n_ref, nsnps_thresh, pvalue_thresh, ld_r2_thresh, fdr_thresh){
    # make sure they are numeric numbers
    m = length(bzx)
    message("There are ", m, " SNPs in the dataset.")
    remain_index = seq(1,m)
    snpIDp = as.character(snp_id);
    bZXp = as.numeric(as.character(bzx))
    seZXp = as.numeric(as.character(bzx_se));
    pZXp = as.numeric(as.character(bzx_pval));
    bZYp = as.numeric(as.character(bzy))
    seZYp = as.numeric(as.character(bzy_se));
    ldrhop = matrix(as.numeric(as.character(unlist(ldrho))), m, m)

    # remove SNPs with missing value
    na_snps=c()
    indx = which(!is.finite(bZXp) | !is.finite(seZXp) | !is.finite(pZXp) | !is.finite(bZYp) | !is.finite(seZYp) | 
                 is.na(bZXp) | is.na(seZXp) | is.na(pZXp) | is.na(bZYp) | is.na(seZYp))
    if(length(indx)>0) {
        na_snps = snpIDp[indx];
        bZXp = bZXp[-indx]; seZXp = seZXp[-indx]; pZXp = pZXp[-indx];
        bZYp = bZYp[-indx]; seZYp = seZYp[-indx];
        ldrhop = ldrhop[-indx, -indx];
        remain_index = remain_index[-indx]
        snpIDp = snpIDp[-indx] 
        warning(length(indx), " SNPs were removed due to missing estimates in the summary data.")
    }
    m = length(bZXp)
    if(m < nsnps_thresh) stop("At least ", nsnps_thresh, " SNPs are required. Note: this hard limit can be changed by the \"nsnps_thresh\".");

    # remove SNPs with very small SE
    indx = which(seZXp < eps | seZYp < eps )
    if(length(indx)>0) {
        na_snps = c(na_snps, snpIDp[indx]);
        bZXp = bZXp[-indx]; seZXp = seZXp[-indx]; pZXp = pZXp[-indx];
        bZYp = bZYp[-indx]; seZYp = seZYp[-indx];
        ldrhop = ldrhop[-indx, -indx];
        remain_index = remain_index[-indx]
        snpIDp = snpIDp[-indx]
        warning(length(indx), " SNPs were removed due to extremely small standard error. Please check that data.")
    }
    m = length(bZXp)
    if(m < nsnps_thresh) stop("At least ", nsnps_thresh, " SNPs are required. Note: this hard limit can be changed by the \"nsnps_thresh\"."); 
    # remove SNPs with missing LD
    indx = which(is.na(ldrhop[upper.tri(ldrhop)]))
    if(length(indx) > 0)
        stop("LD correlations between ", length(indx), " pairs of SNPs are missing. Please check the MAF of the SNPs and the missingness rate in the reference sample.")

    # z score of bzx
    weak_snps = c()
    indx = which(pZXp > pvalue_thresh)
    if(length(indx)>0) {
        weak_snps = snpIDp[indx];
        bZXp = bZXp[-indx]; seZXp = seZXp[-indx]; pZXp = pZXp[-indx];
        bZYp = bZYp[-indx]; seZYp = seZYp[-indx];
        ldrhop = ldrhop[-indx, -indx];
        remain_index = remain_index[-indx];
        snpIDp = snpIDp[-indx];
        warning(length(indx), " non-significant SNPs were removed.")
    }
    m = length(bZXp)
    if(m < nsnps_thresh) stop("At least ", nsnps_thresh, " SNPs are required. Note: this hard limit can be changed by the \"nsnps_thresh\"."); 

    # check LD r
    linkage_snps = c()
    indx = snp_ld_prune(ldrhop, ld_r2_thresh)
    if(length(indx) > 0) {
        linkage_snps = snpIDp[indx]
        bZXp = bZXp[-indx]; seZXp = seZXp[-indx]; pZXp = pZXp[-indx];
        bZYp = bZYp[-indx]; seZYp = seZYp[-indx];
        ldrhop = ldrhop[-indx, -indx];
        remain_index = remain_index[-indx]
        snpIDp = snpIDp[-indx]
        warning("There were SNPs in high LD. After LD pruning with a LD r2 threshold of ", ld_r2_thresh, ", ", length(indx), " SNPs were removed. Note: The threshold of LD can be changed by the \"ld_r2_thresh\".")
    }
    m = length(bZXp)
    if(m < nsnps_thresh) stop("At least ", nsnps_thresh, " SNPs are required. Note: this hard limit can be changed by the \"nsnps_thresh\"."); 
    
    # update LD correlation matrix
    var_rho = 1/n_ref
    pval_rho = pchisq(ldrhop[upper.tri(ldrhop)]^2/var_rho, 1, lower.tail=F)
    qval_rho = p.adjust(pval_rho, method = "fdr")
    qval_mat = matrix(0, m, m)
    qval_mat[upper.tri(qval_mat)] = qval_rho; qval_mat = t(qval_mat); qval_mat[upper.tri(qval_mat)] = qval_rho;
    rho_index = which(qval_mat >= fdr_thresh, arr.ind=T)
    ldrhop[rho_index] = 0 

    message(length(remain_index), " SNPs were retained after filtering.")
    
    # Yazhou added, mainly because GSMR need to have >=3 SNPs
    if(length(remain_index) < 3) {
        warning("Not enough SNPs for the GSMR analysis.");
    }

    # replace the parameters in place
    eval.parent(substitute(bzx <- bZXp))
    eval.parent(substitute(bzy <- bZYp))
    eval.parent(substitute(bzx_se <- seZXp))
    eval.parent(substitute(bzy_se <- seZYp))
    eval.parent(substitute(bzx_pval <- pZXp))
    eval.parent(substitute(ldrho <- ldrhop))
    return(list(remain_index=remain_index, na_snps=na_snps, weak_snps=weak_snps, linkage_snps=linkage_snps))
}

# ************************************************** #
#         standardization of b and s.e.              #
# ************************************************** #
#' @title Standardization of effect size and its standard error
#' @description Standardization of SNP effect and its standard error using z-statistic, allele frequency and sample size
#' @usage std_effect(snp_freq, b, se, n)
#' @param snp_freq vector, allele frequencies
#' @param b vector, SNP effects on risk factor
#' @param se vector, standard errors of b
#' @param n vector, per-SNP sample sizes for GWAS of the risk factor
#' @examples
#' data("gsmr")
#' std_effects = std_effect(gsmr_data$a1_freq, gsmr_data$bzx, gsmr_data$bzx_se, gsmr_data$bzx_n)
#'
#' @return Standardised effect (b) and standard error (se)
#' @export
std_effect <- function(snp_freq, b, se, n) {
    # double check the counts
    # if data set is empty
    check_element(snp_freq,"Minor Allele Frequency")
    check_element(b,"Effect Size")
    check_element(se,"Standard Error")
    check_element(n,"Sample Size")

    message("std effect: ", length(b), " instruments loaded.")

    # length is different or not
    len_vec <- c(length(snp_freq),length(b),length(se),length(n))
    if (!check_vec_elements_eq(len_vec)){
        stop("Lengths of the input vectors are different. Please check.");
    }
  
    # check missing values
    indx = which(!is.finite(snp_freq) | !is.finite(b) | !is.finite(se) | !is.finite(n) | is.na(snp_freq) | is.na(b) | is.na(se) | is.na(n))
    if (length(indx)>0) {
        stop("There are ", length(indx), " SNPs with missing estimates in the summary data. Please check.");
    } 

    # make sure they are numeric numbers
    snpfreq = as.numeric(as.character(snp_freq))
    b = as.numeric(as.character(b))
    se = as.numeric(as.character(se))
    n = as.numeric(as.character(n))

    zscore = b / se
    b_p = zscore / sqrt(2*snp_freq*(1-snp_freq)*(n+zscore^2))
    se_p = 1 / sqrt(2*snp_freq*(1-snp_freq)*(n+zscore^2))

    return(list(b=b_p,se=se_p))
}

# ************************************************** #
#             HEIDI-outlier analysis                 #
# ************************************************** #
#' @title HEIDI-outlier analysis
#' @description An analysis to detect and eliminate from the analysis instruments that show significant pleiotropic effects on both risk factor and disease
#' @usage heidi_outlier(bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, snpid, n_ref, gwas_thresh=5e-8, heidi_outlier_thresh=0.01, nsnps_thresh=10, ld_fdr_thresh=0.05)
#' @param bzx vector, SNP effects on risk factor
#' @param bzx_se vector, standard errors of bzx
#' @param bzx_pval vector, p values for bzx
#' @param bzy vector, SNP effects on disease
#' @param bzy_se vector, standard errors of bzy
#' @param ldrho LD correlation matrix of the SNPs
#' @param snpid genetic instruments
#' @param n_ref sample size of the reference sample
#' @param gwas_thresh threshold p-value to select instruments from GWAS for risk factor
#' @param heidi_outlier_thresh threshold p-value to remove pleiotropic outliers (the default value is 0.01)
#' @param nsnps_thresh the minimum number of instruments required for the GSMR analysis (we do not recommend users to set this number smaller than 10)
#' @param ld_r2_thresh LD r2 threshold to remove SNPs in high LD
#' @param ld_fdr_thresh FDR threshold to remove the chance correlations between SNP instruments
#' @examples
#' data("gsmr")
#' filtered_index = heidi_outlier(gsmr_data$bzx, gsmr_data$bzx_se, gsmr_data$bzx_pval, gsmr_data$bzy, gsmr_data$bzy_se, ldrho, gsmr_data$SNP, n_ref, 5e-8, 0.01, 10, 0.1, 0.05)
#'
#' @return Retained index of genetic instruments, SNPs with missing values, with non-significant p-values and those in LD.
#' @export
heidi_outlier <- function(bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, snpid,
                      n_ref, gwas_thresh=5e-8, heidi_outlier_thresh=0.01, nsnps_thresh=10, ld_r2_thresh = 0.1, ld_fdr_thresh=0.05) {
    # Subset of LD r matrix
    len1 = length(Reduce(intersect, list(snpid, colnames(ldrho))))
    len2 = length(snpid)
    len_vec <- c(len1, len2)    
    if (!check_vec_elements_eq(len_vec)){ 
        stop(paste(len2 - len1, " SNPs are missing in the LD correlation matrix. Please check.", sep=""))
    }
    ldrho = ldrho[snpid, snpid]
    # double check the counts
    len_vec <- c(length(bzx),length(bzx_se),length(bzx_pval),length(bzy),length(bzy_se),dim(ldrho)[1],dim(ldrho)[2])
    if (!check_vec_elements_eq(len_vec)){
      stop("Lengths of the input vectors are different. Please check.");
    }
    message("HEIDI-outlier: ", length(bzx), " instruments loaded.")
    # filter dataset
    resbuf <- filter_summdat(snpid, bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, n_ref, nsnps_thresh, gwas_thresh, ld_r2_thresh, ld_fdr_thresh)
    remain_index <- resbuf$remain_index; 
    na_snps <- resbuf$na_snps; weak_snps <- resbuf$weak_snps; linkage_snps <- resbuf$linkage_snps 
    if(length(remain_index) < nsnps_thresh) {
      stop("Not enough SNPs for the HEIDI-outlier analysis. At least ", nsnps_thresh, " SNPs are required. Note: this hard limit can be changed by the \"nsnp_thresh\".");
    }
    # Perform HEIDI-outlier
    pleio_snps <- NULL
    remain_index_tmp <- remain_index
    remain_index <- heidi_outlier_iter(bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, gwas_thresh, heidi_outlier_thresh, remain_index)
    if(length(remain_index) < length(remain_index_tmp)) {
        removed_index <- remain_index_tmp[-match(remain_index, remain_index_tmp)]
        pleio_snps <- snpid[removed_index]
    }
    message(length(remain_index), " SNPs were retained after the HEIDI-outlier analysis.")
    return(list(remain_index=remain_index, na_snps=na_snps, weak_snps=weak_snps, linkage_snps=linkage_snps, pleio_snps=pleio_snps))
}

# ************************************************** #
#                   GSMR analysis                    #
# ************************************************** #
#' @title Generalized Summary-data-based Mendelian Randomization analysis
#' @description GSMR (Generalised Summary-data-based Mendelian Randomisation) is a flexible and powerful approach that utilises multiple genetic instruments to test for causal association between a risk factor and disease using summary-level data from independent genome-wide association studies.
#' @usage gsmr(bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, snpid, heidi_outlier_flag=T, gwas_thresh=5e-8, heidi_outlier_thresh=0.01, nsnps_thresh=10)
#' @param bzx vector, SNP effects on risk factor
#' @param bzx_se vector, standard errors of bzx
#' @param bzx_pval vector, p values for bzx
#' @param bzy vector, SNP effects on disease
#' @param bzy_se vector, standard errors of bzy
#' @param ldrho LD correlation matrix of the SNPs
#' @param snpid genetic instruments
#' @param n_ref sample size of the reference sample
#' @param heidi_outlier_flag flag for HEIDI-outlier analysis
#' @param gwas_thresh threshold p-value to select instruments from GWAS for risk factor
#' @param heidi_outlier_thresh HEIDI-outlier threshold 
#' @param nsnps_thresh the minimum number of instruments required for the GSMR analysis (we do not recommend users to set this number smaller than 10)
#' @param ld_r2_thresh LD r2 threshold to remove SNPs in high LD
#' @param ld_fdr_thresh FDR threshold to remove the chance correlations between SNP instruments 
#' @examples
#' data("gsmr")
#' gsmr_result = gsmr(gsmr_data$bzx, gsmr_data$bzx_se, gsmr_data$bzx_pval, gsmr_data$bzy, gsmr_data$bzy_se, ldrho, gsmr_data$SNP, n_ref, T, 5e-8, 0.01, 10, 0.1, 0.05) 
#'
#' @return Estimate of causative effect of risk factor on disease (bxy), the corresponding standard error (bxy_se), p-value (bxy_pval), SNP index (used_index), SNPs with missing values, with non-significant p-values and those in LD.
#' @export
gsmr <- function(bzx, bzx_se, bzx_pval, bzy, bzy_se,
                ldrho, snpid, n_ref, heidi_outlier_flag=T, gwas_thresh=5e-8, heidi_outlier_thresh=0.01, nsnps_thresh=10, ld_r2_thresh=0.1, ld_fdr_thresh=0.05) {
    # subset of LD r matrix
    len1 = length(Reduce(intersect, list(snpid, colnames(ldrho))))
    len2 = length(snpid)
    len_vec <- c(len1, len2)    
    if (!check_vec_elements_eq(len_vec)){
        stop(paste(len2 - len1, " SNPs are missing in the LD correlation matrix. Please check.", sep=""))
    }
    ldrho = ldrho[snpid, snpid]
    # double check the counts
    len_vec <- c(length(bzx),length(bzx_se),length(bzy),length(bzy_se),dim(ldrho)[1],dim(ldrho)[2])
    if (!check_vec_elements_eq(len_vec)){
        stop("Lengths of the input vectors are different. Please check.");
    }
    message("GSMR analysis: ", length(bzx), " instruments loaded.")
    # filter dataset
    resbuf <- filter_summdat(snpid, bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, n_ref, nsnps_thresh, gwas_thresh, ld_r2_thresh, ld_fdr_thresh)
    remain_index<-resbuf$remain_index;
    na_snps<-resbuf$na_snps; weak_snps<-resbuf$weak_snps; linkage_snps<-resbuf$linkage_snps;
    if(length(remain_index) < nsnps_thresh) {
      stop("Not enough SNPs for the GSMR analysis. At least ", nsnps_thresh, " SNPs are required. Note: this hard limit can be changed by the \"nsnps_thresh\".");
    }
    pleio_snps=NULL;
    if(heidi_outlier_flag) {
        # Perform HEIDI-outlier
        remain_index2 <- heidi_outlier_iter(bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, gwas_thresh, heidi_outlier_thresh, remain_index)
        if(length(remain_index2) < nsnps_thresh) {
            stop("Not enough SNPs for the GSMR analysis. At least ", nsnps_thresh, " are required. Note: this hard limit can be changed by \"nsnps_thresh\".");
        } else {
            message(length(remain_index2), " SNPs were retained after the HEIDI-outlier analysis.") 
        }
        # Save pleiotropic SNPs 
        if(length(remain_index2) < length(remain_index)) {
            removed_index <- remain_index[-match(remain_index2, remain_index)]
            pleio_snps <- snpid[removed_index]
        }
        # Update estimates
        remain_index2_tmp = remain_index2
        remain_index2 = match(remain_index2, remain_index)
        bzx = bzx[remain_index2]; bzx_se = bzx_se[remain_index2]; 
        bzy = bzy[remain_index2]; bzy_se = bzy_se[remain_index2];
        ldrho = ldrho[remain_index2,remain_index2];
        remain_index <- remain_index2_tmp
    }
    # do the SMR test with multiple instruments
    message("Computing the estimate of bxy at each instrument.")
    bXY = bzy/bzx

    message("Estimating the variance-covariance matrix for bxy.")
    covbXY = cov_bXY(bzx, bzx_se, bzy, bzy_se, ldrho)
    diag(covbXY) = diag(covbXY) + eps
    # Eigen decomposition
    resbuf = eigen(covbXY, symmetric=TRUE)
    eval = as.numeric(resbuf$values)
    evec = resbuf$vectors
    if(min(abs(eval)) < eps) {
      stop("The variance-covariance matrix for bxy is not invertible!");
    }
    covbXY_inv = evec%*%diag(1/eval)%*%t(evec)
    message("Estimating bxy using all the instruments.")
    vec_1 = rep(1, length(bzx))
    num_1_v_1 = as.numeric(solve(t(vec_1)%*%covbXY_inv%*%vec_1))
    vec_1_v = as.numeric(t(vec_1)%*%covbXY_inv)
    bXY_GLS = num_1_v_1*vec_1_v%*%bXY
    varbXY_GLS = num_1_v_1
    chisqbXY_GLS = bXY_GLS^2/varbXY_GLS
    pbXY_GLS = pchisq(chisqbXY_GLS, 1, lower.tail=F)
    message("GSMR analysis is completed.")
    return(list(bxy=bXY_GLS, bxy_se=sqrt(varbXY_GLS), bxy_pval=pbXY_GLS, used_index=remain_index,
                na_snps=na_snps, weak_snps=weak_snps, linkage_snps=linkage_snps, pleio_snps=pleio_snps))
}

# ************************************************** #
#            Bi-directional GSMR analysis            #
# ************************************************** #
#' @title Bi-directional GSMR analysis
#' @description Bi-directional GSMR analysis is composed of a forward-GSMR analysis and a reverse-GSMR analysis that uses SNPs associated with the disease (e.g. at  < 5e-8) as the instruments to test for putative causal effect of the disease on the risk factor.
#' @usage bi_gsmr(bzx, bzx_se, bzx_pval, bzy, bzy_se, bzy_pval, ldrho, snpid, heidi_outlier_flag=T, gwas_thresh=5e-8, heidi_outlier_thresh=0.01, nsnps_thresh=10)
#' @param bzx vector, SNP effects on risk factor
#' @param bzx_se vector, standard errors of bzx
#' @param bzx_pval vector, p values for bzx
#' @param bzy vector, SNP effects on disease
#' @param bzy_se vector, standard errors of bzy
#' @param bzy_pval vector, p values for bzy
#' @param ldrho LD correlation matrix of the SNPs
#' @param snpid genetic instruments
#' @param n_ref sample size of the reference sample
#' @param heidi_outlier_flag flag for HEIDI-outlier analysis
#' @param gwas_thresh threshold p-value to select  instruments from GWAS for risk factor
#' @param heidi_outlier_thresh HEIDI-outlier threshold 
#' @param nsnps_thresh the minimum number of instruments required for the GSMR analysis (we do not recommend users to set this number smaller than 10)
#' @param ld_r2_thresh LD r2 threshold to remove SNPs in high LD
#' @param ld_fdr_thresh FDR threshold to remove the chance correlations between SNP instruments
#' @examples
#' data("gsmr")
#' gsmr_result = bi_gsmr(gsmr_data$bzx, gsmr_data$bzx_se, gsmr_data$bzx_pval, gsmr_data$bzy, gsmr_data$bzy_se, gsmr_data$bzy_pval, ldrho, gsmr_data$SNP, n_ref, T, 5e-8, 0.01, 10, 0.1, 0.05) 
#'
#' @return Estimate of causative effect of risk factor on disease (forward_bxy), the corresponding standard error (forward_bxy_se), p-value (forward_bxy_pval) and SNP index (forward_index), and estimate of causative effect of disease on risk factor (reverse_bxy), the corresponding standard error (reverse_bxy_se), p-value (reverse_bxy_pval), SNP index (reverse_index), SNPs with missing values, with non-significant p-values and those in LD.
#' @export
bi_gsmr <- function(bzx, bzx_se, bzx_pval, bzy, bzy_se, bzy_pval,
                ldrho, snpid, n_ref, heidi_outlier_flag=T, gwas_thresh=5e-8, heidi_outlier_thresh=0.01, nsnps_thresh=10, ld_r2_thresh=0.1, ld_fdr_thresh=0.05) {
    ## Forward GSMR
    message("Forward GSMR analysis...")   
    gsmr_result=gsmr(bzx, bzx_se, bzx_pval, bzy, bzy_se, ldrho, snpid, n_ref, heidi_outlier_flag, gwas_thresh, heidi_outlier_thresh, nsnps_thresh, ld_r2_thresh, ld_fdr_thresh)
    bxy1 = gsmr_result$bxy; bxy1_se = gsmr_result$bxy_se; bxy1_pval = gsmr_result$bxy_pval;
    bxy1_index = gsmr_result$used_index;
    na_snps = gsmr_result$na_snps; weak_snps = gsmr_result$weak_snps; linkage_snps = gsmr_result$linkage_snps; pleio_snps = gsmr_result$pleio_snps;

    ## Reverse GSMR
    message("Reverse GSMR analysis...")           
    gsmr_result=gsmr(bzy, bzy_se, bzy_pval, bzx, bzx_se, ldrho, snpid, n_ref, heidi_outlier_flag, gwas_thresh, heidi_outlier_thresh, nsnps_thresh, ld_r2_thresh, ld_fdr_thresh)
    bxy2 = gsmr_result$bxy; bxy2_se = gsmr_result$bxy_se; bxy2_pval = gsmr_result$bxy_pval;
    bxy2_index = gsmr_result$used_index;
    na_snps = c(na_snps, gsmr_result$na_snps); 
    weak_snps = c(weak_snps, gsmr_result$weak_snps); 
    linkage_snps = c(linkage_snps, gsmr_result$linkage_snps);
    pleio_snps = c(pleio_snps, gsmr_result$pleio_snps);
    return(list(forward_bxy=bxy1, forward_bxy_se=bxy1_se, 
                forward_bxy_pval=bxy1_pval, forward_index=bxy1_index,
                reverse_bxy=bxy2, reverse_bxy_se=bxy2_se,             
                reverse_bxy_pval=bxy2_pval, reverse_index=bxy2_index,
                na_snps=na_snps, weak_snps=weak_snps, linkage_snps=linkage_snps, pleio_snps=pleio_snps))
}

