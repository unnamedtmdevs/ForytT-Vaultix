//
//  BudgetPlannerView.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import SwiftUI

struct BudgetPlannerView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @StateObject private var expenseViewModel = ExpenseTrackerViewModel()
    @State private var showingAddBudget = false
    @State private var selectedBudget: Budget?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.tertiaryBackground.opacity(0.5), Theme.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Theme.spacing16) {
                BudgetSummaryCard(viewModel: viewModel)
                    .padding(.horizontal, Theme.spacing16)
                
                ScrollView {
                    VStack(spacing: Theme.spacing12) {
                        if viewModel.budgets.isEmpty {
                            EmptyBudgetView()
                        } else {
                            ForEach(viewModel.budgets) { budget in
                                BudgetRowView(budget: budget, viewModel: viewModel)
                                    .onTapGesture {
                                        selectedBudget = budget
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.spacing16)
                    .padding(.bottom, 80)
                }
            }
            
            VStack {
                Spacer()
                HStack(spacing: Theme.spacing12) {
                    Button(action: syncBudgets) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title3)
                            Text("Sync")
                                .font(.headline)
                        }
                        .foregroundColor(Theme.textPrimary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.accentYellow)
                        .cornerRadius(Theme.cornerRadiusMedium)
                        .shadow(radius: 4)
                    }
                    
                    Button(action: { showingAddBudget = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Add Budget")
                                .font(.headline)
                        }
                        .foregroundColor(Theme.textPrimary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.accentGreen)
                        .cornerRadius(Theme.cornerRadiusMedium)
                        .shadow(radius: 4)
                    }
                }
                .padding(.horizontal, Theme.spacing24)
                .padding(.bottom, Theme.spacing16)
            }
        }
        .navigationTitle("Budget Planner")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView(viewModel: viewModel)
        }
        .sheet(item: $selectedBudget) { budget in
            EditBudgetView(budget: budget, viewModel: viewModel)
        }
        .onAppear {
            syncBudgets()
        }
    }
    
    private func syncBudgets() {
        viewModel.syncWithExpenses(expenseViewModel.expenses)
    }
}

struct BudgetSummaryCard: View {
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing16) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    Text("Total Budget")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                    Text("$\(viewModel.totalBudget, specifier: "%.2f")")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                }
                Spacer()
            }
            
            HStack(spacing: Theme.spacing24) {
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Text("$\(viewModel.totalSpent, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(Theme.accentRed)
                }
                
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Text("$\(viewModel.totalRemaining, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(Theme.accentGreen)
                }
                
                if viewModel.overBudgetCount > 0 {
                    VStack(alignment: .leading, spacing: Theme.spacing4) {
                        Text("Over Budget")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        HStack(spacing: Theme.spacing4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text("\(viewModel.overBudgetCount)")
                                .font(.headline)
                        }
                        .foregroundColor(Theme.accentRed)
                    }
                }
            }
        }
        .padding(Theme.spacing16)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadiusLarge)
        .shadow(radius: 2)
    }
}

struct BudgetRowView: View {
    let budget: Budget
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing12) {
            HStack {
                Text(budget.category)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Theme.spacing4) {
                    Text("$\(budget.spent, specifier: "%.2f") / $\(budget.limit, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(Theme.textPrimary)
                    
                    if budget.isOverBudget {
                        HStack(spacing: Theme.spacing4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                            Text("Over by $\(abs(budget.remaining), specifier: "%.2f")")
                                .font(.caption)
                        }
                        .foregroundColor(Theme.accentRed)
                    } else {
                        Text("$\(budget.remaining, specifier: "%.2f") remaining")
                            .font(.caption)
                            .foregroundColor(Theme.accentGreen)
                    }
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(budget.isOverBudget ? Theme.accentRed : Theme.accentGreen)
                        .frame(width: min(geometry.size.width * CGFloat(budget.percentageUsed / 100), geometry.size.width), height: 8)
                        .animation(.spring(), value: budget.percentageUsed)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(budget.percentageUsed))% used")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(Theme.spacing16)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadiusMedium)
        .shadow(radius: 1)
    }
}

