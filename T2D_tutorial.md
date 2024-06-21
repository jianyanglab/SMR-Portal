# A case study of using SMR-Portal.

Here, we use **type 2 diabetes (T2D)** as a case study to illustrate how to utilize SMR Portal for exploring gene-trait associations. A total of 370 genes were identified by the SMR & HEIDI analyses using summary statistics from a large-scale GWAS (80,154 T2D cases and 853,816 controls, all of European ancestry) ([PMID: 35551307](https://www.nature.com/articles/s41588-022-01058-3)) and all the pre-built xQTL datasets through online analyses (**Figure 1**), which have been incorporated into the SMR database. Taking the KCNJ11 gene as an example, the SMR and HEIDI analyses suggest that eQTL signals of KCNJ11 in blood, brain, and esophagus, an sQTL signal in brain and skeletal muscle, and an mQTL signal in blood all coincide with the T2D GWAS signal at the KCNJ11 gene locus, implying its role in T2D pathogenesis. The association of KCNJ11 expression in each of these tissues with T2D can be visualized using the 'Locus plot' function, and a 'Multi-xQTL locus plot' to display the associations of KCNJ11 with T2D across multiple tissues and/or xQTL layers simultaneously (**Figure 2**). Additionally, clicking the 'Trait-wise Visualization' button redirects to a new webpage, which displays a list of all genes identified for T2D on the left-hand side, and a multi-xQTL locus plot of a selected locus on the right-hand side (**Figure 3**). When querying KCNJ11, users can investigate the presence of other associated genes in this locus, chr11:16585616-17896930. Notably, other prioritized genes in this locus include NCR3LG1, ABCC8, PIK3C2A, NUCB2, and PLEKHA7. Among these, KCNJ11 and ABCC8 are known targets for T2D therapy (PMID: #). The 'Trait-wise Visualization' page features two interfaces: 'The Most Significant' and 'All xQTL Datasets'. 'The Most Significant' interface displays each gene within the locus alongside the most significant SMR p-value for each omics layer. For a more detailed and customizable visualization, the 'All xQTL Datasets' interface presents SMR results from various xQTL datasets, allowing users to select specific tissues or omics layers to generate customized locus plots (**Figure 4**).

## Figure 1: Creating a task for online SMR analysis

Creating a task for online SMR analysis: Users can input GWAS summary data, select pre-built xQTL datasets, and, if available, their own uploaded xQTL data, then submit the job for online processing.

![Creating a task for online SMR analysis](https://static.westlakefuturegene.com/smr_images/tutorial_1.png)

## Figure 2: Querying the SMR database

Querying the SMR database: Users can search for a gene or trait of interest in the SMR database.

![Querying the SMR database](https://static.westlakefuturegene.com/smr_images/tutorial_2.png)

## Figure 3: Trait-wise visualization

This webpage features a table on the left-hand side that lists prioritized genes, with the right-hand side presenting the locus plot for a selected locus. The tissue with the most significant SMR p-value is highlighted for each omics layer.

![Trait-wise visualization](https://static.westlakefuturegene.com/smr_images/tutorial_3.png)

# Figure 4: Customizing xQTL datasets for the locus plot

In the “All xQTL datasets” interface, users can select xQTL from different tissues or omics layers to create a customized locus plot as shown in panel c.

![Customizing xQTL datasets for the locus plot](https://static.westlakefuturegene.com/smr_images/tutorial_4.png)
