# A case study of using SMR-Portal.

Here, we use **type 2 diabetes (T2D)** as a case study to illustrate how to utilize SMR Portal for exploring gene-trait associations. A total of 370 genes were identified by the SMR & HEIDI analyses using summary statistics from a large-scale GWAS (80,154 T2D cases and 853,816 controls, all of European ancestry) ([PMID: 35551307](10.1038/s41588-022-01058-3)) and all the pre-built xQTL datasets through online analyses (**Figure. 1**), which have been incorporated into the SMR database. Taking the *KCNJ11* gene as an example, the SMR and HEIDI analyses suggest that eQTL signals of *KCNJ11* in blood, brain, and esophagus, an sQTL signal in brain and skeletal muscle, and an mQTL signal in blood all coincide with the T2D GWAS signal at the *KCNJ11* gene locus, implying its role in T2D pathogenesis. The association of *KCNJ11* expression in each of these tissues with T2D can be visualized using the 'Locus plot' function, and a 'Multi-trait/xQTL locus plot' to display the associations of *KCNJ11* with T2D across multiple tissues and/or xQTL layers simultaneously (**Figure. 2a**). Additionally, clicking the 'Trait-wise Visualization' button redirects to a new webpage, which displays a list of all genes identified for T2D on the left-hand side, and a multi-xQTL locus plot of a selected locus on the right-hand side (**Figure. 3**). When querying *KCNJ11*, users can investigate the presence of other associated genes in this locus, 'chr11:16585616-17896930'. Notably, other prioritized genes in this locus include *NCR3LG1*, *ABCC8*, *PIK3C2A*, *NUCB2*, and *PLEKHA7*. Among these, *KCNJ11* and *ABCC8* are known targets for T2D therapy ([PMID: 12540637](10.2337/diabetes.52.2.568); [PMID: 26551672](10.1038/ng.3437)). The 'Trait-wise Visualization' page features two interfaces: 'The Most Significant' and 'All xQTL Datasets'. 'The Most Significant' interface displays each gene within the locus alongside the most significant SMR p-value for each omics layer. For a more detailed and customizable visualization, the 'All xQTL Datasets' interface presents SMR results from various xQTL datasets, allowing users to select specific tissues or omics layers to generate customized locus plots (**Figure. 4**). In addition, researchers interested in identifying multiple traits associated with the specific gene *KCNJ11* can use the database page to search for *KCNJ11*. This search will reveal multiple traits linked to the gene, such as type 2 diabetes, HbA1c, diabetes, and glucose levels. Users can then visualize the results for several traits related to the same gene/locus simultaneously using the 'Multi-trait/xQTL locus plot' (**Figure. 2b**). This visualization helps demonstrate scenarios where genetic associations for multiple complex traits and molecular phenotypes may be influenced by the same causal variant(s) (**Figure. 5**).

# Online analysis

## Figure 1. Creating a task for online SMR analysis

Creating a task for online SMR analysis: Users can input GWAS summary data, select pre-built xQTL datasets, and, if available, their own uploaded xQTL data, then submit the job for online processing.

![Creating a task for online SMR analysis](https://static.westlakefuturegene.com/smr_images/tutorial_1.png)

1) **Upload GWAS summary data file**

	Please upload the GWAS summary statistics (a demo is available here [GWAS.tar.gz](https://static.westlakefuturegene.com/smr_files/GWAS.txt.gz)). It is recommended to use the GCTA-COJO format, although other formats are also supported.

	**GCTA-COJO format**

	*mygwas.txt*

	```
	SNP    A1  A2  freq    b   se  p   n
	rs1001    A   G   0.8493  0.0024  0.0055  0.6653  129850
	rs1002    C   G   0.03606 0.0034  0.0115  0.7659  129799
	rs1003    A   C   0.5128  0.045   0.038   0.2319  129830
	......
	```

	Columns are SNP, the effect allele (A1), the other allele (A2), frequency of the effect allele (freq), effect size (b), standard error (se), p-value (p) and sample size (n). The headers are not keywords and will be omitted by the program. <span style="color: red;">**Important: “A1” needs to be the effect allele with “A2” being the other allele and “freq” needs to be the frequency of “A1”.**</span>

	**NOTE:**
    1) For a case-control study, the effect size should be log(odds ratio) with its corresponding standard error.
    2) We use the GCTA-COJO format here to ensure compatibility with the GCTA software. Note that the column "n" will not be used in either the SMR or HEIDI analysis and thus can be replaced with "NA" if not available.
	3) The allele frequency information in the column "freq" will be used in a QC step to remove SNPs with discrepant allele frequencies between datasets.
	4) Please always input the summary statistics for all SNPs, even if your analysis only focuses on a subset of SNPs.
	5) <span style="color: red;">If the GWAS summary data are in a format other than the GCTA-COJO format, the file to be uploaded must consist of eight columns. These columns should be labeled as follows: **"SNP," "A1," "A2," "freq," "b," "se," "p," and "n."**</span>

