//
//  SettingsView.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("userName") var userName: String = ""
    @AppStorage("enableNotifications") var enableNotifications: Bool = true
    @AppStorage("enableHaptics") var enableHaptics: Bool = true
    @AppStorage("darkModeEnabled") var darkModeEnabled: Bool = false
    
    @State private var showingResetAlert = false
    @State private var showingResetConfirmation = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.primaryBackground.opacity(0.3), Theme.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.spacing24) {
                    ProfileSection(userName: $userName)
                    
                    PreferencesSection(
                        enableNotifications: $enableNotifications,
                        enableHaptics: $enableHaptics
                    )
                    
                    AboutSection()
                    
                    DangerZoneSection(
                        showingResetAlert: $showingResetAlert,
                        showingResetConfirmation: $showingResetConfirmation,
                        hasCompletedOnboarding: $hasCompletedOnboarding
                    )
                }
                .padding(Theme.spacing16)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ProfileSection: View {
    @Binding var userName: String
    @State private var isEditingName = false
    @State private var tempName: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Profile")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            VStack(spacing: Theme.spacing12) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.accentGreen)
                    
                    VStack(alignment: .leading, spacing: Theme.spacing4) {
                        if isEditingName {
                            TextField("Your Name", text: $tempName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(userName.isEmpty ? "Guest User" : userName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimary)
                            Text("Vaultix Member")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if isEditingName {
                            userName = tempName
                        } else {
                            tempName = userName
                        }
                        isEditingName.toggle()
                    }) {
                        Text(isEditingName ? "Save" : "Edit")
                            .font(.subheadline)
                            .foregroundColor(Theme.accentGreen)
                    }
                }
            }
            .padding(Theme.spacing16)
            .background(Theme.cardBackground)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
    }
}

struct PreferencesSection: View {
    @Binding var enableNotifications: Bool
    @Binding var enableHaptics: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Preferences")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            VStack(spacing: Theme.spacing12) {
                SettingToggleRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Get alerts for budget limits and investment changes",
                    isOn: $enableNotifications
                )
                
                Divider()
                
                SettingToggleRow(
                    icon: "waveform",
                    title: "Haptic Feedback",
                    description: "Feel vibrations when interacting with sliders",
                    isOn: $enableHaptics
                )
            }
            .padding(Theme.spacing16)
            .background(Theme.cardBackground)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
    }
}

struct SettingToggleRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: Theme.spacing12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.accentGreen)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("About")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            VStack(spacing: Theme.spacing12) {
                SettingRow(icon: "info.circle.fill", title: "Version", value: "1.0.0")
                Divider()
                SettingRow(icon: "doc.text.fill", title: "Privacy Policy", value: "")
                Divider()
                SettingRow(icon: "shield.fill", title: "Terms of Service", value: "")
                Divider()
                SettingRow(icon: "star.fill", title: "Rate App", value: "")
            }
            .padding(Theme.spacing16)
            .background(Theme.cardBackground)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: Theme.spacing12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.accentGreen)
                .frame(width: 32)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Theme.textPrimary)
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
    }
}

struct DangerZoneSection: View {
    @Binding var showingResetAlert: Bool
    @Binding var showingResetConfirmation: Bool
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Danger Zone")
                .font(.headline)
                .foregroundColor(Theme.accentRed)
            
            VStack(spacing: Theme.spacing12) {
                Button(action: {
                    showingResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: Theme.spacing4) {
                            Text("Reset All Data")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Delete all expenses, investments, and budgets")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(Theme.spacing16)
                    .background(Theme.accentRed)
                    .cornerRadius(Theme.cornerRadiusMedium)
                }
                .alert("Reset All Data", isPresented: $showingResetAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Reset", role: .destructive) {
                        resetAllData()
                        showingResetConfirmation = true
                    }
                } message: {
                    Text("This will permanently delete all your expenses, investments, budgets, and reset the app to its initial state. This action cannot be undone.")
                }
                .alert("Data Reset Complete", isPresented: $showingResetConfirmation) {
                    Button("OK") {
                        hasCompletedOnboarding = false
                    }
                } message: {
                    Text("All your data has been reset. You'll be returned to the onboarding screen.")
                }
            }
        }
    }
    
    private func resetAllData() {
        DataService.shared.resetAllData()
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "enableNotifications")
        UserDefaults.standard.removeObject(forKey: "enableHaptics")
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
