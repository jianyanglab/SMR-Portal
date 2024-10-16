
#### new function ####
plot_gsmr_effect2<-function(gsmr_data, expo_str, outcome_str,effect_col=colors()[75],highlight, highlight_col=colors()[70],xlab=expo_str,ylab=outcome_str) {
  resbuf = gsmr_snp_effect(gsmr_data, expo_str, outcome_str);
  
  bxy = resbuf$bxy
  bzx = resbuf$bzx; bzx_se = resbuf$bzx_se;
  bzy = resbuf$bzy; bzy_se = resbuf$bzy_se;
  # plot
  #plot_snp_effect(expo_str, outcome_str, bxy, bzx, bzx_se, bzy, bzy_se, effect_col)
  
  ## exclude the non-highlight SNPs
  effect_col=rep(effect_col,length(resbuf$snp))
  effect_col[resbuf$snp %in% highlight]=highlight_col
  
  
  plot_snp_effect2(expo_str, outcome_str, bxy, bzx, bzx_se, bzy, bzy_se, effect_col,highlight_col,xlab,ylab)
  
}


plot_snp_effect2<-function(expo_str, outcome_str, bxy, bzx, bzx_se, bzy, bzy_se, effect_col=colors()[75],highlight_col,xlab=expo_str,ylab=outcome_str) {
  vals = c(bzx-bzx_se, bzx+bzx_se)
  xmin = min(vals); xmax = max(vals)
  vals = c(bzy-bzy_se, bzy+bzy_se)
  ymin = min(vals); ymax = max(vals)
  plot(bzx, bzy, pch=20, cex=0.8, bty="n", cex.axis=1.1, cex.lab=1.2,
       col=effect_col, xlim=c(xmin, xmax), ylim=c(ymin, ymax),
       xlab=substitute(paste(trait, " (", italic(b[zx]), ")", sep=""), list(trait=xlab)),
       ylab=substitute(paste(trait, " (", italic(b[zy]), ")", sep=""), list(trait=ylab)))
  #xlab=substitute(paste(trait, " (", italic(b[zx]), ")", sep=""), list(trait=expo_str)),
  #ylab=substitute(paste(trait, " (", italic(b[zy]), ")", sep=""), list(trait=outcome_str)))
  if(!is.na(bxy)) abline(0, bxy, lwd=1.5, lty=2, col=highlight_col)
  ## Standard errors
  nsnps = length(bzx)
  for( i in 1:nsnps ) {
    # x axis
    xstart = bzx[i] - bzx_se[i]; xend = bzx[i] + bzx_se[i]
    ystart = bzy[i]; yend = bzy[i]
    segments(xstart, ystart, xend, yend, lwd=1.5, col=effect_col[i])
    # y axis
    xstart = bzx[i]; xend = bzx[i] 
    ystart = bzy[i] - bzy_se[i]; yend = bzy[i] + bzy_se[i]
    segments(xstart, ystart, xend, yend, lwd=1.5, col=effect_col[i])
  }
}





##############################


plot_gsmr_pvalue2<-function(gsmr_data, expo_str, outcome_str, gwas_thresh=5e-8,truncation=1e-50, effect_col=colors()[75],highlight, highlight_col=colors()[70], ylim=c(0,50),xlim=c(0,50),xlab=expo_str,ylab=outcome_str) {
  resbuf = gsmr_snp_effect(gsmr_data, expo_str, outcome_str);
  bzx_pval = resbuf$bzx_pval; bzy_pval = resbuf$bzy_pval;
  ## exclude the non-highlight SNPs
  effect_col=rep(effect_col,length(resbuf$snp))
  effect_col[resbuf$snp %in% highlight]=highlight_col
  
  # plot
  plot_snp_pval2(expo_str, outcome_str, bzx_pval, bzy_pval, gwas_thresh, truncation, effect_col,ylim=ylim,xlim=xlim,xlab,ylab)
}

plot_snp_pval2<-function(expo_str, outcome_str, bzx_pval, bzy_pval, gwas_thresh, truncation, effect_col,ylim=c(0,50),xlim=c(0,50),xlab,ylab) {
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
       col=effect_col, xlim=xlim, ylim=ylim,
       xlab=substitute(paste(trait, " (", -log[10], italic(P)[zx], ")", sep=""), list(trait=xlab)),
       ylab=substitute(paste(trait, " (", -log[10], italic(P[zy]), ")", sep=""), list(trait=ylab)))
  abline(h=gwas_thresh, lty=2, lwd=1.5, col="maroon")
}






#########################


plot_bxy_distribution2<-function(gsmr_data, expo_str, outcome_str, effect_col=colors()[75],highlight, highlight_col=colors()[70],xlab=expo_str,ylab=outcome_str) {
  resbuf = gsmr_snp_effect(gsmr_data, expo_str, outcome_str);
  bzx = resbuf$bzx; bzx_pval = resbuf$bzx_pval;
  bzy = resbuf$bzy; 
  bxy = bzy/bzx
  ## exclude the non-highlight SNPs
  effect_col=rep(effect_col,length(resbuf$snp))
  effect_col[resbuf$snp %in% highlight]=highlight_col
  
  # plot
  plot_snp_bxy(expo_str, outcome_str, bxy, bzx_pval, effect_col,xlab,ylab)
}

plot_snp_bxy<-function(expo_str, outcome_str, bxy, bzx_pval, effect_col,xlab=expo_str,ylab=outcome_str) {
  eps = 1e-300;
  bzx_pval = -log10(bzx_pval + eps);
  xmin = min(bxy, na.rm=T); xmax = max(bxy, na.rm=T)
  ymin = min(bzx_pval); ymax = max(bzx_pval);
  plot(bxy, bzx_pval, pch=20, cex=0.8, bty="n", cex.axis=1.1, cex.lab=1.2,
       col=effect_col, xlim=c(xmin, xmax), ylim=c(ymin, ymax),
       xlab=substitute(paste(italic(hat(b)[xy]), " (", trait1, " -> ", trait2, ")", sep=""), list(trait1=xlab, trait2=ylab)),
       ylab=substitute(paste(trait, " (", -log[10], italic(P[zx]), ")", sep=""), list(trait=xlab)))
}
