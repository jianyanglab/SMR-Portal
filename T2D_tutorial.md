# A case study of using SMR-Portal.

Here, we use **type 2 diabetes (T2D)** as a case study to illustrate how to utilize SMR Portal for exploring gene-trait associations. A total of 370 genes were identified by the SMR & HEIDI analyses using summary statistics from a large-scale GWAS (80,154 T2D cases and 853,816 controls, all of European ancestry) ([PMID: 35551307](10.1038/s41588-022-01058-3)) and all the pre-built xQTL datasets through online analyses (**Figure 1**), which have been incorporated into the SMR database. Taking the *KCNJ11* gene as an example, the SMR and HEIDI analyses suggest that eQTL signals of *KCNJ11* in blood, brain, and esophagus, an sQTL signal in brain and skeletal muscle, and an mQTL signal in blood all coincide with the T2D GWAS signal at the *KCNJ11* gene locus, implying its role in T2D pathogenesis. The association of *KCNJ11* expression in each of these tissues with T2D can be visualized using the `Locus plot` function, and a `Multi-xQTL locus plot` to display the associations of *KCNJ11* with T2D across multiple tissues and/or xQTL layers simultaneously (**Figure 2**). Additionally, clicking the `Trait-wise Visualization` button redirects to a new webpage, which displays a list of all genes identified for T2D on the left-hand side, and a multi-xQTL locus plot of a selected locus on the right-hand side (**Figure 3**). When querying *KCNJ11*, users can investigate the presence of other associated genes in this locus, `chr11:16585616-17896930`. Notably, other prioritized genes in this locus include *NCR3LG1*, *ABCC8*, *PIK3C2A*, *NUCB2*, and *PLEKHA7*. Among these, *KCNJ11* and *ABCC8* are known targets for T2D therapy ([PMID: 12540637](10.2337/diabetes.52.2.568); [PMID: 26551672](10.1038/ng.3437)). The `Trait-wise Visualization` page features two interfaces: `The Most Significant` and `All xQTL Datasets`. `The Most Significant` interface displays each gene within the locus alongside the most significant SMR p-value for each omics layer. For a more detailed and customizable visualization, the `All xQTL Datasets` interface presents SMR results from various xQTL datasets, allowing users to select specific tissues or omics layers to generate customized locus plots (**Figure 4**).

## Figure 1. Creating a task for online SMR analysis

Creating a task for online SMR analysis: Users can input GWAS summary data, select pre-built xQTL datasets, and, if available, their own uploaded xQTL data, then submit the job for online processing.

### Upload GWAS summary data file

Please upload the GWAS summary statistics. It is recommended to use the GCTA-COJO format, although other formats are also supported.

### GCTA-COJO format

*mygwas.txt*

```
SNP    A1  A2  freq    b   se  p   n
rs1001    A   G   0.8493  0.0024  0.0055  0.6653  129850
rs1002    C   G   0.03606 0.0034  0.0115  0.7659  129799
rs1003    A   C   0.5128  0.045   0.038   0.2319  129830
......
```
Columns are SNP, the effect allele (A1), the other allele (A2), frequency of the effect allele (freq), effect size (b), standard error (se), p-value (p) and sample size (n). The headers are not keywords and will be omitted by the program. <span style="color: red;">Important: “A1” needs to be the effect allele with “A2” being the other allele and “freq” needs to be the frequency of “A1”.</span>

**NOTE:**

1) For a case-control study, the effect size should be log(odds ratio) with its corresponding standard error.
2) We use the GCTA-COJO format here to ensure compatibility with the GCTA software. Note that the column "n" will not be used in either the SMR or HEIDI analysis and thus can be replaced with "NA" if not available.
3) The allele frequency information in the column "freq" will be used in a QC step to remove SNPs with discrepant allele frequencies between datasets.
4) Please always input the summary statistics for all SNPs, even if your analysis only focuses on a subset of SNPs.
5) <span style="color: red;">If the GWAS summary data are in a format other than the GCTA-COJO format, the file to be uploaded must consist of eight columns. These columns should be labeled as follows: "SNP," "A1," "A2," "freq," "b," "se," "p," and "n."</span>



![Creating a task for online SMR analysis](https://static.westlakefuturegene.com/smr_images/tutorial_1.png)

## Figure 2. Querying the SMR database

Querying the SMR database: Users can search for a gene or trait of interest in the SMR database.

![Querying the SMR database](https://static.westlakefuturegene.com/smr_images/tutorial_2.png)

## Figure 3. Trait-wise visualization

This webpage features a table on the left-hand side that lists prioritized genes, with the right-hand side presenting the locus plot for a selected locus. The tissue with the most significant SMR p-value is highlighted for each omics layer.

<span style="background-color: #f0faff;">The Most Significant</span>。


Display the highest -log~10~(P~SMR~) values for each gene across each omics layer.

Specifically:
- `eSMR` represents the most significant -log~10~(P~SMR-eQTL~) value, which is the lowest P~SMR-eQTL~ values among all the eQTL datasets.
- `sSMR` represents the most significant -log~10~(P~SMR-sQTL~) value within all sQTL datasets.
- `mSMR` represents the most significant -log~10~(P~SMR-mQTL~) value within all mQTL datasets.
- `xSMR` represents the most significant -log~10~(P~SMR-xQTL~) value within all user-uploaded xQTL datasets.

The red marker in the upper right corner indicates a P~HEIDI~ > 0.01.

`All xQTL Datasets`

Display all selected xQTL -log10(PSMR) results for each gene in a tabular format , including only genes that exhibit significant PSMR values in at least one xQTL dataset. Users have the option to select any genes of interest along with their respective xQTL datasets to generate locus plots, which can be used to explore gene-trait associations across multiple tissues.

![Trait-wise visualization](https://static.westlakefuturegene.com/smr_images/tutorial_3.png)

# Figure 4. Customizing xQTL datasets for the locus plot

In the “All xQTL datasets” interface, users can select xQTL from different tissues or omics layers to create a customized locus plot as shown in **Figure 3**.

![Customizing xQTL datasets for the locus plot](https://static.westlakefuturegene.com/smr_images/tutorial_4.png)
