library(data.table);library(dplyr);library(tidyr)

#############################################
# MATH                                      #
#############################################

### INT
int = function(x){return(qnorm((rank(x,na.last="keep")-0.5)/sum(!is.na(x))))}

### positive rate
fpr = function(x) {sum(x<=0.05,na.rm=T)/length(which(!is.na(x)))}

### lambda
lambda_gc = function(pvalues) {qchisq(1-median(pvalues), 1)/qchisq(0.5,1)}

### sum with na.rm=T
narmsum = function(x) {sum(x, na.rm=T)}

numscale = function(x) {
if(sum(x==0)==length(x)){x}else{as.numeric(scale(x))}
}

### divide into multiple-task
taskcut = function(n, taskid, tasktotal){
return(which(cut(1:n, tasktotal) == levels(cut(1:n, tasktotal))[taskid]))
}

### GC correction
gccrt = function(pvalue, gc){
chisq = qchisq(pvalue, df=1, lower.tail=F)
chisqcrt = chisq/gc
pvaluecrt = pchisq(chisqcrt, df=1, lower.tail=F)
return(pvaluecrt)
}

### generate error terms with different distribution
grt_err = function(n,sigma, dis){
    ### dis=1: normal distribution
    ### dis=2-4: t distirbution with df=10,5,3
    ### dis=5-7; chisq distribution with df=15,5,1
    if(dis==1){e = rnorm(n);escaled=(e-0)/1
    }else if(dis==2){e = rt(n,10);escaled=(e-0)/sqrt(10/8)
    }else if(dis==3){e = rt(n,5);escaled=(e-0)/sqrt(5/3)
    }else if(dis==4){e = rt(n,3);escaled=(e-0)/sqrt(3/1)
    }else if(dis==5){e = rchisq(n,15);escaled=(e-15)/sqrt(2*15)
    }else if(dis==6){e = rchisq(n,5);escaled=(e-5)/sqrt(2*5)
    }else if(dis==7){e = rchisq(n,1);escaled=(e-1)/sqrt(2*1)
    }else{stop("ERROR: dis option can only be 1-7.")}
    esigma = escaled*sigma
    return(esigma)
}

############################################
# File process                             #
############################################

mydircreate = function(foldername){
dir.create(foldername, showWarnings = F, recursive = T)
}

fread_batch = function(filepathvector){
data = c()
for(filepath in filepathvector){
onedata = fread(filepath)
data = rbind(data, onedata)
}
return(data)
}

############################################
# Statistical tests                        #
############################################

gxe = function(y,g,e,method){
### gxe test
### paramter:
###     y: the phenotype
###     g: the genotype
###     e: the environmental factor
###     method: 1-multiple regression; 2: heterogeneity test (only for binary environmental factor)
if(method==1){
g2 = as.numeric(scale(g, scale=F))
e2 = as.numeric(scale(e, scale=F))
ge = g2*e2
p = coefficients(summary(lm(y~g2+e2+ge)))[4,4]
return(p)
}else if(method==2){
fit1 = lm( y[e == names(table(e))[1]] ~ g[e == names(table(e))[1]])
fit2 = lm( y[e == names(table(e))[2]] ~ g[e == names(table(e))[2]])
b1 = coefficients(summary(fit1))[2,1]; se1 = coefficients(summary(fit1))[2,2]
b2 = coefficients(summary(fit2))[2,1]; se2 = coefficients(summary(fit2))[2,2]
z = (b1-b2)/sqrt(se1^2+se2^2)
p = 1-pchisq(z^2,df=1)
return(p)
}else{stop("The method option could only be 1 or 2!!!")}
}

