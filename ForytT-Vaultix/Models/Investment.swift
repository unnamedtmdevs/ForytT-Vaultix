//
//  Investment.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import Foundation

struct Investment: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var symbol: String
    var type: InvestmentType
    var shares: Double
    var purchasePrice: Double
    var currentPrice: Double
    var purchaseDate: Date
    
    var totalValue: Double {
        shares * currentPrice
    }
    
    var totalCost: Double {
        shares * purchasePrice
    }
    
    var gainLoss: Double {
        totalValue - totalCost
    }
    
    var gainLossPercentage: Double {
        guard totalCost > 0 else { return 0 }
        return (gainLoss / totalCost) * 100
    }
    
    enum InvestmentType: String, Codable, CaseIterable {
        case stock = "Stock"
        case crypto = "Crypto"
        case bond = "Bond"
        case etf = "ETF"
        case mutual = "Mutual Fund"
        
        var icon: String {
            switch self {
            case .stock: return "chart.line.uptrend.xyaxis"
            case .crypto: return "bitcoinsign.circle.fill"
            case .bond: return "doc.text.fill"
            case .etf: return "chart.bar.fill"
            case .mutual: return "chart.pie.fill"
            }
        }
    }
}
