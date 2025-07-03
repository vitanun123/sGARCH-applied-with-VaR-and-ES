# sGARCH-applied-with-VaR-and-ES
update version without external csv data of Siemen stock
# GARCH Modeling and Risk Backtesting for Siemens Stock (SIE.DE)

This project implements volatility modeling and risk backtesting using **GARCH-family models** for Siemens AG stock data (SIE.DE), retrieved directly from Yahoo Finance using the `yfR` package.

## Objectives

- Download monthly Siemens stock prices (2016–2020)
- Compute and visualize log-returns
- Fit and compare:
  - **GARCH(1,1)** with Student-t innovations
  - **APARCH(1,1)** with Student-t innovations
- Estimate:
  - **97.5% Value at Risk (VaR)**
  - **97.5% Expected Shortfall (ES)**
- Evaluate model performance using:
  - **Unconditional Coverage Test**
  - **Traffic Light Test** (Basel)

## Tools & Packages

- `yfR` – download stock data  
- `fGarch`, `ufRisk` – GARCH modeling, VaR/ES estimation, backtesting  
- `ggplot2`, `ggpubr`, `zoo` – time series visualization  
- `forecast` – autocorrelation diagnostics  

## Key Results

- The APARCH(1,1) model captures volatility clustering well  
- Estimated risk measures are consistent with actual losses  
- Backtests (UC Test and Traffic Light Test) indicate model adequacy (Green zone)  

## Structure

- Self-contained `.R` script  
- No external data files required  
- Visual output includes time series plots, ACF diagnostics, and risk measure charts  

---

> Developed as part of the W4451 Applied Project using R (Summer Semester 2023)
