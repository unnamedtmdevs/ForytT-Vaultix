//
//  BudgetViewModel.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import Foundation
import SwiftUI
import Combine

class BudgetViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    
    private let dataService = DataService.shared
    
    init() {
        loadBudgets()
        initializeDefaultBudgets()
    }
    
    func loadBudgets() {
        budgets = dataService.loadBudgets()
    }
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        saveBudgets()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
        }
    }
    
    func deleteBudget(at offsets: IndexSet) {
        budgets.remove(atOffsets: offsets)
        saveBudgets()
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveBudgets()
    }
    
    private func saveBudgets() {
        dataService.saveBudgets(budgets)
    }
    
    func syncWithExpenses(_ expenses: [Expense]) {
        let calendar = Calendar.current
        
        for index in budgets.indices {
            let categoryName = budgets[index].category.lowercased()
            
            let relevantExpenses = expenses.filter { expense in
                let matchesMonth = calendar.isDate(expense.date, equalTo: budgets[index].month, toGranularity: .month)
                let matchesCategory = expense.category.rawValue.lowercased().contains(categoryName) || 
                                     categoryName.contains(expense.category.rawValue.lowercased())
                return matchesMonth && matchesCategory
            }
            
            budgets[index].spent = relevantExpenses.reduce(0) { $0 + $1.amount }
        }
        saveBudgets()
    }
    
    private func initializeDefaultBudgets() {
        if budgets.isEmpty {
            let now = Date()
            let defaultCategories = [
                ("Food", 500.0),
                ("Transport", 200.0),
                ("Entertainment", 150.0),
                ("Shopping", 300.0),
                ("Utilities", 250.0)
            ]
            
            for (category, limit) in defaultCategories {
                let budget = Budget(category: category, limit: limit, spent: 0, month: now)
                budgets.append(budget)
            }
            saveBudgets()
        }
    }
    
    // MARK: - Analytics
    var totalBudget: Double {
        budgets.reduce(0) { $0 + $1.limit }
    }
    
    var totalSpent: Double {
        budgets.reduce(0) { $0 + $1.spent }
    }
    
    var totalRemaining: Double {
        budgets.reduce(0) { $0 + $1.remaining }
    }
    
    var overBudgetCount: Int {
        budgets.filter { $0.isOverBudget }.count
    }
}
