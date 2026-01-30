//
//  ExpenseTrackerView.swift
//  ForytT-Vaultix
//
//  Created by Simon Bakhanets on 30.01.2026.
//

import SwiftUI

struct ExpenseTrackerView: View {
    @StateObject private var viewModel = ExpenseTrackerViewModel()
    @State private var showingAddExpense = false
    @State private var selectedExpense: Expense?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.primaryBackground, Theme.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Theme.spacing16) {
                ExpenseSummaryCard(viewModel: viewModel)
                    .padding(.horizontal, Theme.spacing16)
                
                ScrollView {
                    VStack(spacing: Theme.spacing12) {
                        if viewModel.expenses.isEmpty {
                            EmptyExpenseView()
                        } else {
                            ForEach(viewModel.expenses.sorted(by: { $0.date > $1.date })) { expense in
                                ExpenseRowView(expense: expense)
                                    .onTapGesture {
                                        selectedExpense = expense
                                    }
                                    .gesture(
                                        DragGesture(minimumDistance: 50)
                                            .onEnded { value in
                                                if value.translation.width < 0 {
                                                    withAnimation {
                                                        viewModel.deleteExpense(expense)
                                                    }
                                                }
                                            }
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, Theme.spacing16)
                    .padding(.bottom, 80)
                }
            }
            
            VStack {
                Spacer()
                Button(action: { showingAddExpense = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add Expense")
                            .font(.headline)
                    }
                    .foregroundColor(Theme.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.accentGreen)
                    .cornerRadius(Theme.cornerRadiusMedium)
                    .shadow(radius: 4)
                }
                .padding(.horizontal, Theme.spacing24)
                .padding(.bottom, Theme.spacing16)
            }
        }
        .navigationTitle("Expenses")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(viewModel: viewModel)
        }
        .sheet(item: $selectedExpense) { expense in
            ExpenseDetailView(expense: expense, viewModel: viewModel)
        }
    }
}

struct ExpenseSummaryCard: View {
    @ObservedObject var viewModel: ExpenseTrackerViewModel
    
    var body: some View {
        VStack(spacing: Theme.spacing12) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    Text("This Month")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                    Text("$\(viewModel.monthlyTotal, specifier: "%.2f")")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: Theme.spacing4) {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                    Text("$\(viewModel.totalExpenses, specifier: "%.2f")")
                        .font(.title3)
                        .foregroundColor(Theme.textPrimary)
                }
            }
        }
        .padding(Theme.spacing16)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadiusLarge)
        .shadow(radius: 2)
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: Theme.spacing12) {
            Image(systemName: expense.category.icon)
                .font(.title2)
                .foregroundColor(Theme.accentGreen)
                .frame(width: 44, height: 44)
                .background(Theme.accentGreen.opacity(0.1))
                .cornerRadius(Theme.cornerRadiusSmall)
            
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                Text(expense.description)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                
                HStack {
                    Text(expense.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    
                    if expense.isRecurring {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundColor(Theme.accentYellow)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Theme.spacing4) {
                Text("$\(expense.amount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(Theme.accentRed)
                
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(Theme.spacing12)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadiusMedium)
        .shadow(radius: 1)
    }
}

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ExpenseTrackerViewModel
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: Expense.ExpenseCategory = .other
    @State private var date: Date = Date()
    @State private var isRecurring: Bool = false
    @State private var useAICategory: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.secondaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            Text("Amount")
                                .font(.headline)
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            Text("Description")
                                .font(.headline)
                            TextField("e.g., Grocery shopping", text: $description)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.cornerRadiusMedium)
                                .onChange(of: description) { newValue in
                                    if useAICategory && !newValue.isEmpty {
                                        selectedCategory = viewModel.categorizeExpense(
                                            description: newValue,
                                            amount: Double(amount) ?? 0
                                        )
                                    }
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            HStack {
                                Text("Category")
                                    .font(.headline)
                                Spacer()
                                Toggle("AI", isOn: $useAICategory)
                                    .labelsHidden()
                            }
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(Expense.ExpenseCategory.allCases, id: \.self) { category in
                                    HStack {
                                        Image(systemName: category.icon)
                                        Text(category.rawValue)
                                    }
                                    .tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        
                        VStack(alignment: .leading, spacing: Theme.spacing8) {
                            Text("Date")
                                .font(.headline)
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        
                        Toggle("Recurring Expense", isOn: $isRecurring)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(Theme.cornerRadiusMedium)
                        
                        Button(action: addExpense) {
                            Text("Add Expense")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accentGreen)
                                .cornerRadius(Theme.cornerRadiusMedium)
                        }
                        .disabled(amount.isEmpty || description.isEmpty)
                    }
                    .padding(Theme.spacing24)
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let expense = Expense(
            amount: amountValue,
            category: selectedCategory,
            date: date,
            description: description,
            isRecurring: isRecurring
        )
        
        viewModel.addExpense(expense)
        dismiss()
    }
}

struct ExpenseDetailView: View {
    let expense: Expense
    @ObservedObject var viewModel: ExpenseTrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.secondaryBackground.ignoresSafeArea()
                
                VStack(spacing: Theme.spacing24) {
                    Image(systemName: expense.category.icon)
                        .font(.system(size: 60))
                        .foregroundColor(Theme.accentGreen)
                        .padding(Theme.spacing24)
                        .background(Theme.accentGreen.opacity(0.1))
                        .cornerRadius(Theme.cornerRadiusLarge)
                    
                    Text("$\(expense.amount, specifier: "%.2f")")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    VStack(spacing: Theme.spacing16) {
                        DetailRow(label: "Description", value: expense.description)
                        DetailRow(label: "Category", value: expense.category.rawValue)
                        DetailRow(label: "Date", value: expense.date.formatted(date: .long, time: .omitted))
                        if expense.isRecurring {
                            DetailRow(label: "Type", value: "Recurring")
                        }
                    }
                    .padding(Theme.spacing16)
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadiusMedium)
                    
                    Spacer()
                    
                    Button(action: deleteExpense) {
                        Text("Delete Expense")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accentRed)
                            .cornerRadius(Theme.cornerRadiusMedium)
                    }
                }
                .padding(Theme.spacing24)
            }
            .navigationTitle("Expense Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteExpense() {
        viewModel.deleteExpense(expense)
        dismiss()
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(Theme.textPrimary)
        }
    }
}

struct EmptyExpenseView: View {
    var body: some View {
        VStack(spacing: Theme.spacing16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(Theme.textSecondary.opacity(0.5))
            Text("No Expenses Yet")
                .font(.title2)
                .foregroundColor(Theme.textSecondary)
            Text("Tap the button below to add your first expense")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Theme.spacing32)
    }
}

#Preview {
    NavigationView {
        ExpenseTrackerView()
    }
}