vqtl_test = function(x,y,method){
    ### method=1: Bartlett test
    ### method=2: Levene test (mean-based)
    ### method=3: Levene test (median-based)
    ### method=4: Fligner-Killeen
    ### method=5: Breusch-Pagan test
    ### method=6: Double Generalized Linear Model
    ### method=7: DGLM adj.P
    suppressPackageStartupMessages(library(car))
    suppressPackageStartupMessages(library(lmtest))
    suppressPackageStartupMessages(library(dglm))
    #nonaindex = which(!is.na(x) & !is.na(y))
    #x = x[nonaindex]; y=y[nonaindex]
    if(method==1){pvalue = tryCatch(bartlett.test(y~x)$"p.value", error=function(err) NA)
    }else if(method==2){pvalue = tryCatch(leveneTest(y~as.factor(x), center = mean)$"P"[1], error=function(err) NA)
    }else if(method==3){pvalue = tryCatch(leveneTest(y~as.factor(x), center = median)$"P"[1], error=function(err) NA)
    }else if(method==4){pvalue = tryCatch(fligner.test(y~x)$"p.value", error=function(err) NA)
    }else if(method==5){pvalue = tryCatch(bptest(y ~ x)$"p.value", error=function(err) NA)
    }else if(method==6){pvalue = tryCatch(coefficients(summary(dglm(y~x,dformula=~x))$"dispersion.summary")[2,4], error=function(err) NA)
    }else if(method==7){pvalue = tryCatch(anova.dglm(dglm(y~x,dformula=~x))$Adj.P[2], error=function(err) NA)
    }else{stop("ERROR: method option can only be 1-7.")}
    return(pvalue)
}

#############################################
# Genetics                                  #
#############################################
simSNP = function(Nsnp, Nsample, MinMAF, MaxMAF){
    if(Nsnp == 0){
        maf = NULL
        geno012 = NULL
        genostd = NULL
    }else if(Nsnp == 1){
        maf = runif(Nsnp, min=MinMAF, max=MaxMAF)
        geno012 = rbinom(Nsample, 2, maf)
        genostd = (geno012 - 2*maf)/sqrt(2*maf*(1-maf))
    }else{
        maf = runif(Nsnp, min=MinMAF, max=MaxMAF)
        geno012 = t(replicate(Nsample, rbinom(Nsnp, 2, maf)))
        colnames(geno012) = paste("SNP", 1:Nsnp, sep="")
        genostd = apply(rbind(geno012, maf), 2, function(x) (x-2*x[length(x)])/sqrt(2*x[length(x)]*(1-x[length(x)])))[1:Nsample,]
    }
    return(list(maf=maf, geno012=geno012,genostd=genostd))

}

#############################################
# PLINK2                                    #
#############################################

plink2 = "~/scratch/software/plink2/plink"

extractgeno = function(bfile, snpvector){
### extract the genotype of some snps
### parameter:
###     bfile: plink bfile
###     snpvector: a vector of snps
tmpout = paste(tempdir(), paste(basename(bfile), "snpvector", format(Sys.time(), "%Y-%m-%d-%H-%M-%S"), sep="_"), sep="/")
snplistout = paste(tmpout, ".snplist", sep="")
snplist = data.frame(V1=snpvector)
write.table(snplist, snplistout, sep="\t", col.names=F, row.names=F, quote=F)
cmd = paste(plink2, " --bfile ", bfile, " --extract ", snplistout, " --recode A --allow-no-sex --out ", tmpout, sep="")
system(cmd)
data = fread(paste(tmpout, ".raw", sep=""))
names(data) = sapply(strsplit(names(data), "_"), function(x) x[1])
file.remove(paste(tmpout,c("log","nosex","raw","snplist"), sep="."),showWarnings = F)
return(data)
}

extractgenopheno = function(bfile, snpvector, phenofile, phenoname, binary01=FALSE){
### extract the genotype of some snps
### parameter:
###     bfile: plink bfile
###     snpvector: a vector of snps
###     phenofile: the phenotype file (1 or more phenotypes)
###     phenoname: the phenotype column name
tmpout = paste(tempdir(), paste(basename(bfile), "snpvector", phenoname,  format(Sys.time(), "%Y-%m-%d-%H-%M-%S"), sep="_"), sep="/")
snplistout = paste(tmpout, ".snplist", sep="")
snplist = data.frame(V1=snpvector)
write.table(snplist, snplistout, sep="\t", col.names=F, row.names=F, quote=F)
if(binary01){
cmd = paste(plink2, " --bfile ", bfile, " --pheno ", phenofile, " --pheno-name ", phenoname, " --extract ", snplistout, " --recode A --allow-no-sex --out ", tmpout, " --1", sep="")
}else{
cmd = paste(plink2, " --bfile ", bfile, " --pheno ", phenofile, " --pheno-name ", phenoname, " --extract ", snplistout, " --recode A --allow-no-sex --out ", tmpout, sep="")
}
system(cmd)
data = fread(paste(tmpout, ".raw", sep=""))
names(data) = sapply(strsplit(names(data), "_"), function(x) x[1])
data = data %>% mutate(pheno=ifelse(PHENOTYPE==-9,NA,PHENOTYPE))
file.remove(paste(tmpout,c("log","nosex","raw","snplist"), sep="."),showWarnings = F)
return(data)
}

