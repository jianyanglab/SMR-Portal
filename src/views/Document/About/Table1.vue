<template>
  <table>
    <col>
    <col>
    <col>
    <col>
    <col>
    <col>
    <col>
    <col>
    <tr>
      <th>QTL category</th>
      <th>QTL study</th>
      <th>QTL name</th>
      <th>Sample size</th>
      <th>Tissue</th>
      <th>Tissue or cell type</th>
      <th>Reference</th>
      <th>URL</th>
    </tr>
    <tr>
      <td rowspan="51">
        eQTL
      </td>
      <td>eQTLGen</td>
      <td>eQTLGen</td>
      <td>31,684</td>
      <td>Blood</td>
      <td>Blood</td>
      <td>Võsa, U. et al. Nat Genet. 2021</td>
      <td>https://www.nature.com/articles/s41588-021-00913-z</td>
    </tr>
    <tr>
      <td>BrainMeta</td>
      <td>eQTL_BrainMeta</td>
      <td>2,865</td>
      <td>Brain</td>
      <td>Brain</td>
      <td>Qi, T. et al. Nat Genet. 2022</td>
      <td>https://www.nature.com/articles/s41588-022-01154-4</td>
    </tr>
    <tr>
      <td rowspan="49">
        GTEx v8 eQTL
      </td>
      <td>eQTL_GTEx_Adipose_Subcutaneous</td>
      <td>663</td>
      <td>Adipose</td>
      <td>Adipose Subcutaneous</td>
      <td rowspan="49">
        Consortium,
        G. Science. 2020
      </td>
      <td rowspan="49">
        https://www.science.org/doi/10.1126/science.aaz1776
      </td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Adipose_Visceral_Omentum</td>
      <td>541</td>
      <td>Adipose</td>
      <td>Adipose Visceral Omentum</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Adrenal_Gland</td>
      <td>258</td>
      <td>Adrenal Gland</td>
      <td>Adrenal Gland</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Artery_Aorta</td>
      <td>432</td>
      <td>Blood Vessel</td>
      <td>Artery Aorta</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Artery_Coronary</td>
      <td>240</td>
      <td>Blood Vessel</td>
      <td>Artery Coronary</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Artery_Tibial</td>
      <td>663</td>
      <td>Blood Vessel</td>
      <td>Artery Tibial</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Amygdala</td>
      <td>152</td>
      <td>Brain</td>
      <td>Brain Amygdala</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Anterior_cingulate_cortex_BA24</td>
      <td>176</td>
      <td>Brain</td>
      <td>Brain Anterior cingulate cortex BA24</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Caudate_basal_ganglia</td>
      <td>246</td>
      <td>Brain</td>
      <td>Brain Caudate basal ganglia</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Cerebellar_Hemisphere</td>
      <td>215</td>
      <td>Brain</td>
      <td>Brain Cerebellar Hemisphere</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Cerebellum</td>
      <td>241</td>
      <td>Brain</td>
      <td>Brain Cerebellum</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Cortex</td>
      <td>255</td>
      <td>Brain</td>
      <td>Brain Cortex</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Frontal_Cortex_BA9</td>
      <td>209</td>
      <td>Brain</td>
      <td>Brain Frontal Cortex BA9</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Hippocampus</td>
      <td>197</td>
      <td>Brain</td>
      <td>Brain Hippocampus</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Hypothalamus</td>
      <td>202</td>
      <td>Brain</td>
      <td>Brain Hypothalamus</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Nucleus_accumbens_basal_ganglia</td>
      <td>246</td>
      <td>Brain</td>
      <td>Brain Nucleus accumbens basal ganglia</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Putamen_basal_ganglia</td>
      <td>205</td>
      <td>Brain</td>
      <td>Brain Putamen basal ganglia</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Spinal_cord_cervical_c-1</td>
      <td>159</td>
      <td>Brain</td>
      <td>Brain Spinal cord cervical c-1</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Brain_Substantia_nigra</td>
      <td>139</td>
      <td>Brain</td>
      <td>Brain Substantia nigra</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Breast_Mammary_Tissue</td>
      <td>459</td>
      <td>Breast Mammary</td>
      <td>Breast Mammary Tissue</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Cells_Cultured_fibroblasts</td>
      <td>504</td>
      <td>Skin</td>
      <td>Cells Cultured fibroblasts</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Cells_EBV-transformed_lymphocytes</td>
      <td>174</td>
      <td>Blood Vessel</td>
      <td>Cells EBV-transformed lymphocytes</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Colon_Sigmoid</td>
      <td>373</td>
      <td>Colon</td>
      <td>Colon Sigmoid</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Colon_Transverse</td>
      <td>406</td>
      <td>Colon</td>
      <td>Colon Transverse</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Esophagus_Gastroesophageal_Junction</td>
      <td>375</td>
      <td>Esophagus</td>
      <td>Esophagus Gastroesophageal Junction</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Esophagus_Mucosa</td>
      <td>555</td>
      <td>Esophagus</td>
      <td>Esophagus Mucosa</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Esophagus_Muscularis</td>
      <td>515</td>
      <td>Esophagus</td>
      <td>Esophagus Muscularis</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Heart_Atrial_Appendage</td>
      <td>429</td>
      <td>Heart</td>
      <td>Heart Atrial Appendage</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Heart_Left_Ventricle</td>
      <td>432</td>
      <td>Heart</td>
      <td>Heart Left Ventricle</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Kidney_Cortex</td>
      <td>85</td>
      <td>Kidney</td>
      <td>Kidney Cortex</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Liver</td>
      <td>226</td>
      <td>Liver</td>
      <td>Liver</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Lung</td>
      <td>578</td>
      <td>Lung</td>
      <td>Lung</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Minor_Salivary_Gland</td>
      <td>162</td>
      <td>Minor Salivary Gland</td>
      <td>Minor Salivary Gland</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Muscle_Skeletal</td>
      <td>803</td>
      <td>Muscle Skeletal</td>
      <td>Muscle Skeletal</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Nerve_Tibial</td>
      <td>619</td>
      <td>Nerve Tibial</td>
      <td>Nerve Tibial</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Ovary</td>
      <td>180</td>
      <td>Ovary</td>
      <td>Ovary</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Pancreas</td>
      <td>328</td>
      <td>Pancreas</td>
      <td>Pancreas</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Pituitary</td>
      <td>283</td>
      <td>Pituitary</td>
      <td>Pituitary</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Prostate</td>
      <td>245</td>
      <td>Prostate</td>
      <td>Prostate</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Skin_Not_Sun_Exposed_Suprapubic</td>
      <td>604</td>
      <td>Skin</td>
      <td>Skin Not Sun Exposed Suprapubic</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Skin_Sun_Exposed_Lower_leg</td>
      <td>701</td>
      <td>Skin</td>
      <td>Skin Sun Exposed Lower leg</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Small_Intestine_Terminal_Ileum</td>
      <td>187</td>
      <td>Small Intestine Terminal Ileum</td>
      <td>Small Intestine Terminal Ileum</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Spleen</td>
      <td>241</td>
      <td>Spleen</td>
      <td>Spleen</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Stomach</td>
      <td>359</td>
      <td>Stomach</td>
      <td>Stomach</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Testis</td>
      <td>361</td>
      <td>Testis</td>
      <td>Testis</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Thyroid</td>
      <td>653</td>
      <td>Thyroid</td>
      <td>Thyroid</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Uterus</td>
      <td>142</td>
      <td>Uterus</td>
      <td>Uterus</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Vagina</td>
      <td>156</td>
      <td>Vagina</td>
      <td>Vagina</td>
    </tr>
    <tr>
      <td>eQTL_GTEx_Whole_Blood</td>
      <td>755</td>
      <td>Whole Blood</td>
      <td>Whole Blood</td>
    </tr>
    <tr>
      <td rowspan="50">
        sQTL
      </td>
      <td>BrainMeta</td>
      <td>sQTL_BrainMeta</td>
      <td>2,865</td>
      <td>Brain</td>
      <td>Brain</td>
      <td>Qi, T. et al. Nat Genet. 2022</td>
      <td>https://www.nature.com/articles/s41588-022-01154-4</td>
    </tr>
    <tr>
      <td rowspan="49">
        GTEx v8 sQTL
      </td>
      <td>sQTL_GTEx_Adipose_Subcutaneous</td>
      <td>663</td>
      <td>Adipose</td>
      <td>Adipose Subcutaneous</td>
      <td rowspan="49">
        Consortium,
        G. Science. 2020
      </td>
      <td rowspan="49">
        https://www.science.org/doi/10.1126/science.aaz1776
      </td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Adipose_Visceral_Omentum</td>
      <td>541</td>
      <td>Adipose</td>
      <td>Adipose Visceral Omentum</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Adrenal_Gland</td>
      <td>258</td>
      <td>Adrenal Gland</td>
      <td>Adrenal Gland</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Artery_Aorta</td>
      <td>432</td>
      <td>Blood Vessel</td>
      <td>Artery Aorta</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Artery_Coronary</td>
      <td>240</td>
      <td>Blood Vessel</td>
      <td>Artery Coronary</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Artery_Tibial</td>
      <td>663</td>
      <td>Blood Vessel</td>
      <td>Artery Tibial</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Amygdala</td>
      <td>152</td>
      <td>Brain</td>
      <td>Brain Amygdala</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Anterior_cingulate_cortex_BA24</td>
      <td>176</td>
      <td>Brain</td>
      <td>Brain Anterior cingulate cortex BA24</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Caudate_basal_ganglia</td>
      <td>246</td>
      <td>Brain</td>
      <td>Brain Caudate basal ganglia</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Cerebellar_Hemisphere</td>
      <td>215</td>
      <td>Brain</td>
      <td>Brain Cerebellar Hemisphere</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Cerebellum</td>
      <td>241</td>
      <td>Brain</td>
      <td>Brain Cerebellum</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Cortex</td>
      <td>255</td>
      <td>Brain</td>
      <td>Brain Cortex</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Frontal_Cortex_BA9</td>
      <td>209</td>
      <td>Brain</td>
      <td>Brain Frontal Cortex BA9</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Hippocampus</td>
      <td>197</td>
      <td>Brain</td>
      <td>Brain Hippocampus</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Hypothalamus</td>
      <td>202</td>
      <td>Brain</td>
      <td>Brain Hypothalamus</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Nucleus_accumbens_basal_ganglia</td>
      <td>246</td>
      <td>Brain</td>
      <td>Brain Nucleus accumbens basal ganglia</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Putamen_basal_ganglia</td>
      <td>205</td>
      <td>Brain</td>
      <td>Brain Putamen basal ganglia</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Spinal_cord_cervical_c-1</td>
      <td>159</td>
      <td>Brain</td>
      <td>Brain Spinal cord cervical c-1</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Brain_Substantia_nigra</td>
      <td>139</td>
      <td>Brain</td>
      <td>Brain Substantia nigra</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Breast_Mammary_Tissue</td>
      <td>459</td>
      <td>Breast Mammary</td>
      <td>Breast Mammary Tissue</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Cells_Cultured_fibroblasts</td>
      <td>504</td>
      <td>Skin</td>
      <td>Cells Cultured fibroblasts</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Cells_EBV-transformed_lymphocytes</td>
      <td>174</td>
      <td>Blood Vessel</td>
      <td>Cells EBV-transformed lymphocytes</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Colon_Sigmoid</td>
      <td>373</td>
      <td>Colon</td>
      <td>Colon Sigmoid</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Colon_Transverse</td>
      <td>406</td>
      <td>Colon</td>
      <td>Colon Transverse</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Esophagus_Gastroesophageal_Junction</td>
      <td>375</td>
      <td>Esophagus</td>
      <td>Esophagus Gastroesophageal Junction</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Esophagus_Mucosa</td>
      <td>555</td>
      <td>Esophagus</td>
      <td>Esophagus Mucosa</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Esophagus_Muscularis</td>
      <td>515</td>
      <td>Esophagus</td>
      <td>Esophagus Muscularis</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Heart_Atrial_Appendage</td>
      <td>429</td>
      <td>Heart</td>
      <td>Heart Atrial Appendage</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Heart_Left_Ventricle</td>
      <td>432</td>
      <td>Heart</td>
      <td>Heart Left Ventricle</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Kidney_Cortex</td>
      <td>85</td>
      <td>Kidney</td>
      <td>Kidney Cortex</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Liver</td>
      <td>226</td>
      <td>Liver</td>
      <td>Liver</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Lung</td>
      <td>578</td>
      <td>Lung</td>
      <td>Lung</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Minor_Salivary_Gland</td>
      <td>162</td>
      <td>Minor Salivary Gland</td>
      <td>Minor Salivary Gland</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Muscle_Skeletal</td>
      <td>803</td>
      <td>Muscle Skeletal</td>
      <td>Muscle Skeletal</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Nerve_Tibial</td>
      <td>619</td>
      <td>Nerve Tibial</td>
      <td>Nerve Tibial</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Ovary</td>
      <td>180</td>
      <td>Ovary</td>
      <td>Ovary</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Pancreas</td>
      <td>328</td>
      <td>Pancreas</td>
      <td>Pancreas</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Pituitary</td>
      <td>283</td>
      <td>Pituitary</td>
      <td>Pituitary</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Prostate</td>
      <td>245</td>
      <td>Prostate</td>
      <td>Prostate</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Skin_Not_Sun_Exposed_Suprapubic</td>
      <td>604</td>
      <td>Skin</td>
      <td>Skin Not Sun Exposed Suprapubic</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Skin_Sun_Exposed_Lower_leg</td>
      <td>701</td>
      <td>Skin</td>
      <td>Skin Sun Exposed Lower leg</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Small_Intestine_Terminal_Ileum</td>
      <td>187</td>
      <td>Small Intestine Terminal Ileum</td>
      <td>Small Intestine Terminal Ileum</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Spleen</td>
      <td>241</td>
      <td>Spleen</td>
      <td>Spleen</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Stomach</td>
      <td>359</td>
      <td>Stomach</td>
      <td>Stomach</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Testis</td>
      <td>361</td>
      <td>Testis</td>
      <td>Testis</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Thyroid</td>
      <td>653</td>
      <td>Thyroid</td>
      <td>Thyroid</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Uterus</td>
      <td>142</td>
      <td>Uterus</td>
      <td>Uterus</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Vagina</td>
      <td>156</td>
      <td>Vagina</td>
      <td>Vagina</td>
    </tr>
    <tr>
      <td>sQTL_GTEx_Whole_Blood</td>
      <td>755</td>
      <td>Whole Blood</td>
      <td>Whole Blood</td>
    </tr>
    <tr>
      <td rowspan="3">
        pQTL
      </td>
      <td>INTERVAL</td>
      <td>pQTL_INTERVAL</td>
      <td>3,301</td>
      <td>Blood</td>
      <td>Plasma</td>
      <td>Sun, B. B. et al. Nature. 2018</td>
      <td>https://www.nature.com/articles/s41586-018-0175-2</td>
    </tr>
    <tr>
      <td>Fenland</td>
      <td>pQTL_FENLAND</td>
      <td>10,708</td>
      <td>Blood</td>
      <td>Plasma</td>
      <td>Pietzner et al. 2021 Science</td>
      <td>'https://www.science.org/doi/10.1126/science.abj1541</td>
    </tr>
    <tr>
      <td>SCALLOP</td>
      <td>pQTL_SCALLOP</td>
      <td>30,931</td>
      <td>Blood</td>
      <td>Plasma</td>
      <td>Folkersen, L. et al. Nat Metab. 2020</td>
      <td>https://www.nature.com/articles/s42255-020-00287-2</td>
    </tr>
    <tr>
      <td rowspan="2">
        mQTL
      </td>
      <td>BrainMeta</td>
      <td>mQTL_BrainMeta</td>
      <td>1,160</td>
      <td>Brain</td>
      <td>Brain</td>
      <td>Qi, T. et al. Nat Commun. 2018</td>
      <td>https://www.nature.com/articles/s41467-018-04558-1</td>
    </tr>
    <tr>
      <td>LBC + BSGS</td>
      <td>mQTL_McRae</td>
      <td>1,980</td>
      <td>Blood</td>
      <td>Blood</td>
      <td>McRae, A. F. et al. Sci Rep. 2018</td>
      <td>https://www.nature.com/articles/s41598-018-35871-w</td>
    </tr>
  </table>
</template>