2) **Select pre-built xQTL files**

	The platform provides access to an extensive collection of xQTL summary data (see Table 1 on the About page), which are readily accessible in the SMR Portal without the need for additional downloads. These data are systematically organized into various categories for user selection, including 51 eQTLs, 50 sQTLs, and 2 mQTLs. Specifically, eQTLs are sourced from eQTLGen (Blood tissue, n=31,684), BrainMeta (Brain tissue, n=2,865), and GTEx v8 eQTL (49 tissues, n=838). sQTLs emanate from BrainMeta (Brain tissue, n=2,865) and GTEx v8 sQTL (49 tissues, n=838), while mQTLs are derived from BrainMeta (Brain tissue, n=1,160) and LBC+BSGS (Blood tissue, n=1,980).

3) **Upload user-customized xQTL file**

	Users who wish to conduct SMR analysis using their own xQTL summary data need to upload their xQTL in BESD format. To create a BESD file from data in various formats, please visit [https://yanglab.westlake.edu.cn/software/smr/#MakeaBESDfile](https://yanglab.westlake.edu.cn/software/smr/#MakeaBESDfile).
	
	We recommend that you follow the data processing guidelines below to upload your own xQTL file (a demo is available in [data/demo/xQTL_archive.tar.gz](data/demo/xQTL_archive.tar.gz)).

	1) **First, you need to process your own xQTL data into the query format.**

		*myquery.txt*
		```
		SNP    Chr BP  A1  A2  Freq    Probe   Probe_Chr   Probe_bp    Gene    Orientation b   se  p
		rs01    1   1001    A   G   0.23    cg01    1   1101    gene1   +   -0.033  0.006   3.8e-08
		rs01    1   1001    A   G   0.06    cg02    1   1201    gene2   -   0.043   0.007   8.1e-10
		......
		```

		Columns are SNP, SNP chromosome, SNP position, the effect allele, the other allele, frequency of the effect allele, probe name, probe chromosome, probe position, gene name, gene orientation, effect size, standard error, p-value. Important: “A1” needs to be the effect allele with “A2” being the other allele and “freq” needs to be the frequency of “A1”.
		
	2) **Second, you need to transform the xQTL from query format to BESD format.**
   
		Make a BESD file from SMR query output

		```
		smr --qfile myquery.txt --make-besd --out mybesd
		```

		Make a BESD file from BESD file (optional, if the dense format size is too large). To make a sparse BESD file from a single dense BESD file.

		```
		smr --beqtl-summary my_beqtl --make-besd --out my_sparse
		smr --beqtl-summary my_beqtl --cis-wind 2000 --trans-wind 1000 --peqtl-trans 5.0e-8 --peqtl-other 1.0e-5 --make-besd --out my_sparse
		```
	3) **Third, if you have multiple BESD files (e.g., chr1 to chr22) and wish to merge them into a single BESD file, you can create a sparse BESD file from multiple sparse or dense BESD files, which can be a mixture of both types.**

		```
		smr --besd-flist my_file.list --make-besd --out my_sparse
		```

		**--besd-flist** reads a file to get the full paths of the BESD files.

		*my_file.list*
		```
		path1/my_besd1
		path2/my_besd2
		path3/my_besd3
		...
		```

		**NOTE** : this command can be used to merge multiple BESD files.
		**HINT** : if the SNPs in all the .esi files are identical, you can speed up the analysis using the **--geno-uni** option.
		
	4) **Fourth, you need to create a '.tar.gz' archive containing your three files: xQTL.besd, xQTL.epi, and xQTL.esi.**

		```
		tar -czvf xQTL_archive.tar.gz xQTL.besd xQTL.epi xQTL.esi
		```

