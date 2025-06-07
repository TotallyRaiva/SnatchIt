//
//  ContentView.swift
//  SnatchIt
//
//  Created by Reiwa on 07.06.2025.
//

import SwiftUI

struct ContentView: View {
    // Example expese
    let exampleExpense = Expense(amount: 12.50, category: "Coffee", date: Date(), comment: "Morning Latte")
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exampleExpense.category)
                .font(.headline)
            Text(exampleExpense.comment ?? "No comment")
                .font(.subheadline)
                .foregroundcolor(.gray)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
