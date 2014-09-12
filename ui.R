shinyUI(fluidPage(
  titlePanel("Portfolio Factor Exposure"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("To construct your portfolio, you will first need to upload a textfile with the names of the constituent stocks/ETFs on one column and the corresponding weight of the stock/ETF in the portfolio in decimal form on the other column."),
      h6("If you need help finding tickers,see"),a("Investorhub",href="http://www.myinvestorshub.com/yahoo_stock_list.php"),
      helpText("Reminder: you will need to type the corresponding weights of the given ticker on your portfolio.Please enter these weights in decimal form, as in 50% as 0.5."),
      #allow users to upload a file with tickers and weights.
      fileInput("file",label=h3("file to be uploaded")),
      # Allow users to input dates for data. 
      dateRangeInput(inputId="dateRange",
                     label="Get data starting from:",
                     start=(Sys.Date()-365*2),
                     min="1927-01-01",
                     startview="decade"
      )
      ),    

    mainPanel(
     
      textOutput("greeting"),
      htmlOutput("regTable")
      )
  )
  ))