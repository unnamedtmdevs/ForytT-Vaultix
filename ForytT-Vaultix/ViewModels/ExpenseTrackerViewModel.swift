//
//  ExpenseTrackerViewModel.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import Foundation
import SwiftUI
import Combine

class ExpenseTrackerViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    
    private let dataService = DataService.shared
    
    init() {
        loadExpenses()
    }
    
    func loadExpenses() {
        expenses = dataService.loadExpenses()
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveExpenses()
    }
    
    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
        saveExpenses()
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveExpenses()
    }
    
    private func saveExpenses() {
        dataService.saveExpenses(expenses)
    }
    
    // MARK: - Analytics
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    func totalForCategory(_ category: Expense.ExpenseCategory) -> Double {
        expenses.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
    }
    
    func expensesForCurrentMonth() -> [Expense] {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
        }
    }
    
    var monthlyTotal: Double {
        expensesForCurrentMonth().reduce(0) { $0 + $1.amount }
    }
    
    func categorizeExpense(description: String, amount: Double) -> Expense.ExpenseCategory {
        let lowercased = description.lowercased()
        
        if lowercased.contains("food") || lowercased.contains("restaurant") || lowercased.contains("grocery") {
            return .food
        } else if lowercased.contains("uber") || lowercased.contains("gas") || lowercased.contains("transport") {
            return .transport
        } else if lowercased.contains("movie") || lowercased.contains("game") || lowercased.contains("entertainment") {
            return .entertainment
        } else if lowercased.contains("electric") || lowercased.contains("water") || lowercased.contains("utility") {
            return .utilities
        } else if lowercased.contains("shop") || lowercased.contains("store") || lowercased.contains("amazon") {
            return .shopping
        } else if lowercased.contains("health") || lowercased.contains("doctor") || lowercased.contains("medicine") {
            return .health
        } else if lowercased.contains("school") || lowercased.contains("course") || lowercased.contains("education") {
            return .education
        }
        
        return .other
    }
}
