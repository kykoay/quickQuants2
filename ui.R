shinyUI(pageWithSidebar(
  headerPanel("Quick Quants"),
  
    sidebarPanel(
      helpText("To construct your portfolio, you will first need to upload a textfile with the names of the constituent stocks/ETFs on one column and the corresponding weight of the stock/ETF in the portfolio in decimal form on the other column. See sample below."),
      downloadButton(outputId="downloadSample",label="Download Sample Portfolio"),
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
                      ),
      downloadButton(outputId="downloadData",label="Download Data"),
      helpText("Factor data sourced from Ken French's Website."),
      downloadButton(outputId="downloadReport",label="Download Report"),
      helpText("The results might take awhile to process...reg monkey has to clean and process data for you. Reg monkey loves you!"),
      img(src="monkey.jpg",height=180),
      br(),
      br(),
      br(),
      selectInput(inputId="garchPlotType",label="What do you want to see for the GARCH?",
                  choices=list(
                    "Series with 1% VaR limites",
                    "QQ-Plot"
                  ),
                  selected="Seris with 1% VaR limits",
                  multiple=FALSE)
      
      ),    

    mainPanel(
     
      textOutput("greeting"),
      htmlOutput("regTable"),
      plotOutput("garchPlot")
      )
  ))