//
//  InvestmentPortfolioView.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import SwiftUI

struct InvestmentPortfolioView: View {
    @StateObject private var viewModel = InvestmentViewModel()
    @State private var showingAddInvestment = false
    @State private var selectedInvestment: Investment?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.accentGreen.opacity(0.3), Theme.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Theme.spacing16) {
                PortfolioSummaryCard(viewModel: viewModel)
                    .padding(.horizontal, Theme.spacing16)
                
                ScrollView {
                    VStack(spacing: Theme.spacing12) {
                        if !viewModel.investments.isEmpty {
                            PerformanceInsightsCard(viewModel: viewModel)
                                .padding(.horizontal, Theme.spacing16)
                        }
                        
                        if viewModel.investments.isEmpty {
                            EmptyInvestmentView()
                        } else {
                            ForEach(viewModel.investments) { investment in
                                InvestmentRowView(investment: investment)
                                    .onTapGesture {
                                        selectedInvestment = investment
                                    }
                                    .gesture(
                                        DragGesture(minimumDistance: 50)
                                            .onEnded { value in
                                                if value.translation.width < 0 {
                                                    withAnimation {
                                                        viewModel.deleteInvestment(investment)
                                                    }
                                                }
                                            }
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, Theme.spacing16)
                    .padding(.bottom, 80)
                }
            }
            
            VStack {
                Spacer()
                Button(action: { showingAddInvestment = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add Investment")
                            .font(.headline)
                    }
                    .foregroundColor(Theme.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.accentGreen)
                    .cornerRadius(Theme.cornerRadiusMedium)
                    .shadow(radius: 4)
                }
                .padding(.horizontal, Theme.spacing24)
                .padding(.bottom, Theme.spacing16)
            }
        }
        .navigationTitle("Investments")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddInvestment) {
            AddInvestmentView(viewModel: viewModel)
        }
        .sheet(item: $selectedInvestment) { investment in
            InvestmentDetailView(investment: investment, viewModel: viewModel)
        }
    }
}

struct PortfolioSummaryCard: View {
    @ObservedObject var viewModel: InvestmentViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing16) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    Text("Portfolio Value")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                    Text("$\(viewModel.totalPortfolioValue, specifier: "%.2f")")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                }
                Spacer()
            }
            
            HStack(spacing: Theme.spacing24) {
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    Text("Gain/Loss")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    HStack(spacing: Theme.spacing4) {
                        Image(systemName: viewModel.totalGainLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text("$\(abs(viewModel.totalGainLoss), specifier: "%.2f")")
                            .font(.headline)
                    }
                    .foregroundColor(viewModel.totalGainLoss >= 0 ? Theme.accentGreen : Theme.accentRed)
                }
                
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    Text("Return")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Text("\(viewModel.portfolioGainLossPercentage, specifier: "%.2f")%")
                        .font(.headline)
                        .foregroundColor(viewModel.portfolioGainLossPercentage >= 0 ? Theme.accentGreen : Theme.accentRed)
                }
                
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    Text("Invested")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Text("$\(viewModel.totalInvested, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                }
            }
        }
        .padding(Theme.spacing16)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadiusLarge)
        .shadow(radius: 2)
    }
}

struct PerformanceInsightsCard: View {
    @ObservedObject var viewModel: InvestmentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing12) {
            Text("Performance Insights")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            if let topPerformer = viewModel.getTopPerformer() {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(Theme.accentYellow)
                    VStack(alignment: .leading) {
                        Text("Top Performer")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        Text(topPerformer.name)
                            .font(.subheadline)
                            .foregroundColor(Theme.textPrimary)
                    }
                    Spacer()
                    Text("+\(topPerformer.gainLossPercentage, specifier: "%.2f")%")
                        .font(.headline)
                        .foregroundColor(Theme.accentGreen)
                }
            }
            
            if let worstPerformer = viewModel.getWorstPerformer() {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Theme.accentRed)
                    VStack(alignment: .leading) {
                        Text("Needs Attention")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        Text(worstPerformer.name)
                            .font(.subheadline)
                            .foregroundColor(Theme.textPrimary)
                    }
                    Spacer()
                    Text("\(worstPerformer.gainLossPercentage, specifier: "%.2f")%")
                        .font(.headline)
                        .foregroundColor(Theme.accentRed)
                }
            }
        }
        .padding(Theme.spacing16)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadiusMedium)
        .shadow(radius: 1)
    }
}

struct InvestmentRowView: View {
    let investment: Investment
    
    var body: some View {
        HStack(spacing: Theme.spacing12) {
            Image(systemName: investment.type.icon)
                .font(.title2)
                .foregroundColor(Theme.accentGreen)
                .frame(width: 44, height: 44)
                .background(Theme.accentGreen.opacity(0.1))
                .cornerRadius(Theme.cornerRadiusSmall)
            
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                Text(investment.name)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                
                HStack {
                    Text(investment.symbol)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Text(investment.type.rawValue)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Theme.spacing4) {
                Text("$\(investment.totalValue, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                HStack(spacing: Theme.spacing4) {
                    Image(systemName: investment.gainLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2)
                    Text("\(investment.gainLossPercentage, specifier: "%.2f")%")
                        .font(.caption)
                }
                .foregroundColor(investment.gainLoss >= 0 ? Theme.accentGreen : Theme.accentRed)
            }
        }
        .padding(Theme.spacing12)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadiusMedium)
        .shadow(radius: 1)
    }
}

