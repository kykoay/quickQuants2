inFile<-read.table("sample.csv",sep=",")
start='2012-01-01'

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


buildPortReg=function(inFile,start,factors){
  portfolio=list(
      ticker=NULL
      ,weight=NULL
      ,ret=NULL
    )
  for(i in (1:nrow(inFile))){
  
    portfolio$ticker[i]=as.character(inFile[i,1])
    portfolio$weight[i]=inFile[i,2]
    ret=try(getSymbols(portfolio$ticker[i],auto.assign=FALSE,from=as.Date(start)))
    
    if(class(ret)[1]=="try-error"){
      ##Catch error here with:
      #error handling later 
      print("Oops... Something went horribly wrong. Please call Merissa.")
      return("fuck")
    }
    ret=ret[,6]
    names(ret)[1]="price"
    ret$ret=NA
    for ( j in 2:nrow(ret)){
      ret$ret[j]=as.numeric(ret$price[j])/as.numeric(ret$pric[j-1])-1
    }
    ret=na.omit(ret$ret)
    if(i==1){
      portfolio$ret=ret*portfolio$weight[i]
    }else{
      portfolio$ret=merge(portfolio$ret,ret*portfolio$weight[i],all = c(FALSE,FALSE))
    }
    #Keep in mind that portfolio$ret isn't ret in the usual sense... it's more like a contribution since it's already multiplied by the weight
  }


   portRet=as.xts(rowSums(portfolio$ret),order.by = index(portfolio$ret))
    
    out=(merge(portRet,factors,all=c(TRUE,FALSE)))
    
    return(out)
  }
}