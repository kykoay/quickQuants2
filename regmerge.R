#example on merging factors and portret.

library(shiny)
library(quantmod)
library(xts)
library(rugarch)
library(stargazer)
library(knitr)

#Download factors from Ken French
download.file("http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors_daily.zip","factors.zip")

factors=unz("factors.zip","F-F_Research_Data_Factors_daily.txt")
factors=read.table(factors,header=TRUE,skip=4,fill=TRUE)
n=nrow(factors)-1

factors=unz("factors.zip","F-F_Research_Data_Factors_daily.txt")
factors=read.table(factors,header=TRUE,skip=4,fill=TRUE,nrows=n)
row.names(factors)=(as.Date(row.names(factors),format="%Y%m%d"))
names(factors)[names(factors)=="Mkt.RF"]="MarketPremium"


factors=as.xts(factors/100,dateFormat="Date")

#get portfolio return
#Shows how to read files and read the columns as inputs to quantmod's getSymbols function.
sample=read.table("sample.csv",sep=",")
#turns the ticker into a list of strings, since this is what getSymbol reads.
stock=as.character(sample[,1])
weight=sample[,2]
#Thanks to Joshua Ulrich. See http://stackoverflow.com/questions/5574595/getsymbols-and-using-lapply-cl-and-merge-to-extract-close-prices
getSymbols(stock,src='yahoo',auto.assign=TRUE,from='2012-07-31',to='2014-07-31')
Adjusted <- do.call(merge, lapply(stock, function(x) Ad(get(x))))

portret=0
ret=NA
for (j in 1:length(weight)){
  for(i in 2:nrow(Adjusted)){
    ret[i]=(as.numeric(Adjusted[i,j])/as.numeric(Adjusted[i-1,j]))-1
  }
  portret=portret+(weight[j]*ret)
}
portret=na.omit(portret)

regdata=0
regdata=merge(portret,factors,all=c(TRUE,FALSE))