plink2ld = function(bfile, snp1, snp2){
### calculate the LD between two snps
if(snp1 == snp2){
return(list(r2=1, dprime = 1))
}else{
tmpfile = paste(tempdir(), paste(basename(bfile), gsub(":|;| ","_",snp1), gsub(":|;| ","_",snp2), format(Sys.time(), "%Y-%m-%d-%H-%M-%S"), sep="_"), sep="/")
write.table(rbind(snp1, snp2), paste(tmpfile, ".snplist", sep=""), quote=F, row.names=F, col.names=F)
cmd1 = paste(plink2, " --bfile ", bfile, " --extract ", tmpfile, ".snplist --make-bed --out ", tmpfile, sep="")
cmd2 = paste(plink2, " --bfile ", tmpfile, " --r2 inter-chr dprime-signed --ld-window-r2 0 --out ", tmpfile, sep="")
system(cmd1)
system(cmd2)
ld = fread(paste(tmpfile, ".ld", sep=""))
file.remove(paste(tmpfile, c("snplist", "log", "nosex", "ld", "bim", "fam", "bed"), sep="."), showWarnings=F)
return(list(r2=ld$R2, dprime = ld$DP))
}
}

plink2ld2 = function(bfile, onesnp, snpvector){
### calculate the LD between one SNP and each SNP in a set of SNPs
###     Input:
###         snpvector: vector
###     Output:
###         a data.frame contianing LD (R2 and DPrime)
snplist = data.frame(V1=c(onesnp, snpvector))
tmpfile = paste(tempdir(), paste(basename(bfile), gsub(":|;| ","_",onesnp), "snpvector", format(Sys.time(), "%Y-%m-%d-%H-%M-%S"), sep="_"), sep="/")
write.table(snplist, paste(tmpfile, ".snplist", sep=""), quote=F, row.names=F, col.names=F)
cmd = paste(plink2, " --bfile ", bfile, " --extract ", tmpfile, ".snplist --r2 inter-chr dprime-signed --ld-window-r2 0 --ld-snp '", onesnp, "' --out ", tmpfile, sep="")
system(cmd)
ld = fread(paste(tmpfile, ".ld", sep=""))
file.remove(paste(tmpfile, c("snplist", "log", "nosex", "ld"), sep="."), showWarnings=F)
return(ld)
}

qqplot_CI=function(pval, title){
### QQ plot with confidence interval, got from Yang Wu.
  p1 <- pval
  p2 <- sort(p1)
  n  <- length(p2)
  k  <- c(1:n)
  alpha   <- 0.05
  lower   <- qbeta(alpha/2,k,n+1-k)
  upper   <- qbeta((1-alpha/2),k,n+1-k)
  expect  <- (k-0.5)/n
  biggest <- ceiling(max(-log10(p2),-log10(expect)))
  shade <- function(x1, y1, x2, y2, color = col.shade) {
    n <- length(x2)
    polygon(c(x1, x2[n:1]), c(y1, y2[n:1]), border = NA, col = color)
  }
  xlim=max(-log10(expect)+0.1);
  ylim=biggest;
  plot(-log10(expect),-log10(p2),xlim=c(0,xlim),ylim=c(0,ylim),ylab=expression(paste("Observed  ","-",log[10],"(P)")), xlab=expression(paste("Expected  ","-",log[10],"(P)")), type = "n", main=title, cex.main=0.9, mgp=c(1.5,0.2,0), tcl=-0.1, bty="l")
  shade(-log10(expect),-log10(lower),-log10(expect),-log10(upper), color = "gray")
  abline(0,1,col="white",lwd=2)
  points(-log10(expect),-log10(p2), pch=20, cex=0.8, col=2)
  return(c(xlim,ylim))
}

## show condition of warnings
show_condition <- function(code) {
  tryCatch(code,
    error = function(c) "error",
    warning = function(c) "warning",
    message = function(c) "message"
  )
}


