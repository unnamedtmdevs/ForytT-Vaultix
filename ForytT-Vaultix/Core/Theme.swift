//
//  Theme.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import SwiftUI

struct Theme {
    // Background Colors
    static let primaryBackground = Color(hex: "ae2d27")
    static let secondaryBackground = Color(hex: "dfb492")
    static let tertiaryBackground = Color(hex: "ffc934")
    
    // Element/Button Colors
    static let accentGreen = Color(hex: "1ed55f")
    static let accentYellow = Color(hex: "ffff03")
    static let accentRed = Color(hex: "eb262f")
    
    // Semantic colors
    static let cardBackground = Color.white.opacity(0.95)
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
    static let textOnDark = Color.white
    
    // Spacing tokens
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    
    // Corner radius
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
