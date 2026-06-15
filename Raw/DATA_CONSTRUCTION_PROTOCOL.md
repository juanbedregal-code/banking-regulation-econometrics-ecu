# 📂 Data Construction Protocol & Provenance

## 1. Overview
This document outlines the data provenance and the manual consolidation process required to build the Ecuadorian financial panel (2017-2024). Due to the fragmented nature of public reporting across different regulatory bodies, the primary dataset (`ecuador_financial_panel_raw.xlsx`) was systematically compiled by hand.

## 2. Institutional Data Sources
The dataset integrates micro-financial and macroeconomic variables from three official institutions:
1. **Superintendencia de Economía Popular y Solidaria (SEPS):** Monthly financial bulletins containing balance sheets and risk indicators for Cooperatives (Segments 1, 2, and 3).
2. **Superintendencia de Bancos del Ecuador (SB):** Monthly financial bulletins for Private Commercial Banks (Large, Medium, and Small).
3. **Banco Central del Ecuador (BCE):** M1 Money Supply.
4. **Instituto Nacional de Estadística y Censos (INEC):** Unemployment rate.

## 3. Consolidation Process
- Data was extracted period-by-period (monthly) and entity-by-entity from raw institutional reports (Excel/PDF formats).
- Accounting variables were harmonized across institutions to create standardized metrics: Total Assets, NPL (*Morosidad*), Adjusted NPL, ROE, and Liquidity ratios.
- The final product is a longitudinal, unbalanced panel dataset.

> ⚠️ **Future Development Notice:** 
> To enhance reproducibility, an automated Python data-engineering pipeline is currently under development. Once finalized, it will replace this manual consolidation protocol by programmatically scraping the SEPS and SB public endpoints.
