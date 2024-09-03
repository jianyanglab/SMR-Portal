args <- commandArgs(trailingOnly = TRUE)
SCRIPT_DIR=args[1] 
trait_name=args[2] 
GWAS_DATA=args[3] 
qtl_name=args[4] 
qtl_clumpled_file=args[5] 
MR_snp_min=as.numeric(args[6])
OUTPUT=args[7] 
process_num=as.numeric(args[8])

# SCRIPT_DIR="/storage/yangjianLab/guoyazhou/GAMMA_github/gamma-script/scripts"
# trait_name="T2D"
# GWAS_DATA="/storage/yangjianLab/sharedata/GWAS_summary/01_Public/01_cojo/DIAMANTE_EUR_T2D_2022_NG.txt"
# qtl_name="eQTLGen"
# qtl_clumpled_file="/storage/yangjianLab/guoyazhou/new/QTL_data/QTL_clumping/total/eQTLGen_clumped.cojo"
# MR_snp_min=3
# OUTPUT="/storage/yangjianLab/guoyazhou/GAMMA_git_data"


# ----------------------------------------------------------------
# Multiple MR methods comparison ---------------------------------
suppressMessages({
source(paste0(SCRIPT_DIR, "/L2G/MR/MR_function/gsmr_plot_function.R"))
source(paste0(SCRIPT_DIR, "/L2G/MR/MR_function/GSMR_effect_plot.R"))
source(paste0(SCRIPT_DIR, "/L2G/MR/MR_function/comfun_file.R"))
source(paste0(SCRIPT_DIR, "/L2G/MR/MR_function/MR.R"))

library(data.table)
library(survey);
library(NCmisc);
library(MASS);
library(qvalue)
})


# GWAS summary statitics --------------------------------
gwas=fread(GWAS_DATA,head=T,stringsAsFactors=F,data.table=F)
colnames(gwas)[5:7]=c("b","se","p")

# QTL clumped data --------------------------------
QTL_clumped=fread(qtl_clumpled_file,head=T,stringsAsFactors=F,data.table=F)
colnames(QTL_clumped)[5:7]=c("b","se","p")
probe_SNP_nums=data.frame(table(QTL_clumped$probeID))
colnames(probe_SNP_nums)=c("probeID", "Freq")

# MR_snp_min ------------------------------------
index=which(probe_SNP_nums$Freq >= MR_snp_min)
probe_list=as.character(probe_SNP_nums$probeID[index])

# # MR comparison ----------------------------------
# res=data.frame()
# for(probe_id in probe_list){
# 	print(probe_id)
# 	QTL_clumped_tmp=QTL_clumped[which(QTL_clumped$probeID == probe_id),]
# 	gene_name=unique(QTL_clumped_tmp$gene_name)

# 	index=match(QTL_clumped_tmp$SNP, gwas$SNP, nomatch=0)
# 	if(length(which(index!=0)) >= MR_snp_min){
# 		QTL_clumped_tmp=QTL_clumped_tmp[which(index!=0),]
# 		gwas_tmp=gwas[index,]
		
# 		bzx=QTL_clumped_tmp$b;
# 		bzx_se=QTL_clumped_tmp$se;
# 		bzx_pval=QTL_clumped_tmp$p;
		
# 		bzy=gwas_tmp$b;
# 		bzy_se=gwas_tmp$se;
# 		bzy_pval=gwas_tmp$p;

# 		# c("GSMR_heidi_v1","IVW", "Median", "Simple_Median", "Mode", "Egger", "Robust", "Lasso",  "PRESSO", "MRMix")
# 		for(method in c("GSMR_heidi_v1","IVW", "Egger")){
# 			print(method)

# 			res_mr = all_mr(bzx, bzx_se, bzx_pval,
# 								bzy, bzy_se, bzy_pval, method=method, nsnps_thresh=MR_snp_min)
# 			res = rbind(res,data.frame(gene_name=gene_name,exposure=probe_id,outcome=trait_name,method, p=res_mr$pval, bxy=res_mr$bxy,nr_pleio_rm=length(res_mr$pleio)))

# 		}
# 	}
# }

# MR comparison ----------------------------------

# probe_id
process_probe <- function(probe_id) {
  QTL_clumped_tmp <- QTL_clumped[QTL_clumped$probeID == probe_id, ]
  gene_name <- unique(QTL_clumped_tmp$gene_name)

  index <- match(QTL_clumped_tmp$SNP, gwas$SNP, nomatch = 0)
  if (length(which(index != 0)) >= MR_snp_min) {
    QTL_clumped_tmp <- QTL_clumped_tmp[index != 0, ]
    gwas_tmp <- gwas[index, ]

    bzx <- QTL_clumped_tmp$b
    bzx_se <- QTL_clumped_tmp$se
    bzx_pval <- QTL_clumped_tmp$p

    bzy <- gwas_tmp$b
    bzy_se <- gwas_tmp$se
    bzy_pval <- gwas_tmp$p

    methods <- c("GSMR_heidi_v1", "IVW", "Egger")
    results <- lapply(methods, function(method) {
      res_mr <- all_mr(bzx, bzx_se, bzx_pval, bzy, bzy_se, bzy_pval, method = method, nsnps_thresh = MR_snp_min)
      data.frame(gene_name = gene_name,
                 exposure = probe_id,
                 outcome = trait_name,
                 method = method,
                 p = res_mr$pval,
                 bxy = res_mr$bxy,
                 nr_pleio_rm = length(res_mr$pleio),
                 stringsAsFactors = FALSE)
    })

    do.call(rbind, results)
  } else {
    NULL
  }
}



# process_num : parallel processing
if(process_num<=length(probe_list)){
  probe_list_index=seq(from = process_num, to = length(probe_list), by = 10)
  probe_list_new=probe_list[probe_list_index]
  print(paste0("--------------------- process num: ", process_num))
  print(probe_list_index)
  print(probe_list_new)

  res_list = lapply(probe_list_new, process_probe)
  res_list_new = res_list[!sapply(res_list, is.null)]
  res <- do.call(rbind, res_list_new)
}else{
  res <- NULL
}

if(!is.null(res)){
res[res$method=="GSMR_heidi_v1","method"]="GSMR"
res[res$method=="IVW","method"]="MR-IVW"
res[res$method=="Egger","method"]="MR-Egger"
res$z=p.to.Z(res$p)*sign(res$bxy)
res$se=res$bxy/res$z
# res$association=paste(res$exposure,"_to_",res$outcome,sep="")
res$lower=res$bxy-1.96*res$se
res$upper=res$bxy+1.96*res$se
res$qtl_name=qtl_name

res_final=res[,c("qtl_name","gene_name","exposure","method","bxy","se","p","lower","upper")]
colnames(res_final)=c("qtl_name","gene_name","probeID","method","bxy","se","pval","bxy_lower","bxy_upper")

write.table(res_final,paste0(OUTPUT,"/MR/detail/",trait_name,"_",qtl_name,"_",process_num,"_MR_comparison.txt"),
            row=F, col=T, quo=F, sep="\t")
}