4) **Finally, users can upload the `xQTL_archive.tar.gz` file to conduct SMR analysis using their own xQTL data.**

# SMR database

## Figure 2. Querying the SMR database

Querying the SMR database: Users can search for a gene or trait of interest in the SMR database.

![Querying the SMR database](https://static.westlakefuturegene.com/smr_images/Tutorial_2.png)

`Trait-wise Visualization`

This plot function enables users to visualize locus plots for all gene-trait associations related to a specific trait.

`Locus plot`

This plot function allows users to generate a locus plot by selecting a specific gene-xQTL-phenotype association.

`Multi-xQTL/trait locus plot`

This plot function enables users to simultaneously explore gene-trait associations across multiple genes, omics layers, tissues, and traits, providing detailed visualizations of complex genetic interactions. (<span style="color: red;">Note: **Multiple traits** plot is available only when a gene is searched. (Figure. 2b, Figure. 5)</span>)

# Locus visualization

## Figure 3. Trait-wise visualization

This webpage features a table on the left-hand side that lists prioritized genes, with the right-hand side presenting the locus plot for a selected locus. The tissue with the most significant SMR p-value is highlighted for each omics layer.

![Trait-wise visualization](https://static.westlakefuturegene.com/smr_images/Tutorial_3.png)

`The Most Significant`

Display the highest -log<sub>10</sub>(*P*<sub>*SMR*</sub>) values for each gene across each omics layer.

Specifically:
- `eSMR` represents the most significant -log<sub>10</sub>(*P*<sub>*SMR-eQTL*</sub>) value, which is the lowest *P*<sub>*SMR-eQTL*</sub> values among all the eQTL datasets.
- `sSMR` represents the most significant -log<sub>10</sub>(*P*<sub>*SMR-sQTL*</sub>) value within all sQTL datasets.
- `pSMR` represents the most significant -log<sub>10</sub>(*P*<sub>*SMR-pQTL*</sub>) value within all pQTL datasets.
- `mSMR` represents the most significant -log<sub>10</sub>(*P*<sub>*SMR-mQTL*</sub>) value within all mQTL datasets.
- `xSMR` represents the most significant -log<sub>10</sub>(*P*<sub>*SMR-xQTL*</sub>) value within all user-uploaded xQTL datasets.

The red marker in the upper right corner indicates a *P*<sub>*HEIDI*</sub> > 0.01.

Only gene-trait associations within the same locus can be plotted.

## Figure 4. Customizing xQTL datasets for the locus plot

In the “All xQTL datasets” interface, users can select xQTL from different tissues or omics layers to create a customized locus plot as shown in **Figure 3**.

![Customizing xQTL datasets for the locus plot](https://static.westlakefuturegene.com/smr_images/Tutorial_4.png)

`All xQTL Datasets`

Display all selected xQTL -log<sub>10</sub>(*P*<sub>*SMR*</sub>) results for each gene in a tabular format , including only genes that exhibit significant *P*<sub>*SMR*</sub> values in at least one xQTL dataset. Users have the option to select any genes of interest along with their respective xQTL datasets to generate locus plots, which can be used to explore gene-trait associations across multiple tissues.

Only gene-trait associations within the same locus can be plotted.

## Figure 5. Multiple-trait visualization

The multi-trait locus plot illustrates the associations of a single gene with multiple traits simultaneously, demonstrating scenarios where genetic associations for multiple complex traits and molecular phenotypes may be influenced by the same causal variant(s).

![Customizing xQTL datasets for the locus plot](https://static.westlakefuturegene.com/smr_images/Tutorial_5.png)
