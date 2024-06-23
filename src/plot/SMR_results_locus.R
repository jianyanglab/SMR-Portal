args <- commandArgs(trailingOnly = TRUE)

suppressMessages({
library(GenomicRanges)
library(regioneR)
library(Repitools)
})

SMR_results_file=args[1]
SMR_plot_file=args[2]

SMR_results=read.table(SMR_results_file, head=T)

data=SMR_results
index=which(data$p_SMR < 0.05/ length(which(!is.na(data$p_SMR))) )
data=data[index,]
data$Chr=data$topSNP_chr
data$bp=data$topSNP_bp

data$Chr=paste0("chr", data$Chr)
data$LOCUS_START=data$bp-1000000
data$LOCUS_END=data$bp+1000000
region <- GRanges(data$Chr, IRanges(start = data$LOCUS_START, end = data$LOCUS_END))
merges=mergeRegions(region,region)
res=annoGR2DF(merges)

index=which(res$width >= 3000000)

if(length(index) > 0){
res_tmp=res[index,]
res_need=res[-index,]

res_tmp_split=data.frame()

for(region_index in 1:nrow(res_tmp)) {
  # print(paste0("region_index",region_index))
  chr_region = res_tmp$chr[region_index]
  start_region = res_tmp$start[region_index]
  end_region = res_tmp$end[region_index]

  # Subset data for SNPs within the current region
  snp_indices = which(data$Chr == chr_region & data$bp >= start_region & data$bp <= end_region)
  data_tmp = data[snp_indices, ]
  data_tmp = data_tmp[order(data_tmp$bp), ]  # Order by bp

# ---------------------------------------------------------------
# Make all the regions <= 3 Mb
# Rescale the LOCUS_START and LOCUS_END part
# The key here is that the distance between neighbor SNPs > 1Mb are separated
# < 1Mb are in the same locus.
#  ---------------------------------------------------------------

  # Initialize vectors for adjusted LOCUS_START and LOCUS_END
  adjusted_LOCUS_START = numeric(nrow(data_tmp))
  adjusted_LOCUS_END = numeric(nrow(data_tmp))
  adjusted_LOCUS_START[1] = data_tmp$LOCUS_START[1]
  
  # Adjust LOCUS_START and LOCUS_END based on SNP distances
  for(snp_index in 1:nrow(data_tmp)) {
    # print(paste0("snp_index",snp_index))
    if(snp_index < nrow(data_tmp)) {
      diff_bp = data_tmp$bp[snp_index + 1] - data_tmp$bp[snp_index]
      if(diff_bp > 1000000) {
        mid_point = round((data_tmp$bp[snp_index] + data_tmp$bp[snp_index + 1]) / 2)
        adjusted_LOCUS_END[snp_index] = mid_point
        adjusted_LOCUS_START[snp_index + 1] = mid_point
      } else {
        adjusted_LOCUS_START[snp_index + 1] = adjusted_LOCUS_START[snp_index]
      }
    } else {
      adjusted_LOCUS_END[snp_index] = data_tmp$LOCUS_END[snp_index]
    }
  }
  # Ensure continuity for LOCUS_END in segments with adjacent SNPs closer than 1Mb
  for(snp_index in 1:(nrow(data_tmp) - 1)) {
    # print(paste0("snp_index_new",snp_index))
    if(adjusted_LOCUS_START[snp_index] == adjusted_LOCUS_START[snp_index + 1]) {
      last_index = max(which(adjusted_LOCUS_START == adjusted_LOCUS_START[snp_index]))
      adjusted_LOCUS_END[snp_index] = adjusted_LOCUS_END[last_index]
    }
  }

  # Update data_tmp with adjusted start/end
  data_tmp$LOCUS_START = adjusted_LOCUS_START
  data_tmp$LOCUS_END = adjusted_LOCUS_END

  # Aggregate and combine results
  res_tmp_split_tmp = unique(data.frame(chr = data_tmp$Chr, start = data_tmp$LOCUS_START, end = data_tmp$LOCUS_END, width = data_tmp$LOCUS_END - data_tmp$LOCUS_START))
  res_tmp_split = rbind(res_tmp_split, res_tmp_split_tmp)
}
res=rbind(res_need, res_tmp_split)
}


index=which(res$start < 0)
res$start[index]=0
res=res[order(res$chr, res$start), ]

res$GWAS_LOCUS=paste0(res$chr,":",res$start,":",res$end)


data$GWAS_LOCUS=NA
for(j in 1:nrow(res)){
  chr=as.numeric(gsub("chr","",res$chr[j]))
  start=res$start[j]
  end=res$end[j]
  locus=res$GWAS_LOCUS[j]

  index=which(data$ProbeChr==chr & data$Probe_bp<=end & data$Probe_bp>=start)
  data$GWAS_LOCUS[index]=locus
}


plot_data=data[,c("probeID","Gene","GWAS_LOCUS","p_SMR","p_HEIDI")]


write.table(plot_data, SMR_plot_file, sep = "\t", quote = F, row.names = F, col.names = T)

