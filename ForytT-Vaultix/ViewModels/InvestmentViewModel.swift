//
//  InvestmentViewModel.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import Foundation
import SwiftUI
import Combine

class InvestmentViewModel: ObservableObject {
    @Published var investments: [Investment] = []
    
    private let dataService = DataService.shared
    private var timer: Timer?
    
    init() {
        loadInvestments()
        startPriceSimulation()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func loadInvestments() {
        investments = dataService.loadInvestments()
    }
    
    func addInvestment(_ investment: Investment) {
        investments.append(investment)
        saveInvestments()
    }
    
    func deleteInvestment(at offsets: IndexSet) {
        investments.remove(atOffsets: offsets)
        saveInvestments()
    }
    
    func deleteInvestment(_ investment: Investment) {
        investments.removeAll { $0.id == investment.id }
        saveInvestments()
    }
    
    private func saveInvestments() {
        dataService.saveInvestments(investments)
    }
    
    // MARK: - Portfolio Analytics
    var totalPortfolioValue: Double {
        investments.reduce(0) { $0 + $1.totalValue }
    }
    
    var totalInvested: Double {
        investments.reduce(0) { $0 + $1.totalCost }
    }
    
    var totalGainLoss: Double {
        investments.reduce(0) { $0 + $1.gainLoss }
    }
    
    var portfolioGainLossPercentage: Double {
        guard totalInvested > 0 else { return 0 }
        return (totalGainLoss / totalInvested) * 100
    }
    
    // MARK: - Real-time Price Simulation
    private func startPriceSimulation() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.updatePrices()
        }
    }
    
    private func updatePrices() {
        for index in investments.indices {
            let volatility = 0.02
            let change = Double.random(in: -volatility...volatility)
            investments[index].currentPrice *= (1 + change)
        }
        saveInvestments()
    }
    
    func getTopPerformer() -> Investment? {
        investments.max(by: { $0.gainLossPercentage < $1.gainLossPercentage })
    }
    
    func getWorstPerformer() -> Investment? {
        investments.min(by: { $0.gainLossPercentage < $1.gainLossPercentage })
    }
}
