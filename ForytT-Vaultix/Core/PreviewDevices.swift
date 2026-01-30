//
//  PreviewDevices.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import SwiftUI

struct MultiDevicePreview<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            content
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
                .previewDisplayName("iPhone SE")
            
            content
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro Max"))
                .previewDisplayName("iPhone 15 Pro Max")
            
            content
                .previewDevice(PreviewDevice(rawValue: "iPad Air 11-inch (M2)"))
                .previewDisplayName("iPad Air 11-inch")
        }
    }
}
