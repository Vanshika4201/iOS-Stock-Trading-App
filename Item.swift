//
//  Item.swift
//  PortfolioApp
//
//  Created by Avi Aswal on 4/27/24.
//

import Foundation
import SwiftData


// AUTOCOMPLETE DATA TYPES
struct StockSuggestion: Identifiable, Codable, Hashable {
    var id: String {symbol}
    var description: String
    var displaySymbol: String
    var symbol: String
    var type: String
}


// PORTFOLIO DATA TYPE
struct PortfolioType: Identifiable, Codable, Hashable {
    var id: String { ticker }
    var name: String
    var currentprice: Double
    var change: Double
    var marketvalue: Double
    var ticker: String
    var quantity: Double
    var avgCost: Double
}


// PORTFOLIO DATA TYPE 2 FOR FETCH_BY_KEY
struct PortfolioType2: Identifiable, Codable {
    var id: String { ticker }
    var _id: String
    var ticker: String
    var quantity: Double
    var totalCost: Double
    var avgCost: Double
}


// WALLET AMOUNT
struct WalletType: Identifiable, Decodable {
    var id: String
    var money: Double
    var p: String
    var networth: Double

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case money, p, networth
    }
}


// WATCHLIST DATA TYPE
struct WatchlistType: Identifiable, Decodable, Hashable {
    var id: String
    var currentPrice: Double
    var dailyChange: Double
    var dailyChangePercentage: Double
    var high: Double
    var low: Double
    var open: Double
    var previousClose: Double
    var timestamp: Date
    var ticker: String
    var name: String

    enum CodingKeys: String, CodingKey {
        case currentPrice = "c"
        case dailyChange = "d"
        case dailyChangePercentage = "dp"
        case high = "h"
        case low = "l"
        case open = "o"
        case previousClose = "pc"
        case timestamp = "t"
        case id = "ticker"
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        currentPrice = try container.decode(Double.self, forKey: .currentPrice)
        dailyChange = try container.decode(Double.self, forKey: .dailyChange)
        dailyChangePercentage = try container.decode(Double.self, forKey: .dailyChangePercentage)
        high = try container.decode(Double.self, forKey: .high)
        low = try container.decode(Double.self, forKey: .low)
        open = try container.decode(Double.self, forKey: .open)
        previousClose = try container.decode(Double.self, forKey: .previousClose)
        let timestampSeconds = try container.decode(Int.self, forKey: .timestamp)
        timestamp = Date(timeIntervalSince1970: TimeInterval(timestampSeconds))
        ticker = id
        name = try container.decode(String.self, forKey: .name)
    }
}

// RECOMMENDATION TRENDS DATA TYPE
struct ChartMainType: Decodable {
    var data1: [[Double]]
    var data2: [[Double]]
}


// STOCKSUMMARY DATA TYPE
struct StockInfoType: Identifiable, Decodable {
    var id: String{ticker}
    var country: String
    var currency: String
    var estimateCurrency: String
    var exchange: String
    var finnhubIndustry: String
    var ipo: String
    var logo: String
    var marketCapitalization: Double
    var name: String
    var phone: String
    var shareOutstanding: Double
    var ticker: String
    var weburl: String
}


// STOCKQUOTE DATA TYPE
struct StockQuoteType: Decodable {
    var c: Double
    var d: Double
    var dp: Double
    var h: Double
    var l: Double
    var o: Double
    var pc: Double
    var t: Double

}


// RECOMMENDATION TRENDS DATA TYPE
struct StockRecommendationType: Decodable {
    var buy: Int
    var hold: Int
    var period: String
    var sell: Int
    var strongBuy: Int
    var strongSell: Int
    var symbol: String
}


// NEWS ITEM DATATYPE
struct NewsDataType: Identifiable, Decodable {
    var id: Int
    var category: String
    var datetime: Double
    var headline: String
    var image: String
    var related: String
    var source: String
    var summary: String
    var url: String
}


// INSIDER SENTIMENT DATA TYPE
struct SentimentDataType: Decodable {
    var totalMspr: Double
    var positiveMspr: Double
    var negativeMspr: Double
    var totalChange: Double
    var positiveChange: Double
    var negativeChange: Double
}


// COMPANY PEER DATA TYPE
struct PeerDataType: Decodable {
    var PeerDataType: [String]
}


// EARNINGS DATA TYPE
struct EarningsType: Identifiable, Decodable {
    var id = UUID()
    var actual: Double
    var estimate: Double
    var period: String
    var quarter: Int
    var surprise: Double
    var surprisePercent: Double
    var symbol: String
    var year: Int

    enum CodingKeys: String, CodingKey {
        case actual, estimate, period, quarter, surprise, surprisePercent, symbol, year
    }
}
