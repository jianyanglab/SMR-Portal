# ************************************************** #
#              Read exposure and outcome             #
# ************************************************** #
read_gsmr_trait = function(file_con) {
  expo_str = scan(file_con, nlines=1, quiet=TRUE, what="");
  outcome_str = scan(file_con, nlines=1, quiet=TRUE, what="");
  strbuf = scan(file_con, nlines=1, quiet=TRUE, what="");
  return(list(expo_str=expo_str, outcome_str=outcome_str))
}

# ************************************************** #
#                  Read GSMR result                  #
# ************************************************** #
read_gsmr_result = function(file_con) {
  expo_str = outcome_str = bxy = bxy_se = bxy_pval = bxy_m = c()
  while(1) {
    strbuf = scan(file_con, nlines=1, quiet=TRUE, what="");
    if(strbuf[1] == "#gsmr_end") break;
    if(strbuf[1] == "Exposure") next;
    expo_str = c(expo_str, strbuf[1]);
    outcome_str = c(outcome_str, strbuf[2]);
    bxy = c(bxy, as.numeric(strbuf[3]));
    bxy_se = c(bxy_se, as.numeric(strbuf[4]));
    bxy_pval = c(bxy_pval, as.numeric(strbuf[5]));
    bxy_m = c(bxy_m, as.numeric(strbuf[6]));
  }
  return(cbind(expo_str, outcome_str, bxy, bxy_se, bxy_pval, bxy_m))
}

# ************************************************** #
#                  Read SNP effects                  #
# ************************************************** #
read_snp_effect = function(file_con) {
  snp_effect = c()
  while(1) {
    strbuf = scan(file_con, nlines=1, quiet=TRUE, what="");
    if(strbuf[1] == "#effect_end") break;
    snp_effect = rbind(snp_effect, strbuf);
    print(length(strbuf))
    if(length(strbuf)<14) print(strbuf)
  }
  return(snp_effect)
}

# ************************************************** #
#                  Read SNP instruments              #
# ************************************************** #
read_snp_instru = function(file_con, snplist, nexpo, noutcome) {
  nrow = length(snplist); ncol = nexpo+noutcome
  snp_instru = matrix(NA, nrow, ncol)
  while(1) {
    strbuf = scan(file_con, nlines=1, quiet=TRUE, what="");
    if(strbuf[1] == "#marker_end") break;
    expo_indx = as.numeric(strbuf[1]); outcome_indx = as.numeric(strbuf[2]);
    forward_flag = TRUE;
    if(expo_indx < outcome_indx) {
      outcome_indx = outcome_indx - nexpo
    } else {
      expo_indx = expo_indx - nexpo
      forward_flag = FALSE;
    }
    snpbuf = scan(file_con, nlines=1, quiet=TRUE, what="");
    snp_indx = match(snpbuf, snplist)
    posbuf = rep(0, nrow); posbuf[snp_indx] = 1;
    indxbuf = expo_indx
    if(!forward_flag) indxbuf = indxbuf + nexpo
    if(length(which(!is.na(snp_instru[,indxbuf])))==0) {
      snp_instru[,indxbuf] = posbuf;
    } else {
      snp_instru[,indxbuf] = paste(snp_instru[,indxbuf], posbuf, sep="")
    }
  }
  return(snp_instru)
}