struct AddInvestmentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: InvestmentViewModel
    
    @State private var name: String = ""
    @State private var symbol: String = ""
    @State private var shares: String = ""
    @State private var purchasePrice: String = ""
    @State private var currentPrice: String = ""
    @State private var selectedType: Investment.InvestmentType = .stock
    @State private var purchaseDate: Date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.secondaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            Text("Investment Name")
                                .font(.headline)
                            TextField("e.g., Apple Inc.", text: $name)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            Text("Symbol")
                                .font(.headline)
                            TextField("e.g., AAPL", text: $symbol)
                                .autocapitalization(.allCharacters)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            Text("Type")
                                .font(.headline)
                            
                            Picker("Type", selection: $selectedType) {
                                ForEach(Investment.InvestmentType.allCases, id: \.self) { type in
                                    HStack {
                                        Image(systemName: type.icon)
                                        Text(type.rawValue)
                                    }
                                    .tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        
                        HStack(spacing: Theme.spacing16) {
                            VStack(alignment: .leading, spacing: Theme.spacing8) {
                                Text("Shares")
                                    .font(.headline)
                                TextField("0", text: $shares)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(Theme.cornerRadiusMedium)
                            }
                            
                            VStack(alignment: .leading, spacing: Theme.spacing8) {
                                Text("Purchase Price")
                                    .font(.headline)
                                TextField("0.00", text: $purchasePrice)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(Theme.cornerRadiusMedium)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            Text("Current Price")
                                .font(.headline)
                            TextField("0.00", text: $currentPrice)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            Text("Purchase Date")
                                .font(.headline)
                            DatePicker("", selection: $purchaseDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        
                        Button(action: addInvestment) {
                            Text("Add Investment")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accentGreen)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        .disabled(name.isEmpty || symbol.isEmpty || shares.isEmpty || purchasePrice.isEmpty || currentPrice.isEmpty)
                    }
                    .padding(Theme.spacing24)
                }
            }
            .navigationTitle("New Investment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addInvestment() {
        guard let sharesValue = Double(shares),
              let purchasePriceValue = Double(purchasePrice),
              let currentPriceValue = Double(currentPrice) else { return }
        
        let investment = Investment(
            name: name,
            symbol: symbol,
            type: selectedType,
            shares: sharesValue,
            purchasePrice: purchasePriceValue,
            currentPrice: currentPriceValue,
            purchaseDate: purchaseDate
        )
        
        viewModel.addInvestment(investment)
        dismiss()
    }
}

struct InvestmentDetailView: View {
    let investment: Investment
    @ObservedObject var viewModel: InvestmentViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.secondaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        Image(systemName: investment.type.icon)
                            .font(.system(size: 60))
                            .foregroundColor(Theme.accentGreen)
                            .padding(Theme.spacing24)
                            .background(Theme.accentGreen.opacity(0.1))
                            .cornerRadius(Theme.cornerRadiusLarge)
                        
                        VStack(spacing: Theme.spacing8) {
                            Text(investment.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimary)
                            
                            Text(investment.symbol)
                                .font(.headline)
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        VStack(spacing: Theme.spacing16) {
                            DetailRow(label: "Type", value: investment.type.rawValue)
                            DetailRow(label: "Shares", value: String(format: "%.4f", investment.shares))
                            DetailRow(label: "Purchase Price", value: String(format: "$%.2f", investment.purchasePrice))
                            DetailRow(label: "Current Price", value: String(format: "$%.2f", investment.currentPrice))
                            DetailRow(label: "Total Value", value: String(format: "$%.2f", investment.totalValue))
                            DetailRow(label: "Total Cost", value: String(format: "$%.2f", investment.totalCost))
                            
                            Divider()
                            
                            HStack {
                                Text("Gain/Loss")
                                    .font(.headline)
                                    .foregroundColor(Theme.textSecondary)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("$\(investment.gainLoss, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(investment.gainLoss >= 0 ? Theme.accentGreen : Theme.accentRed)
                                    Text("\(investment.gainLossPercentage, specifier: "%.2f")%")
                                        .font(.subheadline)
                                        .foregroundColor(investment.gainLoss >= 0 ? Theme.accentGreen : Theme.accentRed)
                                }
                            }
                            
                            DetailRow(label: "Purchase Date", value: investment.purchaseDate.formatted(date: .long, time: .omitted))
                        }
                        .padding(Theme.spacing16)
                        .background(Theme.cardBackground)
                        .cornerRadius(Theme.cornerRadiusMedium)
                        
                        Button(action: deleteInvestment) {
                            Text("Delete Investment")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accentRed)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                    }
                    .padding(Theme.spacing24)
                }
            }
            .navigationTitle("Investment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteInvestment() {
        viewModel.deleteInvestment(investment)
        dismiss()
    }
}

struct EmptyInvestmentView: View {
    var body: some View {
        VStack(spacing: Theme.spacing16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(Theme.textSecondary.opacity(0.5))
            Text("No Investments Yet")
                .font(.title2)
                .foregroundColor(Theme.textSecondary)
            Text("Start building your portfolio by adding your first investment")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Theme.spacing32)
    }
}

#Preview {
    NavigationView {
        InvestmentPortfolioView()
    }
}
