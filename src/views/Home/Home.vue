<script setup lang="ts">
import { Button, ConfigProvider } from 'ant-design-vue'
import { useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import Footer from './Footer.vue'
import { useUserStore, useViewNavStore } from '@/stores'

const router = useRouter()
const userStore = useUserStore()
const { user } = storeToRefs(userStore)
const viewNavStore = useViewNavStore()
const { login } = viewNavStore

function handleClick() {
  if (user.value)
    router.push('/task')
  else
    login()
}
</script>

<template>
  <div class="main">
    <div class="wrap">
      <div class="gene" />
      <div class="relative h-full pt-18 pb-16 max-w-[1280px] px-8 mx-auto flex flex-col z-10">
        <div class="flex-1 flex flex-col justify-center gap-8">
          <!-- <div class="font-lexend text-white tracking-tighter text-3xl lg:text-4xl">
            Summary-data-based Mendelian Randomization Portal
          </div> -->
          <div class="text-white text-xl">
            SMR Portal is designed to facilitate the integrative analysis of GWAS and xQTL summary statistics using the SMR & HEIDI methods, aiming to identify genes associated with complex traits, including diseases, and to enhance the accessibility of the identified gene-trait associations for the research community. 
          </div>
        </div>
        <div class="h-[48%] min-h-[280px] max-h-[320px] flex gap-10">
          <div class="flex-1 h-full glass px-10 py-[3%] flex flex-col justify-between">
            <div class="font-lexend text-white text-xl">
              Online SMR Analysis
            </div>
            <div class="text-white h-24 leading-6 mb-4">
              It streamlines the SMR and HEIDI analysis by requiring only a GWAS summary dataset as input and offers 106 pre-built xQTL datasets for integrative analysis, while also allowing users to upload their own xQTL data.
            </div>
            <div>
              <ConfigProvider
                :theme="{
                  components: {
                    Button: {
                      colorPrimary: 'rgba(255, 255, 255, 0.8)',
                      colorPrimaryHover: 'white',
                    },
                  },
                }"
              >
                <Button type="primary" ghost class="w-[180px]" @click="handleClick">
                  Try it now
                </Button>
              </ConfigProvider>
            </div>
          </div>
          <div class="flex-1 h-full glass px-10 py-[3%] flex flex-col justify-between">
            <div class="font-lexend text-white text-xl">
              SMR Database
            </div>
            <div class="text-white h-24 leading-6 mb-4">
              It catalogues 61,092 gene-trait associations derived from SMR & HEIDI analyses across 213 traits and 106 xQTL datasets.
            </div>
            <div>
              <ConfigProvider
                :theme="{
                  components: {
                    Button: {
                      colorPrimary: 'rgba(255, 255, 255, 0.8)',
                      colorPrimaryHover: 'white',
                    },
                  },
                }"
              >
                <Button type="primary" ghost class="w-[180px]" @click="router.push('/database')">
                  Query now
                </Button>
              </ConfigProvider>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="max-w-[1280px] mx-auto py-10 px-8 space-y-20">
    <div class="flex gap-4">
      <div class="flex-1 flex justify-center items-center">
        <img src="https://static.westlakefuturegene.com/smr_images/Home_analysis.png" alt="database" class="max-w-full" loading="lazy">
      </div>
      <div class="flex-1 space-y-6 flex flex-col justify-center">
        <h2 class="font-lexend text-2xl text-gamma">
          Online SMR Analysis
        </h2>
        <p>
          The online SMR analysis module simplifies the SMR & HEIDI analysis process, requiring only GWAS summary statistics as input. It offers access to 106 pre-built xQTL datasets and allows for the flexibility to upload customized xQTL data.
        </p>
        <div>
          <RouterLink to="/doc/about#about_online_smr_analysis">
            <Button type="primary" size="small">
              Learn more
            </Button>
          </RouterLink>
        </div>
      </div>
    </div>
    <div class="flex gap-4">
      <div class="flex-1 space-y-6 flex flex-col justify-center">
        <h2 class="font-lexend text-2xl text-gamma">
          SMR Database
        </h2>
        <p>
          The SMR database is a continuously updated resource that catalogues over 61,092 significant gene-trait associations derived from SMR & HEIDI analyses, covering 213 complex traits with available large-scale GWAS summary statistics.
        </p>
        <div>
          <RouterLink to="/doc/about#about_smr_database">
            <Button type="primary" size="small">
              Learn more
            </Button>
          </RouterLink>
        </div>
      </div>
      <div class="flex-1 flex justify-center items-center">
        <img src="https://static.westlakefuturegene.com/smr_images/Home_database.png" alt="database" class="max-w-full" loading="lazy">
      </div>
    </div>
  </div>
  <Footer />
</template>

<style lang="less">
.main{
  //background: linear-gradient(90deg, #002E6B 1.63%, #0D3672 36.42%, #0F3D7F 60.58%, #002E6C 98.27%);
  background: #012f6b;
  height: 100vh;
  min-height: 768px;
  max-height: 1080px;
  .wrap{
    position: relative;
    background: url('https://static.westlakefuturegene.com/smr_images/main.png') no-repeat bottom center;
    background-size: 1920px 1080px;
    height: 100%;
  }
  .gene{
    position: absolute;
    inset: 0;
    //background: url('/images/gene.png') no-repeat bottom -60px right -50px;
    height: 100%;
    max-width: 1920px;
    margin: 0 auto;
    pointer-events: none;
  }
  .glass{
    background: rgba(255, 255, 255, 0.1);
    //background: radial-gradient(84.63% 54.52% at 40.28% 44.35%, #38fbd833 0%, #b4d7ea00 100%), radial-gradient(34.52% 56.08% at 11.8% 91.72%, #1477bf63 0%, #b1b9d500 100%), radial-gradient(125.72% 72.41% at 27.03% 33.61%, #4eceeb7d 0%, #4f4cc961 62.09%, #4688e178 100%);
    //backdrop-filter: blur(2px);
    &:hover{
      background: rgba(255, 255, 255, 0.2);
      box-shadow: 0px 0px 10px 0px rgba(255, 255, 255, 0.2);
      //backdrop-filter: blur(5px);

    }
    button:hover{
      @apply !bg-white !text-gamma-secondary;
    }
  }
}
</style>