struct AddBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: BudgetViewModel
    
    @State private var category: String = ""
    @State private var limit: Double = 500
    @State private var month: Date = Date()
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.secondaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            Text("Category")
                                .font(.headline)
                            TextField("e.g., Food, Transport", text: $category)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            HStack {
                                Text("Budget Limit")
                                    .font(.headline)
                                Spacer()
                                Text("$\(limit, specifier: "%.0f")")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.accentGreen)
                            }
                            
                            Slider(value: $limit, in: 50...5000, step: 50, onEditingChanged: { _ in
                                impactFeedback.impactOccurred()
                            })
                            .accentColor(Theme.accentGreen)
                            
                            HStack {
                                Text("$50")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                Spacer()
                                Text("$5000")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                        .padding(Theme.spacing16)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(Theme.cornerRadiusMedium)
                        
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            Text("Month")
                                .font(.headline)
                            DatePicker("", selection: $month, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        
                        Button(action: addBudget) {
                            Text("Add Budget")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accentGreen)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        .disabled(category.isEmpty)
                    }
                    .padding(Theme.spacing24)
                }
            }
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            impactFeedback.prepare()
        }
    }
    
    private func addBudget() {
        let budget = Budget(
            category: category,
            limit: limit,
            spent: 0,
            month: month
        )
        
        viewModel.addBudget(budget)
        dismiss()
    }
}

struct EditBudgetView: View {
    let budget: Budget
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var limit: Double
    @State private var spent: Double
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    init(budget: Budget, viewModel: BudgetViewModel) {
        self.budget = budget
        self.viewModel = viewModel
        _limit = State(initialValue: budget.limit)
        _spent = State(initialValue: budget.spent)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.secondaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        VStack(spacing: Theme.spacing16) {
                            Text(budget.category)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimary)
                            
                            Text(budget.month.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(.top, Theme.spacing16)
                        
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            HStack {
                                Text("Budget Limit")
                                    .font(.headline)
                                Spacer()
                                Text("$\(limit, specifier: "%.0f")")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.accentGreen)
                            }
                            
                            Slider(value: $limit, in: 50...5000, step: 50, onEditingChanged: { _ in
                                impactFeedback.impactOccurred()
                            })
                            .accentColor(Theme.accentGreen)
                            
                            HStack {
                                Text("$50")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                Spacer()
                                Text("$5000")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                        .padding(Theme.spacing16)
                        .background(Theme.cardBackground)
                        .cornerRadius(Theme.cornerRadiusMedium)
                        
                        VStack(spacing: Theme.spacing16) {
                            DetailRow(label: "Spent", value: String(format: "$%.2f", spent))
                            DetailRow(label: "Remaining", value: String(format: "$%.2f", limit - spent))
                            DetailRow(label: "Percentage Used", value: String(format: "%.0f%%", min((spent / limit) * 100, 100)))
                        }
                        .padding(Theme.spacing16)
                        .background(Theme.cardBackground)
                        .cornerRadius(Theme.cornerRadiusMedium)
                        
                        VStack(spacing: Theme.spacing12) {
                            Button(action: saveBudget) {
                                Text("Save Changes")
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.accentGreen)
                                    .cornerRadius(Theme.cornerRadiusMedium)
                            }
                            
                            Button(action: deleteBudget) {
                                Text("Delete Budget")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.accentRed)
                                    .cornerRadius(Theme.cornerRadiusMedium)
                            }
                        }
                    }
                    .padding(Theme.spacing24)
                }
            }
            .navigationTitle("Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            impactFeedback.prepare()
        }
    }
    
    private func saveBudget() {
        var updatedBudget = budget
        updatedBudget.limit = limit
        viewModel.updateBudget(updatedBudget)
        dismiss()
    }
    
    private func deleteBudget() {
        viewModel.deleteBudget(budget)
        dismiss()
    }
}

struct EmptyBudgetView: View {
    var body: some View {
        VStack(spacing: Theme.spacing16) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 60))
                .foregroundColor(Theme.textSecondary.opacity(0.5))
            Text("No Budgets Yet")
                .font(.title2)
                .foregroundColor(Theme.textSecondary)
            Text("Start planning your finances by creating your first budget")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Theme.spacing32)
    }
}

#Preview {
    NavigationView {
        BudgetPlannerView()
    }
}
