//
//  DataService.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import Foundation

class DataService {
    static let shared = DataService()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let expenses = "expenses"
        static let investments = "investments"
        static let budgets = "budgets"
    }
    
    private init() {}
    
    // MARK: - Expenses
    func saveExpenses(_ expenses: [Expense]) {
        if let encoded = try? JSONEncoder().encode(expenses) {
            userDefaults.set(encoded, forKey: Keys.expenses)
        }
    }
    
    func loadExpenses() -> [Expense] {
        guard let data = userDefaults.data(forKey: Keys.expenses),
              let expenses = try? JSONDecoder().decode([Expense].self, from: data) else {
            return []
        }
        return expenses
    }
    
    // MARK: - Investments
    func saveInvestments(_ investments: [Investment]) {
        if let encoded = try? JSONEncoder().encode(investments) {
            userDefaults.set(encoded, forKey: Keys.investments)
        }
    }
    
    func loadInvestments() -> [Investment] {
        guard let data = userDefaults.data(forKey: Keys.investments),
              let investments = try? JSONDecoder().decode([Investment].self, from: data) else {
            return []
        }
        return investments
    }
    
    // MARK: - Budgets
    func saveBudgets(_ budgets: [Budget]) {
        if let encoded = try? JSONEncoder().encode(budgets) {
            userDefaults.set(encoded, forKey: Keys.budgets)
        }
    }
    
    func loadBudgets() -> [Budget] {
        guard let data = userDefaults.data(forKey: Keys.budgets),
              let budgets = try? JSONDecoder().decode([Budget].self, from: data) else {
            return []
        }
        return budgets
    }
    
    // MARK: - Reset All Data
    func resetAllData() {
        userDefaults.removeObject(forKey: Keys.expenses)
        userDefaults.removeObject(forKey: Keys.investments)
        userDefaults.removeObject(forKey: Keys.budgets)
    }
}
