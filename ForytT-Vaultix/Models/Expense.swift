//
//  Expense.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import Foundation

struct Expense: Identifiable, Codable {
    var id: UUID = UUID()
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var description: String
    var isRecurring: Bool = false
    
    enum ExpenseCategory: String, Codable, CaseIterable {
        case food = "Food"
        case transport = "Transport"
        case entertainment = "Entertainment"
        case utilities = "Utilities"
        case shopping = "Shopping"
        case health = "Health"
        case education = "Education"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .food: return "fork.knife"
            case .transport: return "car.fill"
            case .entertainment: return "film.fill"
            case .utilities: return "bolt.fill"
            case .shopping: return "cart.fill"
            case .health: return "cross.fill"
            case .education: return "book.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }
}
