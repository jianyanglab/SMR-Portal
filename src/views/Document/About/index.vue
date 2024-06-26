<script setup lang="ts">
import Table1 from './Table1.vue'
import Table2 from './Table2.vue'
</script>

<template>
  <div class="min-h-screen max-w-[1280px] mx-auto py-10 px-8 space-y-16">
    <div class="space-y-3">
      <h5 class="font-lexend text-gamma text-xl">
        Citations
      </h5>
      <p>
        <b>Online tool and database</b>: Guo Y, Xu T, Luo J, Jiang Z, Chen W, Chen H, Qi T, Yang J (2024) SMR-Portal: an online platform for integrative analysis of GWAS and xQTL data to identify complex trait genes. Under review.
      </p>
      <p>
        <b>SMR and HEIDI methods</b>: Zhu Z, Zhang F, Hu H, Bakshi A, Robinson MR, Powell JE, Montgomery GW, Goddard ME, Wray NR, Visscher PM & Yang J (2016) Integration of summary data from GWAS and eQTL studies predicts complex trait gene targets. <a class="underline" href="https://www.nature.com/articles/ng.3538" target="_blank">Nature Genetics, 48:481-487</a>.
      </p>
    </div>

    <div class="space-y-3">
      <h5 class="font-lexend text-gamma text-xl">
        Links
      </h5>
      <div>
        Yang Lab (<a class="underline" href="https://yanglab.westlake.edu.cn/" target="_blank">https://yanglab.westlake.edu.cn/</a>)
      </div>
      <div>
        SMR software tool(<a class="underline" href="https://yanglab.westlake.edu.cn/software/smr" target="_blank">https://yanglab.westlake.edu.cn/software/smr</a>)
      </div>
    </div>

    <div class="space-y-3">
      <h5 class="font-lexend text-gamma text-xl">
        SMR Portal
      </h5>
      <p>
        <b>SMR Portal</b> is a web-based platform designed for the integrative analysis of genome-wide association study (GWAS) and molecular quantitative trait locus (xQTL) summary statistics to identify genes associated with complex traits, including diseases, using the summary-data-based Mendelian Randomization (SMR) and HEIDI (Heterogeneity in Dependent Instruments) methods. It comprises three modules: online SMR analysis, locus visualization, and SMR database. It aims to facilitate the discovery of complex trait genes, to elucidate the regulatory mechanisms underlying GWAS signals, and to enhance the accessibility of these gene-trait associations for the research community.
      </p>
      <div class="flex justify-center">
        <img src="https://static.westlakefuturegene.com/smr_images/SMR_Portal_Overview.png" class="max-h-[600px] max-w-[600px]">
      </div>
    </div>

    <div class="space-y-3 relative">
      <h5 class="font-lexend text-gamma text-xl">
        Online SMR analysis
      </h5>
      <a id="about_online_smr_analysis" class="absolute -top-24" />
      <p>
        The <b>online SMR analysis</b> module simplifies the SMR & HEIDI analysis processes so that users only need to provide GWAS summary statistics for a trait of interest. The platform provides users with access to 106 pre-built xQTL summary datasets, including 51 eQTL, 50sQTL, 2 mQTL, and 3pQTL datasets, spanning 4 omics layers, and 49 tissues (Table 1). Additionally, it offers users the flexibility to upload their own customized xQTL data. An online log file is available for users to monitor the progress of the analysis. Upon completion of the online SMR analyses, an email notification containing a hyperlink is sent to the designated email address, allowing users to access and visualize the results in the SMR-Portal.
      </p>
      <div class="flex justify-center">
        <img src="https://static.westlakefuturegene.com/smr_images/About_analysis.png" class="max-h-[600px] max-w-[600px]">
      </div>
    </div>

    <div class="space-y-3 relative">
      <h5 class="font-lexend text-gamma text-xl">
        SMR database
      </h5>
      <a id="about_smr_database" class="absolute -top-24" />
      <p>
        The <b>SMR database</b> is a continuously updated resource with visualization capabilities for pre-computed SMR results, covering a broad spectrum of complex traits with available large-scale GWAS summary statistics. It catalogues over 61,092 significant gene-trait associations derived from SMR & HEIDI analyses, encompassing 213 GWAS traits (Table 2) and 106 xQTL datasets. Users can query a gene or trait of interest, and the database will display significant gene-trait associations across various xQTL datasets, spanning multiple omics layers and tissues.
      </p>
      <div class="flex justify-center">
        <img src="https://static.westlakefuturegene.com/smr_images/About_database.png" class="max-h-[600px] max-w-[600px]">
      </div>
    </div>

    <div class="space-y-3">
      <h5 class="font-lexend text-gamma text-xl">
        Locus visualization
      </h5>
      <p>
        The <b>locus visualization</b> module provides interactive tools for visualizing GWAS, xQTL, and SMR association signals, along with genomic and epigenomic annotations in the locus identified by SMR & HEIDI. The visualization begins with the GWAS locus plot and the xQTL locus plots for molecular phenotypes associated with traits; the primary purpose of these plots is to show whether the GWAS signals coincide with the xQTL signals (i.e., the pleiotropy or causality model). Below the locus plots, a heatmap illustrates the chromatin states of the specified region across different cell types or tissues, using data from the Roadmap Epigenomics Mapping Consortium (REMC). These epigenomic annotations assist users in identifying functional elements, such as promoters, transcribed regions, and enhancers, along with their potential cell or tissue type specificity. In summary, the locus visualization module enhances our understanding of genetic regulatory mechanisms by demonstrating how genetic variants, potentially located within functional elements, affect one or more traits through molecular phenotypes.
      </p>
      <div class="flex justify-center">
        <img src="https://static.westlakefuturegene.com/smr_images/About_visualization.png" class="max-h-[600px] max-w-[600px]">
      </div>
    </div>

    <div class="space-y-3">
      <h5 class="font-lexend text-gamma text-xl">
        Data security Statement
      </h5>
      <p>
        To ensure the security of your data, you must log in to submit your GWAS summary data for the online SMR analysis. If you have not yet registered, you can do so <RouterLink to="/signup" class="!underline">
          here
        </RouterLink>
        . For those interested, a demo is available on the "Create a Task" interface.
      </p>
      <p>
        Should you have any questions, suggestions, or encounter any issues, please reach out to us at statgenlab@westlake.edu.cn.
      </p>
    </div>

    <div class="space-y-3">
      <h5 class="font-lexend text-gamma text-xl">
        Data Resource
      </h5>
      <p class="text-center">
        Table 1. Descriptive summary of xQTL datasets available in SMR-Portal.
      </p>
      <Table1 class="resource" />
      <div class="mb-20">
        &nbsp;
      </div>
      <p class="text-center">
        Table 2. Descriptive summary of the GWAS datasets used for building the SMR database.
      </p>
      <Table2 class="resource" />
    </div>
  </div>
</template>

<style lang="less">
table.resource {
  width: 1216px;
  border: 1px solid #e5e5e5;
  font-size: 10px;

  th{
    white-space: nowrap;
  }

  th,td {
    border: 1px solid #e5e5e5;
    padding:0 2px
  }
}
</style>