# ************************************************** #
#          Read output by GCTA-GSMR for plot         #
# ************************************************** #
read_gsmr_data = function(gsmr_effect_file) {
  trait_flag = gsmr_flag = marker_flag = effect_flag = FALSE;
  file_con = file(gsmr_effect_file, "r")
  while(1) {
    strbuf = scan(file_con, nlines=1, quiet=TRUE, what="");
    if(strbuf == "#trait_begin") {
      # Read the exposures and outcomes
      resbuf = read_gsmr_trait(file_con);
      expo_str = resbuf$expo_str; 
      outcome_str = resbuf$outcome_str;
      pheno_str = c(expo_str, outcome_str);
      nexpo = length(expo_str); noutcome = length(outcome_str)
      trait_flag = TRUE;
    } else if(strbuf == "#gsmr_begin") {
      # Read the GSMR result
      bxy_result = read_gsmr_result(file_con);
      colnames(bxy_result) = c("Exposure", "Outcome", "bxy", "se", "p", "n_snps")
      gsmr_flag = TRUE;
    } else if(strbuf == "#effect_begin") {
      # Read the summary statistics
      snp_effect = read_snp_effect(file_con);
      snplist = as.character(snp_effect[,1])
      effect_flag = TRUE;
    } else if(strbuf == "#marker_begin") {
      # Read the SNPs
      snp_instru = read_snp_instru(file_con, snplist, nexpo, noutcome);
      snp_effect = cbind(snp_effect[,1], snp_instru, snp_effect[,-1])
      marker_flag = TRUE;
    }
    if(trait_flag==T & gsmr_flag==T & marker_flag==T & effect_flag==T) break;
  }
  return(list(pheno=c(nexpo, noutcome, pheno_str), bxy_result=bxy_result, snp_effect = snp_effect))
}

# ************************************************** #
#         Display summary of the gsmr data           #
# ************************************************** #
gsmr_summary = function(gsmr_data) {
  message("\n## Exposure and outcome")
  pheno_str = gsmr_data$pheno[c(-1,-2)]
  # exposure
  nexpo = as.numeric(gsmr_data$pheno[1]);
  noutcome = as.numeric(gsmr_data$pheno[2]);
  logger_m = paste(nexpo, "exposure(s):");
  logger_m = paste(logger_m, gsmr_data$pheno[3])
  if(nexpo > 1) {
    for(i in 2 : nexpo) 
      logger_m = paste(logger_m, gsmr_data$pheno[i+2], sep=", ")
  } 
  message(logger_m)
  # outcome
  logger_m = paste(noutcome, "outcome(s):");
  logger_m = paste(logger_m, gsmr_data$pheno[3+nexpo])
  if(noutcome > 1) {
    for(i in 2 : noutcome) 
      logger_m = paste(logger_m, gsmr_data$pheno[i+2+nexpo], sep=", ")
  } 
  message(logger_m)
  
  message("\n## GSMR result")
  m_bxy_rst = data.frame(gsmr_data$bxy_result)
  print(m_bxy_rst)
}


