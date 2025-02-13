//
//  StockDetails.swift
//  PortfolioApp
//
//  Created by Avi Aswal on 4/27/24.
//

import SwiftUI
import Alamofire
import Combine
import Kingfisher
import WebKit

struct NewsDetailView: View {
    let newsItem: NewsDataType
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        // CROSS BUTTON
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(newsItem.source)
                        .font(.system(size: 25))
                        .bold()
                    Text(formatDate(fromEpoch: newsItem.datetime))
                        .foregroundColor(.secondary)
                        .padding(.top, -5)
                    Divider()
                        .padding(.top, 10)
                    Text(newsItem.headline)
                        .font(.system(size: 20))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .bold()
                    Text(newsItem.summary)
                        .lineLimit(5)
                    HStack {
                        Text("For more details click")
                            .foregroundColor(.secondary)
                        Text("here")
                            .onTapGesture {
                                if let url = URL(string: newsItem.url) {
                                    openURL(url)
                                }
                            }
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                }
                .padding(.leading)
                .padding(.trailing)
                .padding(.top, 20)
                
                HStack {
                    // TWITTER BUTTON
                    Button(action: {
                        // Handle action
                        let url = URL(string: "https://twitter.com/intent/tweet?text=\(newsItem.url)")!
                        UIApplication.shared.open(url)
                    }) {
                        HStack {
                            Image("twitter")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        }
                    }
                    // FACEBOOK BUTTON
                    Button(action: {
                        // Handle action
                        let url = URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(newsItem.url)")!
                        UIApplication.shared.open(url)
                    }) {
                        HStack {
                            Image("facebook")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarItems(trailing: Button(action: {
                // This action will dismiss the sheet
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
            })
        }
    }
}

struct StockDetails: View {
    
    var ticker: String
    
    @State private var isInWatchlist: Bool = false
    
    @State private var showWatchlistAlert: Bool = false
    
    @State private var isLoading = false  // State to manage loading indicator
    @Environment(\.openURL) var openURL
    @State private var StockInfoData = StockInfoType(
        country : "",
        currency : "",
        estimateCurrency : "",
        exchange : "",
        finnhubIndustry : "",
        ipo : "",
        logo : "",
        marketCapitalization : 0,
        name : "",
        phone : "",
        shareOutstanding : 0,
        ticker : "",
        weburl : ""
    )
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var showingTradeSheet = false
    
    @State private var StockSummaryData = StockQuoteType(
        c : 0,
        d : 0,
        dp : 0,
        h : 0,
        l : 0,
        o : 0,
        pc : 0,
        t : 0
    )
    
    
    @State private var RecommendationData: [StockRecommendationType] = []
    @State private var RecommendHTML: String = ""
    
    @State private var HourlyChartData: [[Double]] = [[]]
    @State private var HourlyHTML: String = ""
    
    @State private var ChartMainData = ChartMainType (
        data1: [[]],
        data2: [[]]
        
    )
    @State private var MainchartHTML: String = ""
    
    @State private var showDetail = false
    @State private var NewsData: [NewsDataType] = []
    @State private var selectedNewsItem: NewsDataType?
    
    @State private var InsiderSentimentData = SentimentDataType(
        totalMspr : 0,
        positiveMspr : 0,
        negativeMspr: 0,
        totalChange: 0,
        positiveChange: 0,
        negativeChange: 0
    )
    
    @State private var PeerData: [String] = []
    
//    @State private var EarningsData = EarningsType(
//        actual: 0,
//        estimate: 0,
//        period: "",
//        quarter: 0,
//        surprise: 0,
//        surprisePercent: 0,
//        symbol: "",
//        year: 0
//    )
    
    @State private var EarningsData: [EarningsType] = []
    @State private var EarningsHTML: String = ""
    
    @State private var PortfolioList = PortfolioType(
        name: "",
        currentprice: 0,
        change: 0,
        marketvalue: 0,
        ticker: "",
        quantity: 0,
        avgCost: 0
    )
    
    @State private var PortfolioList2 = PortfolioType2(
        _id: "",
        ticker: "",
        quantity: 0,
        totalCost: 0,
        avgCost: 0
    )
    
    
    @State private var WalletAmount = WalletType(
        id: "",
        money: 0,
        p: "",
        networth: 0
    )
    
    var body: some View {
        if isLoading {
                VStack {
                    ProgressView("Fetching Data...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                .background(Color.white.opacity(0.8))
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            } else {

        ScrollView{
            
            //            //      Display a loading indicator when data is being fetched
            //            if isLoading {
            //                VStack {
            //                    ProgressView("Fetching Data...")
            //                        .progressViewStyle(CircularProgressViewStyle())
            //                        .scaleEffect(1.5)
            //                        .foregroundColor(.gray)
            //                }
            //                .frame(maxWidth: }, maxHeight: .infinity)
            //                .background(Color.white.opacity(0.8))
            //                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            //            } else {
            
            //            ScrollView{
            HStack {
                Text("\(StockInfoData.name)")
                    .foregroundColor(.secondary)
                    .font(.title2)
                Spacer ()
                if let logoURL = URL(string: StockInfoData.logo) {
                    AsyncImage(url: logoURL) { image in
                        image.resizable()
                        //                                         .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                        //.resizable()
                            .aspectRatio(contentMode: .fill)
                        //.frame(height: 160)
                            .clipped()
                            .cornerRadius(8)// Adjust the size as necessary
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 15)
            
            HStack {
                Text("$\(NSString(format: "%.2f", StockSummaryData.c))")
                    .fontWeight(.semibold)
                    .font(.system(size: 40))
                    .foregroundColor(.primary)
                Spacer()
                VStack(alignment: .leading) {
                    
                    HStack {
                        Image(systemName: StockSummaryData.d >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .foregroundColor(StockSummaryData.d >= 0 ? .green : .red)
                            .imageScale(.large)
                        Text("$\(NSString(format: "%.2f", StockSummaryData.d)) (\(NSString(format: "%.2f", StockSummaryData.dp))%)")
                            .foregroundColor(StockSummaryData.d >= 0 ? .green : .red)
                            .font(.title3)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 10)
            .padding(.bottom, -10)
            
            
            
            // TAB VIEW
            TabView {
                // HOURLY CHART
                HighchartsView(htmlStart: self.HourlyHTML).frame(width: 400,height: 500)
                    .frame(width: 400, height: 500)
                    .padding(.top, 50)
                    .padding(.horizontal, -50)
                    .tabItem {
                        Label("Hourly", systemImage: "chart.xyaxis.line")
                            .padding(.top, 20)
                    }
                
                
                // Second Tab
                HighchartsView(htmlStart: self.MainchartHTML).frame(width: 400,height: 500)
                    .frame(width: 500, height: 500)
                    .padding(.top, 50)
                    .padding(.horizontal, 30)
                    .tabItem {
                        Label("Historical", systemImage: "clock")
                            .padding(.top, 20)
                    }
            }
            .frame(height: 500)
            .padding(.top, 20)
            .padding(.horizontal, -20)
            
            
            // Portfolio section
            VStack(alignment: .leading) {
                Text("Portfolio")
                    .font(.title2)
                    .bold()
                    .padding()
                    .padding(.bottom, -10)
                    .padding(.top, 20)
                
                HStack {
                    if(PortfolioList2.quantity == 0) {
                        VStack {
                            VStack {
                                Text("You have 0 shares of \(StockInfoData.ticker).")
                                    .lineLimit(1)
                            }
                            VStack{
                                Text("Start trading!")
                                Spacer()
                            }
                        }
                    } else {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Shares Owned:    ")
                                    .bold()
                                Text("\(Int(PortfolioList2.quantity))")
                            }
                            .padding(.bottom, 10)
                            HStack {
                                Text("Avg. Cost / Share:     ")
                                    .bold()
                                Text("$\(NSString(format: "%.2f", PortfolioList2.avgCost))")
                            }
                            .padding(.bottom, 10)
                            HStack {
                                Text("Total Cost:     ")
                                    .bold()
                                Text("$\(NSString(format: "%.2f", PortfolioList2.totalCost))")
                            }
                            .padding(.bottom, 10)
                            HStack {
                                Text("Change:     ")
                                    .bold()
                                Text("$\(NSString(format: "%.2f", (PortfolioList2.quantity*StockSummaryData.c)-PortfolioList2.totalCost))")
                                    .foregroundColor(((PortfolioList2.quantity*StockSummaryData.c)-PortfolioList2.totalCost) >= 0 ? .green : .red)
                            }
                            .padding(.bottom, 10)
                            HStack {
                                Text("Market Value:     ")
                                    .bold()
                                Text("$\(NSString(format: "%.2f", PortfolioList2.quantity*StockSummaryData.c))")
                                    .foregroundColor(((PortfolioList2.quantity*StockSummaryData.c)-PortfolioList2.totalCost) >= 0 ? .green : .red)
                            }
                        }
                        .font(.system(size: 16))
                    }
                    Spacer()
                    Spacer()
                    VStack {
                        Button("Trade") {
                            // Action for the button tap
                            self.showingTradeSheet = true
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(45)
                        .bold()
                        .font(.system(size: 20))
                    }
                    .sheet(isPresented: $showingTradeSheet) {
                        // The content of the new trade sheet
                        TradeView(tickerData: self.StockInfoData, PortfoloioData: self.PortfolioList, walletData: WalletAmount, stockquote: self.StockSummaryData)
                    }
                    Spacer()
                    
                }
                .padding()
            }
            .padding([.leading, .trailing])
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Stats")
                    .bold()
                    .font(.title2)
                    .padding()
                    .padding(.bottom, -30)
                    .padding(.top, -20)
                
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text("High Price:").bold()
                        Spacer()
                        Text("Low Price:").bold()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("$\(NSString(format: "%.2f", StockSummaryData.h))")
                        Spacer()
                        Text("$\(NSString(format: "%.2f", StockSummaryData.l))")
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Open Price:").bold()
                        Spacer()
                        Text("Prev. Close:").bold()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("$\(NSString(format: "%.2f", StockSummaryData.o))")
                        Spacer()
                        Text("$\(NSString(format: "%.2f", StockSummaryData.pc))")
                    }
                }
                .padding()
                
                Text("About")
                    .bold()
                    .font(.title2)
                    .padding()
                    .padding(.bottom, -30)
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("IPO Start Date:").bold()
                        Text("Industry:").bold()
                        Text("Webpage:").bold()
                        Text("Company Peers:").bold()
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 5) {
                        let peerShow = PeerData
                        Text("\(StockInfoData.ipo)")
                        Text("\(StockInfoData.finnhubIndustry)")
                            .lineLimit(1)
                        Text("\(StockInfoData.weburl)")
                            .onTapGesture {
                                if let url = URL(string: StockInfoData.weburl) {
                                    openURL(url)
                                }
                            }
                            .lineLimit(1)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(peerShow, id: \.self) { peer in
                                    NavigationLink(destination: StockDetails(ticker: peer)) {
                                        Text(peer)
                                            .cornerRadius(5)
                                            .foregroundColor(.blue)
                                        
                                        if peer != peerShow.last {
                                            Text(",")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                
                Text("Insights")
                    .bold()
                    .font(.title2)
                    .padding()
                    .padding(.bottom, -30)
                Spacer()
                
                VStack {
                    Text("Insider Sentiments")
                        .font(.title2)
                    HStack {
                        Text("\(StockInfoData.name)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("MSPR")
                            .font(.headline)
                            .frame(width: 100, alignment: .center)
                            .padding(.horizontal, 10)
                        Spacer()
                        Text("Change")
                            .font(.headline)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                    }
                    .padding()
                    
                    // Divider
                    Divider()
                    
                    // Rows
                    Group {
                        SentimentRow(label: "Total", msprValue: InsiderSentimentData.totalMspr, changeValue: InsiderSentimentData.totalChange)
                        Divider()
                        SentimentRow(label: "Positive", msprValue: InsiderSentimentData.positiveMspr, changeValue: InsiderSentimentData.positiveChange)
                        Divider()
                        SentimentRow(label: "Negative", msprValue: InsiderSentimentData.negativeMspr, changeValue: InsiderSentimentData.negativeChange)
                        Divider()
                    }
                    .padding(.horizontal)
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding()
                Spacer()
                
                
                // RECOMMENDATION TRENDS CHART DISPLAY
                HighchartsView(htmlStart: self.RecommendHTML).frame(width: 400, height: 400)
                
                
                // EARNINGS CHART DISPLAY
                HighchartsView(htmlStart: self.EarningsHTML).frame(width: 400, height: 400)
                
                
                // NEWS DATA DISPLAY
                Text("News")
                    .bold()
                    .padding()
                    .font(.title2)
                    .padding(.bottom, -20)
                    .padding(.top, 0)
                
                
                VStack(alignment: .leading) {
                    ForEach(NewsData.indices, id: \.self) { index in
                        let newsItem = NewsData[index]
                        
                        if index == 0 {
                            // FIRST ITEM
                            KFImage(URL(string: newsItem.image))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(20)
                                .padding(.bottom, 10)
                                .onTapGesture {
                                    self.selectedNewsItem = newsItem
                                    self.showDetail = true
                                }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(newsItem.source)
                                        .foregroundColor(.secondary)
                                        .bold()
                                    Text(formatRelativeTime(fromEpoch: newsItem.datetime))
                                        .foregroundColor(.secondary)
                                }
                                Text(newsItem.headline)
                                    .font(.headline)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                Divider()
                                Spacer()
                            }
                            .onTapGesture {
                                self.selectedNewsItem = newsItem
                                self.showDetail = true
                            }
                        } else {
                            // ALL OTHER ITEMS
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(newsItem.source)
                                            .foregroundColor(.secondary)
                                            .bold()
                                        Text(formatRelativeTime(fromEpoch: newsItem.datetime))
                                            .foregroundColor(.secondary)
                                    }
                                    Text(newsItem.headline)
                                        .font(.headline)
                                }
                                .padding(.bottom, 20)
                                
                                Spacer()
                                KFImage(URL(string: newsItem.image))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(20)
                            }
                            .padding(.bottom, 10)
                            .onTapGesture {
                                self.selectedNewsItem = newsItem
                                self.showDetail = true
                            }
                        }
                    }
                }
                .padding()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
            //            }
        }
        .padding(.horizontal, 20)
        .onAppear() {
            isLoading = true  // START LOADING
            fetchHourlychartData(query: ticker)
            fetchPortfolioData(query: ticker)
            fetchStocknameData(query: ticker)
            fetchStocksummaryData(query: ticker)
            fetchCompanyPeers(query: ticker)
            fetchNews(query: ticker)
            fetchInsiderSentiment(query: ticker)
            fetchPortfolioData(query: ticker)
            fetchStockrecommendationData(query: ticker)
            fetchEarnings(query: ticker)
            fetchMainchartData(query: ticker)
        }
        .onReceive(timer) { _ in
            fetchPortfolioData(query: ticker)
        }
        .sheet(isPresented: $showDetail) {
            if let selectedNewsItem = selectedNewsItem {
                NewsDetailView(newsItem: selectedNewsItem)
            }
        }
        .navigationTitle(ticker)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    AddtoWatchlist(query: ticker)
                    toggleWatchlistStatus()
                }) {
                    Image(systemName: isInWatchlist ? "plus.circle.fill" : "plus.circle")
                }
            }
        }
        .overlay(
            VStack {
                Text("Adding \(StockInfoData.ticker) to Favorites")
                    .foregroundColor(.white)
                    .padding()
            }
                .frame(maxWidth: .infinity, maxHeight: 80)
                .background(Color.gray)
                .opacity(showWatchlistAlert ? 1 : 0)
                .cornerRadius(55)
                .padding(.horizontal, 40)
                .animation(.easeInOut(duration: 0.3), value: showWatchlistAlert)
                .padding(),
            alignment: .bottom
        )
        
    }
    }
    
    
    private func toggleWatchlistStatus() {
        isInWatchlist = true
        showWatchlistAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showWatchlistAlert = false
        }
    }
    
    
    // STOCKNAME DATA
    func fetchStocknameData(query: String) {
        print("STOCKINFO DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/stockname?symbol=\(query)"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let StockInfo = try decoder.decode(StockInfoType.self, from: data)
                    print("StockInfo Data: \(StockInfoData)")
                    DispatchQueue.main.async {
                        self.StockInfoData = StockInfo
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    
    // PORTFOLIO DATA
    func fetchPortfolioData(query: String) {
        print("PORTFOLIO DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/fetchByKey?symbol=\(query)"
        print(urlString)
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let portfolioData2 = try decoder.decode(PortfolioType2.self, from: data)
                    
                    DispatchQueue.main.async {
                        print("Portfolio Data 2 : \(portfolioData2)")
                        self.PortfolioList2 = portfolioData2
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    
    // STOCK SUMMARY DATA
    func fetchStocksummaryData(query: String) {
        print("STOCK SUMMARY DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/stocksummary?symbol=\(query)"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let Stocksummary = try decoder.decode(StockQuoteType.self, from: data)
                    print("StockSummary Data: \(Stocksummary)")
                    DispatchQueue.main.async {
                        self.StockSummaryData = Stocksummary
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    
    // HOURLY CHART DATA
    func fetchHourlychartData(query: String) {
        print("PORTFOLIO DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/stockcharthourly?symbol=\(query)"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let hourlydata = try decoder.decode([[Double]].self, from: data)
                    print("Hourly Chart Data: \(hourlydata)")
                    DispatchQueue.main.async {
                        self.HourlyChartData = hourlydata
                        
                        var colorName: String {
                            StockSummaryData.dp >= 0 ? "green" : "red"
                            }
                        
                        print("DATA IN HOURLY CHART: ", hourlydata)
                        
                        let hourlyhtml = """
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <script src="https://code.highcharts.com/highcharts.js"></script>
                            <script src="https://code.highcharts.com/modules/exporting.js"></script>
                            <script src="https://code.highcharts.com/modules/export-data.js"></script>
                            <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                        </head>
                        <body>
                            <div id="container" style="height: 100%; width: 100%; margin: 0 auto;"></div>
                            <script>
                                Highcharts.chart('container', {
                                chart: {
                                        type: 'line',
                                        backgroundColor: '#ffffff',
                                      },
                                      title: {
                                        text: `\(StockInfoData.ticker) Hourly Price Variation`,
                                      },
                                      xAxis: {
                                        type: 'datetime',
                                      },
                                      yAxis: {
                                        opposite: true,
                                        title: {
                                               text: '',
                                        },
                                      },
                                      series: [
                                        {
                                          name: '\(StockInfoData.ticker)',
                                          data: \(hourlydata),
                                          color: '\(colorName)',
                                          showInLegend: false
                                        },
                                      ],
                                      plotOptions: {
                                        series: {
                                          marker: {
                                            enabled: false,
                                          },
                                        },
                                      },                                
                            });
                            </script>
                        </body>
                        </html>
                        """
                        
                        self.HourlyHTML = hourlyhtml
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    
    // MAIN CHART FUNCTION
    func fetchMainchartData(query: String) {
        print("PORTFOLIO DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/stockchart?symbol=\(query)"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let chartdata = try decoder.decode(ChartMainType.self, from: data)
                    print("Main Chart Data: \(chartdata)")
                    DispatchQueue.main.async {
                        self.ChartMainData = chartdata
                        
//                        var colorName: String {
//                            StockSummaryData.dp >= 0 ? "green" : "red"
//                            }
                        
                        print("DATA IN MAIN CHART: ", chartdata)
                        
                        
                        let maincharthtml = """
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <script src="https://code.highcharts.com/stock/highstock.js"></script>
                            <script src="https://code.highcharts.com/stock/modules/drag-panes.js"></script>
                            <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
                            <script src="https://code.highcharts.com/stock/indicators/indicators.js"></script>
                            <script src="https://code.highcharts.com/stock/indicators/volume-by-price.js"></script>
                            <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                        </head>
                        <body>
                            <div id="container" style="height: 100%; width: 100%; margin: 0 auto;"></div>
                            <script>
                                Highcharts.chart('container', {
                                 chart: {
                                   },
                                   legend: {
                                       enabled: false
                                   },
                                   rangeSelector: {
                                       enabled: true,
                                       selected: 2,
                                       buttons: [
                                           {type: 'month', count: 1, text: '1m'},
                                           {type: 'month', count: 3, text: '3m'},
                                           {type: 'month', count: 6, text: '6m'},
                                           {type: 'ytd', text: 'YTD'},
                                           {type: 'year', count: 1, text: '1y'},
                                           {type: 'all', text: 'ALL'}
                                       ],
                                       inputEnabled: true
                                   },
                                   title: {
                                       text: "\(StockInfoData.ticker) Historical"
                                   },
                                   subtitle: {
                                       text: 'With SMA and Volume by Price technical indicators'
                                   },
                                   tooltip: {
                                       split: true
                                   },
                                   navigator: {
                                       enabled: true
                                   },
                                   series: [
                                       {type: 'candlestick', name: '\(StockInfoData.ticker) ', id: 'aap', zIndex: 2, data: \(chartdata.data1)},
                                       {type: 'sma', linkedTo: 'aap', zIndex: 1, params: {period: 10}, marker: {enabled: false}, color: 'orange'},
                                       {type: 'column', name: 'Volume', id: 'volume', data: \(chartdata.data2), yAxis: 1},
                                       {type: 'vbp', linkedTo: 'aap', dataLabels: {enabled: false}, zoneLines: {enabled: false}}
                                   ],
                                   xAxis: {
                                       type: 'datetime'
                                   },
                                yAxis: [
                                  {startOnTick: false, endOnTick: false, labels: {align: 'right', x: -3}, title: {text: 'OHLC'}, height: '60%', opposite: true, lineWidth: 2, resize: {enabled: true}},
                                  {labels: {align: 'right', x: -3}, title: {text: 'Volume'}, top: '65%', height: '35%', opposite: true, offset: 0, lineWidth: 2}
                              ]
                            });
                            </script>
                        </body>
                        </html>
                        """
                        
                        print("INISDE CHART FUNCTION", maincharthtml)
                        self.MainchartHTML = maincharthtml
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    
    
    // STOCKSUMMARY RECOMMENDER DATA
    func fetchStockrecommendationData(query: String) {
        print("RECOMMENDATION DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/stocksummaryrecommender?symbol=\(query)"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let RecommendData = try decoder.decode([StockRecommendationType].self, from: data)
                    print("Recommendation Data: \(RecommendData)")
                    DispatchQueue.main.async {
                        self.RecommendationData = RecommendData

                        let buy = RecommendData.map { "\($0.buy)" }.joined(separator: ",")
                        let hold = RecommendData.map { "\($0.hold)" }.joined(separator: ",")
                        let period = RecommendData.map { "'\($0.period)'" }.joined(separator: ",")
                        let sell = RecommendData.map { "\($0.sell)" }.joined(separator: ",")
                        let strongBuy = RecommendData.map { "\($0.strongBuy)" }.joined(separator: ",")
                        let strongSell = RecommendData.map { "\($0.strongSell)" }.joined(separator: ",")

                        print("DATA IN BUY: ", buy)
                        print("DATA IN PERIOD: ", period)

                        let htmlStart = """
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <script src="https://code.highcharts.com/highcharts.js"></script>
                            <script src="https://code.highcharts.com/modules/exporting.js"></script>
                            <script src="https://code.highcharts.com/modules/export-data.js"></script>
                            <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                        </head>
                        <body>
                            <div id="container" style="height: 100%; width: 100%; margin: 0 auto;"></div>
                            <script>
                                Highcharts.chart('container', {
                                    chart: {
                                            type: 'column',
                                          },
                                          title: {
                                            text: 'Recommendation Trends',
                                          },
                                          xAxis: {
                                            categories: [\(period)],
                                            
                                          },
                                          yAxis: {
                                            min: 0,
                                            title: {
                                              text: '# Analysis',
                                            },
                                            stackLabels: {
                                              enabled: false,
                                              style: {
                                                fontWeight: 'bold',
                                              },
                                            },
                                          },
                                          tooltip: {
                                            headerFormat: '<b>{point.x}</b><br/>',
                                            pointFormat: '{series.name}: {point.y}<br/>',
                                          },
                                          plotOptions: {
                                            column: {
                                              stacking: 'normal',
                                              dataLabels: {
                                                enabled: true,
                                              },
                                            },
                                          },
                                          series: [
                                            {
                                              type: 'column',
                                              name: 'Strong Buy',
                                              data: [\(strongBuy)],
                                              stack: 'recommendations',
                                              color: '#1a6334',
                                            },
                                            {
                                              type: 'column',
                                              name: 'Buy',
                                              data: [\(buy)],
                                              stack: 'recommendations',
                                              color: '#24af51',
                                            },
                                            {
                                              type: 'column',
                                              name: 'Hold',
                                              data: [\(hold)],
                                              stack: 'recommendations',
                                              color: '#b07e28',
                                            },
                                            {
                                              type: 'column',
                                              name: 'Sell',
                                              data: [\(sell)],
                                              stack: 'recommendations',
                                              color: '#f15053',
                                            },
                                            {
                                              type: 'column',
                                              name: 'Strong Sell',
                                              data: [\(strongSell)],
                                              stack: 'recommendations',
                                              color: '#CC0800',
                                            },
                                          ],
                                });
                            </script>
                        </body>
                        </html>
                        """

                        self.RecommendHTML = htmlStart
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    
    // NEWS DATA
    func fetchNews(query: String) {
        print("NEWS DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/news?symbol=\(query)"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let newsdata = try decoder.decode([NewsDataType].self, from: data)
                    print("News Data: \(NewsData)")
                    DispatchQueue.main.async {
                        self.NewsData = newsdata
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    
    // INSIDER SENTIMENT DATA
    func fetchInsiderSentiment(query: String) {
        print("INSIDER SENTIMENT DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/insidersentiment?symbol=\(query)"
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let sentimentdata = try decoder.decode(SentimentDataType.self, from: data)
                    print("Insider Data: \(sentimentdata)")
                    DispatchQueue.main.async {
                        self.InsiderSentimentData = sentimentdata
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    
    // COMPANY PEERS DATA
    func fetchCompanyPeers(query: String) {
        print("Company Peers DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/companypeers?symbol=\(query)"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let peerdata = try decoder.decode([String].self, from: data)
                    print("Peer Data: \(peerdata)")
                    DispatchQueue.main.async {
                        self.PeerData = peerdata
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
        isLoading = false  // STOP LOADING
    }
    
    
    // EARNINGS DATA
    func fetchEarnings(query: String) {
        print("PORTFOLIO DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/earnings?symbol=\(query)"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let earningdata = try decoder.decode([EarningsType].self, from: data)
                    print("Earnings Data: \(earningdata)")
                    DispatchQueue.main.async {
                        self.EarningsData = earningdata
                        
                        let actual = earningdata.map { "\($0.actual)" }.joined(separator: ",")
                        let estimate = earningdata.map { "\($0.estimate)" }.joined(separator: ",")
                        let period = earningdata.map { "'\($0.period)'" }.joined(separator: ",")
                        let surprise = earningdata.map { "\($0.surprise)" }.joined(separator: ",")
                        
                        print("DATA IN ACTUAL: ", actual)
                        print("DATA IN PERIOD: ", period)
                        
                        let earninghtml = """
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <script src="https://code.highcharts.com/highcharts.js"></script>
                            <script src="https://code.highcharts.com/modules/exporting.js"></script>
                            <script src="https://code.highcharts.com/modules/export-data.js"></script>
                            <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                        </head>
                        <body>
                            <div id="container" style="height: 100%; width: 100%; margin: 0 auto;"></div>
                            <script>
                                let categories1 = [\(period)].map((p, index) => p + '<br>Surprise: ' + [\(surprise)][index].toFixed(4));
                                Highcharts.chart('container', {
                                chart: {
                                    type: 'spline'
                                },
                                title: {
                                    text: 'Historical EPS Surprises'
                                },
                                xAxis: {
                                    categories: categories1,
                                },
                                yAxis: {
                                    title: {
                                        text: 'Quarterly EPS'
                                    }
                                },
                                plotOptions: {
                                    line: {
                                        dataLabels: {
                                            enabled: true
                                        },
                                        enableMouseTracking: true
                                    }
                                },
                                series: [{
                                    name: 'Actual',
                                    type: 'spline',
                                    data: [\(actual)].map(x => Number(x.toFixed(2))),
                                    color: 'blue'
                                }, {
                                    name: 'Estimate',
                                    type: 'spline',
                                    data: [\(estimate)],
                                    color: 'lightblue'
                                }],
                                tooltip:{
                                    shared:true,
                                    formatter: function() {
                                           let s = [\(period)][this.point.index];
                                           s += '<br/>Surprise: ' + [\(surprise)][this.points[0].point.index].toFixed(4);
                                           this.points.forEach(function(point) {
                                               if (point.series.name === 'Actual') {
                                               s += '<br/><span style="color:' + point.color + '">● </span>' + point.series.name + ':<b> ' + point.y.toFixed(2) + '</b>';
                                               } else {
                                                   s += '<br/><span style="color:' + point.color + '">● </span>' + point.series.name + ':<b> ' + point.y.toFixed(4) + '</b>';
                                               }
                                           });
                                           return s;
                                },
                                },
                                exporting:{
                                enabled:true
                                },
                            });
                            </script>
                        </body>
                        </html>
                        """
                        
                        self.EarningsHTML = earninghtml
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    
    // WALLET DATA
    func fetchWalletAmount() {
        print("WALLET DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/getmoney"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let walletData = try decoder.decode(WalletType.self, from: data)
                    print("Wallet Data: \(walletData)")
                    DispatchQueue.main.async {
                        self.WalletAmount = walletData
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
        print("Wallet success")
    }
    
    
    // ADD TO WATCHLIST
    func AddtoWatchlist(query: String) {
        print("WATCHLIST DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/mongowatchAdd?symbol=\(query)"
        
        print("Added to Watchlist", query)
        
        AF.request(urlString).responseData { response in
        }
    }
    
    
    // REMOVE FROM WATCHLIST
    func RemovefromWatchlist(query: String) {
        print("WATCHLIST DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/mongowatchRemove?symbol=\(query)"
        
        print("Removed From Watchlist", query)
        
        AF.request(urlString).responseData { response in
        }
    }
    
    
    // CHECK IN WATCHLIST
    func CheckinWatchlist(query: String) {
        print("WATCHLIST DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/mongowatchCheck?symbol=\(query)"
        
        print("Checking in Watchlist", query)
        
        AF.request(urlString).responseData { response in
        }
    }
}


// EPOCH TO "March 21, 2024"
func formatDate(fromEpoch epoch: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: epoch)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd, yyyy"
    return dateFormatter.string(from: date)
}


// EPOCH TO "3 hr, 52 min"
func formatRelativeTime(fromEpoch epoch: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: epoch)
    let currentDate = Date()
    let difference = Calendar.current.dateComponents([.hour, .minute], from: date, to: currentDate)
    
    guard let hours = difference.hour, let minutes = difference.minute else {
        return "Time calculation error"
    }
    
    return "\(hours) hr, \(minutes) min"
}


struct SentimentRow: View {
    var label: String
    var msprValue: Double
    var changeValue: Double
    
    var body: some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text(String(format: "%.2f", msprValue))
                .frame(width: 100, alignment: .center)
                .lineLimit(1)
            Spacer()
            Text(String(format: "%.2f", changeValue))
                .frame(maxWidth: 200, alignment: .trailing)
                .lineLimit(1)
        }
    }
}


// TRADE VIEW SHEET
struct TradeView: View {
    let tickerData: StockInfoType
    @State var PortfoloioData: PortfolioType
    @State var walletData: WalletType
    let stockquote: StockQuoteType
    @State private var showAlert: Bool = false
    @State private var showConfirmationBuy = false
    @State private var showConfirmationSell = false
    @State private var showErrorAlert: Bool = false // New state for handling the error alert
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var numberOfSharesText: String = "0"
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack {
                    Text("Trade \(tickerData.name) shares")
                        .font(.title3)
                        .bold()
                    
                    VStack(alignment: .trailing, spacing: 15) {
                        Spacer(minLength: 200)
                        HStack {
                            TextField("0", text: $numberOfSharesText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.leading)
                                .frame(width: 100, height: 100)
                                .font(.system(size: 65, weight: .bold))
                                .onReceive(numberOfSharesText.publisher.collect()) {
                                    self.numberOfSharesText = String($0.prefix(2))
                                }
                                .padding(.horizontal, 10)
                            Spacer()
                            Text(Int(numberOfSharesText) ?? 0 <= 1 ? "Share" : "Shares")
                                .font(.system(size: 35))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 0)
                        }
                        Text("X $\(stockquote.c, specifier: "%.2f")/share = $\(Double(Int(numberOfSharesText) ?? 0) * stockquote.c, specifier: "%.2f")")
                            .font(.system(size: 15))
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    
                    Spacer(minLength: 150)
                    
                    //BUY AND SELL BUTTONS
                    Text("$\(NSString(format: "%.2f", walletData.money)) available to buy \(tickerData.ticker)")
                        .bold()
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                    HStack {
                        Spacer()
                        // BUY BUTTON
                        Button(action: {
                            self.handleBuy(actionType: "buy")
                            
                        }) {
                            Text("Buy")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(45)
                        }
                        Spacer()
                        // SELL BUTTON
                        Button(action: {
                            self.handleSell(actionType: "sell")
                        }) {
                            Text("Sell")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(45)
                        }
                        Spacer()
                    }
                    .padding()
                    // ALERT FOR VALID AMOUNT
                    .overlay(
                        VStack {
                            Text("Please enter a valid amount")
                                .foregroundColor(.white)
                                .padding()
                        }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray)
                            .opacity(showAlert ? 1 : 0)
                            .cornerRadius(55)
                            .padding(.horizontal, 40)
                            .animation(.easeInOut(duration: 0.3), value: showAlert),
                        alignment: .center
                    )
                    //ALERT FOR NOT ENOUGH STOCKS TO SELL
                    .overlay(
                        VStack {
                            Text("Not enough to sell")
                                .foregroundColor(.white)
                                .padding()
                        }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray)
                            .opacity(showErrorAlert ? 1 : 0)
                            .cornerRadius(55)
                            .padding(.horizontal, 40)
                            .animation(.easeInOut(duration: 0.3), value: showErrorAlert),
                        alignment: .center
                    )

                }
            }
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
            })
        }
        .sheet(isPresented: $showConfirmationBuy) {
            BuyConfirmationView(shares: Int(numberOfSharesText) ?? 0, stockSymbol: tickerData.ticker) {
                showConfirmationBuy = false
            }
        }
        .sheet(isPresented: $showConfirmationSell) {
            SellConfirmationView(shares: Int(numberOfSharesText) ?? 0, stockSymbol: tickerData.ticker) {
                showConfirmationSell = false
            }
        }
        .onAppear() {
            fetchWalletAmount()
        }
    }
    
    
    // PORTFOLIO BUY
    func AddtoPortfolio(query: String, quantity: Double, totalCost: Double) {
        print("PORTFOLIO ADD")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/portfolioAdd?symbol=\(query)&quantity=\(quantity)&totalCost=\(totalCost)"
        
        print("Adding to Portfolio", query)
        fetchWalletAmount()
        
        AF.request(urlString).responseData { response in
        }
    }
    
    
    // PORTFOLIO SELL
    func RemovefromPortfolio(query: String, quantity: Double, totalCost: Double) {
        print("PORTFOLIO SELL")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/portfolioReduce?symbol=\(query)&quantity=\(quantity)&totalCost=\(totalCost)"
        
        print("Removing from Portfolio", query)
        fetchWalletAmount()
        
        AF.request(urlString).responseData { response in
        }
    }
    
    
    // WALLET DATA
    func fetchWalletAmount() {
        print("WALLET DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/getmoney"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let walletdata = try decoder.decode([WalletType].self, from: data)
                    print("Wallet Data: \(walletData)")
                    DispatchQueue.main.async {
                        print("WALLET AMOUNT SHEET", walletdata)
                        self.walletData = walletdata[0]
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
        print("Wallet success")
    }
    
    
    // BUY BUTTON ACTION AND FUNCTION
    func handleBuy(actionType: String) {
        guard let numberOfShares = Double(numberOfSharesText), numberOfShares > 0 else {
            showAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert = false
            }
            return
        }
        
        // CALCULATE TOTAL COST
        let totalCost = numberOfShares * stockquote.c
        
        AddtoPortfolio(query: tickerData.ticker, quantity: numberOfShares, totalCost: totalCost)
        showConfirmationBuy = true
        
        fetchWalletAmount()
    }
    
    
    // SELL BUTTON ACTION AND FUNCTION
    func handleSell(actionType: String) {
        guard let numberOfShares = Double(numberOfSharesText), numberOfShares > 0 else {
            showAlert = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert = false
            }
            return
        }

        print("PORTFOLIO QUANTITY : ", PortfoloioData.quantity)
        // CHECK IF ENOUGH SHARES ARE THERE
        if numberOfShares > 15 {
            showErrorAlert = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showErrorAlert = false
            }
            return
        }
        
        else {
            // CALCULATE TOTAL COST
            let totalCost = numberOfShares * stockquote.c
            
            RemovefromPortfolio(query: tickerData.ticker, quantity: numberOfShares, totalCost: totalCost)
            showConfirmationSell = true
            fetchWalletAmount()
        }
    }
}


// GREEN SHEET FOR SUCCESS OF BUY
struct BuyConfirmationView: View {
    var shares: Int
    var stockSymbol: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer(minLength: 300)
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("You have successfully bought \(shares) \(shares == 1 ? "share" : "shares") of \(stockSymbol)")
                .padding()
                .foregroundColor(.white)
            Spacer(minLength: 300)
            HStack {
                Spacer(minLength: 50)
                Button("Done") {
                    onDismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, -30)
                .padding(.vertical, 15)
                .background(Color.white)
                .foregroundColor(.green)
                .cornerRadius(40)
                Spacer(minLength: 50)
            }
            Spacer(minLength: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        .edgesIgnoringSafeArea(.all)
    }
}


// GREEN SHEET FOR SUCCESS OF SELL
struct SellConfirmationView: View {
    var shares: Int
    var stockSymbol: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer(minLength: 300)
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("You have successfully sold \(shares) \(shares == 1 ? "share" : "shares") of \(stockSymbol)")
                .padding()
                .foregroundColor(.white)
            Spacer(minLength: 300)
            HStack {
                Spacer(minLength: 50)
                Button("Done") {
                    onDismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, -30)
                .padding(.vertical, 15)
                .background(Color.white)
                .foregroundColor(.green)
                .cornerRadius(40)
                Spacer(minLength: 50)
            }
            Spacer(minLength: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        .edgesIgnoringSafeArea(.all)
    }
}


// DISPLAY CHART VIEW
struct HighchartsView: UIViewRepresentable {
    var htmlStart: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        print("Inside HTML view ", htmlStart)
        uiView.loadHTMLString(htmlStart, baseURL: nil)
    }
}



#Preview {
    StockDetails(ticker:"AAPL")
}
