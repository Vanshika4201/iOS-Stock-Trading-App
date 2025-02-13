import SwiftUI
import Alamofire
import Foundation

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var PortfolioList: [PortfolioType] = []
    @State private var WatchlistItem: [WatchlistType] = []
    @State private var WalletAmount: [WalletType] = []
    @State private var searchResult: [StockSuggestion] = []
    @State private var isLoading = false  // State to manage loading indicator
    @State private var isSearching = false
    @State private var NetWorth: Double = 0
    
    @State private var editMode: EditMode = .inactive
    
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    
//                    // Display a loading indicator when data is being fetched
//                    if isLoading {
//                        Spacer()
//                        VStack{
//                            HStack{
//                                Spacer()
//                                ProgressView("Fetching Data...")
//                                    .progressViewStyle(CircularProgressViewStyle())
//                                    .scaleEffect(1.5)
//                                    .foregroundColor(.secondary)
//                                Spacer()
//                            }
//                        }
//                        Spacer()
//                    } else {
                        
                        // DATE
                        Section {
                            Text("\(dateFormatter.string(from: Date()))")
                                .font(.system(size: 35))
                                .opacity(0.5)
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                .lineLimit(1)
                                .bold()
                        }
                        
                        // NET WORTH
                        Section(header: Text("PORTFOLIO")) {
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Net Worth")
                                        .fontWeight(.medium)
                                        .font(.headline)
                                        .opacity(0.7)
                                    ForEach(WalletAmount) { list in
                                        Text("$\(NSString(format: "%.2f", list.networth))")
                                            .bold()
                                            .font(.system(size: 25))
                                    }
                                }
                                
                                Spacer()
                                VStack(alignment: .trailing, spacing: 10) {
                                    Text("Cash Balance")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .opacity(0.7)
                                    ForEach(WalletAmount) { list in
                                        Text("$\(NSString(format: "%.2f", list.money))")
                                            .bold()
                                            .font(.system(size: 25))
                                            .padding(.leading)
                                    }
                                }
                            }
                            
                            //PORTFOLIO DATA
                            ForEach(PortfolioList, id: \.id) { list in
                                NavigationLink(destination: StockDetails(ticker:list.ticker)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("\(list.ticker)")
                                                .bold()
                                            Text("\(Int(list.quantity)) Shares")
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 3) {
                                            Text("$\(NSString(format: "%.2f", list.marketvalue))")
                                                .bold()
                                            HStack {
                                                Image(systemName: list.currentprice-list.avgCost >= 0 ? "arrow.up.right" : "arrow.down.left")
                                                    .foregroundColor((list.currentprice-list.avgCost) >= 0 ? .green : .red)
                                                    .imageScale(.small)

                                            let newValue = ((list.currentprice-list.avgCost)/list.avgCost)

                                                Text("$\(NSString(format: "%.2f", list.currentprice-list.avgCost)) (\(NSString(format: "%.2f", newValue*100))%)")
                                                    .foregroundColor(newValue*100 >= 0 ? .green : .red)
                                            }
                                        }
                                    }
                                }
                                }
                                .onMove(perform: move)
                        }
                        .environment(\.editMode, $editMode)
                        
                        //WATCHLIST DATA
                        Section(header: Text("FAVORITES")) {
                            ForEach(WatchlistItem, id: \.id) { item in
                                NavigationLink(destination: StockDetails(ticker:item.id)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("\(item.id)")
                                                .bold()
                                            Text("\(item.name)")
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 3) {
                                            Text("$\(NSString(format: "%.2f", item.currentPrice))")
                                                .bold()
                                            HStack {
                                                Image(systemName: item.dailyChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                                                    .foregroundColor(item.dailyChange >= 0 ? .green : .red)
                                                    .imageScale(.small)
                                                Text("$\(NSString(format: "%.2f", item.dailyChange)) (\(NSString(format: "%.2f", item.dailyChangePercentage))%)")
                                                    .foregroundColor(item.dailyChange >= 0 ? .green : .red)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                }
                            }
                            .onMove(perform: moveWatchlist)
                            .onDelete(perform: deleteFromWatchlist)
                        }
                        .environment(\.editMode, $editMode)

                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("Powered by")
                                    .foregroundColor(.gray)
                                Link("Finnhub.io", destination: URL(string: "https://finnhub.io")!)
                                    .foregroundColor(.gray)
                                    .padding(.leading, -4)
                                Spacer()
                            }
                            Spacer()
                        }