# ************************************************** #
#               Retrieve SNP effects                 #
# ************************************************** #
gsmr_snp_effect = function(gsmr_data, expo_str, outcome_str) {
  # index of SNP instruments
  pheno_str = as.character(gsmr_data$pheno[c(-1,-2)])
  nexpo = as.numeric(gsmr_data$pheno[1])
  noutcome = as.numeric(gsmr_data$pheno[2])
  expo_indx = match(expo_str, pheno_str)
  if(is.na(expo_indx)) stop("\"", expo_str, "\" is not found.")
  outcome_indx = match(outcome_str, pheno_str)
  if(is.na(outcome_indx)) stop("\"", outcome_str, "\" is not found.")
  forward_flag = TRUE;
  if(expo_indx > outcome_indx) forward_flag = FALSE;
  if(forward_flag) {
    outcome_indx = outcome_indx - nexpo;
  } else {
    expo_indx = expo_indx - nexpo;
  }
  indxbuf = expo_indx + 1
  if(!forward_flag) indxbuf = indxbuf + nexpo
  strbuf = as.character(substr(gsmr_data$snp_effect[,indxbuf], outcome_indx, outcome_indx))
  snpindx = which(strbuf=="1")
  if(length(snpindx) < 3) stop("Not enough SNPs retained.")
  # bxy
  indxbuf = which(gsmr_data$bxy_result[,1]==expo_str & gsmr_data$bxy_result[,2]==outcome_str)
  bxy = as.numeric(gsmr_data$bxy_result[indxbuf, 3])
  # SNP effects
  if(forward_flag) {
    indxbuf1 = 1 + nexpo + noutcome + 3 + (expo_indx-1)*2 + 1
    indxbuf2 = 1 + nexpo + noutcome + 3 + nexpo*2 + (outcome_indx-1)*2 + 1
  } else {
    indxbuf1 = 1 + nexpo + noutcome + 3 + nexpo*2 + (expo_indx-1)*2 + 1
    indxbuf2 = 1 + nexpo + noutcome + 3 + (outcome_indx-1)*2 + 1
  }
  snpid = as.character(gsmr_data$snp_effect[snpindx,1])
  bzx = as.numeric(gsmr_data$snp_effect[snpindx,indxbuf1]); indxbuf1 = indxbuf1 + 1;
  bzx_se = as.numeric(gsmr_data$snp_effect[snpindx,indxbuf1]);
  bzx_pval = pchisq((bzx/bzx_se)^2, 1, lower.tail=F);
  bzy = as.numeric(gsmr_data$snp_effect[snpindx,indxbuf2]); indxbuf2 = indxbuf2 + 1;
  bzy_se = as.numeric(gsmr_data$snp_effect[snpindx,indxbuf2]);
  bzy_pval = pchisq((bzy/bzy_se)^2, 1, lower.tail=F);
  return(list(snp=snpid, bxy=bxy, bzx=bzx, bzx_se=bzx_se, bzx_pval=bzx_pval, bzy=bzy, bzy_se=bzy_se, bzy_pval=bzy_pval))
}

# ************************************************** #
#                  Plot bzy vs bzx                   #
# ************************************************** #
plot_snp_effect = function(expo_str, outcome_str, bxy, bzx, bzx_se, bzy, bzy_se, effect_col=colors()[75]) {
  vals = c(bzx-bzx_se, bzx+bzx_se)
  xmin = min(vals); xmax = max(vals)
  vals = c(bzy-bzy_se, bzy+bzy_se)
  ymin = min(vals); ymax = max(vals)
  plot(bzx, bzy, pch=20, cex=0.8, bty="n", cex.axis=1.1, cex.lab=1.2,
       col=effect_col, xlim=c(xmin, xmax), ylim=c(ymin, ymax),
       xlab=substitute(paste(trait, " (", italic(b[zx]), ")", sep=""), list(trait=expo_str)),
       ylab=substitute(paste(trait, " (", italic(b[zy]), ")", sep=""), list(trait=outcome_str)))
  if(!is.na(bxy)) abline(0, bxy, lwd=1.5, lty=2, col="dim grey")
  ## Standard errors
  nsnps = length(bzx)
  for( i in 1:nsnps ) {
    # x axis
    xstart = bzx[i] - bzx_se[i]; xend = bzx[i] + bzx_se[i]
    ystart = bzy[i]; yend = bzy[i]
    segments(xstart, ystart, xend, yend, lwd=1.5, col=effect_col)
    # y axis
    xstart = bzx[i]; xend = bzx[i] 
    ystart = bzy[i] - bzy_se[i]; yend = bzy[i] + bzy_se[i]
    segments(xstart, ystart, xend, yend, lwd=1.5, col=effect_col)
  }
}

