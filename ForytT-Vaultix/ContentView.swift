//
//  ContentView.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                DashboardView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Dashboard", systemImage: "chart.pie.fill")
            }
            .tag(0)
            
            NavigationView {
                ExpenseTrackerView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Expenses", systemImage: "creditcard.fill")
            }
            .tag(1)
            
            NavigationView {
                InvestmentPortfolioView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Investments", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(2)
            
            NavigationView {
                BudgetPlannerView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Budget", systemImage: "slider.horizontal.3")
            }
            .tag(3)
            
            NavigationView {
                SettingsView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .accentColor(Theme.accentGreen)
    }
}

struct DashboardView: View {
    @StateObject private var expenseViewModel = ExpenseTrackerViewModel()
    @StateObject private var investmentViewModel = InvestmentViewModel()
    @StateObject private var budgetViewModel = BudgetViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.primaryBackground, Theme.secondaryBackground, Theme.tertiaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.spacing24) {
                    WelcomeHeader()
                    
                    FinancialOverviewCard(
                        expenseViewModel: expenseViewModel,
                        investmentViewModel: investmentViewModel,
                        budgetViewModel: budgetViewModel
                    )
                    
                    QuickStatsGrid(
                        expenseViewModel: expenseViewModel,
                        investmentViewModel: investmentViewModel,
                        budgetViewModel: budgetViewModel
                    )
                    
                    RecentActivitySection(expenseViewModel: expenseViewModel)
                }
                .padding(Theme.spacing16)
            }
        }
        .navigationTitle("Vaultix")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct WelcomeHeader: View {
    @AppStorage("userName") var userName: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing8) {
            Text(getGreeting())
                .font(.title3)
                .foregroundColor(Theme.textOnDark)
            
            Text(userName.isEmpty ? "Welcome to Vaultix" : userName)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Theme.textOnDark)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
}

struct FinancialOverviewCard: View {
    @ObservedObject var expenseViewModel: ExpenseTrackerViewModel
    @ObservedObject var investmentViewModel: InvestmentViewModel
    @ObservedObject var budgetViewModel: BudgetViewModel
    
    var netWorth: Double {
        investmentViewModel.totalPortfolioValue - expenseViewModel.totalExpenses
    }
    
    var body: some View {
        VStack(spacing: Theme.spacing16) {
            VStack(spacing: Theme.spacing8) {
                Text("Net Worth")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                
                Text("$\(netWorth, specifier: "%.2f")")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(netWorth >= 0 ? Theme.accentGreen : Theme.accentRed)
            }
            
            Divider()
            
            HStack(spacing: Theme.spacing24) {
                VStack(spacing: Theme.spacing4) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(Theme.accentRed)
                    Text("$\(expenseViewModel.monthlyTotal, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    Text("Monthly Expenses")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                Divider()
                
                VStack(spacing: Theme.spacing4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(Theme.accentGreen)
                    Text("$\(investmentViewModel.totalPortfolioValue, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    Text("Portfolio Value")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .padding(Theme.spacing16)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadiusLarge)
        .shadow(radius: 4)
    }
}

struct QuickStatsGrid: View {
    @ObservedObject var expenseViewModel: ExpenseTrackerViewModel
    @ObservedObject var investmentViewModel: InvestmentViewModel
    @ObservedObject var budgetViewModel: BudgetViewModel
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing12) {
            StatCard(
                title: "Expenses",
                value: "\(expenseViewModel.expenses.count)",
                icon: "creditcard.fill",
                color: Theme.accentRed
            )
            
            StatCard(
                title: "Investments",
                value: "\(investmentViewModel.investments.count)",
                icon: "chart.bar.fill",
                color: Theme.accentGreen
            )
            
            StatCard(
                title: "Budgets",
                value: "\(budgetViewModel.budgets.count)",
                icon: "slider.horizontal.3",
                color: Theme.accentYellow
            )
            
            StatCard(
                title: "Portfolio Return",
                value: String(format: "%.1f%%", investmentViewModel.portfolioGainLossPercentage),
                icon: "chart.line.uptrend.xyaxis",
                color: investmentViewModel.portfolioGainLossPercentage >= 0 ? Theme.accentGreen : Theme.accentRed
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.spacing12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Theme.spacing16)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadiusMedium)
        .shadow(radius: 2)
    }
}

struct RecentActivitySection: View {
    @ObservedObject var expenseViewModel: ExpenseTrackerViewModel
    
    var recentExpenses: [Expense] {
        Array(expenseViewModel.expenses.sorted(by: { $0.date > $1.date }).prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing12) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(Theme.textOnDark)
            
            if recentExpenses.isEmpty {
                Text("No recent activity")
                    .font(.subheadline)
                    .foregroundColor(Theme.textOnDark.opacity(0.7))
                    .padding(Theme.spacing16)
                    .frame(maxWidth: .infinity)
                    .background(Theme.cardBackground.opacity(0.5))
                    .cornerRadius(Theme.cornerRadiusMedium)
            } else {
                VStack(spacing: Theme.spacing8) {
                    ForEach(recentExpenses) { expense in
                        HStack {
                            Image(systemName: expense.category.icon)
                                .foregroundColor(Theme.accentGreen)
                            
                            VStack(alignment: .leading, spacing: Theme.spacing4) {
                                Text(expense.description)
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textPrimary)
                                    .lineLimit(1)
                                Text(expense.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Text("$\(expense.amount, specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.accentRed)
                        }
                        .padding(Theme.spacing12)
                        .background(Theme.cardBackground)
                        .cornerRadius(Theme.cornerRadiusSmall)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