//                    }
                }
                .listStyle(.automatic)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                
                .onAppear() {
                    isLoading = true  // START LOADING
                    fetchPortfolioData()
                    fetchWatchlistData()
                    fetchWalletAmount()
                }
                .onReceive(timer) { _ in
                    fetchPortfolioData()
                    fetchWatchlistData()
                    fetchWalletAmount()
                }
                .navigationTitle("Stocks")
                
                // AUTOCOMPLETE
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)) {
                    Section {
                        ForEach(searchResult, id: \.self) { suggestion in
                            NavigationLink(destination: StockDetails(ticker: suggestion.symbol)) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(suggestion.symbol)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                                .padding(.leading, 10)
                                            Text(suggestion.description)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .padding(.leading, 10)
                                            
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .cornerRadius(10)
                            }
                            .listStyle(InsetGroupedListStyle())
                        }
                    }
                }
                .onChange(of: searchText) { newValue in
                    if !newValue.isEmpty {
                        fetchSuggestions(query: newValue)
                        searchText = newValue.uppercased()
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    
    func fetchSuggestions(query: String) {
        print("AUTOCOMPLETE DATA")
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResult = []
            return
        }
        
        let url = "https://angstockappavi7533.wl.r.appspot.com/stockautocomplete?symbol=\(query)"
        
        AF.request(url)
            .validate()
            .responseDecodable(of: [StockSuggestion].self) { response in
                switch response.result {
                case .success(let results):
                    DispatchQueue.main.async {
                        print("SEARCH AUTO", results)
                        self.searchResult = results
                    }
                case .failure(let error):
                    print("Error fetching suggestions: \(error)")
                }
            }
    }
    
    func updateNetWorth(totalMarketValue: Double?) {
        var netWorth = 0.0
        
        if let totalMarketValue = totalMarketValue {
            netWorth += totalMarketValue
        }
        
        if !WalletAmount.isEmpty {
            netWorth += WalletAmount[0].money
        }
        
        self.NetWorth = netWorth
        
        checkLoading()
    }
    
    func fetchPortfolioData() {
        print("PORTFOLIO DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/portfolioList"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let portfolioData = try decoder.decode([PortfolioType].self, from: data)
                    print("Portfolio Data: \(portfolioData)")
                    DispatchQueue.main.async {
                        self.PortfolioList = portfolioData
                        
                        // SUM OF MARKET VALUES
                        let totalMarketValue = portfolioData.reduce(0.0) { $0 + $1.marketvalue }
                        print("Total Market Value: \(totalMarketValue)")

                        // UPDATE NETWORTH
                        self.updateNetWorth(totalMarketValue: totalMarketValue)
                        
                        self.NetWorth = totalMarketValue
                        checkLoading()
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    func fetchWatchlistData() {
        print("WATCHLIST DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/mongofetchquote"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let watchlistData = try decoder.decode([WatchlistType].self, from: data)
                    print("Watchlist Data: \(watchlistData)")
                    DispatchQueue.main.async {
                        self.WatchlistItem = watchlistData
                        checkLoading()
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Request error: \(error)")
            }
        }
    }
    
    func fetchWalletAmount() {
        print("WALLET DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/getmoney"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let walletData = try decoder.decode([WalletType].self, from: data)
                    print("Wallet Data: \(walletData)")
                    DispatchQueue.main.async {
                        self.WalletAmount = walletData
                        self.updateNetWorth(totalMarketValue: WalletAmount[0].money)
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
    
    func checkLoading() {
        if !WalletAmount.isEmpty && !PortfolioList.isEmpty && !WatchlistItem.isEmpty{
            isLoading = false  // STOP LOADING
        }
    }
    
    // REARRANGE FUNCTION
    func move(from source: IndexSet, to destination: Int) {
        PortfolioList.move(fromOffsets: source, toOffset: destination)
    }
    
    // REMOVE FROM WATCHLIST
    func RemovefromWatchlist(query: String) {
        print("WATCHLIST DATA")
        let urlString = "https://angstockappavi7533.wl.r.appspot.com/mongowatchRemove?symbol=\(query)"
        print("Removed From Watchlist", query)
        
        AF.request(urlString).responseData { response in
        }
    }
    
    func moveWatchlist(from source: IndexSet, to destination: Int) {
        WatchlistItem.move(fromOffsets: source, toOffset: destination)
    }

    func deleteFromWatchlist(at offsets: IndexSet) {
        let idsToRemove = offsets.map { WatchlistItem[$0].id }
        
        idsToRemove.forEach { ticker in
            RemovefromWatchlist(query: ticker)
        }
        
        WatchlistItem.remove(atOffsets: offsets)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
