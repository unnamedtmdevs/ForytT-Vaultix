//
//  OnboardingView.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var currentPage = 0
    @State private var initialBudget: String = "2000"
    @State private var userName: String = ""
    
    let pages = [
        OnboardingPage(
            title: "Welcome to Vaultix",
            description: "Your futuristic financial companion for tracking expenses, investments, and budgets.",
            icon: "chart.line.uptrend.xyaxis.circle.fill",
            color: Theme.accentGreen
        ),
        OnboardingPage(
            title: "Track Expenses",
            description: "Automatically categorize and monitor your daily spending with AI-powered insights.",
            icon: "creditcard.fill",
            color: Theme.accentYellow
        ),
        OnboardingPage(
            title: "Monitor Investments",
            description: "Get real-time updates on your portfolio performance and market insights.",
            icon: "chart.bar.fill",
            color: Theme.primaryBackground
        ),
        OnboardingPage(
            title: "Plan Budgets",
            description: "Set monthly budgets and get notified when you're close to limits.",
            icon: "slider.horizontal.3",
            color: Theme.accentRed
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.primaryBackground, Theme.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                    
                    PersonalizationView(
                        userName: $userName,
                        initialBudget: $initialBudget,
                        onComplete: completeOnboarding
                    )
                    .tag(pages.count)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                VStack(spacing: Theme.spacing24) {
                    PageIndicator(currentPage: currentPage, totalPages: pages.count + 1)
                    
                    if currentPage < pages.count {
                        HStack(spacing: Theme.spacing16) {
                            if currentPage > 0 {
                                Button(action: previousPage) {
                                    Text("Back")
                                        .font(.headline)
                                        .foregroundColor(Theme.textOnDark)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(Theme.cornerRadiusMedium)
                                }
                            }
                            
                            Button(action: nextPage) {
                                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.accentGreen)
                                    .cornerRadius(Theme.cornerRadiusMedium)
                            }
                        }
                        .padding(.horizontal, Theme.spacing24)
                    }
                }
                .padding(.bottom, Theme.spacing32)
            }
        }
    }
    
    private func nextPage() {
        withAnimation(.spring()) {
            if currentPage < pages.count {
                currentPage += 1
            }
        }
    }
    
    private func previousPage() {
        withAnimation(.spring()) {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Theme.spacing32) {
            Spacer()
            
            Image(systemName: page.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(page.color)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(spacing: Theme.spacing16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Theme.textOnDark)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 18))
                    .foregroundColor(Theme.textOnDark.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacing32)
            }
            
            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct PersonalizationView: View {
    @Binding var userName: String
    @Binding var initialBudget: String
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.spacing32) {
            Spacer()
            
            VStack(spacing: Theme.spacing24) {
                Text("Let's Personalize")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Theme.textOnDark)
                
                VStack(alignment: .leading, spacing: Theme.spacing16) {
                    Text("Your Name (Optional)")
                        .font(.headline)
                        .foregroundColor(Theme.textOnDark)
                    
                    TextField("Enter your name", text: $userName)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(Theme.cornerRadiusMedium)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Monthly Budget Goal")
                        .font(.headline)
                        .foregroundColor(Theme.textOnDark)
                        .padding(.top, Theme.spacing8)
                    
                    TextField("2000", text: $initialBudget)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(Theme.cornerRadiusMedium)
                        .foregroundColor(Theme.textPrimary)
                }
                .padding(.horizontal, Theme.spacing32)
            }
            
            Spacer()
            
            Button(action: onComplete) {
                Text("Start Using Vaultix")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accentGreen)
                    .cornerRadius(Theme.cornerRadiusMedium)
            }
            .padding(.horizontal, Theme.spacing24)
            .padding(.bottom, Theme.spacing32)
        }
    }
}

struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: Theme.spacing8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Theme.accentGreen : Color.white.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .animation(.spring(), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
