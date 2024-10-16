# This function implements the MR-Lasso method
# Code is from paper
# Slob, Eric AW, and Stephen Burgess. "A Comparison Of Robust Mendelian Randomization Methods Using Summary Data." BioRxiv (2019): 577940.
MR_lasso<-function(betaYG,betaXG,sebetaYG){
    betaYGw = betaYG/sebetaYG # dividing the association estimates by sebetaYG is equivalent
    betaXGw = betaXG/sebetaYG # to weighting by sebetaYG^-2
    pleio = diag(rep(1, length(betaXG)))
    l1grid = c(seq(from=0.1, to=5, by=0.1), seq(from=5.2, to=10, by=0.2))
    # values of lambda for grid search
    l1grid_rse = NULL; l1grid_length = NULL; l1grid_beta = NULL; l1grid_se = NULL
    for (i in 1:length(l1grid)) {
        l1grid_which = which(attributes(penalized(betaYGw, pleio, betaXGw, lambda1=l1grid[i], trace=FALSE))$penalized==0)
        l1grid_rse[i] = summary(lm(betaYG[l1grid_which]~betaXG[l1grid_which]-1, weights=sebetaYG[l1grid_which]^-2))$sigma
        l1grid_length[i] = length(l1grid_which)

        l1grid_beta[i] = lm(betaYG[l1grid_which]~betaXG[l1grid_which]-1, weights=sebetaYG[l1grid_which]^-2)$coef[1]
        l1grid_se[i] = summary(lm(betaYG[l1grid_which]~betaXG[l1grid_which]-1,
                                  weights=sebetaYG[l1grid_which]^-2))$coef[1,2]/min(summary(lm(betaYG[l1grid_which]~betaXG[l1grid_which]-1, weights=sebetaYG[l1grid_which]^-2))$sigma, 1)
    }
    l1which_hetero = c(which(l1grid_rse[1:(length(l1grid)-1)]>1& diff(l1grid_rse)>qchisq(0.95, df=1)/l1grid_length[2:length(l1grid)]), length(l1grid))[1]
    # heterogeneity criterion for choosing lambda
    l1hetero_beta = l1grid_beta[l1which_hetero]
    l1hetero_se = l1grid_se[l1which_hetero]
    list(ThetaEstimate=l1hetero_beta, ThetaSE=l1hetero_se )
}

