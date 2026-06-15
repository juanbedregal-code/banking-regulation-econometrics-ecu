# Financial Econometrics: Dynamic Panels & RDD in Ecuador's Cooperative Sector 🇪🇨

![Stata](https://img.shields.io/badge/Stata-1E4D8C?style=for-the-badge&logo=stata&logoColor=white)
![Econometrics](https://img.shields.io/badge/Econometrics-Dynamic_Panels-005b9f?style=for-the-badge)
![Causal Inference](https://img.shields.io/badge/Causal_Inference-RDD-276DC3?style=for-the-badge)

## 📌 Project Overview
This repository contains the replication package for the econometric analysis of the relationship between **Non-Performing Loans (NPL / Morosidad)** and **Credit Portfolio Growth** in the financial cooperative sector of Ecuador (2017-2024). 

The study overcomes severe Cross-Sectional Dependence (CSD) caused by the COVID-19 pandemic by utilizing **Driscoll-Kraay standard errors** in Dynamic Panel Data Models. Furthermore, it exploits regulatory asset size thresholds ($5M, $20M, $80M) established by the Ecuadorian Superintendency (SEPS) using a **Sharp Regression Discontinuity Design (RDD)** to evaluate the causal impact of stricter regulatory environments on credit risk.

### 🔑 Key Empirical Findings
- **The "U-Shape" Risk Trade-off:** Large cooperatives (Segment 1) exhibit a mathematically precise U-shaped relationship between credit expansion and default rates.
- **The "Shock of Sincerity":** Crossing the $20M threshold causes an abrupt, positive causal jump in *Adjusted* NPL, proving that stricter regulations force entities to recognize hidden portfolio deterioration.
- **Regulatory Arbitrage (Bunching):** McCrary density tests (`rddensity`) reveal massive manipulation at the $80M threshold, proving that medium-sized cooperatives artificially halt asset growth to avoid stricter jurisdictional oversight.

## 📂 DIME-Standard Directory Structure

```text
banking-regulation-econometrics/
├── Data/
│   ├── Raw/               # Raw financial panel and DATA_CONSTRUCTION_PROTOCOL.md
│   ├── Interim/           # Sub-samples for RDD tests
│   └── Cleaned/           # Final balanced panel ready for estimation
├── Code/
│   ├── 01_data_cleaning_eda.do             # Stata: Data wrangling, Winsorization, EDA
│   ├── 02_dynamic_panel_models.do          # Stata: Driscoll-Kraay, Diff-GMM, Sys-GMM
│   └── 03_rdd_regulatory_thresholds.do     # Stata: Sharp RDD, McCrary tests, Placebos
├── Outputs/
│   ├── Tables/            # RTF regression outputs and Excel matrices
│   └── Figures/           # RDD plots, density distributions, and quadratic fits
```

## 💾 Data and Code Availability Statement (DCAS)
- **Raw Data:** The primary dataset `ecuador_financial_panel_raw.xlsx` is provided in the `/Data/Raw` folder.
- **Provenance:** Data was manually compiled and harmonized from monthly public bulletins provided by the *Superintendencia de Economía Popular y Solidaria (SEPS)*, the *Superintendency of Banks*, and the *Central Bank of Ecuador (BCE)*. Detailed replication steps are documented in `DATA_CONSTRUCTION_PROTOCOL.md`. *(Note: An automated Python scraper is currently under development).*

## 💻 Computational Requirements
- **Stata:** Version 16+ is required.
- **Required user-written commands:** `xtabond2`, `xtscc`, `rdrobust`, `rddensity`, `winsor2`, `outreg2`, `coefplot`.
- **Wall-clock time:** ~15 minutes for full estimation on a standard 16GB RAM machine.
---
*Created by [Juan José Bedregal](https://github.com/juanbedregal-code)*
