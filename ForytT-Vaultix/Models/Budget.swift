//
//  Budget.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import Foundation

struct Budget: Identifiable, Codable {
    var id: UUID = UUID()
    var category: String
    var limit: Double
    var spent: Double = 0
    var month: Date
    
    var remaining: Double {
        limit - spent
    }
    
    var percentageUsed: Double {
        guard limit > 0 else { return 0 }
        return min((spent / limit) * 100, 100)
    }
    
    var isOverBudget: Bool {
        spent > limit
    }
}