all_mr = function(bzx, bzx_se, bzx_pval, bzy, bzy_se, bzy_pval, method, nsnps_thresh=10){
### Different methods for Mendelian Randomization analysis
### "GSMR_heidi", "GSMR_noheidi", "IVW", "Median", "Mode", "Egger", "Robust", "Lasso", "RAPS", "PRESSO", "MRMix", "Con-Mix"
    suppressMessages({library(MRMix);library(MendelianRandomization)
    library(mr.raps);library(MRPRESSO);library(penalized)
    library(survey)})
names(bzx)=1:length(bzx)
n1a=10000
    if(method=="GSMR_heidi_v1"){
     #library(gsmr)   
source(paste0(SCRIPT_DIR, "/L2G/MR/MR_function/gsmr_published_version.R"))
snp_coeff_id = names(bzx); ldrho=diag(length(bzx)); colnames(ldrho) = rownames(ldrho) = snp_coeff_id
        mr_results = tryCatch(
            gsmr(bzx, bzx_se, bzx_pval, bzy, bzy_se, bzy_pval,
                ldrho=ldrho, snpid=snp_coeff_id, n_ref=n1a, 
                heidi_outlier_flag=T,gwas_thresh=5e-8, heidi_outlier_thresh=0.01, nsnps_thresh=nsnps_thresh),
                error=function(e){list(bxy_pval=NA, bxy=NA,se=NA,pleio=NA)}
                )
	return(list(pval=mr_results$bxy_pval, bxy=mr_results$bxy,se=mr_results$bxy_se,pleio=mr_results$pleio_snps))
    }else if(method=="GSMR_heidi_v2"){
  envir <- new.env()
  source(paste0(SCRIPT_DIR, "/L2G/MR/MR_function/gsmr_original_global.R"))
  snp_coeff_id = names(bzx); ldrho=diag(length(bzx)); colnames(ldrho) = rownames(ldrho) = snp_coeff_id
  mr_results = tryCatch(gsmr(bzx, bzx_se, bzx_pval, bzy, bzy_se, bzy_pval,
                             ldrho=ldrho, snpid=snp_coeff_id, n_ref=n1a, heidi_outlier_flag=T,gsmr2_beta=1,single_snp_heidi_thresh=0.01, multi_snps_heidi_thresh=0.01),
                        error=function(e){list(bxy_pval=NA, bxy=NA,se=NA,pleio=NA)})
	return(list(pval=mr_results$bxy_pval, bxy=mr_results$bxy,se=mr_results$bxy_se,pleio=mr_results$pleio_snps))
   }else if(method=="GSMR_heidi_v3"){
  envir <- new.env()
  source(paste0(SCRIPT_DIR, "/L2G/MR/MR_function/gsmr_direct_global.R"))
  snp_coeff_id = names(bzx); ldrho=diag(length(bzx)); colnames(ldrho) = rownames(ldrho) = snp_coeff_id
  mr_results = tryCatch(gsmr(bzx, bzx_se, bzx_pval, bzy, bzy_se, bzy_pval,
                             ldrho=ldrho, snpid=snp_coeff_id, n_ref=n1a, heidi_outlier_flag=T,gsmr2_beta=1,single_snp_heidi_thresh=0.01, multi_snps_heidi_thresh=0.01),
                        error=function(e){list(bxy_pval=NA, bxy=NA,se=NA,pleio=NA)})
        return(list(pval=mr_results$bxy_pval, bxy=mr_results$bxy,se=mr_results$bxy_se,pleio=mr_results$pleio_snps))


   }else if(method=="GSMR_heidi_v3_stepwise"){
  envir <- new.env()
  source(paste0(SCRIPT_DIR, "/L2G/MR/MR_function/gsmr_direct_global_stepwise.R"))
  snp_coeff_id = names(bzx); ldrho=diag(length(bzx)); colnames(ldrho) = rownames(ldrho) = snp_coeff_id
  mr_results = tryCatch(gsmr(bzx, bzx_se, bzx_pval, bzy, bzy_se, bzy_pval,
                             ldrho=ldrho, snpid=snp_coeff_id, n_ref=n1a, heidi_outlier_flag=T,gsmr2_beta=1,single_snp_heidi_thresh=0.01, multi_snps_heidi_thresh=0.01),
                        error=function(e){list(bxy_pval=NA, bxy=NA,se=NA,pleio=NA)})
        return(list(pval=mr_results$bxy_pval, bxy=mr_results$bxy,se=mr_results$bxy_se,pleio=mr_results$pleio_snps))


   }else if(method=="GSMR_noheidi"){
	source(paste0(SCRIPT_DIR, "/L2G/MR/MR_function/gsmr_published_version.R"))
	#library(gsmr)
        snp_coeff_id = names(bzx); ldrho=diag(length(bzx)); colnames(ldrho) = rownames(ldrho) = snp_coeff_id
        mr_results = tryCatch(gsmr(bzx, bzx_se, bzx_pval, bzy, bzy_se, bzy_pval,gwas_thresh=5e-8,
                        ldrho=ldrho, snpid=snp_coeff_id, n_ref=n1a, heidi_outlier_flag=F),
                        error=function(e){list(bxy_pval=NA, bxy=NA,se=NA)})
        #detach("package:gsmr", unload=TRUE)
	return(list(pval=mr_results$bxy_pval, bxy=mr_results$bxy,se=mr_results$bxy_se))
    }else if(method == "IVW"){
        mr_results = mr_ivw(mr_input(bx=bzx, bxse=bzx_se, by=bzy, byse=bzy_se))
        return(list(pval=mr_results$Pvalue, bxy=mr_results$Estimate,se=mr_results$StdError))
    }else if(method == "Median"){
        mr_results = mr_median(mr_input(bx=bzx, bxse=bzx_se, by=bzy, byse=bzy_se))
        return(list(pval=mr_results$Pvalue, bxy=mr_results$Estimate,se=mr_results$StdError))
    }else if(method == "Simple_Median"){
        mr_results = mr_median(mr_input(bx=bzx, bxse=bzx_se, by=bzy, byse=bzy_se),weighting="simple")
        return(list(pval=mr_results$Pvalue, bxy=mr_results$Estimate,se=mr_results$StdError))
    }else if(method == "Mode"){
        mr_results = mr_mbe(mr_input(bx=bzx, bxse=bzx_se, by=bzy, byse=bzy_se))
        return(list(pval=mr_results$Pvalue, bxy=mr_results$Estimate,se=mr_results$StdError))
    }else if(method == "Egger"){
        mr_results = try(mr_egger(mr_input(bx=bzx, bxse=bzx_se, by=bzy, byse=bzy_se)), silent = TRUE)
        if (class(mr_results) != "try-error") {
            return(list(pval = mr_results$Pvalue.Est,bxy = mr_results$Estimate,se = mr_results$StdError.Est))
        } else {
            return(list(bxy = NA,se = NA, pval = NA))
        }
    }else if(method == "Robust"){
        mr_results = mr_ivw(mr_input(bx=bzx, bxse=bzx_se, by=bzy, byse=bzy_se),"random", robust = TRUE)
        return(list(pval=mr_results$Pvalue, bxy=mr_results$Estimate,se=mr_results$StdError))
    }else if(method == "Lasso"){
        mr_results = try(MR_lasso(bzy, bzx, bzy_se))
        if(class(mr_results)!="try-error"){
            return(list(bxy=mr_results$ThetaEstimate, se=mr_results$ThetaSE,pval=ifelse(abs(mr_results$ThetaEstimate/mr_results$ThetaSE)>1.96, 0, 1)))    ### no p value provided
        }else{
            return(list(bxy=NA, pval=NA))
        }
    }else if(method == "RAPS"){
        mr_results = mr.raps.overdispersed.robust(bzx, bzy, bzx_se, bzy_se,
                                           loss.function = "huber", k = 1.345, initialization = c("l2"),
                                           suppress.warning = FALSE, niter = 20, tol = .Machine$double.eps^0.5)
        return(list(bxy=mr_results$beta.hat,se=mr_results$beta.se, pval=mr_results$beta.p.value))
    }else if(method == "PRESSO"){
        presso.df = data.frame(bx = bzx, by = bzy, bxse = bzx_se, byse = bzy_se)
        mr_results = try(mr_presso(BetaOutcome = "by", BetaExposure = "bx", SdOutcome = "byse", SdExposure = "bxse",
                               OUTLIERtest = TRUE, DISTORTIONtest = TRUE, data = presso.df, NbDistribution = 3000, SignifThreshold = 0.05))
        if(class(mr_results)!="try-error"){
            if (!is.na(mr_results$`Main MR results`[2,"Causal Estimate"]) & !is.na(mr_results$`Main MR results`[2,"Sd"])){
                return(list(bxy=mr_results$`Main MR results`[2,"Causal Estimate"],se=mr_results$`Main MR results`[2,"Sd"], pval=mr_results$`Main MR results`[2,"P-value"]))
            } else{
                return(list(bxy=mr_results$`Main MR results`[1,"Causal Estimate"],se=mr_results$`Main MR results`[1,"Sd"], pval=mr_results$`Main MR results`[1,"P-value"]))
            }
        } else{
            return(list(bxy=NA, pval=NA))
        }
    }else if(method == "MRMix"){
        mr_results = MRMix(betahat_x=bzx, betahat_y=bzy, sx=bzx_se, sy=bzy_se, theta_temp_vec = seq(-0.5,0.5,by=0.01))
        if(show_condition(MRMix(betahat_x=bzx, betahat_y=bzy, sx=bzx_se, sy=bzy_se, 
                        theta_temp_vec = seq(-0.5,0.5,by=0.01)))[1]=="warning"){
  	return(list(pval=NA, bxy=NA,se=NA))
  }
	return(list(pval=mr_results$pvalue_theta, bxy=mr_results$theta,se=mr_results$SE_theta))
    }else if(method == "Con-Mix"){
        mr_results = mr_conmix(mr_input(bx=bzx, bxse=bzx_se, by=bzy, byse=bzy_se))
        b=mr_results$Estimate; se = (mr_results$CIUpper-mr_results$CILower)/2/1.96
	p=pchisq((b/se)^2,1,lower.tail=F)
	return(list(pval=mr_results$Pvalue, bxy=mr_results$Estimate,se=se))   ### No pvalue in the results of mr_conmix() function
    }else{stop("there is no code for this method!!!")}
}