# ************************************************** #
#             Plot bzy_pval vs bzx_pval              #
# ************************************************** #
plot_snp_pval = function(expo_str, outcome_str, bzx_pval, bzy_pval, gwas_thresh, truncation, effect_col) {
  eps = 1e-300; truncation = -log10(truncation);
  if(truncation > 300) {
    warning("The minimal truncated p-value would be 1e-300.")
    truncation = 300
  }
  bzx_pval = -log10(bzx_pval + eps);
  bzy_pval = -log10(bzy_pval + eps);
  pval = c(bzx_pval, bzy_pval)
  min_val = 0; max_val = max(pval);
  max_val = ifelse(max_val > truncation, truncation, max_val)
  gwas_thresh = -log10(gwas_thresh);
  plot(bzx_pval, bzy_pval, pch=20, cex=0.8, bty="n", cex.axis=1.1, cex.lab=1.2,
       col=effect_col, xlim=c(min_val, max_val), ylim=c(min_val, max_val),
       xlab=substitute(paste(trait, " (", -log[10], italic(P)[zx], ")", sep=""), list(trait=expo_str)),
       ylab=substitute(paste(trait, " (", -log[10], italic(P[zy]), ")", sep=""), list(trait=outcome_str)))
  abline(h=gwas_thresh, lty=2, lwd=1.5, col="maroon")
}

# ************************************************** #
#                Plot bxy vs bzx_pval                #
# ************************************************** #
plot_snp_bxy = function(expo_str, outcome_str, bxy, bzx_pval, effect_col) {
  eps = 1e-300;
  bzx_pval = -log10(bzx_pval + eps);
  xmin = min(bxy, na.rm=T); xmax = max(bxy, na.rm=T)
  ymin = min(bzx_pval); ymax = max(bzx_pval);
  plot(bxy, bzx_pval, pch=20, cex=0.8, bty="n", cex.axis=1.1, cex.lab=1.2,
       col=effect_col, xlim=c(xmin, xmax), ylim=c(ymin, ymax),
       xlab=substitute(paste(italic(hat(b)[xy]), " (", trait1, " -> ", trait2, ")", sep=""), list(trait1=expo_str, trait2=outcome_str)),
       ylab=substitute(paste(trait, " (", -log[10], italic(P[zx]), ")", sep=""), list(trait=expo_str)))
}

# ************************************************** #
#                  Effect size plot                  #
# ************************************************** #
# expo_str, exposure
# outcome_str, outcome
# effect_col, plotting colour
plot_gsmr_effect = function(gsmr_data, expo_str, outcome_str, effect_col=colors()[75]) {
  gsmr_snp_effect(gsmr_data1, ex, out)
  resbuf = gsmr_snp_effect(gsmr_data, expo_str, outcome_str);
  bxy = resbuf$bxy
  bzx = resbuf$bzx; bzx_se = resbuf$bzx_se;
  bzy = resbuf$bzy; bzy_se = resbuf$bzy_se;
  # plot
  plot_snp_effect(expo_str, outcome_str, bxy, bzx, bzx_se, bzy, bzy_se, effect_col)
}

# ************************************************** #
#                    P-value plot                    #
# ************************************************** #
# expo_str, exposure
# outcome_str, outcome
# effect_col, plotting colour
plot_gsmr_pvalue = function(gsmr_data, expo_str, outcome_str, gwas_thresh=5e-8, truncation=1e-50, effect_col=colors()[75]) {
  resbuf = gsmr_snp_effect(gsmr_data, expo_str, outcome_str);
  bzx_pval = resbuf$bzx_pval; bzy_pval = resbuf$bzy_pval;
  # plot
  plot_snp_pval(expo_str, outcome_str, bzx_pval, bzy_pval, gwas_thresh, truncation, effect_col)
}

# ************************************************** #
#                     bxy distribution plot                         #
# ************************************************** #

# expo_str, exposure
# outcome_str, outcome
# effect_col, plotting colour
plot_bxy_distribution = function(gsmr_data, expo_str, outcome_str, effect_col=colors()[75]) {
  resbuf = gsmr_snp_effect(gsmr_data, expo_str, outcome_str);
  bzx = resbuf$bzx; bzx_pval = resbuf$bzx_pval;
  bzy = resbuf$bzy; 
  bxy = bzy/bzx
  # plot
  plot_snp_bxy(expo_str, outcome_str, bxy, bzx_pval, effect_col)
}