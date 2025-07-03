library(yfR)
library(ggplot2)
library(fGarch)
library(ggpubr)
library(zoo)
library(forecast)

set.seed(6858797)

# Import the stock data using Yahoo Finance API
data <- yf_get("SIE.DE", first_date = "2016-01-01", last_date = "2020-01-01")
close <- zoo(data$price_close, order.by = data$ref_date)
ret <- diff(log(close)) # Calculate returns

# Plot Log-transformed monthly Stock prices
fig_1 <- autoplot.zoo(close) +
  ylab("Log-price (price in EUR)") +
  ggtitle("Log-transformed monthly Stock prices, Jan 2016 to Jan 2020") +
  xlim(as.Date("2016-01-01"), as.Date("2019-12-31"))
fig_1

# Plot log-returns for stock prices
fig_2 <- autoplot.zoo(ret) +
  xlab("Year") +
  ylab("Price change (in EUR)") +
  ggtitle("Monthly log-price change, Jan 2016 to Jan 2020") +
  xlim(as.Date("2016-01-01"), as.Date("2019-12-31"))
fig_2

# Arrange the figures
plotd_SIEMEN <- ggarrange(fig_1, fig_2, nrow = 2, ncol = 1, align = "v")
plotd_SIEMEN

#b.Compute the log returns from the selected closing prices series---- 
data$Date <- as.Date(data$ref_date, format = "%Y-%m-%d")
str(data)
close <- zoo(data$price_close, order.by = data$ref_date)
log_close <- log(close)  
diff_close <- diff(close)
return <- diff(log(close))
t <- time(close)
min_t <- min(t)
max_t <- max(t)
log_return <- ggplot(data.frame(t = t[-1], xt = return), aes(x = t, y = xt)) +
  geom_line() +
  xlim(min_t, max_t) +
  xlab("Year") +
  ylab("Log-return") +
  ggtitle("Log-returns of the SIEMENS stock")
log_return

# Absolute returns
abs_ret <- abs(ret)

# ACF for log-returns, squared log-returns, and absolute log-returns
acf1 <- ggAcf(as.numeric(ret)) +
  ggtitle("Correlogram of the log-returns")

acf2 <- ggAcf(as.numeric(ret)^2) +
  ggtitle("Correlogram of the squared log-returns")

acf3 <- ggAcf(as.numeric(abs_ret)) +
  ggtitle("Correlogram of the absolute log-returns")

plot_ACF_SIEMEN <- ggarrange(acf1, acf2, acf3, ncol = 2, nrow = 2)
plot_ACF_SIEMEN

#c. split the return data and  a test set by reserving the last 250 observations----
#Using the training data for p = 1 and q = 1 for GARCH(p,q) and APARCH(p,q)
n_test <-  250 #number of observations
n_ret <- length(return) 
n_train <- n_ret - n_test
ret_train <-head(return, n_train)
#BIC GARCH MODEL
garchFit(~ garch(1, 1), ret_train, trace = FALSE,cond.dist = "std")@fit$ics[[2]]# fitted Garch(1,1)
#refitted GARCH(1,1) Model
garch_t <- garchFit(~ garch(1, 1), ret_train, trace = FALSE,cond.dist ="std")
garch_t
#BIC APARCH(1,1)
garchFit(~ aparch(1, 1), ret_train, trace = FALSE, cond.dist = "std")@fit$ics[[2]]
#refitted APRACH-t(1,1) MODEL
aparch_t <- garchFit(~ aparch(1, 1), ret_train, trace = FALSE, cond.dist = "std")
aparch_t

#d.97.5%VaR-(Value at Risk) and 97.5%-ES(expected shortfall )----
#plot the estimated 97.5%-VAR and 97.5%-ES
fcast <- varcast(as.numeric(close), model = "apARCH", distr = "std", 
                 garchOrder = c(1, 1)) 
Date <- data$Date
Date_test <- tail(Date, n_test)
VaR99 <- zoo(fcast$VaR.v, order.by = Date_test)
VaR975 <- zoo(fcast$VaR.e, order.by = Date_test)
ES975 <- zoo(fcast$ES, order.by = Date_test)
Loss_test <- tail(-return, 250)
violations <- Loss_test > VaR975
Date_violations <- Date_test[violations]
VaR_violations <- VaR975[violations]

df <- data.frame(Date = Date_test, Var975 = VaR975, ES975 = ES975, 
                 Loss = Loss_test)
df_vio <- data.frame(Date = Date_violations, VaR = VaR_violations)

colors <- c("Loss_test" = "gray64", "VaR975" = "red", "ES975" = "green")
labels <- c("Loss_test" = "Losses", "VaR975" = "97.5%-VaR", "ES975" = "97.5%-ES")

plot_ES_VaR <- ggplot(df, aes(x = Date)) +
  geom_segment(aes(y = Loss, xend = Date, yend = 0, color = "Loss_test")) +  
  geom_line(aes(y = VaR975, color = "VaR975")) +
  geom_line(aes(y = ES975, color = "ES975")) +
  geom_point(data = df_vio, aes(x = Date, y = VaR), color = "blue", size = 3,
             pch = 13) +
  scale_color_manual(values = colors, 
                     labels =labels,
                     name = "Series") +
  xlab("Month and year") +
  ylab("Loss, 97.5%-VaR and 97.5%-ES") +
  ggtitle("The test losses together with 97.5% risk measures")
plot_ES_VaR
# conclude: there are ten violations of the 97.5%-VaR in the test period
# the observed loss is smaller than the 97.5%-ES

#e conduct an unconditional coverage----
covtest(fcast)
#here we have P-Value 0.3805 is greater than 0.05 then we cannot reject we cannot reject the null hypothesis

#f conduct a traffic light test for the time-varying 99%-VaR and the time-varying 97.5%-ES----
trafftest(fcast)
#tests of 99%,97.5%-Var and 97.5%-ES are in the green zone 

